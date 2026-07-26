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

## Validate

Install [`skill-validator`](https://github.com/agent-ecosystem/skill-validator)
and run the repository-wide strict check:

```bash
brew tap agent-ecosystem/tap
brew install skill-validator
make validate-skills
```

The validator checks every `skills/<group>/<skill>/SKILL.md`. The
`user-invocable` frontmatter and the `agents/` and `schema/` directories are
explicitly allowed repository extensions; all other warnings fail the check.

The Nix development shell provides `lefthook`. Enter it directly, or allow
direnv to load it automatically:

```bash
nix develop
# or: direnv allow
```

Then enable this repository's pre-commit hook once:

```bash
lefthook install
```

GitHub Actions runs the same command for pushes and pull requests that change
skills or validation configuration.

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
| `dev-workflow` | kickoff, create-epic/spec/plan, self-review, user-review, acceptance-review, plan-compliance-review, resume-work, post-task, base |
| `review-tools` | ai-review, import-pr, import-ci, resolve, reply-pr, report, base (portable review process: a review.md record of items fed by ingestion sources — AI review / PR / CI / direct — and worked to resolution; used by dev-workflow and other flows) |
| `inception` | inception, inception-base, framing, diverge, structure, deepen, converge, quick, finalize (shape a fuzzy idea into a footing: PRD / decisions / actions) |
| `exec-plan` | exec-plan, exec-plan-base (rough-goal autonomous plan; decision log + parking lot) |
| `dispatch` | dispatch-work (separates intent clarification, concept shaping, candidate pressure-testing, human-gated work, autonomous work, and direct implementation) |
| `linear` | linear, linear-base, linear-groom, linear-start, linear-handoff (Linear issue lifecycle; start picks an issue — new or In Progress — → worktree → execution; handoff records a cross-session pickup note) |
| `skill-quality` | skill-quality-optimize, skill-quality-evaluate, skill-quality-improve, skill-quality-review, skill-quality-base (measure / review / autonomously optimize an existing skill; mechanical loop + one-shot advisory review) |
| `ai-council` | ai-council, ai-council-codex-cli, ai-council-fugu-cli |
| `discuss-toolkit` | dig (intent fidelity), grill-me (candidate robustness), one-point (discussion pacing) |
| `git-helpers` | commit, draft-pr, explain-pr, pr-description, rebase-onto-rewritten, squash-merge |
| `writing-toolkit` | critical-review, fact-check, objective-review, revise-document |
| `lang-reference` | go, java, python, rust, scala, sql, typescript |
| `app-reference` | backend, frontend (application-specific architecture and framework recommendations) |
| `jira-cli` | jira-cli |
| `showcase-capture` | plan, terminal, browser, screen (plan app/tool demo media; capture each planned shot on its appropriate surface) |
| `product-showcase` | readme (create or improve the product front door: value, proof, first success, and routes to deeper documentation) |
| `codebase-structure` | codebase-structure, codebase-structure-refactor (model code around concepts, types, invariants, and ownership; safely refactor existing code toward that structure) |
| `refactoring-tools` | refactoring-tools-planner (inspect a repository and create an evidence-based, implementation-ready refactor plan without changing production code) |

> MoonBit skills are **not** vendored here — install them straight from upstream: `skills add moonbitlang/skills`.

## Skill dependencies

Skills delegate to each other **by name** (a prose convention, not a resolved
manifest — see the architecture doc). This catalog lists only skills that depend
on another; everything else is standalone. **Bold** marks a **cross-group**
dependency — the edges that matter when installing a partial set. `(ext)` is a
skill not vendored in this repo. Within a group, `base` is that group's `*-base`.

**Cross-group hubs** (one skill that many groups delegate to):

- `discuss-toolkit-dig` ← dispatch-work, grill-me, dev-workflow-kickoff, inception (+framing/deepen), inception-quick, exec-plan, review-tools-resolve
- `grill-me` ← dispatch-work
- `dev-workflow-kickoff` ← dispatch-work
- `inception` / `exec-plan` ← dispatch-work (shaping/execution routing; native `/goal` is host-provided)
- `review-tools` (ai-review, resolve, report) ← dev-workflow (self-review, user-review)

**dev-workflow**
- kickoff → create-spec, create-epic, **discuss-toolkit-dig**
- create-spec → base, create-plan
- create-epic → base, create-spec
- create-plan → base, resume-work
- resume-work → base, create-plan, self-review, user-review, post-task
- self-review → base, plan-compliance-review, **review-tools-ai-review**
- user-review → acceptance-review, create-spec, post-task, **review-tools-resolve**, **review-tools-report**

**inception**
- inception → base, framing/diverge/structure/deepen/converge, finalize, **discuss-toolkit-dig**
- inception-quick → inception, **discuss-toolkit-dig**, **dispatch-work**
- inception-finalize → llm-wiki-base `(ext)`, **linear**, **dispatch-work**
- inception-framing → **discuss-toolkit-dig**
- inception-deepen → **discuss-toolkit-dig**
- inception-converge → finalize

**exec-plan**
- exec-plan → base, **discuss-toolkit-dig**

**review-tools**
- ai-review → base, code-review `(ext)`
- import-pr → base
- import-ci → base
- resolve → base, **discuss-toolkit-dig**
- report → base

**git-helpers**
- draft-pr → pr-description
- explain-pr → understanding-explain-diff `(ext; explainer-studio)`
- squash-merge → commit

**linear**
- linear-start → linear, **dispatch-work**, **dev-workflow-resume-work**, **exec-plan**, wtm-worktree `(ext)`
- linear-groom → linear

**skill-quality**
- skill-quality-optimize → base, skill-quality-evaluate, skill-quality-improve, skill-quality-review, skill-creator `(ext)`
- skill-quality-evaluate → base
- skill-quality-improve → base
- skill-quality-review → base

**ai-council**
- ai-council → ai-council-codex-cli, ai-council-fugu-cli
- ai-council-fugu-cli → ai-council-codex-cli

**product-showcase**
- readme → **showcase-capture-plan** (when useful README media is missing and the user wants it produced)

**codebase-structure**
- codebase-structure → **app-reference-\<kind\>**, **lang-reference-\<language\>** when matching installed skills exist

**app-reference**
- backend → **lang-reference-rust** when Rust is selected

**standalone**
- dispatch-work → **discuss-toolkit-dig**, **grill-me**, **inception**, **exec-plan**, **dev-workflow-kickoff**; native `/goal` is a host command
