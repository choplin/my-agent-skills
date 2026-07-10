---
name: skill-quality-base
description: Shared resources for the skill-quality family — two domains. (1) The optimization training-loop model that treats a skill as optimizable parameters (trajectories = data, verification signal = loss, text edits = gradient, SKILL.md = parameters), the run-directory + state.json layout, the train/held-out isolation rule, the verifier-quality guard, and the agent-agnostic shell+jq scripts (init.sh, record.sh, gate.sh) that scaffold a run, record scores, and enforce the accept/reject gate. (2) The content-quality rubric (B1–B6) plus anti-patterns and instruction patterns that skill-quality-review scores a skill against and skill-quality-improve writes edits by. Other skill-quality skills delegate to this skill by name. Use this skill when a skill-quality skill asks to apply the state schema, the verification-signal taxonomy, the content-quality rubric, or run a base script. Not typically invoked on its own.
user-invocable: false
---

# skill-quality base resources

This skill owns the resources shared across the **skill-quality** family. Other
skill-quality skills **delegate to this skill by name** instead of referencing
plugin-root paths, so the same skills work whether installed flat by the skills
CLI or loaded as part of a plugin.

It holds **two independent domains**, used by different family members:

- **Optimization loop** (the run layout, four laws, and `init.sh`/`record.sh`/`gate.sh`) — used by `skill-quality-optimize`, `skill-quality-evaluate`, `skill-quality-improve`.
- **Content-quality rubric** (`references/content-quality-rubric.md`, `references/anti-patterns.md`, `references/instruction-patterns.md`) — the B1–B6 rubric for judging *what a skill says*. `skill-quality-review` scores against it; `skill-quality-improve` writes edits by it. This is orthogonal to the loop: reviewing text needs no run, no signal, no gate.

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
   **do not run the loop** — score once for a baseline and route the judgment to
   a human. See `references/verification-signals.md`.
2. **Isolate the oracle; gate on held-out.** Edits are proposed from *train*
   trajectories; whether an edit is kept is decided only by its score on a
   *held-out* task split the improver never sees. Training on your test set
   manufactures overfitting. `gate.sh` is the sole writer of accept/revert.
3. **Regularize: keep only edits that recur.** A correction seen in a single
   trajectory is likely a fluke; adopt an edit only when it addresses a failure
   that recurs across multiple train trajectories (Trace2Skill). One-off
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

## Scripts (shell + jq, agent-agnostic)

All three are POSIX-ish `bash` depending only on **`jq`** (each checks for it up
front and exits with a clear message if missing) — no Python, no per-host runtime.
They mirror goal-loop's discipline: the mechanical gate is script-enforced, never
model-asserted.

- `scripts/init.sh` — scaffold `state.json` from the target skill, the
  train/held-out split, and the signal kind.
- `scripts/record.sh` — record a version's pass/fail results on a split and
  compute its score. Pure recorder.
- `scripts/gate.sh` — set the v0 baseline, then for each candidate decide
  accept (strictly beats best on held-out) or reject/revert, advance the budget,
  and recompute status. **The only sanctioned writer of accept decisions.**

See `references/state-schema.md` for exact invocations.

## Graceful fallback

If this base skill is unavailable, inline the same behavior: keep the run-dir
layout, hand-maintain `state.json` with the same fields, split tasks into
train/held-out, propose edits only from train traces, and accept a candidate only
after its recorded held-out score is *strictly greater* than the current best —
never by judgment alone.
