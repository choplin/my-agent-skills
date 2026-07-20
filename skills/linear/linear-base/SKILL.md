---
name: linear-base
description: Foundation of the Linear skill family and the agent's home for ad-hoc issue work — defines how the agent treats Linear's model (Project / Milestone / Cycle / Issue / Sub-issue / Label / Status / Priority), owns the full issue lifecycle (create, groom, comment, transition status, close), and holds the shared "resolve repo → active Project" procedure that `linear` / `linear-start` / `linear-groom` build on. Not a slash command; the agent auto-invokes it whenever creating, grooming, triaging, updating, or closing Linear issues/projects, or when deciding how to structure work in Linear. Triggers on "Linear issue", "add to Linear", "triage the backlog", "groom this issue", "Linearに積む", "Issueを作って", "Linearで管理". Should NOT trigger for non-Linear trackers (Jira → jira-cli; GitHub Issues → github tools), or for git/PR mechanics (git-helpers).
user-invocable: false
---

# Linear operating conventions

This skill defines **how work is structured and managed in this Linear workspace**. The agent owns the full issue lifecycle — capturing, grooming, commenting, moving through statuses, and closing. Follow Linear's recommended semantics rather than fighting the tool.

**Context:** a solo, single-person workspace (one team). Team-collaboration features (assignee routing, velocity across a team) carry little value here and are deliberately skipped. Optimize instead for a two-tier authoring model: an expensive model (Opus/Fable) grooms issues into self-complete work orders, and a cheaper model (Sonnet) executes the implementation ones by reference. Not every issue fits the cheap-executor mould — design and research issues stay on the expensive model to execute; the **Type** label carries that signal so an executor can pick issues matching its capability (see Label groups). Everything below serves that model.

The MCP field names referenced (`state`, `project`, `milestone`, `parentId`, `blockedBy`/`blocks`/`relatedTo`, `labels`, `priority`) are stable Linear API fields; use whichever Linear MCP server is wired.

## Model mapping

How each Linear primitive is treated here:

| Primitive | Treatment | Why |
|---|---|---|
| **Team** | Single team. Don't create more. | Solo workspace; extra teams only buy separate issue-ID prefixes, not needed. |
| **Project** | A **finite outcome/goal** with a target ("ship X"), not a repo or a permanent bucket. Always tagged with its repo via the **Repo** project-label group (required; single-select — `1 Project = 1 repo`). | Linear projects have target dates and a completed state; a permanent project makes all of that formless. A project must be able to *complete*. The mandatory Repo tag makes "which repo does this outcome target" directly queryable. |
| **Milestone** | Phases **within** a project. Use only when a project has distinct stages. | Structure only when it earns its keep; skip for small projects. |
| **Cycle** | **Not used** (leave disabled). | Solo velocity tracking has little value; priority + status already order work. |
| **Issue** | The unit of work. **1 Issue = 1 atomic deliverable** — for implementation that is **1 PR = 1 branch**; for design it is 1 decision (ADR), for research 1 document. Always **self-complete** (see below). | Keeps each deliverable reviewable and lets a context-free executor pick up any Todo. |
| **Sub-issue** | Avoid by default. Use **only** to group a small multi-PR effort (see grouping). | Prevents needless hierarchy; solo work rarely needs it. |
| **Label** | Issues: two single-select groups, **Type** (deliverable kind — also drives executor-model choice) and **Repo**. Projects: a **Repo** project-label group (single-select), **required on every Project**. See Label groups. | Cheap, queryable classification; single-select keeps each axis unambiguous. A Project targets one repo (multi-repo projects are rare and out of this model). |
| **Status** | Keep the 6 defaults; each carries a distinct machine-meaning (see Lifecycle). | The agent maintains status, so granularity costs nothing and aids agent decisions. |
| **Priority** | Used simply: 1=Urgent, 2=High, 3=Medium, 4=Low, 0=None. | Lightweight ordering signal. |
| **Estimate** | **Not used.** | Point estimation has no payoff solo. |

## Issue authoring standard (self-completeness)

This is the core requirement. An issue that is ready to work (**Todo**) must be workable by an agent that has **no prior conversation context** — it starts and finishes from the issue alone. This is what makes the "Opus grooms → Sonnet executes" split work.

A Todo-ready issue's description must contain:

