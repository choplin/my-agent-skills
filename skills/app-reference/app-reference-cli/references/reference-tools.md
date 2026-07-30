# Reference tools

The rules in `SKILL.md` are induced from tools that are good to use. Each entry
covers a different axis; they are not interchangeable examples of one virtue.
Consult one when a rule needs a concrete precedent.

## Operation surface

### `rg`

- Useful with a single positional argument and no configuration. Config is
  optional and absent by default.
- Defaults are opinionated — respects ignore files, skips binaries — and every
  one is overridable by an explicit flag.
- Streams matches as they are found; the first result appears long before the
  search ends.
- Line-oriented and stable, so it composes with `xargs`, `cut`, and editors
  without needing a machine mode. `--json` exists for consumers that want
  structure.

### `gh`

- A two-level noun-verb tree (`gh pr create`) keeps a large surface navigable
  without a wizard at the root.
- Human-formatted commands also offer `--json` with field selection, so one
  command serves a reader and a script.
- Missing required values are prompted for on a TTY and rejected with a named
  flag when there is none, so the same command runs unattended in CI.

### `fzf`

- The interactive part is a stage in a pipeline, not a program that owns the
  session: candidates on stdin, selection on stdout, UI drawn on the terminal
  device.
- The precedent for "one choice from a set is a selection step, not a screen".

### `jj`

- Operations are recorded and undoable, which removes the reason to confirm
  them.
- The direct demonstration that recoverability substitutes for confirmation.

## Run report

### `cargo`

- Silent for fast operations; the report appears only once work is genuinely
  slow.
- Progress is reported in units the user recognises — crates, packages,
  resolved versions — not an abstract percentage.
- Status lines and the progress bar go to stderr by deliberate decision, so
  `--message-format=json` can put structured output on stdout.
- Completed work is reused on the next run rather than repeated, and what
  remains at the end is the artifact and its path.

### `bun` — counterexample

- `bun install` writes its banner and timing (`bun install v1.3.13`,
  `[3.00ms] done`) to **stdout**, while a warning from the same command goes to
  stderr.
- Included as the failure mode to recognise: not a decision, but the result of
  assuming a person is watching. See `references/stream-conventions.md`.

### `rustc` — diagnostics

- Has no progress output at all; it is a batch compiler, and the progress people
  associate with Rust belongs to `cargo`.
- Diagnostics go to stderr with location, source span, explanation, and a
  suggested fix.
- The precedent for spending the largest design budget on errors. Framing and
  colour are justified in a diagnostic and unjustified in a success message.

## Navigation surface

### `lazygit`

- Justified as a TUI on all three counts: repeated actions, retained state,
  navigation over sets.
- Panels correspond to domain objects, and the available keys depend on which
  panel holds focus, so the key space stays small.
- Every action maps to something git can do directly. The TUI accelerates git;
  it does not replace it.

### `yazi`

- Navigation structure is the interface: parent, current, and preview columns,
  so position is visible without a status line stating it.
- The preview renders what is known immediately and fills in asynchronously;
  a directory of large files never blocks the cursor.
- Demonstrates that responsiveness under slow I/O is a property of the render
  loop, not a progress indicator bolted on.

### `k9s`

- Handles large object sets: incremental filtering, a stable columnar layout,
  and movement between levels of a hierarchy without losing position.
- Shows how to keep a dense table scannable — fixed column order, a leading
  state marker, colour as the second carrier of that state.

### `helix`

- Surfaces which keys are available as they become available, so a large key
  space stays discoverable without memorisation.
- The precedent for showing the scoped key set rather than hiding it behind a
  help screen.
