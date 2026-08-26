# Move Claude Code into the selected worktree

## Enter

1. Use `workflow-adapter-worktree` to confirm the selected worktree and resolve
   its absolute path.
2. Call `EnterWorktree` with `path` set to that path.
3. Do not call `EnterWorktree` without `path`; that creates another worktree.
4. Confirm that Claude Code's working directory is the selected worktree before
   running an Issue tool call.

## Leave

1. Confirm that the retained entry workspace still exists. If it does not,
   retain the Issue worktree and report that cleanup cannot return safely.
2. Call `ExitWorktree` with `action: "keep"`.
3. Do not use `action: "remove"`; `workflow-adapter-worktree` owns removal.
4. Confirm that Claude Code's working directory is the retained entry workspace.
5. Return to the caller so it can remove the Issue worktree.

## Terminal pane

Do not emit OSC 7, access a pty, invoke a terminal manager, or inspect an
external `CwdChanged` hook. The hook may update the pane after `EnterWorktree`
and `ExitWorktree`, but it is not an octa prerequisite.
