---
name: app-reference-cli
description: >-
  Conventions for terminal-facing tools: separating the product channel from the
  run-report channel, dividing an operation surface from a navigation surface,
  placing each input, and the concrete ergonomics of run reports, prompts, and
  TUI components.
user-invocable: false
metadata:
  description-role: documentation
---

# Terminal Tools

Applies to any tool driven from a shell: a single-shot command, a command that
prompts, a command that renders a live run report, or a full-screen TUI. Read
this before fixing the shape of a new tool, and before adding output, prompts,
or components to an existing one.

## Why a competent tool still feels bad to use

A terminal tool built without these rules is rarely wrong on principle. It fails
because each accommodation looks like kindness on its own: ask rather than
assume, confirm before acting, announce what is happening, mark success clearly,
frame the important part. Together they produce a tool nobody wants to run
twice.

**Richness is not the failure.** A tool that renders a dense live build report,
or a full-screen navigator with previews and vim motions, is not a compromise of
some purer command-line ideal. For a great deal of work it is the better tool,
and the preference for capable single tools over pipelines of minimal ones is
real and is not a decline in taste.

The failure is **richness in the wrong place**: a wizard where a flag belonged,
a status banner on the product channel, a screen built for something the user
was never choosing between, a spinner where the user needed a record.

Two separations decide almost everything below. Get them right and the rest is
detail; get them wrong and no amount of polish recovers.

## 1. Separate the two channels

Every terminal tool writes to two channels with different audiences and
different contracts.

| | Product channel (stdout) | Report channel (stderr, screen) |
|---|---|---|
| Audience | A program | A person |
| Contract | Stable, parseable, composable | Legible, immediate, disposable |
| Consumed by | Pipes, redirects, scripts, agents | Nobody |
| Richness | Forbidden | Free — it costs nothing |

Nothing consumes the report channel. That is the whole reason it can be as rich
as it earns: colour, live updates, hierarchy, framed diagnostics, an entire TUI.
None of it can break a caller, because there is no caller.

The austerity that the command-line tradition demands is owed by **one channel
only**. Applying it to the report channel is where the "silent, minimal tool"
instinct becomes actively wrong.

Practice varies here and there is no convention to conform to, so this is a
stated position rather than a description. See
`references/stream-conventions.md` for the measurements and the reasoning.

### Rules

- Put the product on stdout and the account of the run on stderr, by default, in
  every form — including a tool nobody will plausibly pipe. It is free now and
  expensive to retrofit once callers exist.
  - Do not write a status banner, a timing, a progress line, or a completion
    notice to stdout. This is the state an unguided implementation lands in.
- Distinguish the answer to a query from the account of a run. `--version`,
  `--print`, and a computed result are products. "Compiling", "Finished", and a
  percentage are not.
- Abandon the split only deliberately and only wholesale. If the artifact is a
  file and stdout is the report, hold that everywhere.
  - Do not be half composable. Splitting the product across a file and stdout is
    worse than openly not composing.
- Send errors, warnings, and diagnostics to stderr always, with no exception for
  a tool that has abandoned the split.
- Declare a machine channel explicitly when the output has structure worth
  consuming — `--json` or equivalent, data only, stable schema, one spelling
  across every subcommand.
- Let TTY detection govern presentation only, never facts. `tool | cat` reports
  the same information as a terminal run; only the rendering degrades.

## 2. Separate the two surfaces

Above the channels sit two surfaces, and a good modern tool usually has both.

- **The operation surface** performs the work. Composable, scriptable,
  non-interactive, deterministic in what it will do. This is where the
  command-line tradition still governs completely.
- **The navigation surface** shows what is there, lets the user move through it,
  and lets them decide what to operate on. Stateful and rich — a TUI, a
  selector, a prompt.

**The TUI navigates; the commands operate.** A TUI whose actions exist nowhere
else has trapped the user's work inside a screen: it cannot be scripted,
repeated, reviewed, or automated. A tool with only an operation surface leaves
the user unable to find out what to name in the arguments.

### Deciding what the tool needs

An operation surface is never optional. For the navigation surface:

1. **Does the user already know what to name?** If the subject is a path, a
   pattern, or a name they hold in their head, no navigation surface is needed.
2. **Is it one choice from a set?** Then it is a selection step, not a screen —
   a filtering selector that reads candidates and emits the choice, composable
   as a stage.
