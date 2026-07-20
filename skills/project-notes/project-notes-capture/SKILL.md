---
name: project-notes-capture
description: Quickly capture a raw project note into the Project Notes Obsidian vault (the disposable Inbox layer), organized per repository. Use when the user wants to jot down a fragment, pasted output, or a mid-session thought without shaping it. Triggers on "Inboxに入れて", "とりあえずメモ", "生ログを残して", "jot this down", "capture this raw", "dump this into my project notes". Should NOT trigger for shaping something worth keeping long-term (use project-notes-distill); saving transient state to resume the SAME session shortly (keep it in session); updating in-repo docs, README, docs/, or code comments; TODO lists; or committing code.
allowed-tools: Read, Write, Glob, Bash
user-invocable: true
---

# Project Notes: Capture Raw Note

Capture a raw, unshaped project note into the vault's disposable **Inbox** layer.

Read `project-notes-base` and run its "Resolving the Anchor" step first — it is
mandatory and gives you `<anchor>` (the in-repo symlink into the vault). This
skill only handles the raw-capture half.

## When to Capture vs Distill

Capture is for the flow layer: mid-session fragments, pasted output, quick
thoughts. **No shaping** — speed over polish; these are fine to delete later.

If the content is clearly worth keeping long-term (a decision + rationale, a
reusable concept, a proposal, a durable handoff), don't capture it raw — hand off
to `project-notes-distill` instead.

## Workflow

1. Resolve the anchor (see `project-notes-base`, MUST run first).
2. Get today's date from `date +%F` (do not guess it).
3. Write or append the fragment to `<anchor>/Inbox/YYYY-MM-DD <topic>.md`.
   Append to an existing same-day file rather than creating duplicates.

## Success Criteria

- [ ] Written under `<anchor>/Inbox/`, not `Notes/`.
- [ ] Filename is `YYYY-MM-DD <topic>.md` with the real date from `date +%F`.
- [ ] Same-day fragments are appended to one file, not scattered across duplicates.
