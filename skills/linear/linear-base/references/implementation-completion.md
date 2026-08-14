# Implementation review and completion evidence

Read this before committing work for an `impl` Issue or moving it among In
Progress, In Review, and Done.

## Pre-commit human review

1. Finish the implementation and run the relevant checks without committing.
2. Ask the user to review it with a compact, self-contained brief. It must make
   sense without the earlier conversation or requiring the user to open Linear:
   - **Reference** — Issue identifier, title, and URL; Project or parent Issue
     when it materially explains the scope. Keep these Linear references in the
     internal review conversation, not in commits, branches, files, or PR text.
   - **Background / problem** — what user-visible or engineering problem made
     the work necessary, including the relevant prior behavior.
   - **Goal and acceptance** — the intended outcome and the Issue's checkable
     done conditions; include important constraints or exclusions when they
     shape the review.
   - **Changes** — what was changed, grouped by behavior rather than file list.
   - **Verification** — checks run and their results; identify anything not run.
   - **Review focus** — the concrete points the user should inspect or decide.
     Tie each point to acceptance-critical behavior, a meaningful implementation
     choice, a deviation from the Issue, or a risk-prone area; name the relevant
     entry point when useful. Do not say only "review the diff."
   - **Risks / open points** — residual concerns or `None`.
   Re-read the Issue before writing the brief if its context was not retained
   through execution. Do not reduce background and goal to a generic one-line
   purpose when the Issue contains enough detail to distinguish them.
3. Move the Issue to In Review and wait for explicit approval before invoking
   `git-helpers-commit`. Silence is not approval, and requesting implementation
   earlier is not approval of the resulting change.
4. Keep the Issue In Review while addressing feedback. If feedback materially
   changes the prospective commit, implement the correction, rerun relevant
   checks, and present the result again without changing status. Return it to
   In Progress only when the user explicitly sends it back.
5. Once approved, keep the Issue In Review, stage exactly the reviewed Issue
   scope, and invoke `git-helpers-commit` as a nested operation. After it
   returns, automatically continue through the established integration path,
   verify the target branch, move the Issue to Done, complete its note, and
   apply `worktree-cleanup.md`. Select the path from repository conventions and
   existing Git/PR artifacts; do not stop merely to offer it as a next action.
   Continue until Done or a genuine external, permission, safety, or materially
   ambiguous integration gate blocks progress, then return that exact outcome
   to the caller for its post-completion or blocked flow.
6. Stop after the commit only when the user explicitly limits the request to
   **commit only** (for example, "commit only", "do not merge", or "do not
   update Linear"). A plain approval or ordinary "commit" request is not that
   limitation, even in a later user turn; it authorizes resuming this workflow
   after `git-helpers-commit`. If explicitly limited, verify the commit, keep
   the Issue In Review, and report that integration and completion remain.
7. Skip the review gate only when the user explicitly asks to commit this work
   without review.

## Commit and integration evidence

1. Resolve both the intended target branch and the branch containing the Issue's
   commits.
2. Verify that every Issue-related change is committed and no staged, unstaged,
   or untracked Issue-related change remains. The completion note cites those
   commits. A failed cleanliness check leaves an approved Issue In Review (or
   an explicitly unreviewed Issue In Progress).
3. Determine status from observable integration evidence:
   - Approved work branch, no PR, not integrated → In Review.
   - Review explicitly skipped; work branch not integrated → In Progress.
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
