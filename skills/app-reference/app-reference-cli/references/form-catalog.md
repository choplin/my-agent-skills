# Form catalog

Concrete patterns that did not fit in `SKILL.md`. Read the section for the
surface being built; the decision about which surfaces the tool has belongs to
chapter 2.

## Operation surface

### Command structure

- One binary. A two-level noun-verb tree once there are more than a handful of
  operations, and no deeper.
- The most common task reachable as `tool <subject>` with no flags.
- Subcommand `--help` shows a synopsis, that subcommand's flags, and two or
  three examples. Full detail belongs in a man page or docs.

### Input handling

- Accept `-` as a positional meaning stdin where a file is expected.
- Read stdin when no positional is given and stdin is not a TTY.
- Accept a repeated flag for repeated values (`--include a --include b`) rather
  than inventing a separator.
- Reject unknown flags rather than ignoring them.

### Output shapes

- A list: one record per line, stable field order, no header unless requested.
- A structure: the declared machine channel, data only.
- A change: nothing on success, and the path or identifier of what changed if
  the caller cannot otherwise find it.

### Partial failure

- Continue across the remaining items, report each failure on stderr as it
  happens, exit non-zero once at the end, and state how many succeeded.
- Never abort a batch on the first failure without saying what was left
  untouched.

## Prompts

### Choosing the prompt shape

| Situation | Shape |
|---|---|
| Free text with a derivable default | Inline default, empty input accepts it |
| Up to ~9 fixed options | Single-key selection, default marked |
| More than ~9, or unbounded | Incremental filter over candidates |
| Long-form text | Hand off to `$EDITOR` |
| Irreversible destruction | Show count and sample, then require the target's name |

### Mechanics

- Prompt on stderr; read from the terminal device, not stdin, so piped input
  still reaches the operation surface.
- Echo the accepted value after the prompt resolves, so scrollback records the
  decision.
- Never re-ask something already supplied by a flag.
- Never chain prompts for values that could all have been flags.

## Persistent TUI

### Layout skeleton

- A fixed context line at the top: where the user is, in domain terms.
- The working region: one or more panels corresponding to domain objects.
- A fixed key or status line at the bottom, scoped to the focused panel.
- Content never reflows the fixed lines; long values truncate with an ellipsis
  and reveal in full on focus.

### Focus rendering

- Focused: accent-coloured border plus a heavier or doubled border style.
- Unfocused: dimmed border and dimmed text, content still readable.
- Under `NO_COLOR`: the border style change alone must still identify focus.
- Selection within a panel is distinct from panel focus, and both are visible at
  once.

### Key map skeleton

| Key | Meaning |
|---|---|
| `h` `j` `k` `l` | Move within and between levels |
| `g g` / `G` | First / last |
| `C-d` / `C-u` | Half page |
| `Tab` / `S-Tab` | Cycle focus between panels |
| `/` then `n` / `N` | Search and cycle matches |
| `Enter` | Act on the selection |
| `Esc` | Cancel the current thing, restoring prior position |
| `q` | Leave the current level, or the tool at the top level |
| `?` | Full key reference |

Bare letters outside this set belong to verbs acting on the focused object.

### Async rendering

- Every panel renders in three states: loading, loaded, and failed. Failure is
  shown in the panel, not as a modal.
- A selection change cancels the previous selection's in-flight work before
  starting new work.
- Work that outlives a single frame reports into its own panel, never by
  freezing the frame.

### Exit

- Restore the terminal from a handler that runs on normal exit, on panic, and on
  `SIGINT` and `SIGTERM`.
- Print the resulting path, identifier, or equivalent command to stderr after
  restoring, so the session leaves a trace.
