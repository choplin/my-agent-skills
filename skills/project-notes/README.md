# project-notes

Capture and distill per-project knowledge into an Obsidian vault, keeping raw
session notes (`Inbox/`) separate from distilled long-term notes (`Notes/`),
organized per repository.

## Skills

| Skill | Description |
|-------|-------------|
| `project-notes-capture` | Quickly capture a raw project note into `Inbox/` (disposable) |
| `project-notes-distill` | Distill knowledge into a typed long-term note in `Notes/` |
| `project-notes-base` | Shared model: vault location, layout, repo-name resolution (delegated, not invoked directly) |

## Commands

| Command | Description |
|---------|-------------|
| `/project-notes-capture` | Capture a raw note |
| `/project-notes-distill` | Distill a long-term note |

## Layout

Notes live in the vault, reached from the repo through a `.agents/project-notes`
symlink (kept untracked via `.git/info/exclude`, so it is never committed but
stays visible in editor file panels):

```
<repo>/.agents/project-notes  →  <vault>/<repo-name>/
                                 ├── Inbox/   # raw notes (disposable)  → project-notes-capture
                                 └── Notes/   # distilled notes         → project-notes-distill
                                              #   Concept- / Decision- / Proposal- / Handoff-
```

The symlink is created (idempotently) on every run — see the "Resolving the
Anchor" step in `project-notes-base`.

Default vault: `~/Obsidian/Project Notes` (configurable in `project-notes-base`).
