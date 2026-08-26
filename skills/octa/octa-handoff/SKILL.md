---
name: octa-handoff
description: Records a self-complete handoff comment on an unfinished octa Issue so another session can resume the same work from its decisions, open questions, current state, and next step. Use at a session boundary while work remains In Progress.
metadata:
  description-role: documentation
---

# Hand off unfinished octa work

Apply `octa-base`. A handoff is a comment, not a completion or status change.
The Issue remains In Progress.

Do not use this flow after implementation review has started. Feedback,
corrections, approval, commit, and integration keep that Issue in the review
state unless the user explicitly sends it back to working; continue through
`octa-base`'s `references/implementation-completion.md` instead. A review or
integration wait that has not closed the Issue may release its lease for a later
explicit resume, but it is not an In Progress handoff.

Two more cases route elsewhere:

- **Finished, not paused** — the work is complete, so it takes `octa-base`'s
  completion comment at the review or Done transition, not a handoff.
- **No Issue yet** — cross-session work belongs in an Issue. Create it first,
  then hand it off. There is no local-file fallback; the Issue is the anchor.

## Flow

### 1. Identify the Issue

Resolve the current Issue in this order:

1. worktree association metadata created by `octa-start`, containing repository
   identity and `#number`;
2. the Issue explicitly selected in this session;
3. current repository Issues in In Progress for which this live session
   retains a lease ID.

If the result is not exactly one, ask the user. Never guess.

### 2. Align before writing

Summarize and confirm with the user when any point is uncertain:

- goal and why it matters;
- decisions made, rationale, and rejected alternatives;
- open questions;
- actual current state;
- first concrete next step.

Do not merely summarize the diff or test output; Git can reconstruct those.

### 3. Draft and verify

Write a proportional comment headed `## Handoff note` containing Goal,
Decisions, Open questions, Current state, and Next step. It must stand alone for
a fresh session that knows only the repository and Issue number.

Self-check that the note explains all five items without relying on this
conversation. If independent agent validation is available and safe, pass only
the drafted note to a fresh agent and ask it to reconstruct those items; revise
gaps before posting.

### 4. Post and release ownership

Post the comment without a lease because comments are unprotected:

    octa issue comment <number> --body <note>

Keep the Issue In Progress. If another session may resume it, release ownership
with the lease ID retained by this live session:

    octa issue unlock <number> --lease "$LEASE"

Keep the lease only when this same live session will continue imminently and
the user expects ownership to stay reserved. Never include the lease ID in
the handoff. If it has been lost, report that normal release is impossible;
`--force` is a separate recovery action requiring explicit confirmation that
no active session still owns the work.

Report the recorded Issue and whether its lease remains held. A later session
uses `octa-start`, which reads the newest handoff plus Git state before acting.