- **What & why** — the change and the reason it's wanted, in enough detail to act without asking.
- **Where** — the repo (Repo label) and the relevant files/areas/entry points, named concretely.
- **Acceptance** — how "done" is judged, in terms of the issue's deliverable: for an implementation, the expected behavior plus the check to run (test/command) when one exists; for a design, the decision recorded; for research, the question answered. There must be a concrete, checkable notion of done.
- **Constraints** — anything that would otherwise be guessed wrong (APIs to use/avoid, patterns to follow, out-of-scope items).

Self-check before moving an issue to Todo: *could a fresh agent open only this issue and produce the intended PR without further questions?* If no, it stays in Backlog and needs more grooming.

Backlog issues carry no such bar — capture them roughly. The bar is applied at the Backlog→Todo grooming step, not at capture.

## Grouping & ordering — two independent axes

When work spans multiple PRs, two separate decisions apply. They are **orthogonal** — decide each independently.

### Axis 1 — Grouping (how to bundle), choose one by size

| Size of the coherent work | Bundle with |
|---|---|
| Single (finishes in one PR) | **Nothing** — just one Issue. |
| Small, but a few dependent PRs | **Parent Issue + Sub-issues** (each sub = 1 PR). This is the sanctioned exception to "avoid sub-issues". |
| A distinct outcome/goal | **Project** (add **Milestones** if it has stages). |

### Axis 2 — Ordering (execution sequence), orthogonal, add only when needed