3. **Do repeated actions, retained state, and navigation over a set all hold**
   — cursor, selection, filters, current view surviving between actions? Only
   then is a persistent TUI the right answer, and then it is the right answer,
   not a concession.

### Rules

- Give every navigation-surface action a command-line equivalent, and make the
  TUI able to show the user what that equivalent is.
- Keep the operation surface fully usable with no TTY, no prompts, and no
  screen.
- Treat prompting as a fallback for a missing required value on a TTY, never as
  an input channel.
  - Do not build a wizard — a prompt sequence collecting every input — as the
    primary interface. It cannot be scripted, re-run, or diffed.
- Never prompt when stdin or stdout is not a TTY. Fail naming the flag that
  would have supplied the value.
  - Do not block waiting for input in CI. That is broken, not cautious.
- Make actions recoverable instead of confirming them. A tool that asks "are you
  sure?" often is usually one that failed to make its actions reversible.
  - Do not confirm what the user can undo, re-run, or inspect afterward.

## 3. Place each input

| Destination | Holds | Test |
|---|---|---|
| Positional argument | What the command acts on | Naming it is naming the task |
| Flag | What modifies this invocation | Plausibly different next run |
| Config file | Stable per project or per user | Retyping it every time would be absurd |
| Environment | Secrets and ambient context | Set by the surroundings, not by intent |
| Prompt | A required value with no default and no way to infer it | Only with a person present |

### Rules

- Keep positional arguments to the subject, one or two at most; everything else
  is a flag.
  - Do not accept options positionally, and do not change a positional's meaning
    based on how many were given.
- Derive before asking. The working directory, the repository, the file's own
  contents, and one obvious default all beat a question.
- Introduce a config file only when at least three values genuinely qualify as
  stable, and keep it optional forever. Every key needs a working default and an
  overriding flag.
  - Do not require an `init` before first use. The tool must do useful work in a
    fresh directory with no setup.
- Fix and document precedence: flag > environment > project config > user config
  > built-in default.
- Reserve the environment for secrets and for what the surroundings set —
  `NO_COLOR`, `EDITOR`, `PAGER`, `CI`, credentials.
  - Do not use environment variables as a shadow flag namespace.
- Name flags after their effect on the result, not the mechanism inside. Pair
  booleans as `--thing` / `--no-thing`.
- Keep escalation of power explicit and separate. `--yes` skips a question;
  `--force` widens what is affected. One flag must not do both.

## 4. Render the run report

For work whose *process* is information — builds, deploys, migrations, test
runs, dependency resolution — where a run can fail partway and the location of
the failure changes what the user does next. For a query or a transform the
process is not information, and the report should be empty.

### Rules

- Report the structure of the user's work, not the tool's internals. Name steps
  in units the user recognises: packages, files, tests, resources.
  - Do not print internal phase names, module names, or a version banner by
    default.
- Align a fixed-width state marker in the leading column so the eye scans one
  axis. Use colour as the second carrier of that state, never the only one.
- Collapse a live-updating region into one stable line when it ends. The report
  is read afterwards in scrollback, not only watched.
  - Do not let an erase-on-finish spinner be the only account of what happened.
- Keep nesting to two levels. Deeper hierarchy stops being scannable in a
  scrolling stream.
- Spend the largest share of the design budget on diagnostics: what was
  attempted, the offending value, why it failed, what to do next, and the
  location with surrounding context when there is one. Framing and colour are
  justified here and nowhere else.
  - Do not show a stack trace by default; put it behind `--debug`.
- Degrade without a TTY to the same facts with no cursor control, no in-place
  update, and no animation frames.
- End with the outcome and the durable artifact — the path, the identifier, the
  next command.
  - Do not end with a celebration.
- Expose one verbosity axis (`-v` / `-q`), not per-subsystem log flags.
- Make exit codes meaningful: zero for success, non-zero for failure, and a
  distinct documented code for "ran correctly, found nothing" only when callers
  must tell them apart.

## 5. Design prompts

### Rules

- Write prompts to stderr and read the answer from the terminal device, so a
  prompting run still produces clean stdout.
- Show the derived default inline and let empty input accept it.
- Use single-key selection for up to about nine options, with the default
  marked; use an incremental filter beyond that.
  - Do not make the user read a numbered list and then type a number and Enter.
    It is ceremony at small N and unusable at large N.
