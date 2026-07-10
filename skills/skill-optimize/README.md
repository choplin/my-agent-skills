# skill-optimize

Improve a skill the way you train a model: **run it, measure it, edit it, keep only
what verifiably helps** — as a bounded, autonomous loop.

## Problem

Authoring produces a skill; it doesn't prove the skill *works*. Empirically, most
don't: a survey of 49 public skills (SWE-Skills-Bench) found 39 gave no pass-rate
lift, and a few made things worse. Static review catches bad *writing*, but only
running the skill on real tasks reveals whether it changes outcomes — and naive
"just iterate on it" can degrade quality when the thing judging the output is
unreliable.

## Solution

Treat a skill as an optimizable artifact and drive a training loop over it:

| Training loop | skill-optimize |
|---------------|----------------|
| Training data | success/failure-labeled traces from running the skill |
| Loss function | a mechanical **verification signal** (oracle / anchor / self-criteria) |
| Gradient + learning rate | proposed text edits at a controlled magnitude |
| Parameters | the skill's `SKILL.md` |
| Step + regularization + held-out gate | propose → gate → accept/revert |

Four laws keep it honest (details in `skill-optimize-base`): the verifier caps
quality, so no signal → no loop; propose edits from *train* traces and accept only
on a *held-out* split; adopt only edits that recur across trajectories; bound edit
magnitude and reject ties.

It complements `skill-authoring` (which owns *what good content is*) — the improve
step delegates content judgment to it. This group adds the empirical, executable
measurement and iteration machinery.

## Components

### Skill: `skill-optimize`

The orchestrator. Runs the full evaluate → improve → gate loop over an existing
skill until the held-out score plateaus or the budget is spent. Requires a working
skill, real tasks, and a mechanical verification signal.

### Skill: `skill-optimize-evaluate`

The loss step, **also useful standalone**: run a skill on real tasks, score each
deliverable against a verification signal, and report a pass rate with the failing
traces. Use it to baseline a fresh draft or audit an existing skill.

### Skill: `skill-optimize-improve`

One improvement step: cluster failures across train traces, adopt only recurring
ones, apply minimal edits at the budgeted magnitude, and emit a candidate version.

### Skill: `skill-optimize-base`

Shared model: the training-loop mapping, the run-directory + `state.json` schema,
the four laws, and the agent-agnostic shell+jq scripts `init.sh` (scaffold),
`record.sh` (score), and `gate.sh` (the sole writer of accept/reject decisions).

## Installation

Skills are distributed via the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills add choplin/my-agent-skills \
  --skill 'skill-optimize' --skill 'skill-optimize-evaluate' \
  --skill 'skill-optimize-improve' --skill 'skill-optimize-base'
```

See [docs/skill-first-architecture.md](../../docs/skill-first-architecture.md) for the distribution model.

## When (not) to use

- **Use** when you have a working skill, real tasks, and a mechanical way to judge
  its output pass/fail.
- **Don't use** to author a skill from scratch (`skill-authoring` +
  `plugin-dev:skill-development`), for static content review
  (`skill-authoring-quality-review`), or when the deliverable's quality is a human
  judgment call with no mechanical signal — there is nothing to optimize against,
  and iterating anyway makes it worse.

## License

MIT