When PRs have an order (B can't start until A merges), express it with a **`blocked by`** relation (`B blocked by A`) — **not** hierarchy. This lets the executor mechanically find "not blocked = pickable" issues.

Axis 1 and Axis 2 coexist: e.g. two Issues in the same Project with one `blocked by` the other.

```
Work splits into multiple PRs?
  ├─ Is it a self-contained outcome/goal?
  │     ├─ YES → Project (Milestones if staged)
  │     └─ NO  → Parent Issue + Sub-issues
  └─ Do the PRs have a start order (A→B)?
        └─ YES → add "B blocked by A" (combine with either above)
```

## Lifecycle & status transitions

Statuses and their machine-meaning:

| Status | type | Means |
|---|---|---|
| **Backlog** | backlog | Captured, not yet groomed / not ready to start. |
| **Todo** | unstarted | Groomed & self-complete — an executor can pick it up now. |
| **In Progress** | started | Actively being worked (branch exists). |
| **In Review** | started | PR is open / under review. |
| **Done** | completed | Merged / shipped. |
| **Canceled** | canceled | Dropped, or superseded (e.g. promoted into a Project). |

Transitions (who/when):

- **→ Backlog**: whenever an idea/task appears. Rough content is fine.
- **Backlog → Todo**: the **grooming step** (below). The gate where self-completeness and true size are settled.
- **Todo → In Progress**: work starts / branch created.
- **In Progress → In Review**: PR opened. **Leave a completion note first** (see below).
- **In Review → Done**: PR merged. (Review requesting changes → back to In Progress.) If Done is reached with **no** In Review step, leave the completion note at this transition instead.
- **In Progress → (session boundary, stays In Progress)**: not a status change, but a checkpoint. When work on an issue **spans sessions** and this session ends before the issue finishes, **leave a handoff note** (see below) so a fresh session can resume it.
- **any → Canceled**: dropped or superseded. Use Canceled, never Done, for work that wasn't actually completed.

### Completion note (record what was decided & changed)

**Required, not optional.** When an issue leaves active work into **In Review** — or jumps **straight to Done** where there is no review step — leave a comment on the issue recording, in the issue's own terms:

- **What was decided** — the choices made *while working* that the groomed issue didn't already fix: the approach taken, alternatives rejected, scope trimmed or added, and anything that deviated from the plan and why.
- **What was changed** — the actual deliverable: for `impl`, what the PR does; for `design`, the decision reached; for `research`, the finding.

Rationale: commit messages and PR text describe only the change and carry **no** Linear references (see *Linear references stay internal*), so the *why* and the delta-from-spec have no home outside the issue. This comment makes the issue a durable, self-contained record of how the work actually resolved — the completion-side counterpart to the self-completeness bar applied at grooming.

Keep it proportional: an issue that shipped exactly as groomed needs a sentence; one where the approach shifted needs the decisions spelled out. When nothing deviated from the groomed plan, **say so explicitly** rather than omitting the note.

### Handoff note (record in-progress context for a cross-session pickup)

The completion note's mid-work sibling. When an issue is **still In Progress** and a session ends before it finishes — the work is large enough to span sessions — leave a comment recording, in the issue's own terms, enough for a **fresh session with no memory of this one** to resume the *same* issue:

- **Why / 経緯 / discussion** — the path that led to where the work now stands.
- **Decisions made while working** — each with its rationale and the alternatives rejected (the same "why" the completion note captures, but recorded mid-flight).
- **Open questions** — what is still undecided.
- **Current state & next step** — where the work actually stands, and the first concrete action a resumer should take.

Record only what a fresh reader **cannot reconstruct from git and the tracked artifacts**. Do **not** re-describe the diff (git holds it) or transcribe local execution state — `state.json`, exec-plan files, and loop artifacts are read directly on resume (see `linear-start` step 5 and `dev-workflow-resume-work`). The note carries the judgement those files cannot.

The issue **stays In Progress** — a handoff note is not a status transition. The `linear-handoff` skill drives this end-to-end (identify issue → align → draft → verify self-completeness → post as a comment).

**Corollary — cross-session work must be an issue.** Because the note's anchor is the issue comment, a discussion or task that has grown to span sessions but is **not yet a Linear issue** is itself in a bad state: create the issue first (there is no local-file handoff fallback), then hand it off. This is why there is no separate "continue this discussion" mechanism — the durable place for anything worth carrying across sessions is the issue.

## The grooming step (Backlog → Todo)

Grooming is where a rough Backlog item becomes a ready Todo. Three things are settled here, together:

1. **Self-completeness** — bring the description up to the authoring standard above.
2. **True size** — decide whether it's really one deliverable, or splits into several.
3. **Deliverable type** — set the **Type** label (`impl`/`design`/`research`), which fixes both the atomic-deliverable unit and which model will execute the issue.

If grooming reveals the work is **multiple PRs**, apply the grouping rule — and note the asymmetry in *how* to convert:

- **Splits into a small multi-PR effort → promote the issue to a parent (don't close it).** The original Issue becomes the parent; add sub-issues under it. Its ID, history, and description are preserved.
- **Turns out to be a distinct outcome → build a Project (Issues can't convert to Projects).** Create the Project, move the original's content into the Project description, then create the constituent Issues. Dispose of the original:
  - Nothing references it yet (typical at Backlog) → **Canceled + link to the Project** (not Done — it wasn't completed), or reuse it as the Project's first Issue.
  - Something already references its ID (branch name, notes) → **reuse it**: move it into the Project as one of the constituent Issues.

Rule of thumb: **sub-issue split = promote (keep the issue); Project split = rebuild (Cancel+link or reuse)** — because parent/child is mutable but Issue→Project conversion doesn't exist.

## Label groups

Two single-select groups (a Linear label group makes its members mutually exclusive — right for "exactly one per axis"):

- **Type** (one per issue) — the issue's **deliverable kind**, which also drives which model executes it:
  - `impl` — deliverable is a PR (code). Convergent, groomable to self-completeness → executes on the **cheap** model (Sonnet).
  - `design` — deliverable is a decision/ADR. Divergent, judgement-heavy → executes on the **expensive** model (Opus/Fable).
  - `research` — deliverable is a document/findings. Exploratory → executes on the **expensive** model.

  The executor **picks the issues that match its capability**: a cheap-model session takes `impl`, an expensive-model session takes `design`/`research`. Start with these three; add a Type only when a recurring deliverable is a genuinely different artefact from PR/decision/document (e.g. a throwaway `spike`), never merely to describe a variation of one. A documentation change that ships as a PR (README etc.) is `impl`; an independent design/research document is `design`/`research`.
- **Repo**: which repository work targets. In Linear, issue labels and project labels are **separate namespaces**, so this axis is maintained as a **`Repo` group in each**:
  - **On issues** (single-select group, one per issue) — the repo an issue's deliverable lands in. `1 issue = 1 repo`.
  - **On Projects** (single-select `Repo` group, **required on every Project**) — the one repo the outcome targets. `1 Project = 1 repo`; multi-repo projects are rare and deliberately out of this model. This is what lets a repo resolve directly to its active Project(s) (see **Resolving the current repo's active Project(s)** below).

  **The agent cannot create project labels.** The Linear MCP exposes issue-label *creation* and project-label *assignment*, but not project-label creation — a new repo's Repo project-label must be created once in the Linear UI. When a needed one is missing, ask the user to create it, then assign it. Issue Repo labels the agent creates itself. Add the matching label in both namespaces as new repos appear.

**Exception — `deep` override (defer until observed):** `impl` defaults to the cheap model, but some implementations need deep judgement despite producing a PR. Rather than a new Type, mark these with a single non-grouped **`deep`** label that overrides the executor choice back to the expensive model. This is an **exception patch, not a primary axis** — introduce it only once real usage shows how often `impl` issues actually need it; until then leave it out and rely on Type alone.

Branch/PR linkage is **not** a label — individual branches/PRs attach to their issue via Linear's Git integration (or a manual `links` attachment). The Repo label answers "which repo"; the Project/parent answers "which effort"; the git link answers "which branch". Don't encode branches as labels.

### Initial setup

Create the issue label groups (`isGroup: true`, then members with `parent: <group>` — both supported by the label-create MCP tool):

1. Create the issue **Type** group and its 3 members (`impl` / `design` / `research`).
2. Create the issue **Repo** group; add a member per active repository on demand.
3. Create the **Repo** project-label group in the project-label namespace (mirror the issue Repo group and its members). **This is a manual UI step — the MCP cannot create project labels.** Every Project must carry exactly one Repo label; when a repo's label is missing, ask the user to add it in the UI.

## Resolving the current repo's active Project(s)

Several skills (`linear` (the overview), `linear-start`, `linear-groom`) begin by resolving the repository they run in to the Linear Project(s) that target it. That resolution — and its edge cases — is defined **once here**; those skills reference this section and add only what they do with the result.

**Step A — repo → Repo label.** Derive the repo name from the current git repository (`git remote get-url origin` basename with any `.git` stripped, else the repo-root directory name). Match it to a member of the **Repo** label group (case-insensitive).

- Exactly one match → use it silently.
- No match, or ambiguous → **ask** the user which Repo label applies (don't guess). If the repo has no label yet, offer to add its issue Repo label (the agent can create issue labels).

**Step B — Repo label → active Project(s).** List the Projects tagged with the **Repo project-label = R** whose state is **active** — not `completed` and not `canceled`. Every Project carries exactly one Repo tag (`1 Project = 1 repo`), so the repo resolves to its active Project(s) directly.

- **The `Repo/R` project-label doesn't exist yet** → the agent **cannot create project labels** (see Label groups). Ask the user to create the `Repo/R` project-label in the Linear UI and tag the relevant Project(s) with it, then continue. (Once-per-repo setup.)
- **No active Project carries R** → say so and stop; offer to create a Project or groom the backlog.

The result is a set of **0, 1, or many** active Projects. **What to do with multiple is the caller's choice:** `linear-start` / `linear-groom` act on a single Project (auto-select when there's exactly one, ask the user when there are several); `linear` (the overview) reports on all of them.

## Linear references stay internal

Linear is this workspace's internal tracker. **Never write Linear references — issue IDs (e.g. `ENG-123`), issue/project URLs — into work products**: commit messages, files committed to a repository, branch/worktree names, or PR titles/descriptions. Those artifacts persist outside Linear and are read by people and tools without workspace access, where the reference is dead weight at best and leaks internal context at worst.

Keep the work↔issue link in the other direction — on the Linear side or in local-only state:

- **Linear side**: attach the branch/PR to the issue via the Git integration or a `links` attachment on the issue.
- **Local side**: worktree notes (`wtm add -m`, see `linear-start`), `state.json.linear_issue_id` (dev-workflow), or session context.

When exporting issue content into a repo (e.g. a spec/plan → `docs/`), carry the content but strip issue IDs/URLs from it.

## Deferred (out of scope for this base skill)

The following are intentionally *not* covered here:

- **Mapping to the `dev-workflow` family** — now **owned by `dev-workflow`**: an Epic
  is a **Project**, a Story is an **Issue** (its description holds the spec + plan;
  `state.json.linear_issue_id` links back). `dev-workflow-create-spec`/`create-epic`
  create or adopt them following this skill's conventions. See the `dev-workflow-base`
  skill (`references/state-schema.md` § Linear backing).
- Linking to `git-helpers` / PR flow. (Where Linear references may and may not appear is already settled above — they stay internal.)
- Linear ⇄ GitHub native integration setup.

This skill defines the vocabulary and rules those skills build on.
