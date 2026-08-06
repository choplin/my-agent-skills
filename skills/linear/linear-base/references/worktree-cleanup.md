# Worktree and branch cleanup after Done

Read this after an `impl` Issue reaches Done and before removing its local Git
artifacts. Cleanup is automatic after the safety checks; do not ask the user for
another instruction.

1. Resolve the intended target branch and the exact worktree name, path, and
   local work branch from the execution workspace or `wtm` note.
2. Verify all of the following:
   - the completion gate has evidence that the change reached the target branch;
   - no staged, unstaged, or untracked content in the worktree needs preserving;
   - the work branch is not the target branch;
   - the resolved worktree and branch belong to this Issue.
3. For an isolated `wtm` worktree, delegate to `wtm-worktree` and run from
   outside it:

   ```bash
   wtm remove <name> --force -D
   ```

   `--force` skips the interactive prompt; `-D` removes the local branch even
   when squash or cherry-pick integration means Git cannot prove ancestry. The
   integration check above is therefore mandatory.
4. If the current workspace is on an integrated work branch without a separate
   worktree, switch it to the target branch and run
   `git branch -D <resolved-work-branch>`. If work was committed directly on the
   target branch, there is no work branch or worktree to remove.
5. Verify that the worktree and local work branch no longer exist, then report
   what was removed. Do not delete a remote branch unless separately requested.

If any identity, cleanliness, or integration check fails, do not delete either
artifact. Report what remains and the failed check so cleanup can be recovered
safely.
