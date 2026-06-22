---
title: "Agent Skills Cross-Agent Portability and Shared Resources — Research Report"
date: 2026-06-22
type: research
status: completed
tags:
  - agent-skills
  - vercel-labs-skills
  - claude-code
  - portability
  - shared-resources
---

# Research Report: Agent Skills Cross-Agent Portability and Shared Resources

**Date**: 2026-06-22
**Purpose**: To inform an "agent-skill-first / agent-specific-features opt-in" architecture for this repository (a collection of Claude Code plugins), as we look to also distribute its skills via the `vercel-labs/skills` CLI.
**Method**: deep-research (21 sources fetched → 95 claims extracted → top 25 claims adversarially verified with 3 votes each → 23 confirmed / 2 refuted). Confidence is high across the board (almost all 3-0 unanimous), with key claims resting on multiple primary sources.

---

## Foundation (settled)

Anthropic **published Agent Skills as an open standard on 2025-12-18** for cross-platform portability and donated it to the Linux-Foundation-backed Agentic AI Foundation. It is now hosted at [agentskills.io](https://agentskills.io/specification) and adopted by 17–72+ coding agents. A **self-contained skill directory (SKILL.md plus optional `scripts/`, `references/`, `assets/`) is the portable, agent-agnostic primitive**.

SKILL.md frontmatter is intentionally minimal:

- **Only two required fields**: `name` (max 64 chars, lowercase/digits/hyphens, reserved words `anthropic`/`claude` prohibited) and `description` (max 1024 chars).
- **Four optional fields**: `license`, `compatibility`, `metadata`, `allowed-tools` (Experimental).

Sources:
- [agentskills.io/specification](https://agentskills.io/specification) (primary)
- [Anthropic Agent Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) (primary)
- [anthropics/skills](https://github.com/anthropics/skills) (primary)
- [Anthropic engineering blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) (primary)

---

## 1. Subagent cross-agent portability → NOT portable (settled)

- **The standard has no subagent field.** There is no portable way to declare or invoke a subagent from within a skill. Claude Code's own docs state that subagent execution is an *extension* to the open standard ("Claude Code extends the standard with additional features like invocation control, subagent execution, and dynamic context injection").
- **Implementations are mutually non-interoperable**:
  - Claude Code: Markdown+YAML subagent files (14+ vendor-specific optional fields: `tools`, `model`, `permissionMode`, `isolation`, `skills`, etc.) invoked via `subagent_type`.
  - OpenCode: `mode: subagent` agent files invoked via `@`-mention / the Task tool.
  - The two field sets overlap only on `description`, and SKILL.md has no field to declare a subagent at all.
- **The vercel-labs/skills compatibility matrix confirms it**: the `context: fork` row is **Yes only in Claude Code** (1 Yes, 17 No across 18 agents).
- **There is no standard pattern for graceful degradation** (running optionally-subagent-using skills on agents without subagent support). The spec does not address it. In practice the only option is to write the skill so a single agent can do the work inline, treating subagent delegation purely as a Claude Code optimization.

Sources:
- [code.claude.com/docs/skills](https://code.claude.com/docs/en/skills) (primary)
- [code.claude.com/docs/sub-agents](https://code.claude.com/docs/en/sub-agents) (primary)
- [opencode.ai/docs/agents](https://opencode.ai/docs/agents/) (primary)
- [vercel-labs/skills README](https://github.com/vercel-labs/skills/blob/main/README.md) (primary)

---

## 2. Shared resources between skills → no standard (settled, but a proposal is in progress)

- **There is no mechanism for a shared/common directory, dependency declaration, or composition.** Every skill is self-contained, **the skill name must match its parent directory name**, and file references must be "relative paths from the skill root," kept "one level deep."
- The dependency-resolution proposal **Discussion #210 ("Skill Package Manifest for Dependency Resolution and Distribution") is unmerged**.
- Consequently, **duplication / symlinks / a build-generation step / a shared-skill-as-dependency are all non-standard workarounds** — none is established as "the" answer.
- Anthropic's own example skills follow the **self-contained model**: each skill bundles its own files (FORMS.md, REFERENCE.md, scripts/fill_form.py) and loads them on demand via bash.

Sources:
- [agentskills.io/specification](https://agentskills.io/specification) (primary)
- [Anthropic Agent Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview) (primary)
- [anthropics/skills](https://github.com/anthropics/skills) (primary)
- agentskills Discussion #210 (primary, unmerged proposal)

---

## 3. Skill-first / agent-agnostic architecture

- **Agent targeting is expressed only through the optional free-text `compatibility` field** (max 500 chars, no enumerated values). The spec itself says "Most skills do not need the compatibility field" and it "should only be included if your skill has specific environment requirements" → **agent-agnostic by default**.
- **The vercel-labs/skills CLI has no templating/conditional mechanism.** Agent differences are merely *documented* in a compatibility matrix.
- **Single-source distribution defaults to symlinks**: each agent's install location (e.g. `~/.claude/skills/`) is symlinked to one canonical copy at `~/.agents/skills/<skill>`. `--copy` produces real copies instead.
- **Known defect**: for `npx skills add -g -a claude-code` global installs, the symlink is not reliably created (issues #693/#744/#851). The symlink/single-source design is intended-but-not-fully-reliable today.

Sources:
- [vercel-labs/skills README](https://github.com/vercel-labs/skills/blob/main/README.md) (primary)
- [vercel-labs/skills issue #744](https://github.com/vercel-labs/skills/issues/744) (primary)
- [vercel-labs/skills issue #519](https://github.com/vercel-labs/skills/issues/519) (primary)
- [Vercel changelog](https://vercel.com/changelog/introducing-skills-the-open-agent-skills-ecosystem) (primary)

---

## Findings that directly affect this repository's plan

- **There is no established precedent for running one repository as BOTH a Claude Code plugin marketplace AND a vercel-skills source from a single source of truth** (this claim was refuted, 1-2). The notion that anthropics/skills demonstrates this was rejected. → The targeted setup is a **self-devised pattern**, not an ecosystem convention (not impossible, but with no reference exemplar to copy).
- The vercel CLI discovers skills by walking `skills/<name>/SKILL.md` one level deep. **Exposing the plugin's nested layout (`<plugin>/skills/<skill>`) as flat skill directories requires a build step or symlinks.**

---

## Refuted claims

- "The same anthropics/skills repository serves simultaneously as a Claude Code plugin marketplace and as a source of agent-agnostic skills, demonstrating the dual-distribution layout." → **refuted (1-2)** (insufficient evidence).
- "The symlink-vs-copy choice is only meaningful when multiple distinct target folders must be created." → **refuted (1-2)**.

---

## Open questions

1. Graceful degradation of optionally-subagent-using skills — the spec provides no mechanism (no conditional logic, no feature detection). Is the only portable option to write the skill so a single agent does the work inline, with subagent delegation as a Claude-Code-only optimization?
2. One repository serving both distribution models from a single source — no exemplar exists, and nesting → flat conversion needs a build step or symlinks.
3. If the skill-dependency / package-manifest proposal (Discussion #210) is adopted, current symlink/duplication workarounds for shared resources may become obsolete.
4. Subagent declaration/invocation in other major agents (Cursor, Cline, Amp, Roo, Kilo) was not individually verified; no sign of convergence toward a portable format, so fragmentation is expected to persist.
