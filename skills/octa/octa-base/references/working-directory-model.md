# Working-directory model

Read this reference only when modifying or diagnosing octa's host-specific
working-directory procedures. Normal Issue execution uses
[terminal-pane-cwd.md](terminal-pane-cwd.md) instead.

## Session and tool working directories

The host session's working directory supplies the default location for tool
calls and may determine filesystem sandbox scope. A host can expose either a
session-wide move or only a per-call working-directory option:

- Claude Code's `EnterWorktree` and `ExitWorktree` move the session.
- Codex keeps the session in place and directs individual tool calls to the
  selected worktree.

An explicit tool working directory controls that tool call. It does not change
the outer terminal pane's directory metadata.

## Terminal pane working directory

A terminal pane may track a reported working directory for navigation and UI.
This value is metadata. Changing it does not move the agent session, change a
tool process's working directory, or change filesystem sandbox scope.

OSC 7 commonly reports this metadata to the terminal parser:

```text
ESC ] 7 ; file://localhost<percent-encoded-absolute-path> BEL
```

The path is a file-URI path: percent-encode characters that require encoding
and preserve `/`. The sequence must reach the outer terminal as raw ESC
(`0x1b`) and BEL (`0x07`) bytes. Rendered assistant output and captured tool
output may escape or intercept those bytes instead of passing them to the
terminal parser. A host-specific procedure may identify an assistant output
channel that forwards them.

The host procedure owns OSC 7 delivery. Codex emits it through `commentary`;
Claude Code leaves it to an optional external hook. Neither route changes the
session or tool working directory.
