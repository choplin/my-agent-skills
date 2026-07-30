# Stream conventions in practice

The stdout/stderr split is a convention, not an enforced contract, so real tools
disagree. This file records what was actually measured, why the disagreement
happens, and the position this skill takes regardless of it.

## What was measured

Run on macOS with the versions installed at the time. Each command was run as
`cmd >out 2>err` and the byte counts compared.

| Command | stdout | stderr | Reading |
|---|---:|---:|---|
| `git clone --progress src dst` | 0 | 28 | Status to stderr |
| `git status` | 53 | 0 | Product to stdout |
| `curl https://github.com/` | 0 | 396 | Progress meter to stderr |
| `rg foo /nonexistent` | 0 | 105 | Diagnostic to stderr |
| `wget` (no argument) | 0 | 88 | Usage error to stderr |
| `npm ls` | 48 | 0 | Product to stdout |
| `bun install` | 46 | 36 | **Run banner and timing to stdout**, warning to stderr |
| `ffmpeg -version` | 826 | 0 | Query answer to stdout |

Two entries deserve care.

`ffmpeg -version` on stdout is not a violation. `-version` is a query whose
answer *is* the product. The encoding log of an actual `ffmpeg` run goes to
stderr. The split here is not "human-formatted versus machine-formatted" but
"the answer to a question versus the account of a run".

`bun install` is a genuine violation. `bun install v1.3.13` and `[3.00ms] done`
are the account of a run, and they land on stdout, while a warning from the same
command goes to stderr. The inconsistency shows it is not a deliberate contract
but an implementation that assumed a human was watching.

`gh auth status` also wrote to stderr in the measurement, but with a non-zero
exit — an error path, so it says nothing about where the tool puts a successful
status report.

## Why tools disagree

The split holds where it is load-bearing and erodes where it is not.

- Tools built to be piped — `git`, `curl`, `wget`, `rg`, `ffmpeg` — keep it.
  Not out of discipline: breaking it breaks them.
- Application and ecosystem tools — much of npm, bun, many build and CI tools —
  drift. They were written assuming a terminal with a person in front of it, and
  a pipeline is never exercised.

Rich logging pushes in the wrong direction. Once a tool renders a live,
multi-line, coloured report, it starts treating the screen as its own, and the
report ends up on stdout with everything else. `cargo` putting its status lines
on stderr is a deliberate decision, not a consequence of being rich.

## How tools that get it right resolve it

Two workable shapes.

- **Human render on stderr, machine channel declared separately.**
  `cargo build --message-format=json`, `gh ... --json`, `rg --json`. The default
  invocation is for a person; the machine channel is explicit and austere.
- **Product to a file, stdout freed for reporting.** `curl -o`, `ffmpeg out.mp4`.
  This is a different contract — the artifact is the file, not stdout — and it
  is coherent as long as it is consistent.

Flag naming for the machine channel is itself unsettled: `--json`, `--format
json`, `-o json`, `--output=json`, `--message-format=json` all appear in
widely-used tools. There is no convention to conform to, only a choice to make
and hold.

## The position taken here

Practice varies, so the rule cannot be justified as conformity. It is justified
by what it buys and what it costs.

1. **stdout carries the product. stderr carries the account of the run.** Hold
   this by default, in every form, including a tool that will never plausibly be
   piped. It costs nothing at build time and cannot be retrofitted cheaply once
   callers exist.
2. **Abandoning it is allowed, but only deliberately and only wholesale.** If
   the artifact is a file and stdout is the report, say so, and never write part
   of the product to stdout as well. A tool that is half composable is worse
   than one that is openly not.
3. **The unacceptable case is the unexamined one** — writing the run report to
   stdout because that is where `print` goes. This is what `bun install` does,
   and it is the state an unguided implementation lands in.
4. **Declare the machine channel explicitly** when the output has structure
   worth consuming. Pick one spelling and use it across every subcommand.
   `--json` is the most common; consistency inside the tool matters more than
   the choice between spellings.
5. **Errors and diagnostics always go to stderr**, in every shape the tool
   takes, with no exception for a tool that has abandoned rule 1.