- Validate in place and re-ask the same question. Never restart the sequence.
- Show the consequence before an irreversible action: the count affected and a
  sample of it. Require typing the target's name when the blast radius is wide.
- Abort with a non-zero exit on interrupt at a prompt.
  - Do not fall through to a default value when the user cancels.

## 6. Design TUI components

Grounded in the response thresholds that govern felt quality: about 100 ms is
the ceiling for something to feel like a direct consequence of a keystroke, about
1 s is the ceiling for staying in flow, and about 10 s is where attention
leaves. Every rule below serves one of those three.

### Focus and state

- Mark the focused region with **both** a border weight or style change **and**
  an accent colour. Colour alone disappears under `NO_COLOR`, colour vision
  deficiency, and low-contrast themes.
  - Do not indicate focus by colour alone, and do not make the user infer
    position from a label.
- Dim the border and text of unfocused regions, but keep their content visible.
  Context is the reason there are multiple regions.
- Keep exactly one region focused, and scope the available keys to it so the
  global key space stays small.
- Reserve one fixed line for the current context and one for available keys or
  pending state. Content must never reflow those lines.
- Give every empty state a sentence saying what to do, not a blank pane.

### Keys

- Follow vim motions for navigation: `h` `j` `k` `l`, `g g`, `G`, `C-d`, `C-u`,
  `/` to search, `n` and `N` to cycle matches, `Esc` to cancel, `q` to leave,
  `?` for help.
- Reserve bare single letters for verbs acting on the focused object, keeping
  the navigation namespace and the verb namespace disjoint.
- Show the keys available for the focused region without requiring the user to
  open help.
- Require a modifier, a typed confirmation, or an undo for any destructive verb.
  - Do not put an irreversible action on a bare key.
- Restore the pre-search position when a search is cancelled.

### Responsiveness

- Paint from what is already known and fill the rest in asynchronously. Never
  block the render loop on I/O.
- Repaint within about 100 ms of a keystroke. If the true result cannot arrive
  in that window, paint optimistically and correct.
- Show a placeholder in the region that is still loading, not a modal over the
  whole screen.
- Cancel in-flight work for the previous selection as soon as the selection
  changes.

### Layout and exit

- Use the parent / current / preview arrangement when navigating a hierarchy, so
  position is visible without being stated.
- Keep semantic colour roles to about four, legible on both light and dark
  backgrounds. Do not depend on pure white or pure black.
- Treat the mouse as optional. Wheel scroll and click-to-focus are worth
  supporting; nothing may require a pointer.
- Relayout on resize rather than resetting state.
- Restore the terminal on every exit path, including panic and signal.
- Leave the result behind on exit — a path, an identifier, a command to re-run.

## 7. Handle long work

- Say nothing for work under about a second. Progress reporting for fast work is
  noise.
- Report indeterminate work as one stderr line naming what is happening, redrawn
  in place on a TTY and appended plainly when not.
- Report determinate work in the unit the user cares about, with what remains. A
  bare percentage hides whether it is stuck.
- Stream results as they are produced. The first result appears as soon as it is
  known, not when the run ends.
- Make work past about ten seconds interruptible, and state on interrupt what
  completed and what did not.
- Make long multi-step work resumable, so a second run reuses completed work.
- Keep anything long able to run detached, with no TTY, in CI.

## Check the result

1. `tool --help` fits one screen for the common path.
2. `tool ... | cat` reports the same facts as a terminal run.
3. `tool ... > /dev/null` still shows progress, warnings, and errors.
4. `tool ... > out` leaves a file containing the product and nothing else.
5. `tool ... < /dev/null` with no TTY neither hangs nor prompts.
6. `NO_COLOR=1 tool ...` emits no escape sequences, and focus is still visible
   in the TUI.
7. The tool works in a fresh directory with no config and no `init`.
8. Interrupting mid-run leaves a stated, consistent condition.
9. `--json`, if present, parses and contains no presentation.
10. Every navigation-surface action has a command-line equivalent.
11. Holding a navigation key scrolls without visible lag.
12. Resizing the terminal preserves selection and scroll position.

## References

- `references/stream-conventions.md` — measured stdout/stderr practice across
  real tools, why it varies, and the position taken here.
- `references/reference-tools.md` — the tools these rules are induced from and
  the specific behaviour each demonstrates.
- `references/form-catalog.md` — concrete patterns for the operation surface,
  prompts, and a persistent TUI.
