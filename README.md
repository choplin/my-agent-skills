# my-agent-skills

A personal collection of **agent-agnostic [Agent Skills](https://agentskills.io)**.

Skills are the only primitive here — distributed to any coding agent via the [`vercel-labs/skills`](https://github.com/vercel-labs/skills) CLI. The repository is a catalog: it ships no agent-specific extras (subagents, hooks) and no installer.

> Design rationale and the full distribution model: [`docs/skill-first-architecture.md`](./docs/skill-first-architecture.md)

## Structure

```
skills/                      # portable, agent-agnostic skills (the source of truth)
  <group>/                   #   organized by group (former plugin name)
    <group>-<skill>/SKILL.md #   names are group-prefixed for namespacing
scripts/validate-skills.sh   # strict skill-validator check (used by lefthook and CI)
docs/                        # architecture, policy, and design principles
```

**Naming / namespace:** Neither the Agent Skills standard nor the skills CLI has a namespace mechanism (installs are flat by `name`; same names overwrite). So skills are namespaced by a `<group>-` prefix baked into the flat name (e.g. `orchestration-toolkit-execute`). See the architecture doc for details.

## Install

Works for Claude Code, Codex, Cursor, Kimi, and 70+ agents:

```bash
skills add choplin/my-agent-skills --list                            # browse
skills add choplin/my-agent-skills/skills/skill-quality --skill '*'  # one group
skills add choplin/my-agent-skills --skill orchestration-toolkit-execute
skills add ./skills --skill '*' -a claude-code codex -g -y           # this working tree
```

**A group is the unit to install.** Skills within a group delegate to each other by name and the standard resolves no dependencies, so picking individual skills can leave a broken subset. Point the source at `skills/<group>` to keep the group intact.

Installs are **copies**, not links into this repository: a global install lands in `~/.agents/skills/<name>/` with the agent's directory symlinked to it. **Edits here take effect only after re-running the install.** To drop skills again, `skills remove <name...> -g`.

Which skills an environment installs is decided outside this repository; there is no installer here.

## Validate

Install [`skill-validator`](https://github.com/agent-ecosystem/skill-validator)
and run the repository-wide strict check:

```bash
brew tap agent-ecosystem/tap
brew install skill-validator
scripts/validate-skills.sh
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

## Skill groups

| Group | Skills |
|-------|--------|
| `code-review-session` | import-ai, import-pr, import-ci, run-checks, resolve, reply-pr, report, base (the record of one code review: a review.md list of items fed by ingestion sources — AI review / PR / CI / local checks / direct — and worked to resolution) |
| `artifact-review-toolkit` | quick, adversarial (how a work artifact is reviewed: a one-off review redirected to the host's reviewer, or a lens-selected adversarial pass with independent reviewers; called by code-review-session and orchestration-toolkit) |
| `inception` | inception, inception-base, framing, diverge, structure, deepen, converge, finalize (shape a fuzzy idea into a footing: PRD / decisions / actions) |
| `design-note` | design-note (write down a problem and the approach taken to it as one durable llm-wiki note — lighter than a PRD, shallower than a design doc) |
| `exec-plan` | exec-plan, exec-plan-base (ad-hoc autonomous run with no tracker issue behind it; decision log + parking lot) |
| `linear` | linear, linear-base, linear-groom, linear-start, linear-handoff (Linear issue lifecycle; start picks an issue — new or In Progress — → worktree → execution; handoff records a cross-session pickup note) |
| `planning-toolkit` | plan, resolve, mvp, base (turn an established direction into a finite outcome and its delivery graph; resolve blocking research/design and make implementation autonomous-ready; `mvp` is a scope policy, not a phase — the smallest-build-that-teaches standard the cut is judged against) |
| `orchestration-toolkit` | execute, orchestrate (carry groomed Linear work to completion: one Issue inline, or a whole Project through delegated graph execution, mandatory global adversarial review, and final human approval) |
| `skill-quality` | skill-quality-optimize, skill-quality-evaluate, skill-quality-improve, skill-quality-review, skill-quality-base (measure / review / autonomously optimize an existing skill; mechanical loop + one-shot advisory review) |
| `ai-council` | ai-council, ai-council-codex-cli, ai-council-fugu-cli |
| `discuss-toolkit` | dig (intent fidelity), grill-me (candidate robustness), one-point (discussion pacing) |
| `git-helpers` | commit, draft-pr, explain-pr, pr-description, rebase-onto-rewritten, squash-merge |
| `document-toolkit` | review, fact-check, distill, trim (review or revise one document, verify its claims, rework a whole set: consolidate / refresh / split / retire, or strip content the set no longer needs) |
| `lang-reference` | go, java, python, rust, scala, sql, typescript |
| `app-reference` | backend, frontend (application-specific architecture and framework recommendations) |
| `jira-cli` | jira-cli |
| `showcase-capture` | plan, terminal, browser, screen, cleanshot-annotate, figma-annotate, pen-annotate (plan app/tool demo media; capture each shot on its appropriate surface; route planned annotations to a concrete editor workflow) |
| `product-showcase` | readme (create or improve the product front door: value, proof, first success, and routes to deeper documentation) |
| `codebase-structure` | codebase-structure, codebase-structure-review, codebase-structure-refactor, base (design a target structure; review ownership and boundaries without changing code; safely migrate an implementation; share the reviewability and boundary model) |
| `refactoring-tools` | refactoring-tools-planner (inspect a repository and create an evidence-based, implementation-ready refactor plan without changing production code) |
| `3d-print` | 3d-print, 3d-print-eufymake-cli (model a small printable object as parametric OpenSCAD; slice it from the CLI to trace a print warning back to the geometry that causes it) |

> MoonBit skills are **not** vendored here — install them straight from upstream: `skills add moonbitlang/skills`.

## Skill dependencies

Skills delegate to each other **by name** (a prose convention, not a resolved
manifest — see the architecture doc). This catalog lists only skills that depend
on another; everything else is standalone. **Bold** marks a **cross-group**
dependency — the edges that matter when installing a partial set. `(ext)` is a
skill not vendored in this repo. Within a group, `base` is that group's `*-base`.

**Cross-group hubs** (one skill that many groups delegate to):

- `discuss-toolkit-dig` ← grill-me, inception (+framing/deepen), design-note, exec-plan, code-review-session-resolve
- `linear-base` ← orchestration-toolkit (execute, orchestrate), planning-toolkit, inception-finalize
- `artifact-review-toolkit` (quick, adversarial) ← code-review-session (import-ai), orchestration-toolkit (execute, orchestrate)

**inception**
- inception → base, framing/diverge/structure/deepen/converge, finalize, **discuss-toolkit-dig**
- inception-finalize → llm-wiki-base `(ext)`, **linear-base**, **linear-start**
- inception-framing → **discuss-toolkit-dig**
- inception-deepen → **discuss-toolkit-dig**
- inception-converge → finalize

**design-note**
- design-note → llm-wiki-base `(ext)`, **discuss-toolkit-dig**, **planning-toolkit-plan**

**exec-plan**
- exec-plan → base, **discuss-toolkit-dig**

**code-review-session**
- import-ai → base, **artifact-review-toolkit-quick**, **artifact-review-toolkit-adversarial**
- import-pr → base
- import-ci → base
- run-checks → base
- resolve → base, **discuss-toolkit-dig**
- report → base

**artifact-review-toolkit**
- quick → code-review `(ext; host-provided)`

**git-helpers**
- draft-pr → pr-description
- explain-pr → diff-explainer `(ext; explainer-studio)`
- squash-merge → commit

**linear**
- linear-start → linear, **orchestration-toolkit-execute**, **orchestration-toolkit-orchestrate**, **exec-plan**, wtm-worktree `(ext)`
- linear-groom → linear

**planning-toolkit**
- plan → base, **discuss-toolkit-dig**, **linear-base**, llm-wiki-base `(ext)`, llm-wiki retrieval skills `(ext)`
- resolve → base, **discuss-toolkit-dig**, **linear-base**, llm-wiki-base `(ext)`, llm-wiki retrieval skills `(ext)`
- mvp → base, plan (a scope policy; it declares the standard and delegates the workflow)
- base → **linear-base**, llm-wiki-base `(ext)`

**orchestration-toolkit**
- execute → **artifact-review-toolkit-adversarial**, **linear-base**, **linear-handoff**, **git-helpers-commit**, llm-wiki-overview `(ext)`, llm-wiki-retrieve `(ext)`, wtm-worktree `(ext)`
- orchestrate → **artifact-review-toolkit-adversarial**, **linear-base**, **git-helpers-commit**, llm-wiki-overview `(ext)`, llm-wiki-retrieve `(ext)`, wtm-worktree `(ext)`

**skill-quality**
- skill-quality-optimize → base, skill-quality-evaluate, skill-quality-improve, skill-quality-review
- skill-quality-evaluate → base
- skill-quality-improve → base
- skill-quality-review → base

**ai-council**
- ai-council → ai-council-codex-cli, ai-council-fugu-cli
- ai-council-fugu-cli → ai-council-codex-cli

**product-showcase**
- readme → **showcase-capture-plan** (when useful README media is missing and the user wants it produced)

**codebase-structure**
- codebase-structure → base, codebase-structure-review, **app-reference-\<kind\>**, **lang-reference-\<language\>** when matching installed skills exist
- codebase-structure-review → base
- codebase-structure-refactor → base, codebase-structure-review; codebase-structure when the target is undecided; **lang-reference-sql** when SQL changes

**app-reference**
- backend → **lang-reference-rust** when Rust is selected
