---
name: skill-optimize-evaluate
description: Empirically measure how good a skill is — run it on a set of real tasks, score each deliverable against a mechanical verification signal, and report a pass rate with the failing traces. Usable standalone to audit or baseline any existing skill ("how good is this skill really?", "benchmark this skill", "score this skill's outputs"), and used by the skill-optimize loop as its loss-function step. Triggers on "evaluate this skill", "measure this skill", "benchmark a skill", "score a skill's deliverables", "スキルを評価", "スキルの実力を測る". Should NOT trigger for static content review without running it (use skill-authoring-quality-review), or for authoring a skill from scratch (use skill-authoring).
user-invocable: true
---

# skill-optimize: evaluate a skill

Measure a skill by **running it and scoring the output**, not by reading it. This
is the loss-function step of the training loop (`skill-optimize-base`). It stands
alone as a benchmark/audit, and it is what `skill-optimize` calls each round.

> Load `skill-optimize-base` for the run layout, `state.json`, and the scripts.
> Load `skill-optimize-base` (`references/verification-signals.md`) before
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

Aim for at least ~5 train + ~3 holdout; more is better, but a weak-but-real set
beats a large invented one. Standalone audits can skip the split (evaluate one
pooled set) — the split only matters when feeding `skill-optimize`.

### 2. Design the verification signal

Decide how each deliverable is judged **pass or fail**, following
`skill-optimize-base` (`references/verification-signals.md`): an **oracle**
(tests/reference/validator), a **verification anchor** (mechanically-checkable
facts), or agent-judged **self-criteria** (binary/observable/specific). Write it
to `<run-dir>/signal.md`.

> If no signal can mechanically discriminate good from bad output, stop here:
> report that the skill's quality is not machine-evaluable, give a baseline on
> whatever *is* checkable, and route the rest to a human (base law 1). Do not
> fabricate a signal to keep the loop running.

### 3. Scaffold the run (if not already)

```
skill-optimize-base/scripts/init.sh --run-dir <dir> --skill <name> \
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
`skill-optimize-improve` learns from). Read traces, not just verdicts — wasted
steps and near-misses are signal too.

### 5. Record the score

```
skill-optimize-base/scripts/record.sh <dir> --version vN --split <split> \
    --results 't1::pass,t2::fail,...'
```

For a v0 baseline feeding the loop, also run
`skill-optimize-base/scripts/gate.sh <dir> --set-baseline` once the holdout is
recorded.

## Output

Report: pass rate per split, the list of failing tasks with their failure
reasons, and a one-line verdict — does the skill clear the bar, and is the signal
trustworthy enough to optimize against? The scored `state.json` + traces are the
handoff to `skill-optimize-improve` / `skill-optimize`.
