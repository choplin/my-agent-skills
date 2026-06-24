# skill-authoring

Create skills whose **content** an agent can actually act on — grounded in real expertise, economical with context, and self-evaluable.

## Problem

Standard skill creation focuses on format and structure. Skills made that way often contain generic advice ("write clean code", "follow best practices") that an agent already knows and cannot act on — they look correct but produce disappointing results.

## Solution

This group distills the [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices) into a working guide, organized around two independent axes:

| Axis | What it covers |
|------|----------------|
| **Layer A — Authoring lifecycle** | Where content comes from (ground in real expertise → draft → refine from execution traces) |
| **Layer B — Content quality** | What goes in the skill: context economy, why & concrete criteria, self-evaluable output, triggering description, calibrated control |

It complements `plugin-dev:skill-development`, which owns file structure and formatting. Load both together when authoring.

## Components

### Skill: `skill-authoring`

The content-quality guide (Layers A and B) plus a pre-ship quality checklist. Triggers when you want to create or improve a skill, or a skill isn't producing expected results.

References (loaded on demand):
- `references/instruction-patterns.md` — concrete templates for gotchas, output templates, checklists, validation loops, plan-validate-execute, and bundled scripts
- `references/anti-patterns.md` — common content failure modes with detection cues
- `references/agentskills-best-practices.md` — the upstream source these guidelines distill

### Skill: `skill-authoring-quality-review`

A portable review procedure that evaluates a target skill against the content-quality guidelines (B1–B5). Use after creating a skill or when one isn't producing expected results.

### Agent (Claude Code): `skill-authoring-quality-reviewer`

A thin subagent wrapper that runs `skill-authoring-quality-review` in an isolated context. Agent-specific add-on under `opts/claude/`.

## Installation

Skills are distributed via the [vercel-labs/skills](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills add choplin/my-agent-skills --skill 'skill-authoring' --skill 'skill-authoring-quality-review'
```

Install the Claude Code subagent wrapper with:

```bash
scripts/install-opts.sh claude
```

See [docs/skill-first-architecture.md](../../docs/skill-first-architecture.md) for the distribution model.

## Recommended workflow

1. **Ground & draft** — apply `skill-authoring` (Layer A1: extract from a real task or existing artifacts; dig as fallback) and write the content (Layer B), alongside `plugin-dev:skill-development` for structure.
2. **Validate** — run the pre-ship checklist and `skill-authoring-quality-review` (or dispatch the `skill-authoring-quality-reviewer` subagent under Claude Code).
3. **Refine** — run the skill against a real task, read the execution trace, and fold every correction back in — especially into the Gotchas section (Layer A3).

## License

MIT
