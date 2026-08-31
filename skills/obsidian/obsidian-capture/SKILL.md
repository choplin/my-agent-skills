---
name: obsidian-capture
description: >-
  Capture a web article, X post, or YouTube video into the personal Obsidian
  vault. Use when given a URL to file away: fetches the page (or the video's
  transcript), writes a Japanese summary note to 03_References/, and links it
  from today's Daily Note "## Captures" section. Invoke explicitly as
  `/obsidian-capture <url>`.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
  - WebFetch
  - mcp__claude-in-chrome__list_connected_browsers
  - mcp__claude-in-chrome__tabs_context_mcp
  - mcp__claude-in-chrome__navigate
  - mcp__claude-in-chrome__get_page_text
  - mcp__claude-in-chrome__tabs_close_mcp
metadata:
  description-role: trigger
---

# Obsidian Capture

Capture a web article, X post, or YouTube video into `~/Obsidian/My Vault` as a
Japanese summary note in `03_References/`, then link it from today's Daily Note.

The URL is passed as the invocation argument (`/obsidian-capture <url>`). If no
URL is given, ask for one — do not guess.

## Why this skill works the way it does

This vault follows a Zettelkasten workflow defined in `~/Obsidian/My Vault/CLAUDE.md`.
The note lifecycle is **Capture → Process → Use**. This skill is *only* the
Capture step. Two rules follow directly from that, and you must not "improve"
on them:

- **No topical tags at capture time.** The vault rule is: "Tags are added during
  processing (not capture) to reduce friction." So the only tag is `resource/web`
  (or `resource/video` for a YouTube video — the resource-type tag). Do NOT
  infer `area/*` or `project/*` tags, even if the topic is obvious — that is the
  user's job during Process.
- **A Japanese summary, not the full article.** The point of capture is a quick,
  reviewable gist for later processing. Save a structured Japanese summary and
  mark it `ai-summary: "true"`, matching existing notes like
  `03_References/2025-03-24 FDAP Stack explained.md`. Do NOT paste the full
  English/source text.

## Vault facts (fixed — this is a personal skill)

- Vault root: `~/Obsidian/My Vault`
- Article destination: `03_References/`
- Reference filename convention: `YYYY-MM-DD <Title>.md` (date = today)
- Daily Note: `10_Daily Notes/YYYY-MM-DD.md`, with a `## Captures` section
- Get today's date and timestamp at runtime:
  - `date +%Y-%m-%d` → e.g. `2026-06-24` (used for filename and `created`)

## Procedure

### 1. Check whether the URL was already captured

Before fetching anything, search existing reference notes for the given URL as
their `web-source`. This catches the common case where the user forgot that a URL
was already captured on an earlier day.

Use `rg` against `03_References/`:

```bash
rg -n --fixed-strings "web-source: <url>" 03_References
```

Also check the trailing-slash variant for non-X URLs, because some pages may have
been captured with or without a final `/`:

```bash
rg -n --fixed-strings "web-source: <url-without-trailing-slash>" 03_References
rg -n --fixed-strings "web-source: <url-with-trailing-slash>" 03_References
```

For X status URLs, also search the status ID inside `web-source` lines, so the
same post is detected even if the URL has minor formatting differences:

```bash
rg -n "web-source: .*status/<status-id>" 03_References
```

For YouTube URLs, search the 11-character video ID instead of the whole URL —
the same video is handed over as `youtu.be/<id>`, `watch?v=<id>`, `shorts/<id>`,
or with a `&t=` timestamp appended, so a literal URL match misses duplicates:

```bash
rg -n --fixed-strings "<video-id>" 03_References
```

If any match is found, stop immediately. Report the existing note path and do not
fetch the page, create a new note, or add another Daily Note capture link.

### 2. Fetch the article

**X URLs** (host `x.com`) — WebFetch cannot read these (JS-only, bot-blocked).
Do NOT use WebFetch for them. Instead run the bundled helper, which pulls the
post from X's public syndication endpoint (no auth) via curl:

```bash
python3 "$HOME/Obsidian/My Vault/.agents/skills/obsidian-capture/scripts/fetch_x.py" "<url>"
```

It prints the author, post date, full text (including long-form posts and any
quoted post), and referenced links. Use that output as the source for the
summary; the given URL stays the `web-source`, the author becomes `web-author`,
and the post date becomes `web-published`.

An X post has no title. Derive a short Japanese title from the post's gist for
the filename and `web-title` (e.g. `<author>の投稿: <topic>`), and keep the
usual hashtag-stripping rule below.

