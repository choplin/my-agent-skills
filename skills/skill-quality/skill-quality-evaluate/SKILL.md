---
name: skill-quality-evaluate
description: >-
  Measures how good a skill is empirically: runs it on a set of real tasks,
  scores each deliverable against a mechanical verification signal, and
  reports a pass rate with the failing traces.
user-invocable: false
metadata:
  description-role: documentation
---

# skill-quality-evaluate: evaluate a skill

Measure a skill by **running it and scoring the output**, not by reading it. This
is the loss-function step of the training loop (`skill-quality-base`). It stands
alone as a benchmark/audit, and it is what `skill-quality-optimize` calls each round.

> Load `skill-quality-base` for the run layout, `state.json`, and the scripts.
> Load `skill-quality-base` (`references/verification-signals.md`) before
> designing the signal.

## When to use standalone

- Baseline a fresh draft right after authoring (v0) — confirm the signal actually
  discriminates before committing to a loop.
- Audit an existing skill: "is this skill earning its context? does it help?"
  (SWE-Skills-Bench found 39 of 49 public skills gave *no* pass-rate lift — assume
  nothing; measure.)
- Compare two versions of a skill on the same tasks.

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
(tests/reference/validator), a **verification anchor** (mechanically-checkable
facts), or agent-judged **self-criteria** (binary/observable/specific). Write it
to `<run-dir>/signal.md`.

> If no signal can mechanically discriminate good from bad output, stop here:
> report that the skill's quality is not machine-evaluable, give a baseline on
> whatever *is* checkable, and route the rest to a human (base law 1). Do not
> fabricate a signal to keep the loop running.

### 3. Scaffold the run (if not already)

```
skill-quality-base/scripts/init.sh --run-dir <dir> --skill <name> \
    --train <ids> --holdout <ids> --signal-kind <kind> [--signal-cmd '<cmd>']
```

Copy the skill under test into `versions/v0/`.

### 4. Run the skill on each task and label it

For each task, execute the skill **as an agent actually would** — load it, follow
it, produce the deliverable — in a *fresh* context per task so runs don't
contaminate each other. Then apply the signal:

- oracle/anchor → run `signal.command`; exit 0 = pass.
- self-criteria → a *separate* fresh agent judges the deliverable against the
  criteria (not the agent that produced it), to reduce self-grading noise.

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
`skill-quality-base/scripts/gate.sh <dir> --set-baseline` once the holdout is
recorded.

## Output

Before reporting, self-check: every task in the declared split has a recorded
pass/fail (`record.sh` warns on a mismatch — don't ignore it); holdout
deliverables were not read before scoring; and if the signal is self-criteria, a
*separate* fresh agent did the judging.

Report: pass rate per split, the list of failing tasks with their failure
reasons, and a one-line verdict. "Clears the bar" is not self-defined — state the
pass rate against a threshold given up front by whoever requested the run; if none
was given, report the rate and say no bar was set rather than inventing one. Also
state whether the signal itself is precise enough to trust for further iteration
(base law 1), not just whether the skill happened to pass this time. The scored
`state.json` + traces are the handoff to `skill-quality-improve` /
`skill-quality-optimize`.
