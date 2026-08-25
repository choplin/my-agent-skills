# Direct Codex work to the selected worktree

## Enter

1. Set every Issue tool call's working directory to the selected worktree's
   absolute path.
2. For a tool with no working-directory option, use absolute paths rooted in
   the selected worktree.
3. Do not use the terminal pane's reported directory to choose a tool working
   directory.
4. Percent-encode the selected worktree path as a file-URI path while
   preserving `/`.
5. Emit the following OSC 7 sequence in a `commentary` message using actual ESC
   (`0x1b`) and BEL (`0x07`) bytes:

   ```text
   ESC ] 7 ; file://localhost<encoded-absolute-path> BEL
   ```

6. Do not emit the sequence through a shell command, tool call, or captured
   command output.

## Leave

1. Choose a safe existing directory: prefer the retained entry workspace;
   otherwise use the resolved target-branch worktree.
2. Percent-encode that path and emit its OSC 7 sequence in a `commentary`
   message using the same procedure as Enter.
3. Set every cleanup tool call's working directory to the safe directory.
4. Return to the caller so it can remove the Issue worktree.
