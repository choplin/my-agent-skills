---
name: linear-base
description: >-
  How work is structured and managed in this Linear workspace: the treatment
  of Project, Milestone, Cycle, Issue, Sub-issue, Label, Status, and Priority;
  the full issue lifecycle from capture through grooming, status transitions,
  and closure; and the procedure that resolves a repository to its active
  Projects. Applies whenever Linear issues or projects are created, groomed,
  triaged, updated, or closed, and whenever work is being shaped into Linear.
user-invocable: false
metadata:
  description-role: trigger
---

# Linear operating conventions

This skill defines **how work is structured and managed in this Linear workspace**. The agent owns the full issue lifecycle — capturing, grooming, commenting, moving through statuses, and closing. Follow Linear's recommended semantics rather than fighting the tool.

**Context:** one workspace, so assignee routing and velocity are skipped.
An expensive model grooms self-complete work orders;
a cheaper model executes implementation by reference. Design and research stay
on the expensive model, orchestration in the main session, and the
**Type** label carries that routing signal (see Label groups).

The MCP field names referenced (`state`, `project`, `milestone`, `parentId`, `blockedBy`/`blocks`/`relatedTo`, `labels`, `priority`) are stable Linear API fields; use whichever Linear MCP server is wired.

## Which skill does what

The conventions below govern every one of these. Reach for a sibling skill when
the work is one of the repeating loops; otherwise act on the issue directly
under these conventions.

| The work at hand | Skill |
|---|---|
| See all open work for the current repository, including Project-unassigned Issues, before deciding anything | `linear` |
| Pick up a Todo or Backlog issue, or resume one already In Progress, and carry it into execution | `linear-start` |
| Work the Backlog into ready Todo work, issue after issue | `linear-groom` |
| Pause an unfinished issue so a different session can resume it | `linear-handoff` |
| Create, comment on, transition, or close a single issue | no separate skill — follow the lifecycle below |

Grooming a single named issue is the same operation `linear-groom` repeats; the
standard it applies is the authoring standard below, not something the loop
skill owns.

## Model mapping

How each Linear primitive is treated here:

| Primitive | Treatment | Why |
|---|---|---|
| **Team** | Single team. Don't create more. | Solo workspace; extra teams only buy separate issue-ID prefixes, not needed. |
| **Project** | A **finite outcome/goal** with a target ("ship X"), not a repo or a permanent bucket. Always tagged with its repo via the **Repo** project-label group (required; single-select — `1 Project = 1 repo`). | Linear projects have target dates and a completed state; a permanent project makes all of that formless. A project must be able to *complete*. The mandatory Repo tag makes "which repo does this outcome target" directly queryable. |
| **Milestone** | Phases **within** a project. Use only when a project has distinct stages. | Structure only when it earns its keep; skip for small projects. |
| **Cycle** | **Not used** (leave disabled). | Solo velocity tracking has little value; priority + status already order work. |
| **Issue** | The unit of work. **1 Issue = 1 atomic deliverable** — for implementation, one coherent code change on one branch; for design, 1 decision (ADR); for research, 1 findings document. A PR is an optional integration mechanism, not the unit of atomicity; an implementation completed on a work branch must still be integrated into its target branch before the Issue is Done. Always **self-complete** (see below). A reserved `Type/orchestration` Issue is the explicit control-plane exception: it records one Project run and its final human approval rather than an atomic work deliverable. | Keeps each deliverable reviewable and lets a context-free executor pick up any Todo without making Linear structure depend on whether integration happens through a PR, cherry-pick, or direct commit. The explicit orchestration exception gives cross-session graph execution one durable ledger without distorting work dependencies. |
| **Sub-issue** | Avoid by default. Use **only** to group a small effort with a few atomic deliverables (see grouping). | Prevents needless hierarchy; solo work rarely needs it. |
| **Label** | Issues: two single-select groups, **Type** (deliverable kind — also drives executor-model choice) and **Repo**. Projects: a **Repo** project-label group (single-select), **required on every Project**. See Label groups. | Cheap, queryable classification; single-select keeps each axis unambiguous. A Project targets one repo (multi-repo projects are rare and out of this model). |
| **Status** | Keep the 6 defaults; each carries a distinct machine-meaning (see Lifecycle). | The agent maintains status, so granularity costs nothing and aids agent decisions. |
| **Priority** | Used simply: 1=Urgent, 2=High, 3=Medium, 4=Low, 0=None. | Lightweight ordering signal. |
| **Estimate** | **Not used.** | Point estimation has no payoff solo. |

