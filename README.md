# my-agent-skills

A personal collection of **agent-agnostic [Agent Skills](https://agentskills.io)**, plus the Claude-Code-specific add-ons that layer on top of them.

Skills are the portable primitive — distributed to any coding agent via the [`vercel-labs/skills`](https://github.com/vercel-labs/skills) CLI. Agent-specific extras (subagents, hooks) are kept separate and installed per agent.

> Design rationale and the full distribution model: [`docs/skill-first-architecture.md`](./docs/skill-first-architecture.md)

## Structure

```
skills/                      # portable, agent-agnostic skills (the source of truth)
  <group>/                   #   organized by group (former plugin name)
    <group>-<skill>/SKILL.md #   names are group-prefixed for namespacing
opts/                        # agent-specific add-ons, installed per agent
  claude/
    agents/                  #   flat subagents  -> ~/.claude/agents/
    skills/dev-workflow/     #   a minimal plugin (hooks + namespaced subagents)
scripts/install-opts.sh      # distributes opts/<agent>/* into each agent's config
docs/                        # research + decision records
```

**Naming / namespace:** Neither the Agent Skills standard nor the skills CLI has a namespace mechanism (installs are flat by `name`; same names overwrite). So skills are namespaced by a `<group>-` prefix baked into the flat name (e.g. `dev-workflow-create-spec`). See the architecture doc for details.

## Install

**Skills** (works for Claude Code, Codex, Cursor, Kimi, and 70+ agents):

```bash
skills add choplin/my-agent-skills --list          # browse
skills add choplin/my-agent-skills --skill '*'     # install all
skills add choplin/my-agent-skills --skill dev-workflow-kickoff   # one
```

**Claude-Code add-ons** (subagents + dev-workflow hooks) — not carried by the skills CLI:

```bash
scripts/install-opts.sh claude        # symlink opts/claude/* into ~/.claude/
scripts/install-opts.sh --dry-run     # preview
```

## Skill groups

| Group | Skills |
|-------|--------|
| `dev-workflow` | kickoff, create-epic/spec/plan/task, self-review, user-review, acceptance-review, plan-compliance-review, handoff, resume-work, post-task, workflow-status, import/reply-pr-comments, base |
| `goal-loop` | goal-loop, goal-loop-base (Codex /goal-style bounded autonomous loop; shell + jq, hooks opt-in) |
| `skill-authoring` | skill-authoring, skill-authoring-quality-review |
| `ai-council` | ai-council, ai-council-codex-cli, ai-council-gemini-cli |
| `discuss-toolkit` | dig, name-project, quick-chat |
| `git-helpers` | branch-commit, draft-pr, pr-description, rebase-onto-rewritten |
| `writing-toolkit` | critical-review, fact-check, objective-review, revise-document |
| `lang-reference` | go, java, python, scala, typescript |
| `discussion-continuity` | continue-discussion |
| `jira-cli` | jira-cli |

> MoonBit skills are **not** vendored here — install them straight from upstream: `skills add moonbitlang/skills`.
