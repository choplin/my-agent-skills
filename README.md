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

**Everything at once** (skills + Claude-Code add-ons, via the Makefile):

```bash
make install        # = install-skills + install-opts, from this working tree
make help           # list all targets; SOURCE/AGENT/SKILL/SCOPE are overridable
```

`make install` symlinks skills from `./skills` for `claude-code` globally, so edits to this repo take effect without re-running. To install the published repo instead, override `SOURCE=choplin/my-agent-skills`.

Or run each piece directly:

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
| `dev-workflow` | kickoff, create-epic/spec/plan, self-review, user-review, acceptance-review, plan-compliance-review, handoff, resume-work, post-task, workflow-status, base |
| `review-tools` | ai-review, import-pr, import-ci, resolve, reply-pr, report, base (portable review process: a review.md record of items fed by ingestion sources — AI review / PR / CI / direct — and worked to resolution; used by dev-workflow and other flows) |
| `goal-loop` | goal-loop, goal-loop-base (Codex /goal-style bounded autonomous loop; shell + jq, hooks opt-in) |
| `inception` | inception, inception-base, framing, diverge, structure, deepen, converge, quick, finalize (shape a fuzzy idea into a footing: PRD / decisions / actions) |
| `exec-plan` | exec-plan, exec-plan-base, exec-plan-record (rough-goal autonomous plan; decision log + parking lot) |
| `dispatch` | dispatch-work (routes a new task to inception / goal-loop / exec-plan / dev-workflow-kickoff) |
| `linear` | linear, linear-groom, linear-start (Linear issue lifecycle; start picks an issue — new or In Progress — → worktree → execution) |
| `skill-quality` | skill-quality-optimize, skill-quality-evaluate, skill-quality-improve, skill-quality-review, skill-quality-base (measure / review / autonomously optimize an existing skill; mechanical loop + one-shot advisory review) |
| `ai-council` | ai-council, ai-council-codex-cli, ai-council-fugu-cli |
| `discuss-toolkit` | dig, name-project, quick-chat, focus (handle multiple discussion points one at a time) |
| `git-helpers` | branch-commit, draft-pr, explain-pr, pr-description, rebase-onto-rewritten |
| `understanding` | explain-diff (reviewer-facing HTML explanation of a diff; explain-pr publishes it for PRs), html-docs (shared web-doc design system; base for explain-diff) |
| `writing-toolkit` | critical-review, fact-check, objective-review, revise-document |
| `lang-reference` | go, java, python, scala, typescript |
| `discussion-continuity` | continue-discussion |
| `project-notes` | project-notes-capture, project-notes-distill, project-notes-base (raw→distilled project notes in an Obsidian vault) |
| `jira-cli` | jira-cli |

> MoonBit skills are **not** vendored here — install them straight from upstream: `skills add moonbitlang/skills`.

## Skill dependencies

Skills delegate to each other **by name** (a prose convention, not a resolved
manifest — see the architecture doc). This catalog lists only skills that depend
on another; everything else is standalone. **Bold** marks a **cross-group**
dependency — the edges that matter when installing a partial set. `(ext)` is a
skill not vendored in this repo. Within a group, `base` is that group's `*-base`.

**Cross-group hubs** (one skill that many groups delegate to):

- `discuss-toolkit-dig` ← dev-workflow-kickoff, inception (+framing/deepen), inception-quick, exec-plan, goal-loop, review-tools-resolve
- `dev-workflow-kickoff` ← dispatch-work, inception-quick, inception-finalize, goal-loop
- `inception` / `goal-loop` / `exec-plan` ← dispatch-work (execution-mode routing)
- `review-tools` (ai-review, resolve, report) ← dev-workflow (self-review, user-review)

**dev-workflow**
- kickoff → create-spec, create-epic, **discuss-toolkit-dig**, **goal-loop**, **exec-plan**
- create-spec → base, create-plan
- create-epic → base, create-spec
- create-plan → base, resume-work
- resume-work → base, create-plan, self-review, user-review, post-task
- self-review → base, plan-compliance-review, handoff, **review-tools-ai-review**
- user-review → acceptance-review, create-spec, post-task, **review-tools-resolve**, **review-tools-report**
- handoff → base, resume-work
- workflow-status → base, **linear**

**inception**
- inception → base, framing/diverge/structure/deepen/converge, finalize, **discuss-toolkit-dig**
- inception-quick → inception, **discuss-toolkit-dig**, **dev-workflow-kickoff**
- inception-finalize → **project-notes-base**, **linear**, **dev-workflow-kickoff**
- inception-framing → **discuss-toolkit-dig**
- inception-deepen → **discuss-toolkit-dig**
- inception-converge → finalize

**exec-plan**
- exec-plan → base, **discuss-toolkit-quick-chat**, **discuss-toolkit-dig**
- exec-plan-record → base

**goal-loop**
- goal-loop → base, **discuss-toolkit-dig**, **dev-workflow-kickoff**

**review-tools**
- ai-review → base, code-review `(ext)`
- import-pr → base
- import-ci → base
- resolve → base, **discuss-toolkit-dig**
- report → base

**git-helpers**
- draft-pr → pr-description
- explain-pr → **understanding-explain-diff**

**discuss-toolkit**
- name-project → dig

**project-notes**
- capture → base
- distill → base

**linear**
- linear-start → linear, **dispatch-work**, **dev-workflow-resume-work**, **exec-plan**, **goal-loop**, wtm-worktree `(ext)`
- linear-groom → linear

**skill-quality**
- skill-quality-optimize → base, skill-quality-evaluate, skill-quality-improve, skill-quality-review, skill-creator `(ext)`
- skill-quality-evaluate → base
- skill-quality-improve → base
- skill-quality-review → base

**ai-council**
- ai-council → ai-council-codex-cli, ai-council-fugu-cli
- ai-council-fugu-cli → ai-council-codex-cli

**understanding**
- explain-diff → html-docs

**standalone**
- dispatch-work → **inception**, **goal-loop**, **exec-plan**, **dev-workflow-kickoff**
