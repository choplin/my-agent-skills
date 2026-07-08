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

## Naming / namespace convention

Neither the Agent Skills standard nor the vercel CLI provides skill namespacing
(verified 2026-06-23: the standard `name` is a flat slug with no slash/scope, and
in-spec proposals #109/#312 and CLI PRs #250/#1464 are all unmerged; the CLI
installs flat to `.agents/skills/<name>` and same-name skills overwrite). So we
namespace by **baking a `<group>-` prefix into the flat `name`**:

- Skill `name` = `<group>-<skill>` (e.g. `dev-workflow-create-spec`). The
  group's "root" skill may keep the bare group name (e.g. `skill-authoring`).
- **An opt add-on under `opts/<agent>/skills/<name>` must not reuse any portable
  skill's `name`.** Both mechanisms install to `<agent-home>/skills/<name>`, so
  whichever runs last silently wipes the other — the skills CLI recreates the
  whole skill dir on every `skills add`, uninstalling the add-on's hooks
  (observed live with goal-loop, 2026-07-04). This bites exactly when a group
  keeps a bare-name root skill *and* ships a same-named opt plugin; suffix the
  add-on dir instead (e.g. `goal-loop-addon`). `install-opts.sh` enforces this:
  it refuses names that match a portable skill and refuses to write through a
  skills-CLI-managed symlink.
- Directory layout keeps the group folder: `skills/<group>/<group>-<skill>/`
  (the leaf equals `name`, so it stays spec-conformant; the `<group>/` folder is
  for repo organization only and is discarded on install).
- **Cross-skill references use the full prefixed name** — a tool-side `--prefix`
  cannot rewrite references inside skill bodies, so this is necessarily an
  author-side convention.
- Forward-compatible: if the standard later adopts slash namespaces (#109-style
  `name: group/skill`), migration is renaming `-` to `/`.
- Claude-Code subagents in `opts/` keep the real plugin namespace
  (`dev-workflow:acceptance-reviewer`); only flat skills need the prefix.

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

5. **When a required capability is absent, a skill does one of three things**,
   depending on how replaceable the capability is:
   - **fallback** — equivalent path exists, full behavior preserved. The subagent
     case: the `opts/<agent>/agents/` wrapper is only for isolation; the logic
     lives in the portable skill and runs inline (convention #4).
   - **degrade** — only an enhancement is missing, core still runs. The hook case:
     host-side enforcement (`stop-gate`, `session-start`) can't be re-created in
     prose, so it drops while the guidance remains.
   - **abort** — capability is essential and irreplaceable. Declare it as a
     *capability* prerequisite (not an agent name), probe it where possible, and
     stop before any side effect if absent.

6. **Graceful degradation is a prose convention, not a mechanism.** The Agent
   Skills standard has no feature-detection or conditionals. Capability-aware
   wording ("under Claude Code you may dispatch …; otherwise apply inline")
   relies on the host model honoring it. Expect to refine this with real use.

7. **Runtime & dependency handling has its own policy.** How a skill may depend
   on a runtime (bash+jq default, Python/Node by fit), declares it in a
   leaf-bundled `flake.nix`, and resolves it at run time (preflight → PATH else
   `nix develop` else aggregated fail) is specified in
   [skill-runtime-and-dependencies.md](./skill-runtime-and-dependencies.md).

## Rollout (incremental, non-destructive until validated)

- **Step 0** — scaffold `skills/`, `opts/`, `scripts/install-opts.sh`, this doc. ✅
- **Step 1** — pilot **skill-authoring** end-to-end (skill + extracted
  `skill-authoring-quality-review` skill + thin `opts/claude/agents/` wrapper). ✅
  Discovery validated with `skills add ./skills --list`.
- **Step 2** — migrate **dev-workflow**. ✅
  - 13 skills → `skills/dev-workflow/`; shared `references/` + `workflow-state.py`
    + `workflow-concepts.md` → `dev-workflow-base` skill (delegated by name).
  - `acceptance-reviewer` / `plan-compliance-reviewer` → `dev-workflow-acceptance-review` /
    `dev-workflow-plan-compliance-review` skills + thin wrappers in the Claude add-on.
  - hooks → the **minimal plugin** `opts/claude/skills/dev-workflow/` (with
    `.claude-plugin/` + `hooks/` + a symlink to the base skill's
    `workflow-state.py`). Claude Code v2.1.157 auto-loads plugins placed under
    `~/.claude/skills/`, so `${CLAUDE_PLUGIN_ROOT}` resolves and hooks need no
    rewrite. Placing the plugin there also preserves the `dev-workflow:` namespace
    for the reviewer subagents.
- **Step 3** — migrate the remaining plugins. ✅ Done: discuss-toolkit,
  discussion-continuity, git-helpers, jira-cli, lang-reference, writing-toolkit,
  ai-council (advisor agents → flat group-prefixed agents under `opts/claude/agents/`).
  **moonbit was dropped**, not migrated — it was a vendored submodule of upstream
  `moonbitlang/skills`, which is directly installable (`skills add moonbitlang/skills`,
  9 skills, already `moonbit-*` namespaced and more current than our snapshot).
  Plugin format retired: removed all `.claude-plugin/` manifests and the root
  `marketplace.json`; refreshed the root `README.md` and `CLAUDE.md`.

All groups are now skill-first. Top level is just `skills/`, `opts/`, `scripts/`,
`docs/`.

## Notes / open issues

- dev-workflow's state tracking is intrinsically Claude-Code-specific (it uses
  `$CLAUDE_CODE_SESSION_ID` and the hooks). Other agents get the portable
  workflow guidance; the session-binding mechanics degrade gracefully.
- Cross-skill delegation phrasing (`` `dev-workflow-base` skill (`references/X`) ``,
  `dev-workflow-base/scripts/...`) is a convention, not a spec mechanism — refine
  with real use.
- Running the skills CLI / `install-opts.sh` against real agent homes is validated
  in real use; the repo structure and discovery (`skills add ./skills --list`)
  are validated here.
