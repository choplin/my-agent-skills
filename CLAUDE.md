# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is a collection of **agent-agnostic [Agent Skills](https://agentskills.io)**, distributed via the `vercel-labs/skills` CLI. It is not an executable application — skills are markdown + optional resources loaded by coding agents. See [`docs/skill-first-architecture.md`](./docs/skill-first-architecture.md) for the full model.

## Structure

```
skills/<group>/<group>-<skill>/SKILL.md   # portable skills (source of truth)
scripts/validate-skills.sh                # strict skill-validator check
docs/                                     # architecture, policy, and design principles
```

Key conventions (details in the architecture doc):
- **Namespace by prefix.** No namespace exists in the standard or the CLI, so skill `name` = `<group>-<skill>` (the leaf dir matches `name`; the `<group>/` folder is organization only). A group's root skill may keep the bare group name.
- **Portable SKILL.md.** No plugin-root paths or `${CLAUDE_PLUGIN_ROOT}`; share across skills by delegating to a base skill by name; cross-skill references use the full prefixed name.
- **Skills only.** Nothing is distributed outside a skill directory: no separately-installed subagent, command, or hook, and no installer. A capability that would need one is written as a skill that runs inline on any agent; a host-side wrapper, if an environment wants one, lives in that environment and may hold nothing the skill needs. Host-specific *presentation* metadata may travel inside a skill (`agents/openai.yaml`).
- **Docs.** Every `docs/*.md` carries `created` / `updated` frontmatter (no dated filenames) and ends with a `## History` section — newest first, one entry per substantive change, stating what changed and why. History is where the past lives, so the body can describe only the current state: no "previously / no longer / used to" in the body.
- **Runtime & dependencies.** Default to bash+jq; escalate runtime (Python/Node) only by fit, declare it in a leaf-bundled `flake.nix`, and resolve it in a preflight (PATH → `nix develop` → aggregated fail). Full policy: [`docs/skill-runtime-and-dependencies.md`](./docs/skill-runtime-and-dependencies.md).
- **Descriptions.** Two independent settings, neither inferred from the other: `user-invocable: false` when no real situation has the user typing `/name`, and `metadata.description-role` (`trigger` / `documentation`) for whether the description must make the model choose the skill. `disable-model-invocation` is never set — blocking fails silently when a caller or standing instruction needs the skill, and a `Skill(name)` deny rule stops what must not run — so every description stays in context and `documentation` means *shorter*, not free. Descriptions are English only. How to write one: the `skill-quality-base` skill (`references/writing-descriptions.md`).

## Recommended Skills

When working in this repository, actively use these skills:

| Skill | Use When |
|-------|----------|
| `/skill-quality-review` | Reviewing or improving an existing skill's quality (static rubric + deliverable read). Autonomously tune with skill-quality-optimize |
| `/plugin-dev:skill-development` | Skill file structure and formatting |
| `/plugin-dev:agent-development` | Creating subagents |
| `/plugin-dev:command-development` | Creating slash commands |
| `/plugin-dev:hook-development` | Creating hooks (PreToolUse, PostToolUse, etc.) |
| `/plugin-dev:plugin-structure` | Understanding plugin directory layout |
| `/plugin-dev:create-plugin` | End-to-end plugin creation workflow |

## Commit Convention

Use the skill group as the commit scope when a change is limited to one group.
Omit the scope for repository-wide changes.
