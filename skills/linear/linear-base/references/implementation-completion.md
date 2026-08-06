# Implementation review and completion evidence

Read this before committing work for an `impl` Issue or moving it among In
Progress, In Review, and Done.

## Pre-commit human review

1. Finish the implementation and run the relevant checks without committing.
2. Ask the user to review it with a compact summary:
   - **Purpose** — what outcome the Issue needs and why.
   - **Changes** — what was changed, grouped by behavior rather than file list.
   - **Verification** — checks run and their results; identify anything not run.
   - **Review focus** — the concrete points the user should inspect or decide.
     Tie each point to acceptance-critical behavior, a meaningful implementation
     choice, a deviation from the Issue, or a risk-prone area; name the relevant
     entry point when useful. Do not say only "review the diff."
   - **Risks / open points** — residual concerns or `None`.
3. Move the Issue to In Review and wait for explicit approval before invoking
   `git-helpers-commit`. Silence is not approval, and requesting implementation
   earlier is not approval of the resulting change.
4. Review feedback returns the Issue to In Progress. If it materially changes
   the prospective commit, implement the correction, rerun relevant checks,
   present the result again, and return the Issue to In Review.
5. Once approved, return the Issue to In Progress while performing the
   agent-owned commit and integration work. A PR opened during that work moves
   it back to In Review; verified integration permits Done.
6. Skip this gate only when the user explicitly asks to commit this Linear work
   without review.

## Commit and integration evidence

1. Resolve both the intended target branch and the branch containing the Issue's
   commits.
2. Verify that every Issue-related change is committed and no staged, unstaged,
   or untracked Issue-related change remains. The completion note cites those
   commits. A failed cleanliness check leaves the Issue In Progress.
3. Determine status from observable integration evidence:
   - Work branch, no PR, not integrated → In Progress.
   - PR open against the target branch → In Review.
   - PR merged → Done.
   - Cherry-pick or another explicit integration visible in the target branch's
     history or resulting tree → Done.
   - Commits made directly on the target branch → Done without a PR.
4. Do not infer integration from a clean worktree, pushed branch, review
   approval, or commit existence alone. Use forge metadata and/or target-branch
   history or tree state.
5. If the deliverable is intentionally complete without integration, obtain the
   user's explicit decision before Done and record the exception in the
   completion note.
