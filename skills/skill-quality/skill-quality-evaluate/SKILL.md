---
name: skill-quality-evaluate
description: >-
  Quantitatively evaluates a skill when a reproducible mechanical pass/fail
  signal can be defined in advance: runs it on real tasks and reports the
  resulting pass rate and failure traces. Applies only when the relevant
  outcome is genuinely machine-checkable.
user-invocable: false
metadata:
  description-role: documentation
---

# skill-quality-evaluate: quantitative evaluation

Measure a skill by **running it and scoring the output against a predetermined
mechanical signal**. This is the quantitative path and the loss-function step of
`skill-quality-optimize`. Constructing a faithful checker has a high practical
setup cost. The result measures only what the named task set and signal can
observe; it does not produce an overall quality judgment.

> Load `skill-quality-base` for the run layout, `state.json`, and the scripts.
> Load `skill-quality-base` (`references/verification-signals.md`) before
> designing the signal.

## When to use standalone

- Baseline a skill on tasks whose deliverables have an external checker, reference
  result, schema, compiler, test suite, or other reproducible pass/fail criterion.
- Compare two versions against the same fixed tasks and mechanical signal.
- Supply the measured loss for `skill-quality-optimize`.

Most skill quality cannot be evaluated this way. When the relevant judgment
depends on clarity, usefulness, coherence, taste, or context-sensitive reasoning,
use `skill-quality-review` and keep the result qualitative.

## Procedure

### 1. Assemble a task set and split it

Collect real, representative tasks the skill is meant to handle — ideally from
actual usage, not invented ones. You need enough to split:

- **train** — tasks whose failures you are allowed to learn from.
- **holdout** — tasks reserved to judge whether a change genuinely helped. Never
  derive edits from these (base law 2).

Aim for at least ~5 train + ~3 holdout — below that, one fluke task swings a
split's pass rate so far that any score reads as anecdote, not a rate. More is
better, but a weak-but-real set beats a large invented one; if you can't reach
~5/~3 with real tasks, say the scores are indicative only rather than padding with
invented ones. Standalone audits can skip the split (evaluate one pooled set) —
the split only matters when feeding `skill-quality-optimize`.

### 2. Design the verification signal

Decide how each deliverable is judged **pass or fail**, following
`skill-quality-base` (`references/verification-signals.md`): an **oracle**
(tests/reference/validator) or a **verification anchor** implemented as a
mechanical checker. Write it to `<run-dir>/signal.md`.

> If no signal can reproducibly discriminate pass from fail, stop here and route
> the assessment to `skill-quality-review`. Do not fabricate a proxy or convert
> model judgment into a score to keep this path running.

### 3. Scaffold the run (if not already)

```
skill-quality-base/scripts/init.sh --run-dir <dir> --skill <name> \
    --train <ids> --holdout <ids> --signal-kind <kind> --signal-cmd '<cmd>'
```

Copy the skill under test into `versions/v0/`.

### 4. Run the skill on each task and label it

For each task, execute the skill **as an agent actually would** — load it, follow
it, produce the deliverable — in a *fresh* context per task so runs don't
contaminate each other. Then apply the signal:

Run `signal.command`; exit 0 = pass and any non-zero exit = fail.

Write each run to `traces/<version>/<split>/<taskid>.md`: what the skill produced,
the verdict, and **why it failed** (the failure reason is the raw material
`skill-quality-improve` learns from). Read traces, not just verdicts — wasted
steps and near-misses are signal too.

### 5. Record the score

```
skill-quality-base/scripts/record.sh <dir> --version vN --split <split> \
    --results 't1::pass,t2::fail,...'
```

For a v0 baseline feeding the loop, also run
`skill-quality-base/scripts/gate.sh <dir> --set-baseline` once both splits are
recorded.

## Output

Before reporting, self-check: every task in the declared split has a recorded
pass/fail (`record.sh` rejects a mismatch); holdout deliverables were not read
before scoring; and the same mechanical command was used for every comparable
deliverable.

Report the pass rate per split, failing tasks and reasons, the exact signal, and
the scope it measures. State the result against a threshold only when that
threshold was supplied before the run; otherwise report the measurement without a
quality verdict. Also state whether the signal is precise enough to trust for
further iteration (base law 1). The scored
`state.json` + traces are the handoff to `skill-quality-improve` /
`skill-quality-optimize`.