**When the syndication helper is not enough → use Claude in Chrome.** Two cases:
(a) the script exits non-zero because the URL is not a status URL — an **X Article**
(`x.com/i/article/...` or `x.com/<user>/article/...`) or a profile page; or
(b) the script succeeds but the post body is essentially empty and its `Links:`
point at an `x.com/.../article/...` URL — i.e. the post is just a pointer to an X
Article. In both cases the real content sits behind X's login and can only be read
in a logged-in browser. Do NOT try to log in from an automated browser (Google/X
bot-detection blocks it, and bypassing bot-detection is out of scope). Instead use
the **Claude in Chrome** extension, which attaches to the user's own already-logged-in
Chrome (no new login, nothing to bypass):

1. `mcp__claude-in-chrome__list_connected_browsers` — if it returns `[]`, the
   extension is not connected. Stop and ask the user to open Chrome (logged into X)
   with the Claude for Chrome extension signed in, then retry.
2. `mcp__claude-in-chrome__tabs_context_mcp` with `createIfEmpty: true` to get a tab.
3. `mcp__claude-in-chrome__navigate` to the **article URL** (for case (b), the
   `x.com/.../article/...` link from the post's `Links:`, not the status URL).
4. `mcp__claude-in-chrome__get_page_text` to read the article body. If the URL
   redirected to `/i/flow/login` or `/i/jf/onboarding`, the Chrome session is not
   logged into X — stop and tell the user.
5. `mcp__claude-in-chrome__tabs_close_mcp` on the tab when done.

Use the article's own heading as the title; keep the given post URL as `web-source`
(so the Captures link points back to the post the user handed you).

**YouTube URLs** (host `youtube.com`, `youtu.be`, including `/shorts/` and
`/live/`) — WebFetch only sees the JS shell, so at best it returns the
description, never the video's content. Run the bundled helper instead, which
uses `yt-dlp` to read the metadata and the caption track without downloading the
video:

```bash
python3 "$HOME/Obsidian/My Vault/.agents/skills/obsidian-capture/scripts/fetch_youtube.py" "<url>"
```

It prints the title, channel, publish date, duration, description, and the
transcript as paragraphs prefixed with `[mm:ss]` markers. Use captions in the
video's original language: the helper detects that language from the video
metadata, prefers uploader-provided captions, and otherwise uses the original
auto-generated track. Do not pass `--langs` unless the user explicitly asks to
override the video's original language. The `Captions:` line says which track
was used and whether it is official or auto-generated — auto-generated tracks
carry recognition errors, so treat proper nouns and figures in them with
suspicion rather than asserting them in the summary.

Base the summary on the transcript, not the description. Use the video's own
title as the title, the channel as `web-author`, and the publish date as
`web-published`. If the helper exits non-zero because the video has no captions
at all, report that and stop — do not summarize from the description alone, and
do not download the audio to transcribe it.

**All other URLs** — use `WebFetch`. Extract: title, source URL (the given URL),
author/publication name, published date (if present in the page), and a
one-sentence description. If the fetch fails (paywall, JS-only, 4xx/5xx),
stop and report the failure — do not fabricate content.

### 3. Write the summary note

Compute `TODAY=$(date +%Y-%m-%d)` and `NOW=$(date +%Y-%m-%dT%H:%M)`.

First, **strip hashtags from the title**. Many articles end their title with
social tags like `#dbtCoalesce #Coalesce23`. A `#` inside an Obsidian wikilink is
parsed as a heading reference, so a title containing `#` produces a Captures link
that never resolves. Remove every `#tag` token (the `#` and the word that follows
it, e.g. `#dbtCoalesce`) and trim any resulting trailing/double spaces. Use this
cleaned title everywhere: the filename, the `web-title` frontmatter value, and the
Daily Note link target + alias.

Then **sanitize the title for the filesystem**. This vault is synced through Git
to a Windows machine, and Windows rejects paths containing `\ / : * ? " < > |`
— a note whose filename contains any of them makes `git pull` fail there with
`error: invalid path ...`. So the title must be cleaned before it becomes a
filename:

| Character | Replacement |
| --- | --- |
| `"` | `'` (single quote — valid on Windows; `'` itself is *not* a forbidden character) |
| `/` `\` `:` | `-` |
| `*` `?` | `＊` `？` (full-width) |
| `<` `>` `\|` | `＜` `＞` `｜` (full-width) |

Also trim leading/trailing spaces and any trailing `.` from the title (Windows
drops them silently). Keep every other character as-is — full-width punctuation
like `？` `…` `【】` `—` is valid on Windows and matches existing filenames.

Use this sanitized title for the **filename**, the **Daily Note wikilink target**,
and the **link alias**, so all three stay identical. Leave `web-title` as the
article's real title (it is source metadata, not a path).

Then build the filename: `03_References/<TODAY> <sanitized Title>.md`.
If a file with that exact name already exists, stop and report it (do not
overwrite).

Write the file with this exact frontmatter schema (matching existing References
notes), then the summary body:

```markdown
---
web-title: <article title>
web-source: <the URL>
web-author: "[[<author or publication name>]]"
web-published: <published date if known, else leave empty>
web-description: <one-sentence description>
created: <TODAY>
tags:
  - resource/web
ai-summary: "true"
---
<structured Japanese summary: markdown headings + bullet points capturing the
article's main points and conclusions, faithful to the source>
```

For a YouTube video, head each section of the body with the timestamp it starts
at, so the note leads back into the video:

```markdown
## 00:00 導入 — 扱う問題
- ...
## 04:12 手法の説明
- ...
```


Rules for the frontmatter:
- `created` is date-only (`<TODAY>`).
- `web-author` is a wikilink: `"[[Name]]"`. If unknown, leave the value empty.
- `tags` contains exactly one resource-type tag and nothing else:
  `resource/video` for a YouTube video, `resource/web` otherwise.

### 4. Link from today's Daily Note

Daily note path: `10_Daily Notes/<TODAY>.md`.

**If it exists:** read it, find the `## Captures` line, and append a bullet
immediately under it (before `## Tasks`):

```
- [[03_References/<TODAY> <Title>|<Title>]]
```

Use the sanitized filename (without `.md`) as the link target and the title as
the alias. If a `## Captures` section is somehow missing, add it after the
frontmatter/navigation line.

**If today's daily note does not exist:** create it, replicating what the
`Templates/Daily Note.md` template would produce (Templater syntax does not run
when written from outside Obsidian, so fill the values yourself):

```markdown
---
day: <full weekday name, e.g. Wednesday>
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

### 5. Report

Tell the user the saved file path and confirm the Captures link was added.

## Success criteria (verify each before reporting done)

- [ ] Before fetching, `03_References/` was searched for an existing
      `web-source` matching the given URL (including trailing-slash variants for
      non-X URLs, status-ID matches for X URLs, and video-ID matches for YouTube
      URLs), and the run stopped without changes if a match existed.
- [ ] A file exists at `03_References/<TODAY> <Title>.md` (today's date prefix).
- [ ] Frontmatter contains all of: `web-title`, `web-source` (= the given URL),
      `web-author`, `web-published`, `web-description`, `created` (= `<TODAY>`,
      date-only), `tags` (exactly `resource/video` for a YouTube video and
      `resource/web` otherwise), `ai-summary: "true"`.
- [ ] The body is a Japanese summary (not the full source text, not English prose).
- [ ] For a YouTube video, the summary came from the transcript (not the
      description alone) and its sections carry timestamps.
- [ ] `10_Daily Notes/<TODAY>.md` exists and contains exactly one new bullet
      under `## Captures` linking to the created note.
- [ ] The Captures wikilink target matches the created file's basename (so it
      resolves in Obsidian).
