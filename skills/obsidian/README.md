# obsidian

## Skills

| Skill | Description |
|-------|-------------|
| `obsidian-capture` | Capture a web article into the personal Obsidian vault: fetch the page, write a Japanese summary note to `03_References/`, and link it from today's Daily Note |
| `obsidian-import-pdf` | Import a PDF (local path or URL) into the vault: keep the original in `attachments/`, write a Japanese summary note that links to it, and link the note from today's Daily Note |

Both skills implement only the **Capture** step of the vault's Zettelkasten
lifecycle (Capture → Process → Use). They deliberately stop short of topical
tagging and interpretation, which belong to processing.

## Prerequisites

These skills are personal to a single vault: they assume the vault layout and
conventions documented in that vault's own `CLAUDE.md` (`03_References/`,
`attachments/`, `10_Daily Notes/`, a `## Captures` section). They are meant to
be installed into that vault, not globally.

`obsidian-capture` reads pages through WebFetch, falling back to the browser
tools and, for X/Twitter, to the bundled `scripts/fetch_x.py`.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