## Issue authoring standard (self-completeness)

This is the core requirement. An issue that is ready to work (**Todo**) must be
workable by an agent that has **no prior conversation context**. It starts from
the Issue plus any **explicitly named, completed blocker outcomes** declared as
inputs; it must never rely on implicit session history or an unresolved blocker.
This is what makes the "Opus grooms → Sonnet executes" split work.

A Todo-ready issue's description must contain:

- **What & why** — the change and the reason it's wanted, in enough detail to act without asking.
- **Where** — the repo (Repo label) and the relevant files/areas/entry points, named concretely.
- **Inputs** — any completed blocker outcome, durable decision, or external artifact the executor must consume. Name it explicitly and state what it supplies. Omit this only when the repository and Issue already contain everything needed.
- **Acceptance** — how "done" is judged, in terms of the issue's deliverable: for an implementation, the expected behavior plus the check to run (test/command) when one exists; for a design, the decision recorded; for research, the question answered. There must be a concrete, checkable notion of done.
- **Constraints** — anything that would otherwise be guessed wrong (APIs to use/avoid, patterns to follow, out-of-scope items).

Self-check before moving an issue to Todo: *could a fresh agent open this Issue,
follow its explicit inputs to completed blocker outcomes, and produce the atomic
deliverable without further questions?* If no, it stays in Backlog and needs
more grooming or blocker resolution.

Backlog issues carry no such bar — capture them roughly. The bar is applied at the Backlog→Todo grooming step, not at capture.

## Grouping & ordering — two independent axes

When work spans multiple atomic deliverables, two separate decisions apply. They
are **orthogonal** — decide each independently.

### Axis 1 — Grouping (how to bundle), choose one by size

| Size of the coherent work | Bundle with |
|---|---|
| Single atomic deliverable | **Nothing** — just one Issue. |
| Small, but a few dependent deliverables | **Parent Issue + Sub-issues** (each sub = 1 atomic deliverable). This is the sanctioned exception to "avoid sub-issues". |
| A distinct outcome/goal | **Project** (add **Milestones** if it has stages). |

### Axis 2 — Ordering (execution sequence), orthogonal, add only when needed

