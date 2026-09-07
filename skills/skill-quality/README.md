# skill-quality

The normative standard for good skills, plus the tools that review conformance and
measure or optimize behavior. Skill-authoring workflows use the standard while
creating content; this family does not own their intent-capture or drafting flow.

## Problem

"Good" depends first on what a skill contributes. `skill-quality-standard`
identifies whether its value comes from capability uplift, encoded intent, or both,
distinguishes guidance, workflow coordination, and task execution, then
calibrates each part as interpretive, coordinated, or deterministic. It does not
force one content shape onto every skill.

After that classification, two separate assessment paths answer different
questions:

- **Qualitative path (normal)** — the model applies the standard with judgment to
  the skill text, its context, and observable deliverables. `skill-quality-review`
  returns evidence-backed findings rather than a score or guarantee.
- **Quantitative path (conditional)** — when a reproducible mechanical pass/fail signal
  can be defined before the run, `skill-quality-evaluate` measures performance on
  real tasks and `skill-quality-optimize` may improve that measurement.

And "just iterate on it" is not safe: when the thing judging the output is
unreliable, iterating *degrades* quality rather than improving it.

## Architecture

The paths share artifacts, not verdicts. The qualitative review applies the
common standard and only the role guidance relevant to the target. The
quantitative path is a specialized option for outcomes with a real mechanical
boundary; it reports only what its named task set and signal measure. Neither
result is converted into the other.

| Path | Owner | Question | Availability |
|---|---|---|---|
| Qualitative standard | `skill-quality-standard` | What properties should a good skill have? | Always |
| Qualitative review | `skill-quality-review` | How well does this skill satisfy those properties in context? | Default |
| Quantitative evaluation | `skill-quality-evaluate` / `-optimize` / `-improve` | What pass rate does this fixed mechanical signal observe? | Requires a reproducible checker with high practical setup cost |

A faithful mechanical proxy for useful, coherent, well-judged output is difficult
to construct, which gives the quantitative path a high practical setup threshold.
Model judgment belongs in review and never enters the quantitative gate. The loop
remains mechanical-only because an imprecise signal driven repeatedly makes output
worse (`skill-quality-base` law 1).

## Current usage

The qualitative path is currently the routine path in this repository. The
quantitative path is currently used infrequently. This is an observation about
present usage, separate from its eligibility rule and setup cost.

## Components

### Skill: `skill-quality-standard`

The role-aware standard for good skill content. It owns the initial
classification, common requirements, role-specific guidance, loadability
preflight, anti-patterns, description guidance, and optional instruction
patterns. Authoring, review, and improvement refer to it by name rather than
carrying independent definitions of quality.

### Skill: `skill-quality-optimize`

The orchestrator of the mechanical loop. Runs evaluate → improve → gate over an
existing skill until the held-out score plateaus or the budget is spent. Requires a
working skill, real tasks, and a mechanical verification signal.

| Training loop | skill-quality-optimize |
|---------------|------------------------|
| Training data | success/failure-labeled traces from running the skill |
| Loss function | a mechanical **verification signal** (oracle or executable anchor) |
| Gradient + learning rate | proposed text edits at a controlled magnitude |
| Parameters | the skill's `SKILL.md` |
| Step + regularization + held-out gate | propose → gate → accept/revert |

### Skill: `skill-quality-evaluate`

The quantitative path: run a skill on real tasks, score each deliverable
against a predetermined reproducible checker, and report the pass rate and failing
traces. If judgment by a model is required, use review instead.

### Skill: `skill-quality-improve`

One improvement step: cluster failures across train traces, adopt only recurring
ones, apply minimal edits at the budgeted magnitude, emit a candidate version. It
keeps every candidate conformant with `skill-quality-standard`.

### Skill: `skill-quality-review`

One advisory review pass — findings, never a gate or a loop. **Static** classifies
the target and applies the relevant parts of `skill-quality-standard`. Optional **family** mode
reconstructs caller → delegate → reference → deliverable paths to find unused
contract data, duplicated ownership, repeated context, and historical residue
across cooperating skills. Optional **deliverable** mode runs the skill on a few
real tasks and reads the outputs qualitatively. When the deliverable can't be
observed, it does static only and says so. This is the normal quality-assessment
path.

### Skill: `skill-quality-base`

The quantitative optimization substrate: the training-loop model, run-directory
and `state.json` schema, four laws, verification-signal policy, and the
agent-agnostic shell+jq scripts `init.sh` (scaffold), `record.sh` (score), and
`gate.sh` (the sole writer of accept/reject).

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README. See
[docs/skill-first-architecture.md](../../docs/skill-first-architecture.md) for
the distribution model.

## Which to use

- **Author or revise skill content** → apply `skill-quality-standard`.
- **Assess a skill's quality** → `skill-quality-review` by default.
- **A reproducible mechanical checker exists and a pass rate is wanted** →
  `skill-quality-evaluate`.
- **Review before shipping** → `skill-quality-review` (static always; add family
  mode for cooperating skills or repository scope, and the deliverable read when
  observable).
- **Autonomously tune a measured outcome** → `skill-quality-optimize` — *only*
  with a working skill, real tasks, and a reproducible mechanical pass/fail
  signal. Model judgment stays in review.

## License

MIT
