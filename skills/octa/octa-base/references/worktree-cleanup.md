# Worktree cleanup after Done

Cleanup is automatic only after safety checks.

1. Resolve target branch and exact Issue worktree/branch from session context
   or its association metadata through `workflow-adapter-worktree`.
2. Verify:
   - completion evidence proves integration;
   - no staged, unstaged, or untracked Issue work needs preservation;
   - the work branch is not the target branch;
   - the worktree/branch identity belongs to this Issue.
3. For an isolated worktree under Codex or Claude Code, apply the leaving
   procedure in [terminal-pane-cwd.md](terminal-pane-cwd.md). Under Claude Code,
   do not wait for or verify the optional external pane hook. Under any other
   host, skip this step.
4. For an isolated worktree, use `workflow-adapter-worktree` and remove it from
   outside that worktree. Request `delete-if-merged` for the local work branch
   only after the checks pass; never request `force-delete` here.
5. For a work branch in the current workspace, switch to the target branch and
   delete only the resolved local work branch. Direct target-branch work needs
   no cleanup.
6. Verify removal and report it. Never delete a remote branch unless separately
   requested.

If any check fails, retain both artifacts and report the exact failed check.
