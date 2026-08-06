# Implementation completion evidence

Read this before moving an `impl` Issue out of In Progress or from In Review to
Done.

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