- [ ] No `#` remains in the title (filename, `web-title`, or the Daily Note link),
      so the wikilink is not misread as a heading reference.
- [ ] The filename contains none of `\ / : * ? " < > |` and has no trailing space
      or `.`, so the vault still clones/pulls on Windows.
- [ ] No `area/*` or `project/*` tag was added to the reference note.

## Edge cases

- **No URL argument:** ask the user for the URL; do not proceed.
- **Already captured URL:** report the matching existing note and stop; do not
  fetch, create a duplicate note, or add a duplicate Daily Note link.
- **Fetch failed / paywalled:** report and stop; create nothing.
- **X post:** fetch with `scripts/fetch_x.py` (not WebFetch); derive a
  title since posts have none.
- **YouTube video:** fetch with `scripts/fetch_youtube.py` (not WebFetch);
  tag `resource/video`.
- **YouTube video with no captions:** the helper exits non-zero — report and
  stop; do not use translated captions or summarize from the description.
- **Non-video YouTube URL** (channel, playlist, search results): the helper
  rejects it as "not a YouTube video URL". Ask the user for a video URL; do not
  fall back to WebFetch.
- **X Article** (`x.com/.../article/...`, or a post that only links to one): the
  syndication helper can't read it — read it with Claude in Chrome (step 1). If the
  Chrome extension is not connected or not logged into X, report and stop.
- **Duplicate filename:** report the existing file; do not overwrite.
- **Multiple URLs given:** process each as a separate note, each linked under
  Captures.
