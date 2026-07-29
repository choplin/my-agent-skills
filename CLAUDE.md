# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository is a collection of **agent-agnostic [Agent Skills](https://agentskills.io)**, distributed via the `vercel-labs/skills` CLI, plus Claude-Code-specific add-ons. It is not an executable application — skills are markdown + optional resources loaded by coding agents. See [`docs/skill-first-architecture.md`](./docs/skill-first-architecture.md) for the full model.

## Structure

```
skills/<group>/<group>-<skill>/SKILL.md   # portable skills (source of truth)
opts/<agent>/...                           # agent-specific add-ons (subagents, hooks)
scripts/install-opts.sh                    # distributes opts/ per agent
docs/                                      # research + decision records
```

Key conventions (details in the architecture doc):
- **Namespace by prefix.** No namespace exists in the standard or the CLI, so skill `name` = `<group>-<skill>` (the leaf dir matches `name`; the `<group>/` folder is organization only). A group's root skill may keep the bare group name.
- **Portable SKILL.md.** No plugin-root paths or `${CLAUDE_PLUGIN_ROOT}`; share across skills by delegating to a base skill by name; cross-skill references use the full prefixed name.
- **Agent-specific = opt-in.** Subagents/hooks live under `opts/` and install via `install-opts.sh`. A group that needs hooks ships a minimal opt-plugin (whose subagents stay `<group>:`-namespaced); agent-only groups distribute flat, group-prefixed agents.
- **Runtime & dependencies.** Default to bash+jq; escalate runtime (Python/Node) only by fit, declare it in a leaf-bundled `flake.nix`, and resolve it in a preflight (PATH → `nix develop` → aggregated fail). Full policy: [`docs/skill-runtime-and-dependencies.md`](./docs/skill-runtime-and-dependencies.md).
- **Descriptions.** `metadata.description-role` says whether a description must work as a trigger. `trigger` → write it positively, include the phrasings the request actually uses, and add an exclusion only after observing a real mistrigger. `documentation` → drop trigger phrasings and keep it short; every description stays in context, since `disable-model-invocation` is never set. **Never redirect** — no "use X instead", no sibling names; skills install one at a time, and a workflow member states only that it is a part, with the relationships in the body. Say what the skill is for rather than what it is not, and write descriptions in English only. Full policy, including how the two invocation settings are decided: [`docs/skill-description.md`](./docs/skill-description.md).

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
