# Worktree cleanup after Done

Cleanup is automatic only after safety checks.

1. Resolve target branch and exact Issue worktree/branch from session context
   or its worktree note.
2. Verify:
   - completion evidence proves integration;
   - no staged, unstaged, or untracked Issue work needs preservation;
   - the work branch is not the target branch;
   - the worktree/branch identity belongs to this Issue.
3. For an isolated worktree, apply the leaving procedure in
   [terminal-pane-cwd.md](terminal-pane-cwd.md) and synchronize the terminal to
   a safe existing directory before removal.
4. For an isolated worktree, use the installed `wtm-worktree` skill and remove
   it from outside that worktree. Delete the local work branch only after the
   checks pass.
5. For a work branch in the current workspace, switch to the target branch and
   delete only the resolved local work branch. Direct target-branch work needs
   no cleanup.
6. Verify removal and report it. Never delete a remote branch unless separately
   requested.

If any check fails, retain both artifacts and report the exact failed check.
