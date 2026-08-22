# Terminal pane working-directory synchronization

Synchronize terminal navigation metadata whenever octa selects an isolated
worktree. This does not and cannot change the agent process's actual working
directory. Terminals that do not support OSC 7 ignore the sequence.

## Enter the selected worktree

After selecting or recovering the exact worktree:

1. Resolve its absolute, existing directory path. Retain the absolute entry
   workspace path in live session context as the return directory when it is
   outside the selected worktree. Do not persist it in an Issue, note,
   repository file, or comment.
2. Percent-encode the selected path as a file-URI path, preserving `/`, and
   emit this OSC 7 sequence directly in a host-facing output message:

   ```text
   ESC ] 7 ; file://localhost<encoded-absolute-path> BEL
   ```

   Write actual ESC (`0x1b`) and BEL (`0x07`) control bytes. In Codex, put the
   sequence in a `commentary` message. Do not emit it through a shell command,
   tool call, or captured command output; that output may not reach the outer
   terminal's parser.

## Leave the worktree

Immediately before removing the isolated worktree, choose a safe existing
return directory: prefer the retained entry workspace, otherwise use the
resolved target-branch worktree. Emit OSC 7 for that directory using the same
procedure, then remove the worktree.

When cleanup retains the worktree after a failed safety check, retain its pane
directory too. No restoration is needed for work performed directly in the
current workspace.
