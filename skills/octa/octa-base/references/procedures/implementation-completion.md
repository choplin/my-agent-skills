# Implementation review and completion procedure

Read and apply this procedure from before committing an `impl` Issue until it
reaches Done or a genuine external, permission, safety, or materially ambiguous
integration gate stops progress. Retain the Issue's live lease ID throughout;
pass it to every protected Issue mutation.

## Pre-commit human review

1. Finish the implementation and run the relevant checks without committing.
2. Before asking for approval, orient the user with enough relevant context to
   review the implementation effectively. The account should be concise and
   self-contained: bring forward the problem, intended behavior, and material
   context needed to judge the result instead of making the user reconstruct
   them from the Issue or discover the review questions from the diff. Choose
   the structure and level of detail that best fit the change.

   Explain the work in coherent change units rather than collapsing it into one
   summary. Help the user understand what changed, why it was needed, how the
   implementation realizes it, and what deserves scrutiny. Ground each
   explanation in the corresponding change by weaving in whichever location is
   most useful in context — for example a file and line, class, function, or
   variable — without turning those references into an inventory.

   Exercise judgment about supporting detail. Surface design decisions,
   constraints, deviations, uncertainty, unverified critical behavior, and
   risks when they affect review. Omit routine passing checks, pass counts,
   workspace metadata, path or symbol dumps, lifecycle narration, and other
   execution detail that does not help the user judge the change. Translate
   implementation terminology into the behavior or risk it represents, and
   end with the specific approval or decision needed from the user.
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
