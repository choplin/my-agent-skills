---
title: "Agent Skills Portability — What the Standard and the CLI Provide"
created: 2026-06-22
updated: 2026-08-03
---

# Agent Skills Portability

The constraints this repository's conventions are derived from: what the Agent
Skills standard guarantees, what it leaves undefined, and how the
`vercel-labs/skills` CLI actually installs. The conventions themselves are in
[skill-first-architecture.md](./skill-first-architecture.md).

## The standard

Agent Skills is an open standard hosted at
[agentskills.io](https://agentskills.io/specification) and adopted by dozens of
coding agents. The portable primitive is a **self-contained skill directory**:
`SKILL.md` plus optional `scripts/`, `references/`, `assets/`.

Frontmatter is intentionally minimal:

- **Required**: `name` (max 64 chars, lowercase/digits/hyphens; `anthropic` and
  `claude` are reserved) and `description` (max 1024 chars).
- **Optional**: `license`, `compatibility`, `metadata`, `allowed-tools`
  (experimental).

`name` must match the skill's directory name, and file references are relative
to the skill root and kept one level deep.

## What the standard does not provide

**No namespace.** `name` is a flat slug with no scope or slash. Installs are
flat, and same-named skills overwrite each other. In-spec proposals (#109, #312)
and CLI PRs (#250, #1464) are unmerged. Hence the `<group>-` prefix baked into
each name.

**No subagent declaration or invocation.** There is no field to declare a
subagent and no portable way to dispatch to one. Claude Code documents subagent
execution as an *extension* to the standard, and implementations do not
interoperate — Claude Code uses Markdown+YAML subagent files invoked via
`subagent_type`, OpenCode uses `mode: subagent` agent files invoked via
`@`-mention, and the two field sets overlap only on `description`. The CLI's own
compatibility matrix shows `context: fork` supported in Claude Code alone. Hence
the rule that behavior lives in the skill and runs inline.

**No shared resources or dependency resolution.** Every skill is self-contained.
There is no shared directory, no dependency declaration, and no composition
mechanism; the package-manifest proposal (Discussion #210) is unmerged.
Duplication, symlinks, and a build step are all non-standard workarounds. Hence
delegation by name to a base skill, documented in the dependent skill's body.

**No feature detection or conditionals.** There is no mechanism for a skill to
branch on host capabilities. Capability-aware wording is prose that relies on
the host model honoring it.

**No agent targeting beyond prose.** The only targeting field is the optional
free-text `compatibility` (max 500 chars, no enumerated values), which the spec
says most skills do not need. Skills are agent-agnostic by default.

## How the skills CLI installs

Verified against the CLI in use:

- **Discovery walks `skills/<name>/SKILL.md`**, one level deep. A group folder
  is therefore organization only — it is discarded on install.
- **A source may be a repository subdirectory**: `skills add
  <owner>/<repo>/skills/<group>` narrows the source to that group. Local
  absolute paths work as sources too.
- **`--skill` takes multiple names as separate arguments** (`--skill a b`). A
  single quoted string containing spaces is treated as one name and fails.
- **Installs are copies, not links into the source.** A global install
  (`-g`) copies each skill into the shared store `~/.agents/skills/<name>/` and
  symlinks the agent's directory entry (e.g. `~/.claude/skills/<name>`) to the
  store. Editing the source repository therefore has no effect until the install
  is re-run.
- **Project scope** (no `-g`) copies into the project's agent directory (e.g.
  `./.claude/skills/`) and writes a `skills-lock.json` at the project root
  recording each skill's source and a content hash. A local-path source is
  recorded as an absolute path, so a lock produced that way is not portable.
- **`skills use <package>@<skill>`** generates a prompt for one skill without
  installing it.

## Consequences for this repository

- The repository is a catalog only: no installer, no agent-specific artifact.
  Which skills an environment installs is decided outside it.
- **A group is the unit of selection.** Skills within a group delegate to each
  other by name, and the standard resolves no dependencies, so selecting
  individual skills out of a group can silently install a broken subset.
  Pointing a source at `skills/<group>` keeps the unit intact.
- Cross-skill references must use the full prefixed name, since no tool-side
  rewriting reaches into skill bodies.
- If the standard later adopts slash namespaces, migration is renaming `-` to
  `/`.

## Sources

- [agentskills.io/specification](https://agentskills.io/specification)
- [Anthropic Agent Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [anthropics/skills](https://github.com/anthropics/skills)
- [code.claude.com/docs/skills](https://code.claude.com/docs/en/skills),
  [sub-agents](https://code.claude.com/docs/en/sub-agents)
- [opencode.ai/docs/agents](https://opencode.ai/docs/agents/)
- [vercel-labs/skills](https://github.com/vercel-labs/skills)

## History

- **2026-08-03** — Rewritten from a dated research report into a standing
  reference. The research framing (method, vote counts, refuted claims, open
  questions) and the plugin-marketplace material were dropped; the CLI's actual
  install behavior was measured and added — subdirectory sources, `--skill`
  argument splitting, copy-not-symlink installs, project scope and
  `skills-lock.json`.
- **2026-06-22** — Created as the research report behind the move to portable
  skills.
