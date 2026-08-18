# Implementation review and completion procedure

Read and apply this procedure from before committing an `impl` Issue until it
reaches Done or a genuine external, permission, safety, or materially ambiguous
integration gate stops progress. Retain the Issue's live lease ID throughout;
pass it to every protected Issue mutation and Issue–PR link change.

## Pre-commit human review

1. Finish the implementation and run the relevant checks without committing.
2. Ask the user to review it with a compact, self-contained brief. It must make
   sense without the earlier conversation or requiring the user to open octa:
   - **Reference** — Issue number and title; Project or parent Issue when it
     materially explains the scope. Keep octa references in the internal
     review conversation, not in commits, branches, repository files, or forge
     PR text.
   - **Background / problem** — what user-visible or engineering problem made
     the work necessary, including the relevant prior behavior.
   - **Goal and acceptance** — the intended outcome and the Issue's checkable
     done conditions; include important constraints or exclusions when they
     shape the review.
   - **Changes** — what changed, grouped by behavior rather than file list.
   - **Verification** — checks run and their results; identify anything not run.
   - **Review focus** — the concrete points the user should inspect or decide.
     Tie each point to acceptance-critical behavior, a meaningful
     implementation choice, a deviation from the Issue, or a risk-prone area;
     name the relevant entry point when useful. Do not say only "review the
     diff."
   - **Risks / open points** — residual concerns or `None`.
   Re-read the Issue before writing the brief if its context was not retained
   through execution. Do not reduce background and goal to a generic one-line
   purpose when the Issue contains enough detail to distinguish them.
3. Move the Issue to In Review with `issue set --as "In Review"` and the lease,
   then wait for explicit approval before invoking `git-helpers-commit`. Silence is not
   approval, and requesting implementation earlier is not approval of the
   resulting change.
4. Keep the Issue in review while addressing feedback. If feedback materially
   changes the prospective commit, implement the correction, rerun relevant
   checks, and present the result again without changing status. Return it to
   working only when the user explicitly sends it back.
5. Once approved, keep the Issue in review, stage exactly the reviewed Issue
   scope, and invoke `git-helpers-commit` as a nested operation. After it
   returns, automatically continue through the established integration path,
   verify the target branch, post or finish the completion comment, close the
   Issue to Done with `issue close`, release the lease normally, and apply
   `worktree-cleanup.md`. Select the integration path from repository
   conventions and existing Git, octa PR, and forge PR artifacts; do not stop
   merely to offer it as a next action. Continue until Done or a genuine
   external, permission, safety, or materially ambiguous integration gate
   blocks progress, then return that exact outcome to the caller.
6. Stop after the commit only when the user explicitly limits the request to
   **commit only** (for example, "commit only", "do not merge", or "stop after
   committing"). A plain approval or ordinary "commit" request is not that
   limitation, even in a later user turn; it authorizes resuming this workflow
   after `git-helpers-commit`. If explicitly limited, verify the commit, keep
   the Issue in review, and report that integration and completion remain.
7. Skip the review gate only when the user explicitly asks to commit this work
   without review.

## Commit and integration evidence

1. Resolve target branch and work branch.
2. Verify all Issue-related work is committed and no related staged, unstaged,
   or untracked content remains. A failed cleanliness check leaves an approved
   Issue in review, or an explicitly unreviewed Issue in working.
3. Determine status from evidence:
   - approved work branch only, no integration PR → review;
   - review explicitly skipped and work branch not integrated → working;
   - open PR against target → review;
   - merged PR, verified cherry-pick/merge, equivalent target-tree result, or
     direct commit on target → Done;
   - intentionally unintegrated deliverable → Done only after explicit user
     acceptance recorded in the completion comment.
4. Do not infer integration from cleanliness, a pushed branch, approval, a
   closed octa PR record, or commit existence alone. Verify forge metadata or
   target branch history/tree.
5. Record target branch and evidence in the Issue completion comment. Keep octa
   numbers out of Git artifacts.

## Stops before Done and lease release

When the procedure stops before Done because of an explicit commit-only limit
or a genuine gate, keep the lifecycle state required above. Keep the lease only
while this same live session will continue imminently. Otherwise release it
normally so a later session can explicitly resume the review or integration
work with a fresh lease. Never put the lease ID in the completion comment,
handoff note, worktree note, repository file, commit, or user-facing report.
