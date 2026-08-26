---
title: "Skill-First Distribution Architecture"
created: 2026-06-22
updated: 2026-08-03
---

# Skill-First Distribution Architecture

How this repository is organized and distributed: every capability is an
**agent-agnostic skill**.

The constraints these conventions answer to:
[agent-skills-portability.md](./agent-skills-portability.md).

## Goal

One source of truth that can be distributed to any coding agent:

- **Skills** are the only primitive this repository ships, distributed to every
  agent (including Claude Code) via the `vercel-labs/skills` CLI.
- **Agent-specific artifacts** (Claude Code subagents, commands, hooks; and the
  equivalents for other agents) are out of scope. A capability that would need
  one is written as a skill that runs inline on any agent.

## Layout

```
repo/
  skills/                     # portable, agent-agnostic. Distributed via vercel CLI.
    <group>/                  #   organization + --list readability; discarded on install
      [<family>/]             #   optional organization for a larger group
        <skill>/SKILL.md      #   leaf directory equals the skill name
      README.md               #   the group's inventory (every group has one)
  scripts/validate-skills.sh  # runs skill-validator over the skills a commit touches
  docs/                       # architecture, policy, and design principles
```

Everything the repository ships is a portable skill. The repository is a
catalog: it holds no installer, and nothing is distributed outside a skill
directory — which skills an environment installs is decided outside it. Skills
may bundle host-specific *presentation* metadata (`agents/openai.yaml`, an
interface hint for Codex-style hosts) and JSON schemas (`schema/`); the
validator allows both as repository extensions.

## Distribution

Every agent gets the same thing by the same mechanism: `npx skills add <repo>`,
which installs skills into that agent's skill directory (e.g. `~/.claude/skills/`).
A source may be narrowed to a single group by pointing at its subdirectory
(`<repo>/skills/<group>`), which is the unit selections should use — skills
within a group delegate to each other by name (convention 3).

## Naming / namespace convention

Neither the Agent Skills standard nor the vercel CLI provides skill namespacing
(see [agent-skills-portability.md](./agent-skills-portability.md)). So we
namespace by **baking a `<group>-` prefix into the flat `name`**:

- Skill `name` = `<group>-<skill>` (e.g. `orchestration-toolkit-execute`). The
  group's "root" skill may keep the bare group name (e.g. `inception`).
- Anything an environment places into `<agent-home>/skills/<name>` by other
  means must not reuse a skill's `name`. The skills CLI recreates the whole
  skill directory on every `skills add`, so whichever runs last silently wipes
  the other (observed live, 2026-07-04).
- Directory layout keeps the group folder and may add one organizational
  family/provider level: `skills/<group>/[<family>/]<namespaced-skill>/`. The
  leaf equals `name`, so it stays spec-conformant; directories above the leaf
  are discarded on install.
- **Cross-skill references use the full prefixed name** — a tool-side `--prefix`
  cannot rewrite references inside skill bodies, so this is necessarily an
  author-side convention.
- Forward-compatible: if the standard later adopts slash namespaces (#109-style
  `name: group/skill`), migration is renaming `-` to `/`.

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
   - Document the dependency in the dependent skill's body, where it can be
     stated as a prerequisite and checked at run time, and in the group README.
     Not in the `description`.
   - Write a graceful fallback for when the owner skill is absent.

4. **A skill never depends on subagent invocation.** Dispatching to a subagent
   is not portable ([why](./agent-skills-portability.md)), so the behavior lives in the skill and runs
   inline on any agent. A skill may say "dispatch this to an isolated agent if
   the host has one; otherwise apply it inline" — that fallback procedure is
   itself part of the skill.

   **A host-side wrapper is the consuming environment's, and may hold nothing
   the skill needs.** A fallback path is worthless if the knowledge required to
   walk it only exists in the wrapper — the skill then degrades into a broken
   procedure rather than a slower one. Anything about *doing the work* (required
   flags, a host permission the call needs, a confirmation to obtain before
   sending data somewhere) belongs in the skill. What legitimately stays in a
   wrapper is only what the agent layer itself provides: isolation, a tool
   allowlist, a model choice.

5. **When a required capability is absent, a skill does one of three things**,
   depending on how replaceable the capability is:
   - **fallback** — equivalent path exists, full behavior preserved. The subagent
     case: a host-side wrapper is only for isolation; the logic lives in the
     skill and runs inline (convention #4).
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

## Related policies

- **Descriptions** — what a `description` is for, and how the two invocation
  settings (`user-invocable`, `metadata.description-role`) are decided: the
  `skill-quality-base` skill (`references/writing-descriptions.md`), summarized in
  the repo `CLAUDE.md`. It lives with the skill that reviews descriptions rather
  than in `docs/`, so the reviewer loads it where it is applied.
- **Runtime & dependencies** — convention 7 above:
  [skill-runtime-and-dependencies.md](./skill-runtime-and-dependencies.md).

## Open issues

- Cross-skill delegation phrasing (`` `<group>-base` skill (`references/X`) ``,
  `<group>-base/scripts/...`) is a convention, not a spec mechanism — refine
  with real use.
- Upstream skill sets are installed from upstream, not vendored here. A vendored
  copy goes stale and re-namespaces what is already namespaced; prefer
  `skills add <owner>/<repo>` alongside this repo.

## History

- **2026-08-03** — Agent-specific add-ons (`opts/`) and their install scripts
  removed. The repository became a catalog: it ships only skill directories and
  no installer, and which skills an environment installs is decided outside it.
  A group is now stated as the unit of selection, since delegation between
  skills is unresolved by the standard.
- **2026-06-22** — Created, alongside the move from Claude Code plugins to
  portable skills.
