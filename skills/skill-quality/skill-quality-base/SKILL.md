---
name: skill-quality-base
description: >-
  Defines the quantitative skill-optimization model: its run directory and
  state schema, four evaluation laws, verification-signal policy, and the
  agent-agnostic shell+jq scripts that record results and gate candidate
  versions. Applies when a skill is evaluated or improved from real task runs.
user-invocable: false
metadata:
  description-role: documentation
---

# Skill quality optimization base

This skill owns the quantitative optimization machinery shared by
`skill-quality-optimize`, `skill-quality-evaluate`, and `skill-quality-improve`.
Other skills delegate to it by name so the same workflow works whether installed
flat or as part of a plugin. The normative definition of a good skill belongs to
`skill-quality-standard`.

References here are addressed in two forms. In both, resolve the path **relative
to this skill's installed directory** (load this skill, then read/run the named
file from its own root):

- `` `skill-quality-base` skill (`references/<file>`) `` → read `references/<file>` from this skill.
- `skill-quality-base/scripts/<name>.sh` → run this skill's script.

## The core idea: a skill is an optimizable artifact

Improving a skill from real execution is a training loop. The mapping is exact,
and every skill-quality-optimize phase is one part of it:

| Training loop | skill-quality-optimize | Owned by |
|---------------|----------------|----------|
| Training data | success/failure-labeled **trajectories** (the skill run on real tasks) | `skill-quality-evaluate` |
| Loss function | the **verification signal** scoring each deliverable | `skill-quality-evaluate` |
| Gradient + learning rate | proposed **text edits** and their controlled magnitude | `skill-quality-improve` |
| Parameters | the skill's `SKILL.md` (+ references) | the edited artifact |
| Training step + regularization + held-out gate | propose → gate → accept/revert | `skill-quality-optimize` (orchestrator) + `gate.sh` |

## Four laws (why the machinery exists)

These come from the failure modes observed across the skill-optimization research
(SWE-Skills-Bench, Trace2Skill, OpenSkill, SkillOpt). Each maps to a mechanism
this family enforces — do not shortcut them:

1. **The verifier is the whole game.** An imprecise verification signal makes
   iteration *degrade* quality, not improve it (OpenSkill: a ~57%-precision
   self-verifier drove pass rate down 82.7% → 78.0% over more rounds). If you
   cannot build a signal that mechanically discriminates good output from bad,
   **do not run the quantitative path** — use `skill-quality-review` for a
   qualitative assessment. See `references/verification-signals.md`.
2. **Isolate the oracle; gate on held-out.** Edits are proposed from *train*
   trajectories; whether an edit is kept is decided only by its score on a
   *held-out* task split the improver never sees. Training on your test set
   manufactures overfitting. `gate.sh` is the sole writer of accept/revert.
3. **Regularize: keep only edits that recur.** A correction seen in a single
   trajectory is likely a fluke; adopt an edit only when it addresses a failure
   that recurs across **≥2 train trajectories** (Trace2Skill). One-off
   corrections do not become rules.
4. **Bound the edit magnitude.** Big edits early, small edits as scores plateau;
   reject any candidate that does not *strictly* beat the current best on
   held-out (ties rejected, per SkillOpt). The budget caps iterations so the loop
   always terminates.

## Run layout & state

A run lives in one directory. `state.json` is the bookkeeping + gate record; the
agent writes the human-readable artifacts (versions, traces, evals) around it.
Full schema, layout, and stop conditions: `references/state-schema.md`.

```
<run-dir>/
  state.json           # bookkeeping + gate decisions (scripts own this)
  signal.md            # the verification signal definition (human-readable)
  versions/vN/         # candidate skill snapshots (v0 = baseline copy)
  traces/vN/<split>/   # per-task execution traces with pass/fail labels
  evals/               # per-version, per-split scored results
```

## Scripts (shell, agent-agnostic)

POSIX-ish `bash` (works on macOS's bash 3.2). The runtime scripts depend on **`jq`**
and check for it up front. They follow the same default-fail discipline: the
mechanical parts are script-enforced, never model-asserted.

- `scripts/init.sh` — scaffold `state.json` from the target skill, the
  train/held-out split, and the signal kind.
- `scripts/record.sh` — record a version's pass/fail results on a split and
  compute its score. Pure recorder.
- `scripts/gate.sh` — set the v0 baseline, then for each candidate decide
  accept (strictly beats best on held-out) or reject/revert, advance the budget,
  and recompute status. **The only sanctioned writer of accept decisions.**
- `scripts/test.sh` — exercise the split-isolation, complete-recording, and gate
  preconditions. Run it when changing the loop scripts.

See `references/state-schema.md` for exact invocations of the loop scripts.

## Graceful fallback

If this base skill is unavailable, inline the same behavior: keep the run-dir
layout, hand-maintain `state.json` with the same fields, split tasks into
train/held-out, propose edits only from train traces, and accept a candidate only
after its recorded held-out score is *strictly greater* than the current best —
never by judgment alone.
