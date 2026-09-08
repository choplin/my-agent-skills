# Apply the host working-directory procedure

## Enter the selected worktree

After selecting or recovering the exact worktree:

1. Resolve and verify the worktree's absolute path.
2. Retain the absolute entry workspace path in live session context. Do not
   persist it in an Issue, note, repository file, or comment.
3. Apply exactly one entry procedure:
   - Codex: [terminal-pane-cwd-codex.md](terminal-pane-cwd-codex.md)
   - Claude Code:
     [terminal-pane-cwd-claude-code.md](terminal-pane-cwd-claude-code.md)
4. Complete the entry procedure before reading, editing, or running commands
   for the Issue.

## Leave the worktree

1. Run every cleanup safety check before changing directories.
2. If any check fails, retain the worktree and do not run a leave procedure.
3. Apply the running host's leave procedure immediately before removal.
4. Remove the worktree only after the host procedure places cleanup operations
   outside it.

Do not apply this reference to work performed directly in the current
workspace.