When deliverables have an order (B cannot start until A's outcome is complete),
express it with a **`blocked by`** relation (`B blocked by A`) — **not**
hierarchy. This lets the executor mechanically find "not blocked = pickable"
issues.

Axis 1 and Axis 2 coexist: e.g. two Issues in the same Project with one `blocked by` the other.

```
Work splits into multiple atomic deliverables?
  ├─ Is it a self-contained outcome/goal?
  │     ├─ YES → Project (Milestones if staged)
  │     └─ NO  → Parent Issue + Sub-issues
  └─ Do the deliverables have a start order (A→B)?
        └─ YES → add "B blocked by A" (combine with either above)
```

## Lifecycle & status transitions

Statuses and their machine-meaning:

| Status | type | Means |
|---|---|---|
| **Backlog** | backlog | Captured, not yet groomed / not ready to start. |
| **Todo** | unstarted | Groomed & self-complete — an executor can pick it up now. |
| **In Progress** | started | Actively being worked. |
| **In Review** | started | Awaiting a review response or integration (e.g. pre-commit review or an open PR). |
| **Done** | completed | The deliverable is accepted and complete (merged or shipped when applicable). |
| **Canceled** | canceled | Dropped, or superseded (e.g. promoted into a Project). |

**Set a status by its type, not by the name above** — those names are this
workspace's and a workspace may rename them. Where a type covers two statuses,
the first `started` one is the working state and the later one is review. Match
the display name only when the type leaves the choice ambiguous.

Transitions (who/when):

- **→ Backlog**: whenever an idea/task appears. Rough content is fine.
- **Backlog → Todo**: the **grooming step** (below). The gate where self-completeness and true size are settled.
- **Todo → In Progress**: work starts.
- **In Progress → In Review**: the deliverable is submitted for review. For an
  `impl` Issue, both presenting the uncommitted change for human review and
  opening a PR trigger this transition.
- **In Review → Done**: the deliverable is accepted and completed. For an
  `impl` Issue, verify that the PR was merged or that the change was otherwise
  integrated into the target branch; approval alone is insufficient. Review
  feedback or approval that returns work to the agent moves it to In Progress.
  If Done is reached with **no final-deliverable review step**, leave the
  completion note at this transition instead.
- **In Progress → (session boundary, stays In Progress)**: not a status change, but a checkpoint. When work on an issue **spans sessions** and this session ends before the issue finishes, **leave a handoff note** (see below) so a fresh session can resume it.
- **any → Canceled**: dropped or superseded. Use Canceled, never Done, for work that wasn't actually completed.

### Implementation review and completion gates

For an `impl` Issue, apply both gates in
`references/implementation-completion.md`: user review precedes the commit;
target-branch integration completes the Issue.

- Present the verified, uncommitted change and move to **In Review**. Feedback
  returns it to **In Progress**; material changes require review again. Only an
  explicit request skips review.
- Approval returns the Issue to **In Progress** while the agent commits and
  integrates, unless that immediately establishes a later state below.
- A clean, committed work branch with no PR and no verified integration stays
  **In Progress**.
- An open PR against the target branch moves it to **In Review**.
- A merged PR, verified cherry-pick, other verified integration, or direct
  commit on the target branch permits **Done**.
- An intentionally unintegrated deliverable permits **Done** only after explicit
  user acceptance.

If agent-owned work pauses, keep **In Progress** and leave a handoff note. Once
the gate is presented, keep **In Review** while awaiting the user. A PR is
optional; integration is not without the exception above.

### Worktree cleanup after Done

After **Done**, automatically remove the Issue's isolated worktree and local
work branch without asking for another instruction. Before cleanup, read and
apply `references/worktree-cleanup.md`. Delete only after verifying integration,
that no worktree changes need preserving, and that the branch is not the target
branch. If any check fails, retain the artifacts and report the exact reason.

### Completion note (record what was decided & changed)

**Required, not optional.** When an issue's **completed deliverable** enters
review (for `impl`, an open PR) — or jumps **straight to Done** without that step
— leave a comment in the issue's own terms. Do not leave this completion note
for pre-commit review: the deliverable may still change.

- **What was decided** — the choices made *while working* that the groomed issue didn't already fix: the approach taken, alternatives rejected, scope trimmed or added, and anything that deviated from the plan and why.
- **What was changed** — the actual deliverable: for `impl`, what the code
  change does; for `design`, the decision reached; for `research`, the finding.
- **How it was integrated** — at `impl` Done, record the target branch and
  evidence; follow up if the note was posted at In Review.

Rationale: commit messages and PR text describe only the change and carry **no** Linear references (see *Linear references stay internal*), so the *why* and the delta-from-spec have no home outside the issue. This comment makes the issue a durable, self-contained record of how the work actually resolved — the completion-side counterpart to the self-completeness bar applied at grooming.

Keep it proportional: an issue that shipped exactly as groomed needs a sentence; one where the approach shifted needs the decisions spelled out. When nothing deviated from the groomed plan, **say so explicitly** rather than omitting the note.

### Handoff note (record in-progress context for a cross-session pickup)

When an Issue remains **In Progress** at a session boundary, leave a comment
that lets a fresh session resume it: record the path and decisions that led to
the current state, their rationale and rejected alternatives, open questions,
and the next concrete step. Record only judgement that git and execution
artifacts cannot reconstruct; do not restate diffs or local execution state.

Keep the Issue In Progress and use `linear-handoff` for the end-to-end flow. If
cross-session work has no Issue yet, create one first; there is no local-file
handoff fallback.

## The grooming step (Backlog → Todo)

Grooming is where a rough Backlog item becomes a ready Todo. Three things are settled here, together:

1. **Self-completeness** — bring the description up to the authoring standard above.
2. **True size** — decide whether it's really one deliverable, or splits into several.
3. **Deliverable type** — set the **Type** label (`impl`/`design`/`research`), which fixes both the atomic-deliverable unit and which model will execute the issue. `orchestration` is reserved for the control Issue created by `orchestration-toolkit-orchestrate`; ordinary grooming does not assign it.

If grooming reveals the work is **multiple atomic deliverables**, apply the
grouping rule — and note the asymmetry in *how* to convert:

- **Splits into a small multi-deliverable effort → promote the issue to a parent
  (don't close it).** The original Issue becomes the parent; add sub-issues under
  it. Its ID, history, and description are preserved.
- **Turns out to be a distinct outcome → build a Project (Issues can't convert to Projects).** Create the Project, move the original's content into the Project description, then create the constituent Issues. Dispose of the original:
  - Nothing references it yet (typical at Backlog) → **Canceled + link to the Project** (not Done — it wasn't completed), or reuse it as the Project's first Issue.
  - Something already references its ID (branch name, notes) → **reuse it**: move it into the Project as one of the constituent Issues.

Rule of thumb: **sub-issue split = promote (keep the issue); Project split = rebuild (Cancel+link or reuse)** — because parent/child is mutable but Issue→Project conversion doesn't exist.

## Label groups

Two single-select groups (a Linear label group makes its members mutually exclusive — right for "exactly one per axis"):

- **Type** (one per issue) — the issue's **deliverable kind**, which also drives which model executes it:
  - `impl` — deliverable is a coherent code change on one branch. Convergent, groomable to self-completeness → executes on the **cheap** model (Sonnet). The active execution workflow decides how many commits it needs and whether to open a PR.
  - `design` — deliverable is a decision/ADR. Divergent, judgement-heavy → executes on the **expensive** model (Opus/Fable).
  - `research` — deliverable is a document/findings. Exploratory → executes on the **expensive** model.
  - `orchestration` — reserved control record for one finite Project execution. It is created and driven by `orchestration-toolkit-orchestrate` in the expensive main session, remains outside the work dependency graph, and completes only after its final human approval gate. Do not use it for ordinary implementation, design, research, or backlog grouping.

  The executor **picks the issues that match its capability**: a cheap-model
  session takes `impl`, an expensive-model session takes `design`/`research`,
  and the main orchestrator owns `orchestration`. Start with these four; add a
  Type only when a recurring deliverable is a
  genuinely different artefact from code-change/decision/document (e.g. a
  throwaway `spike`), never merely to describe a variation of one. A
  documentation change that ships as code-repository work (README etc.) is
  `impl`; an independent design/research document is `design`/`research`.
- **Repo**: which repository work targets. In Linear, issue labels and project labels are **separate namespaces**, so this axis is maintained as a **`Repo` group in each**:
  - **On issues** (single-select group, one per issue) — the repo an issue's deliverable lands in. `1 issue = 1 repo`.
  - **On Projects** (single-select `Repo` group, **required on every Project**) — the one repo the outcome targets. `1 Project = 1 repo`; multi-repo projects are rare and deliberately out of this model. This is what lets a repo resolve directly to its active Project(s) (see **Resolving the current repo's active Project(s)** below).

  **The agent cannot create project labels.** The Linear MCP exposes issue-label *creation* and project-label *assignment*, but not project-label creation — a new repo's Repo project-label must be created once in the Linear UI. When a needed one is missing, ask the user to create it, then assign it. Issue Repo labels the agent creates itself. Add the matching label in both namespaces as new repos appear.

**Exception — `deep` override (defer until observed):** `impl` defaults to the
cheap model, but some code changes need deep judgement. Rather than a new Type,
mark these with a single non-grouped **`deep`** label that overrides the executor
choice back to the expensive model. This is an **exception patch, not a primary
axis** — introduce it only once real usage shows how often `impl` issues actually
need it; until then leave it out and rely on Type alone.

Branch/PR linkage is **not** a label. An `impl` Issue uses one branch; attach
that branch and any optional PR through Linear's Git integration or a manual
`links` attachment. The Repo label answers "which repo"; the Project/parent
answers "which effort"; the git link answers "which Git artifact". Do not encode
branches as labels or assume every Issue must produce a PR.

Creating the label groups themselves is one-time workspace setup: see this
skill's `references/label-setup.md`.

## Resolving the current repo's active Project(s)

Several skills use this resolution: `linear-groom` resolves the repository to its active Linear Project(s), while `linear` and `linear-start` use **Step A** to find all relevant Issues for the repository and treat a Project as grouping context. The shared label/project mechanics and edge cases are defined once here; each caller adds its own selection behavior.

**Step A — repo → Repo label.** Derive the repo name from the current git repository (`git remote get-url origin` basename with any `.git` stripped, else the repo-root directory name). Match it to a member of the **Repo** label group (case-insensitive).

- Exactly one match → use it silently.
- No match, or ambiguous → **ask** the user which Repo label applies (don't guess). If the repo has no label yet, offer to add its issue Repo label (the agent can create issue labels).

**Step B — Repo label → active Project(s).** List the Projects tagged with the **Repo project-label = R**, then retain the ones whose state is **not** `completed` or `canceled`. Here “active” is a local convenience term for a non-terminal Project; it is **not** a Linear `state` value, so never query `state: "active"`. Every Project carries exactly one Repo tag (`1 Project = 1 repo`), so the repo resolves to its active Project(s) directly.

- **The `Repo/R` project-label doesn't exist yet** → the agent **cannot create project labels** (see Label groups). Ask the user to create the `Repo/R` project-label in the Linear UI and tag the relevant Project(s). `linear` must still report Repo-labeled Project-unassigned Issues; `linear-groom` stops until the label exists. (Once-per-repo setup.)
- **No active Project carries R** → `linear-groom` says so and stops; `linear` must still report Repo-labeled Project-unassigned Issues, and `linear-start` must still list all Repo-labeled candidate Issues.

The result is a set of **0, 1, or many** active Projects. **What to do with multiple is the caller's choice:** `linear-groom` acts on a single Project (auto-select when there's exactly one, ask the user when there are several); `linear` reports on all of them plus a No Project block; `linear-start` does not select one before listing Issues.

## Linear references stay internal

Linear is this workspace's internal tracker. **Never write Linear references — issue IDs (e.g. `ENG-123`), issue/project URLs — into work products**: commit messages, files committed to a repository, branch/worktree names, or PR titles/descriptions. Those artifacts persist outside Linear and are read by people and tools without workspace access, where the reference is dead weight at best and leaks internal context at worst.

Keep the work↔issue link in the other direction — on the Linear side or in local-only state:

- **Linear side**: attach the branch/PR to the issue via the Git integration or a `links` attachment on the issue.
- **Local side**: worktree notes (`wtm add -m`, see `linear-start`) or session context.

When exporting issue content into a repo (e.g. a spec/plan → `docs/`), carry the content but strip issue IDs/URLs from it.
