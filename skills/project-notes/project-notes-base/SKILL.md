---
name: project-notes-base
description: >-
  Shared model for the project-notes skill family — the Project Notes vault rule
  (raw thinking is disposable, only distilled notes become long-term memory), the
  vault location convention, the per-repository / Inbox-vs-Notes layout, and the
  MUST-run procedure that resolves the in-repo notes anchor (a
  `.git/project-notes` symlink into the vault). project-notes-capture and
  project-notes-distill delegate here to resolve the anchor before reading or
  writing. Use this skill when another project-notes skill asks to resolve the
  anchor or apply the vault layout. Not typically invoked on its own.
---

# Project Notes — Shared Model

The Project Notes vault follows one rule:
**raw thinking is disposable, only distilled notes become long-term memory.**

Knowledge from working sessions (why a decision was made, a reusable concept, a
handoff) is lost when the session ends, and dumping everything into one folder
buries the durable insights under disposable scratch. So the vault splits on two
axes — **per repository**, then **raw (Inbox) vs distilled (Notes)** — keeping it
navigable and the long-term layer high-signal.

## Vault Location

- Default: `~/Obsidian/Project Notes`
- If that folder does not exist, ask the user for the vault path before writing.
- To use a different vault, the user edits this path.

## The In-repo Notes Anchor

Notes live in the vault, but the skills always operate through an in-repo
symlink so the repo can reference its own notes with a stable path:

```
<repo>/.git/project-notes   →   <vault>/<repo-name>/
                                 ├── Inbox/   ← raw (disposable)   → project-notes-capture
                                 └── Notes/   ← distilled (keep)    → project-notes-distill
```

The link lives **inside `.git/`**, which git never tracks — so it is never
committed, never leaks the vault path to collaborators, and needs no `.gitignore`
or `.git/info/exclude` entry.

## Resolving the Anchor (MUST run before any read/write)

Every project-notes skill runs this first. It is idempotent.

```sh
# Vault (see "Vault Location"; ask the user if it does not exist)
vault="$HOME/Obsidian/Project Notes"

# repo-name: stable across worktrees (derived from the shared git dir, not the
# worktree path)
repo_name=$(basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")")

# Anchor location inside THIS checkout's git dir (worktree-correct)
anchor=$(git rev-parse --git-path project-notes)

# Ensure the repo's vault folder exists, then the symlink (never clobber)
mkdir -p "$vault/$repo_name"
[ -e "$anchor" ] || ln -s "$vault/$repo_name" "$anchor"
```

- If not in a git repo, there is no `.git/` to anchor into — fall back to writing
  directly under `<vault>/<repo-name>/` and tell the user the in-repo link was
  skipped (resolve `<repo-name>` from the current directory name, or ask).
- After this step, **all note paths are under the anchor**: raw notes go to
  `<anchor>/Inbox/`, distilled notes to `<anchor>/Notes/`. The `Inbox/`/`Notes/`
  subfolders are created on first write (the Write tool creates parents).
