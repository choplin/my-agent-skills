# skill-quality

Tools to keep a skill's quality honest: **measure it, review it, and optimize it.**
Authoring a skill from scratch is out of scope — use whatever skill-creation path
your agent provides for that, then bring the result here.

## Problem

Authoring produces a skill; it doesn't prove the skill is any good. Empirically,
most aren't: a survey of 49 public skills (SWE-Skills-Bench) found 39 gave no
pass-rate lift, and a few made things worse. Two different failures hide here, and
they need different tools:

- **Bad content** — generic advice ("write clean code") the agent already knows,
  vague criteria, keyword-y descriptions. Visible by *reading* the skill.
- **No real effect** — the skill reads fine but doesn't change outcomes. Only
  visible by *running* it on real tasks.

And "just iterate on it" is not safe: when the thing judging the output is
unreliable, iterating *degrades* quality rather than improving it.

## Two tracks

The family splits along how "good" is decided — a high-trust autonomous loop, and
a one-shot advisory review — because their trust models are different.

| | **Optimize loop** | **Review** |
|---|---|---|
| Skills | `skill-quality-optimize` / `-evaluate` / `-improve` | `skill-quality-review` |
| Decides good via | a **mechanical** verification signal | a human reading **findings** |
| Autonomy | autonomous: gate + iterate, unattended | one-shot, advisory: no gate, no loop |
| Covers | skills with a machine-checkable deliverable | everything else (subjective output, no signal) + a cheap pre-check |
| Risk model | verifier precision caps quality (four laws) | can't compound — one pass, human decides |

Keeping the loop **mechanical-only** is deliberate: an imprecise signal driven in a
loop makes things worse (`skill-quality-base` law 1). The advisory reviewer is
where an LLM/static judgment belongs — run once, never gating, so it can't compound.

## Components

### Skill: `skill-quality-optimize`

The orchestrator of the mechanical loop. Runs evaluate → improve → gate over an
existing skill until the held-out score plateaus or the budget is spent. Requires a
working skill, real tasks, and a mechanical verification signal.

| Training loop | skill-quality-optimize |
|---------------|------------------------|
| Training data | success/failure-labeled traces from running the skill |
| Loss function | a mechanical **verification signal** (oracle / anchor / self-criteria) |
| Gradient + learning rate | proposed text edits at a controlled magnitude |
| Parameters | the skill's `SKILL.md` |
| Step + regularization + held-out gate | propose → gate → accept/revert |

### Skill: `skill-quality-evaluate`

The loss step, **also useful standalone**: run a skill on real tasks, score each
deliverable against a mechanical signal, report a pass rate with the failing
traces. Use it to baseline a fresh draft or audit an existing skill.

### Skill: `skill-quality-improve`

One improvement step: cluster failures across train traces, adopt only recurring
ones, apply minimal edits at the budgeted magnitude, emit a candidate version. It
writes edits by the content-quality rubric in `skill-quality-base`.

### Skill: `skill-quality-review`

One advisory review pass — findings, never a gate or a loop. Two modes that
degrade gracefully: **static** (score the `SKILL.md` against the B1–B6 rubric, no
run needed) and **deliverable** (run the skill on a few real tasks and read the
outputs qualitatively). When the deliverable can't be observed, it does static only
and says so. This is the home for skills the mechanical loop can't touch, and a
cheap sanity check before committing to a loop.

### Skill: `skill-quality-base`

Shared resources, two domains:
- **Optimization loop** — the training-loop model, the run-directory + `state.json`
  schema, the four laws, and the agent-agnostic shell+jq scripts `init.sh`
  (scaffold), `record.sh` (score), `gate.sh` (the sole writer of accept/reject).
- **Content-quality rubric** — `references/content-quality-rubric.md` (B1–B6),
  `anti-patterns.md`, `instruction-patterns.md`. What `skill-quality-review` scores
  against and `skill-quality-improve` writes edits by.

### Agent (Claude Code): `skill-quality-reviewer`

A thin subagent wrapper that runs `skill-quality-review` in an isolated context.
Agent-specific add-on under `opts/claude/`.

## Installation

Skills are distributed via the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills add choplin/my-agent-skills \
  --skill 'skill-quality-optimize' --skill 'skill-quality-evaluate' \
  --skill 'skill-quality-improve' --skill 'skill-quality-review' \
  --skill 'skill-quality-base'
```

Install the Claude Code subagent wrapper with:

```bash
scripts/install-opts.sh claude
```

See [docs/skill-first-architecture.md](../../docs/skill-first-architecture.md) for the distribution model.

## Which to use

- **Is this skill any good? / benchmark it** → `skill-quality-evaluate` (mechanical) or `skill-quality-review` (advisory).
- **Review before shipping** → `skill-quality-review` (static always; add the deliverable read when observable).
- **Autonomously tune a skill** → `skill-quality-optimize` — *only* with a working skill, real tasks, and a mechanical pass/fail signal. No signal → the loop makes it worse; review instead.

## License

MIT
