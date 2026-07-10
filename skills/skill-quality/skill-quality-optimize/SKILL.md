---
name: skill-quality-optimize
description: >-
  Autonomously improve an existing skill by running it as a training loop — evaluate it on real
  tasks against a mechanical verification signal, propose edits from the failure traces, and keep
  only edits that beat a held-out task split, iterating until the score plateaus or a budget is
  spent. Use when you have a working skill (not a blank draft), a set of real tasks, and a way to
  mechanically judge its output pass/fail, and you want the agent to drive the improvement loop.
  Triggers on "optimize this skill", "auto-improve this skill", "run the skill training loop",
  "tune this skill from traces", "スキルを自律最適化", "スキルを自動改善". Should NOT trigger for
  authoring a skill from scratch (use skill-creator), for advisory or static review (use
  skill-quality-review), or when the skill's quality cannot be judged mechanically (no usable
  verification signal — see skill-quality-base law 1).
user-invocable: true
---

# skill-quality-optimize: the skill training loop

Drive a bounded, autonomous **evaluate → improve → gate** loop over an existing
skill until its held-out score plateaus or the budget is spent. The skill's
`SKILL.md` is the parameter set; real task runs are the data; the verification
signal is the loss. Mechanism and laws live in `skill-quality-base` — load it.

## Preconditions (all three, or don't run)

1. **A working skill exists.** This tunes; it does not author. No draft → author
   it first (e.g. `skill-creator`), then tune here.
2. **Real tasks exist**, enough to split into train + held-out.
3. **A mechanical verification signal exists** (oracle / anchor / self-criteria).
   If the deliverable's quality is a human judgment call, **stop** — a loop with a
   signal that can't discriminate converges on worse output (base law 1). Run
   `skill-quality-evaluate` once for a baseline and hand the rest to a human.

If any precondition is unmet, say so and stop; do not fabricate tasks or a signal.

## The loop

Delegate each phase to its skill; use the base scripts for all bookkeeping and the
gate.

### Setup (once)

1. Confirm preconditions with the user; agree on the task set and signal.
2. `skill-quality-evaluate`: design the signal, `init.sh` the run, copy the skill
   to `versions/v0/`, evaluate **v0 on both splits**, `record.sh` both, then
   `gate.sh <dir> --set-baseline`.
3. If v0's held-out score already meets the goal, report and stop — nothing to do.

### Each iteration (until terminal status)

1. **Improve** — `skill-quality-improve` reads `traces/<current>/train/*` and
   emits `versions/v<next>/` with a changelog.
2. **Evaluate on both splits** — `skill-quality-evaluate` runs the candidate on
   **train and holdout**, `record.sh` both. Holdout decides the gate; the fresh
   train traces are the material the *next* improve step learns from (so an
   accepted version always has train traces ready). Comparing the two also exposes
   overfitting: train up while holdout flat means the edit fit the train tasks, not
   the domain.
3. **Gate** — `gate.sh <dir> --candidate v<next> --reason '<changelog>'`. The
   script accepts iff the candidate *strictly* beats the best held-out score, else
   reverts. Never override its decision.
4. Read back `status`. Loop while `running`.

### Terminal

- `converged` (`no_improve_streak` hit): the signal can't extract more, or the
  skill is at its ceiling. **Before trusting it, hand-spot-check a few held-out
  deliverables** — a plateau can also mean the verifier stopped discriminating
  (base law 1).
- `blocked` (budget spent): report the best version and its trajectory.

Either way the deliverable is `versions/<best.version>/`. Present a summary:
starting vs best held-out score, which edits were accepted (from `history`), and
your spot-check verdict. Get user approval before copying the best version back
over the real skill.

## Guardrails

- **Held-out isolation is absolute.** `improve` reads only train traces; accept is
  decided only by held-out score. This is what stops the loop from overfitting to
  its own traces.
- **The gate is mechanical.** `gate.sh` is the only thing that accepts an edit. If
  you find yourself wanting to keep an edit the gate rejected, your signal or your
  split is the problem — fix that, don't bypass the gate.
- **Degradation guard.** If accepted held-out gains don't track your own read of
  the deliverables improving, the verifier is too noisy — stop and strengthen the
  signal rather than iterating further.

## Composition

- `skill-quality-evaluate` — the loss step; also runs standalone to audit/baseline.
- `skill-quality-improve` — the gradient+update step.
- `skill-quality-base` — state schema, laws, scripts, and the content-quality
  rubric that `improve` writes edits by.
- `skill-quality-review` — advisory review (static rubric + deliverable read); a
  cheap pre-filter before committing to a run, and the home for skills this loop
  can't touch (no mechanical signal). `skill-creator` — authoring from scratch.
