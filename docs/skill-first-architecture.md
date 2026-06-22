---
title: "Skill-First Distribution Architecture"
date: 2026-06-22
type: decision
status: in-progress
tags:
  - architecture
  - agent-skills
  - distribution
---

# Skill-First Distribution Architecture

Decision record for restructuring this repository so its capabilities are
**agent-agnostic skills first**, with agent-specific features kept opt-in.

Background research: [2026-06-22-agent-skills-portability-research.md](./2026-06-22-agent-skills-portability-research.md).

## Goal

One source of truth that can be distributed to any coding agent:

- **Skills** are the portable primitive, distributed to every agent (including
  Claude Code) via the `vercel-labs/skills` CLI.
- **Agent-specific add-ons** (Claude Code subagents, commands, hooks; and the
  equivalents for other agents) are managed per-agent and installed directly
  into each agent's config location.

## Layout

```
repo/
  skills/                     # portable, agent-agnostic. Distributed via vercel CLI.
    <group>/                  #   group = former plugin name (organization + --list readability)
      <skill>/SKILL.md        #   catalog layout: skills/<group>/<skill>/SKILL.md
  opts/                       # agent-specific add-ons. Distributed via scripts/install-opts.sh.
    claude/                   #   mirrors ~/.claude/ subtree
      agents/<name>.md        #     -> ~/.claude/agents/<name>.md
      commands/ hooks/ ...
    codex/ kilo/ ...          #   one dir per agent
  scripts/install-opts.sh     # links opts/<agent>/* into each agent's config home
  docs/                       # research + decision records
```

## Distribution

| Target | Mechanism | Gets |
|--------|-----------|------|
| Claude Code | `npx skills add <repo>` (+ `scripts/install-opts.sh`) | portable skills (+ Claude subagents/commands/hooks from `opts/claude/`) |
| Other agents | `npx skills add <repo>` (+ `install-opts.sh` if that agent has opts) | portable skills (+ that agent's opts, if any) |

Skills install into each agent's skill directory (e.g. `~/.claude/skills/`).
`opts/` is **not** the skills CLI's job — `install-opts.sh` symlinks (default) or
copies (`--copy`) each `opts/<agent>/` subtree into that agent's config home.

## Authoring conventions

1. **SKILL.md must be portable.** Do not reference plugin-root paths (`../`,
   `references/state-schema.md` living outside the skill, `${CLAUDE_PLUGIN_ROOT}`).
   The same SKILL.md must work whether installed flat by the skills CLI or read
   in any agent.

2. **Bundle skill-local resources inside the skill.** A skill's own
   `references/`, `scripts/`, `assets/` travel with it (the skills CLI installs
   the whole skill directory). Reference them by skill-root-relative path.

3. **Share across skills by name, not by path (base/common skill).** When
   multiple skills need the same content or script, put it in one owner skill and
   have the others **delegate to it by name** ("apply the `<owner>` skill"). The
   owner reads/runs its own bundled files relative to its own root. There is no
   cross-skill path reference, and no spec-level dependency resolution, so:
   - Document the dependency in the dependent skill's description / the group README.
   - Write a graceful fallback for when the owner skill is absent.

4. **Subagents are opt-in.** Subagent invocation is not portable
   (see research). The pattern:
   - The behavior lives in a **portable skill** that works inline on any agent.
   - A **thin agent under `opts/<agent>/agents/`** wraps that skill for isolation
     (e.g. Claude Code subagent with `skills: [<skill>]`).
   - The calling skill says: use the agent's subagent if available; otherwise
     apply the skill inline. This "fallback procedure" is itself the skill.

5. **Graceful degradation is a prose convention, not a mechanism.** The Agent
   Skills standard has no feature-detection or conditionals. Capability-aware
   wording ("under Claude Code you may dispatch …; otherwise apply inline")
   relies on the host model honoring it. Expect to refine this with real use.

## Rollout (incremental, non-destructive until validated)

- **Step 0** — scaffold `skills/`, `opts/`, `scripts/install-opts.sh`, this doc. ✅
- **Step 1** — pilot **skill-authoring** end-to-end (skill + extracted
  `skill-quality-review` skill + thin `opts/claude/agents/` wrapper). ✅
  Discovery validated with `skills add ./skills --list`.
- **Step 2** — migrate **dev-workflow**. ✅
  - 13 skills → `skills/dev-workflow/`; shared `references/` + `workflow-state.py`
    + `workflow-concepts.md` → `dev-workflow-base` skill (delegated by name).
  - `acceptance-reviewer` / `plan-compliance-reviewer` → `acceptance-review` /
    `plan-compliance-review` skills + thin wrappers in the Claude add-on.
  - hooks → the **minimal plugin** `opts/claude/skills/dev-workflow/` (with
    `.claude-plugin/` + `hooks/` + a symlink to the base skill's
    `workflow-state.py`). Claude Code v2.1.157 auto-loads plugins placed under
    `~/.claude/skills/`, so `${CLAUDE_PLUGIN_ROOT}` resolves and hooks need no
    rewrite. Placing the plugin there also preserves the `dev-workflow:` namespace
    for the reviewer subagents.
- **Step 3** — migrate the remaining skills-only plugins (ai-council,
  discuss-toolkit, discussion-continuity, git-helpers, jira-cli, lang-reference,
  moonbit, writing-toolkit), then retire the plugin format and refresh the root
  README + `marketplace.json`.

## Notes / open issues

- `.claude-plugin/marketplace.json` and the root `README.md` are already stale
  (list removed plugins, wrong skill names). Refresh as part of Step 3.
- dev-workflow's state tracking is intrinsically Claude-Code-specific (it uses
  `$CLAUDE_CODE_SESSION_ID` and the hooks). Other agents get the portable
  workflow guidance; the session-binding mechanics degrade gracefully.
- Cross-skill delegation phrasing (`` `dev-workflow-base` skill (`references/X`) ``,
  `dev-workflow-base/scripts/...`) is a convention, not a spec mechanism — refine
  with real use.
- Running the skills CLI / `install-opts.sh` against real agent homes is validated
  in real use; the repo structure and discovery (`skills add ./skills --list`)
  are validated here.
