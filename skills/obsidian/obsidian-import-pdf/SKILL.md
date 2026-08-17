---
name: obsidian-import-pdf
description: >-
  Import a PDF (local file path or http(s) URL) into the personal Obsidian
  vault. Use when given a PDF to file away: saves the original to attachments/,
  writes a Japanese summary note to 03_References/, links the original PDF from
  that note, and links the note from today's Daily Note "## Captures" section.
  Invoke explicitly as `/obsidian-import-pdf <path-or-url>`.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
metadata:
  description-role: trigger
---

# Obsidian Import PDF

Import a PDF into `~/Obsidian/My Vault`: keep the **original PDF** in
`attachments/`, write a **Japanese summary note** in `03_References/` that links
to the original, then link the note from today's Daily Note.

The argument is a **local PDF path or an http(s) URL** (`/obsidian-import-pdf
<path-or-url>`). If no argument is given, ask for one — do not guess.

This is the PDF sibling of the `obsidian-capture` skill (which handles web
articles). It follows the same Capture-step philosophy; the only differences are
the source (a PDF), the extra step of preserving the original file, and the
`pdf-*` frontmatter / `resource/pdf` tag.

## Why this skill works the way it does

This vault follows a Zettelkasten workflow defined in `~/Obsidian/My Vault/CLAUDE.md`.
The note lifecycle is **Capture → Process → Use**. This skill is *only* the
Capture step. Three rules follow directly, and you must not "improve" on them:

- **No topical tags at capture time.** The vault rule is: "Tags are added during
  processing (not capture) to reduce friction." So the only tag is `resource/pdf`
  (the resource-type tag). Do NOT infer `area/*` or `project/*` tags, even if the
  topic is obvious — that is the user's job during Process.
- **A Japanese summary, not the full text.** The point of capture is a quick,
  reviewable gist for later processing. Save a structured Japanese summary and
  mark it `ai-summary: "true"`, matching existing notes like
  `03_References/2025-03-24 FDAP Stack explained.md`. Do NOT paste the full
  extracted PDF text — the original PDF is preserved for full fidelity.
- **Keep the original retrievable.** The original PDF is the source of truth and
  must be reachable from the summary note (frontmatter `pdf-file` + a body link),
  so nothing is lost to summarization.

## Vault facts (fixed — this is a personal skill)

