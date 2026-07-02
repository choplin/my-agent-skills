---
name: linear
description: Operating conventions for managing work in this Linear workspace — how the agent treats Linear's model (Project / Milestone / Cycle / Issue / Sub-issue / Label / Status / Priority) and owns the full issue lifecycle (create, groom, comment, transition status, close). Use this skill whenever creating, grooming, triaging, updating, or closing Linear issues/projects, or when deciding how to structure work in Linear. Triggers on "Linear issue", "add to Linear", "triage the backlog", "groom this issue", "Linearに積む", "Issueを作って", "Linearで管理". Should NOT trigger for non-Linear issue trackers (Jira → jira-cli; GitHub Issues → github tools), or for git/PR mechanics (git-helpers).
user-invocable: true
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
| **Project** | A **finite outcome/goal** with a target ("ship X"), not a repo or a permanent bucket. | Linear projects have target dates and a completed state; a permanent project makes all of that formless. A project must be able to *complete*. |
| **Milestone** | Phases **within** a project. Use only when a project has distinct stages. | Structure only when it earns its keep; skip for small projects. |
| **Cycle** | **Not used** (leave disabled). | Solo velocity tracking has little value; priority + status already order work. |
| **Issue** | The unit of work. **1 Issue = 1 atomic deliverable** — for implementation that is **1 PR = 1 branch**; for design it is 1 decision (ADR), for research 1 document. Always **self-complete** (see below). | Keeps each deliverable reviewable and lets a context-free executor pick up any Todo. |
| **Sub-issue** | Avoid by default. Use **only** to group a small multi-PR effort (see grouping). | Prevents needless hierarchy; solo work rarely needs it. |
| **Label** | Two single-select groups: **Type** (deliverable kind — also drives executor-model choice) and **Repo** (see Label groups). | Cheap, queryable classification; single-select keeps each axis unambiguous. |
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
- **In Progress → In Review**: PR opened.
- **In Review → Done**: PR merged. (Review requesting changes → back to In Progress.)
- **any → Canceled**: dropped or superseded. Use Canceled, never Done, for work that wasn't actually completed.

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
- **Repo** (one per issue): one label per repository the issue targets. Add labels as new repos appear.

**Exception — `deep` override (defer until observed):** `impl` defaults to the cheap model, but some implementations need deep judgement despite producing a PR. Rather than a new Type, mark these with a single non-grouped **`deep`** label that overrides the executor choice back to the expensive model. This is an **exception patch, not a primary axis** — introduce it only once real usage shows how often `impl` issues actually need it; until then leave it out and rely on Type alone.

Branch/PR linkage is **not** a label — individual branches/PRs attach to their issue via Linear's Git integration (or a manual `links` attachment). The Repo label answers "which repo"; the Project/parent answers "which effort"; the git link answers "which branch". Don't encode branches as labels.

### Initial setup

Create both label groups (`isGroup: true`, then members with `parent: <group>` — both supported by the label-create MCP tool):

1. Create the **Type** group and its 3 members (`impl` / `design` / `research`).
2. Create the **Repo** group; add a member per active repository on demand.

## Deferred (out of scope for this base skill)

The following are intentionally *not* covered here and belong to later `linear-*` skills:

- Mapping to the `dev-workflow` family (Epic/Story/Task ↔ Project/Issue/Sub-issue).
- Linking to `git-helpers` / PR flow, and issue-ID-in-branch-name conventions.
- Linear ⇄ GitHub native integration setup.

This skill defines the vocabulary and rules those skills build on.
