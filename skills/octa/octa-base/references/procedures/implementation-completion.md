# Implementation review and completion procedure

Read and apply this procedure from before committing an `impl` Issue until it
reaches Done or a genuine external, permission, safety, or materially ambiguous
integration gate stops progress. Retain the Issue's live lease ID throughout;
pass it to every protected Issue mutation.

## Pre-commit human review

1. Finish the implementation and run the relevant checks without committing.
2. Present a concise, self-contained review brief that lets the user decide
   whether the implementation satisfies the Issue and is safe to approve,
   without reopening the Issue or reconstructing the change from the diff.

   Include the context and evidence that decision depends on:

   - the Issue number and title as the review's starting point, plus its Project
     or parent Issue when that context materially explains the scope;
   - the original problem and intended behavior;
   - the material change units, connecting what changed, why it was needed, and
     how the implementation produces the intended behavior;
   - the evidence for acceptance-critical behavior; and
   - when material to the decision, consequential design choices, scope
     boundaries, deviations, uncertainty, unverified critical behavior, and
     residual risks.

   These are content requirements, not required headings or a fixed order.
   Adapt the presentation to the change: a small change may need only a few
   sentences, while a larger change may use short sections or grouped bullets.
   Explain larger work in coherent change units that connect behavior,
   rationale, and implementation rather than collapsing it into one summary.

   Do not satisfy the brief with an inventory of files, symbols, checks, or
   lifecycle events. Use code locations and verification details only where
   they help explain behavior, evidence, or risk. Omit routine passing checks,
   pass counts, workspace metadata, and other execution detail that does not
   affect the decision. Re-read the Issue when necessary to recover its problem,
   intended behavior, or acceptance context.

   At this gate, ask only whether the implementation is approved. Approval
   authorizes the established commit and integration workflow unless the user
   explicitly limits it.
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
   conventions and existing Git and forge PR artifacts; do not stop
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
4. Do not infer integration from cleanliness, a pushed branch, approval, or
   commit existence alone. Verify forge metadata or target branch history/tree.
5. Record target branch and evidence in the Issue completion comment. Keep octa
   numbers out of Git artifacts.

## Stops before Done and lease release

When the procedure stops before Done because of an explicit commit-only limit
or a genuine gate, keep the lifecycle state required above. Keep the lease only
while this same live session will continue imminently. Otherwise release it
normally so a later session can explicitly resume the review or integration
work with a fresh lease. Never put the lease ID in the completion comment,
handoff note, worktree association metadata, repository file, commit, or
user-facing report.