- Vault root: `~/Obsidian/My Vault`
- Original PDF destination: `attachments/` (the vault's configured attachment folder)
- Summary note destination: `03_References/`
- Filename convention (both files share a basename): `YYYY-MM-DD <Title>` (date = today)
  - Original PDF: `attachments/<TODAY> <Title>.pdf`
  - Summary note: `03_References/<TODAY> <Title>.md`
- Daily Note: `10_Daily Notes/YYYY-MM-DD.md`, with a `## Captures` section
- Get today's date and timestamp at runtime:
  - `date +%Y-%m-%d` → e.g. `2026-06-29` (used for filenames and `created`)

## Procedure

### 1. Obtain the PDF locally

Determine whether the argument is a URL or a local path:

- **http(s) URL:** download it to a scratch path first (not directly into the
  vault, so a failed/partial download never lands in `attachments/`):
  ```bash
  curl -fL --retry 2 -o "$TMPDIR/import.pdf" "<url>"
  ```
  If `curl` fails (4xx/5xx, network error), stop and report — do not fabricate.

  **Google Drive URLs need conversion first.** A `…/file/d/<ID>/view` or
  `…/open?id=<ID>` link is an HTML viewer page, not the PDF — downloading it
  yields HTML and fails the PDF check below. Extract the file `<ID>` and download
  the direct form instead:
  ```bash
  curl -fL --retry 2 -o "$TMPDIR/import.pdf" \
    "https://drive.google.com/uc?export=download&id=<ID>"
  ```
  This works for small/medium files. For large files Drive interposes a
  virus-scan confirmation page (the download returns HTML containing a
  `confirm=<token>`); if the downloaded file is HTML, re-request with
  `&confirm=t` (or the parsed token) appended. If it still returns HTML, the file
  likely requires sign-in — stop and tell the user it is not publicly
  downloadable.
- **Local path:** use it directly as the source. If the file does not exist,
  stop and report.

Verify the file is actually a PDF before continuing:
```bash
file "<source>"   # expect "PDF document"
```
If it is not a PDF (e.g. an HTML error page returned for the URL), stop and
report — suggest `/obsidian-capture <url>` for web articles.

### 2. Extract text and metadata

The PDF tools (`poppler-utils` → `pdftotext`/`pdfinfo`/`pdfimages`/`pdftoppm`,
and `tesseract` with `eng`+`jpn`+`jpn_vert`) live in **this vault's Nix
devshell** (`flake.nix` + `devshell.toml`), not on the global PATH. The skill's
Bash runs a fresh non-interactive shell per command and does NOT auto-load the
devshell (there is no direnv hook in the profile), so **every tool invocation
must be wrapped** to enter the devshell. Use one of:

```bash
VAULT=~/Obsidian/My\ Vault
# Preferred (fast after first load; .envrc has `use flake`, already `direnv allow`ed):
direnv exec "$VAULT" pdfinfo "<source>"
# Self-contained fallback (no direnv state needed, re-evaluates each call):
nix develop "$VAULT" --command pdfinfo "<source>"
```

Use the **`anthropic-skills:pdf`** skill's techniques, run through that wrapper.

Primary path — the poppler CLI:
```bash
direnv exec "$VAULT" pdfinfo "<source>"             # metadata: pages, title, author
direnv exec "$VAULT" pdftotext -layout "<source>" - # text to stdout for summarizing
```
If `pdfinfo`'s `Title` is empty/meaningless, fall back to the first page's
prominent heading from the extracted text (see the title priority below).

**Scanned PDF (text extraction yields little/no text):** OCR with the CLI — no
Python needed. Render pages to images with `pdftoppm`, then OCR each with
`tesseract -l jpn+eng`:
```bash
cd "$TMPDIR"
# pdftoppm zero-pads the page number to the width of the last page,
# e.g. an 11-page PDF produces page-01.png … page-11.png (NOT page-1.png).
direnv exec "$VAULT" pdftoppm -r 300 -png "<source>" page
for img in page-*.png; do
  direnv exec "$VAULT" tesseract "$img" stdout -l jpn+eng   # text to stdout
done > ocr.txt
```
tesseract writes a temp file, so run it from a writable dir (`$TMPDIR`); a
`fopenReadStream`/`PPM` error means the working dir is not writable.

Determine the **title** in this priority order:
1. PDF metadata title (`pdfinfo` → `Title:`), if meaningful.
2. The most prominent heading on the first page.
3. The source filename / URL basename (without `.pdf`), as a last resort.

### 3. Save the original PDF into the vault

Compute `TODAY=$(date +%Y-%m-%d)`.

Build the basename: `<TODAY> <Title>`. **Sanitize the title for the filesystem.**
This vault is synced through Git to a Windows machine, and Windows rejects paths
containing `\ / : * ? " < > |` — such a filename makes `git pull` fail there with
`error: invalid path ...`:

| Character | Replacement |
| --- | --- |
| `"` | `'` (single quote — valid on Windows; `'` itself is *not* a forbidden character) |
| `/` `\` `:` | `-` |
| `*` `?` | `＊` `？` (full-width) |
| `<` `>` `\|` | `＜` `＞` `｜` (full-width) |

Also trim leading/trailing spaces and any trailing `.`. Keep every other
character as-is (full-width punctuation like `？` `…` `【】` `—` is fine — it
matches existing filenames). Use the same sanitized basename for the PDF, the
note, and the wikilink target.

Copy the original into `attachments/<TODAY> <Title>.pdf`:
```bash
cp "<source>" "attachments/<TODAY> <Title>.pdf"
```
If a file with that exact name already exists, stop and report it (do not
overwrite). For a URL source, you may then remove the scratch copy.

### 4. Write the summary note

Compute `NOW=$(date +%Y-%m-%dT%H:%M)`.

Write `03_References/<TODAY> <Title>.md` with this exact frontmatter schema
(mirroring the `web-*` schema of `obsidian-capture`, adapted for PDF), then the
summary body:

```markdown
---
pdf-title: <document title>
pdf-source: <the original URL, or the original local path>
pdf-file: attachments/<TODAY> <Title>.pdf
pdf-author: "[[<author or publication name>]]"
pdf-published: <published date if known, else leave empty>
pdf-pages: <page count if known, else leave empty>
pdf-description: <one-sentence description>
created: <TODAY>
tags:
  - resource/pdf
ai-summary: "true"
---
<structured Japanese summary: markdown headings + bullet points capturing the
document's main points and conclusions, faithful to the source>

---
- 📄 オリジナル: [[attachments/<TODAY> <Title>.pdf|<Title>]]
```

Rules for the frontmatter:
- `created` is date-only (`<TODAY>`).
- `pdf-file` is the vault-relative path to the saved original (used to retrieve it).
- `pdf-source` records where it came from (URL or original local path).
- `pdf-author` is a wikilink: `"[[Name]]"`. If unknown, leave the value empty.
- `tags` contains exactly `resource/pdf` and nothing else.

The trailing body link is the human-clickable path back to the original PDF.

### 5. Link from today's Daily Note

Daily note path: `10_Daily Notes/<TODAY>.md`.

**If it exists:** read it, find the `## Captures` line, and append a bullet
immediately under it (before `## Tasks`):

```
- [[03_References/<TODAY> <Title>|<Title>]]
```

Use the sanitized note filename (without `.md`) as the link target and the title
as the alias. If a `## Captures` section is somehow missing, add it after the
frontmatter/navigation line.

**If today's daily note does not exist:** create it, replicating what the
`Templates/Daily Note.md` template would produce (Templater syntax does not run
when written from outside Obsidian, so fill the values yourself):

```markdown
---
day: <full weekday name, e.g. Monday>
lunch:
dinner:
tags:
  - diary/daily/<YYYY-MM>
---
:LiCalendar: [[10_Daily Notes/<yesterday YYYY-MM-DD>|prev]] ‹ [[11_Monthly Notes/<YYYY-MM>|<YYYY-MM>]] › [[10_Daily Notes/<tomorrow YYYY-MM-DD>|next]]
## Captures
- [[03_References/<TODAY> <Title>|<Title>]]
## Tasks
## Journal
```

Derive weekday with `date +%A`, yesterday with `date -v-1d +%Y-%m-%d`, tomorrow
with `date -v+1d +%Y-%m-%d` (macOS `date`).

### 6. Report

Tell the user: the saved original PDF path, the summary note path, and confirm
the Captures link was added.

## Success criteria (verify each before reporting done)

- [ ] The original PDF exists at `attachments/<TODAY> <Title>.pdf`.
- [ ] A summary note exists at `03_References/<TODAY> <Title>.md` (today's date prefix).
- [ ] Frontmatter contains all of: `pdf-title`, `pdf-source`, `pdf-file`
      (= the saved PDF path), `pdf-author`, `pdf-published`, `pdf-pages`,
      `pdf-description`, `created` (= `<TODAY>`, date-only), `tags` (exactly
      `resource/pdf`), `ai-summary: "true"`.
- [ ] `pdf-file` and the body link both resolve to the saved original PDF.
- [ ] The body is a Japanese summary (not the full extracted text, not raw English prose).
- [ ] `10_Daily Notes/<TODAY>.md` exists and contains exactly one new bullet
      under `## Captures` linking to the created note.
- [ ] The Captures wikilink target matches the note's basename (so it resolves in Obsidian).
- [ ] No `area/*` or `project/*` tag was added to the reference note.

## Edge cases

- **No argument:** ask the user for the PDF path or URL; do not proceed.
- **URL returns non-PDF (HTML/paywall):** report and stop; suggest
  `/obsidian-capture <url>` for web articles. Create nothing.
- **Download/curl failed:** report and stop; create nothing.
- **Local file missing:** report and stop.
- **Scanned PDF (no extractable text):** OCR via the `anthropic-skills:pdf`
  approach before summarizing; if OCR is unavailable, still save the original and
  note in the summary that text could not be extracted.
- **Duplicate filename:** report the existing file; do not overwrite (neither the
  PDF nor the note).
- **Multiple arguments given:** process each as a separate import, each linked
  under Captures.
