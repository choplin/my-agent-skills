---
title: "Skill-First Distribution Architecture"
date: 2026-07-30
---

# Skill-First Distribution Architecture

How this repository is organized and distributed: capabilities are
**agent-agnostic skills first**, with agent-specific add-ons kept opt-in.

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
    <group>/                  #   organization + --list readability; discarded on install
      <skill>/SKILL.md        #   catalog layout: skills/<group>/<skill>/SKILL.md
      README.md               #   the group's inventory (every group has one)
  opts/                       # agent-specific add-ons. Distributed via scripts/install-opts.sh.
    claude/                   #   mirrors the ~/.claude/ subtree; one dir per agent
      agents/<name>.md        #     -> ~/.claude/agents/<name>.md
  scripts/install-opts.sh     # links opts/<agent>/* into each agent's config home
  scripts/uninstall-opts.sh   # removes them again (the inverse)
  scripts/validate-skills.sh  # runs skill-validator over the skills a commit touches
  docs/                       # research + decision records
```

Everything the repository ships is a portable skill, except one Claude Code
subagent (`opts/claude/agents/skill-quality-reviewer.md`). No group currently
ships hooks or a plugin, so `opts/` carries no `commands/` or `hooks/` subtree
and no agent other than `claude/` has a directory yet. That is an outcome, not a
policy: the conventions below still describe what to do when a group needs one.

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

- Skill `name` = `<group>-<skill>` (e.g. `orchestration-toolkit-execute`). The
  group's "root" skill may keep the bare group name (e.g. `inception`).
- **An opt add-on under `opts/<agent>/skills/<name>` must not reuse any portable
  skill's `name`.** Both mechanisms install to `<agent-home>/skills/<name>`, so
  whichever runs last silently wipes the other — the skills CLI recreates the
  whole skill dir on every `skills add`, uninstalling the add-on's hooks
  (observed live with a portable-skill/add-on collision, 2026-07-04). This bites
  exactly when a group keeps a bare-name root skill *and* ships a same-named opt
  plugin; suffix the add-on dir. `install-opts.sh` enforces this:
  it refuses names that match a portable skill and refuses to write through a
  skills-CLI-managed symlink.
- A group that needs hooks ships them as a **minimal plugin** under
  `opts/<agent>/skills/<name>/`. For Claude Code this works because the host
  auto-loads plugins placed under `~/.claude/skills/` (since v2.1.157), so
  `${CLAUDE_PLUGIN_ROOT}` resolves and the hooks need no rewriting. No group
  currently needs this.
- Directory layout keeps the group folder: `skills/<group>/<group>-<skill>/`
  (the leaf equals `name`, so it stays spec-conformant; the `<group>/` folder is
  for repo organization only and is discarded on install).
- **Cross-skill references use the full prefixed name** — a tool-side `--prefix`
  cannot rewrite references inside skill bodies, so this is necessarily an
  author-side convention.
- Forward-compatible: if the standard later adopts slash namespaces (#109-style
  `name: group/skill`), migration is renaming `-` to `/`.
- Subagents under `opts/<agent>/agents/` carry the same `<group>-` prefix as
  skills, because they install flat into a shared directory. A group that ships a
  minimal plugin is the exception: its subagents live inside the plugin and keep
  the real `<group>:<agent>` namespace instead.

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

4. **Subagents are opt-in.** Subagent invocation is not portable
   (see research). The pattern:
   - The behavior lives in a **portable skill** that works inline on any agent.
   - A **thin agent under `opts/<agent>/agents/`** wraps that skill for isolation
     (e.g. Claude Code subagent with `skills: [<skill>]`).
   - The calling skill says: use the agent's subagent if available; otherwise
     apply the skill inline. This "fallback procedure" is itself the skill.

   **The wrapper may hold nothing the skill needs.** A fallback path is worthless
   if the knowledge required to walk it only exists in the wrapper — the skill
   then degrades into a broken procedure rather than a slower one. Anything the
   wrapper knows about *doing the work* (required flags, a host permission the
   call needs, a confirmation to obtain before sending data somewhere) belongs in
   the portable skill. What legitimately stays in the wrapper is only what the
   agent layer itself provides: isolation, a tool allowlist, a model choice.

   Judge the wrapper by that residue. If removing it would lose nothing but an
   output format, it is not carrying its keep — a subagent's descriptions are
   another routing surface to maintain, and one that host-specific conventions
   pull away from the repository's own.

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
