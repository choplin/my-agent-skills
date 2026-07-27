---
name: orchestration-toolkit-orchestrate
description: >-
  Drive one ready Linear Project to completion as a quick, durable
  orchestration run: recover design and decisions from llm-wiki, reconstruct the
  Issue dependency graph from Linear, create or resume a Type/orchestration
  control Issue, schedule safe parallel waves, delegate implementation to
  economical subagents, integrate and verify each Issue, run mandatory global
  adversarial review, and stop at a final human approval gate. Use when the user
  asks an orchestrator to finish a multi-Issue Project, complete an initial
  development phase, execute a Linear graph with subagents, or combine native
  goal persistence with delegated delivery. Not for shaping an unformed
  project, planning an ungroomed backlog, executing one isolated Issue, or
  debating a proposition.
---

# Orchestrate a Project

Act as the control plane for one finite Linear Project. Keep execution-wave
scheduling, integration, verification, and judgment in the main session;
delegate Issue deliverables to subagents. Project shaping and backlog planning
remain outside this skill. Optimize for a quick autonomous run, but never waive
the final human approval gate.

Apply `linear-base` for Linear mechanics, installed llm-wiki skills for durable
knowledge retrieval, `wtm-worktree` for worktree operations, and
`git-helpers-commit` for every commit. Use the host's native subagent mechanism;
if no subagents are available, stop rather than silently implementing the
Project inline.

Read both references before starting or resuming a run:

- [references/model-routing.md](references/model-routing.md) defines capability
  tiers, default budgets, escalation, and host-model mapping.
- [references/orchestration-records.md](references/orchestration-records.md)
  defines the control Issue, graph, checkpoints, and final review packet.

## Invariants

- The main session remains the sole orchestrator.
- Linear owns executable state and `blocked by` relations; llm-wiki owns durable
  design, research, and decision knowledge; the repository owns implementation
  reality.
- One `impl` Issue produces one coherent, independently reviewable change on
  one branch. A PR is optional. Integrate only verified commits.
- Give each concurrently executing Issue an isolated worktree. Never let
  parallel agents edit the same worktree or share uncommitted state.
- An executor receives one self-complete Issue plus explicit inputs, not the
  whole Project conversation.
- Do not start a blocked Issue. Recompute readiness after every integration,
  finding, or graph change.
- Enforce the Issue's acceptance and constraints. Reject speculative features,
  future-only flexibility, and abstractions without a present second use.
- Keep Linear identifiers and URLs out of branches, commits, repository files,
  and PR text as required by `linear-base`.
- A Project is not complete until mandatory global adversarial review finishes
  and the user explicitly approves the final review packet.

## Workflow

### 1. Bind the run to an outcome

If a native goal is active, treat it as the persistent terminal outcome and
ensure the selected Project is its executable scope. Do not create a native goal
unless the user explicitly requested one. Without an active goal, use the
Project goal and acceptance as the terminal outcome.

Resolve the current repository through `linear-base`, then select one
non-terminal Project:

- one matching active Project: use it;
- several plausible Projects: ask one focused question;
- no Project: stop and ask for the Project rather than inventing one.

Read the Project description, milestones, all non-canceled Issues, comments,
relations, labels, and statuses. The Project must state a finite outcome and
observable completion. If those are materially ambiguous, obtain the human
decision before execution.

### 2. Recover the knowledge surface

Use `llm-wiki-overview` or `llm-wiki-retrieve` to locate relevant PRDs, designs,
research, and decision logs. Search from Project and Issue terminology instead
of loading the whole wiki. Read the selected notes and follow only links needed
to interpret scope, constraints, acceptance, or completed blocker outcomes.

Build a source map:

- Project outcome, scope, non-goals, and acceptance;
- binding decisions and rejected alternatives;
- completed research or design inputs named by Issues;
- repository facts that constrain execution;
- contradictions or stale assumptions.

Do not invent a universal source precedence. Linear is authoritative for current
execution state, llm-wiki for durable rationale, and the repository for actual
code behavior. A material contradiction is a decision point: continue other
ready work, record it, and request human judgment when it blocks progress.

### 3. Create or resume the control Issue

Search the selected Project for a non-terminal `Type/orchestration` Issue.

- Exactly one: resume it using its latest checkpoint.
- None: create `Orchestrate: <Project name>` in the Project with the same Repo
  label, `Type/orchestration`, and `In Progress`.
- Several: do not create another; ask which run is authoritative.

If the Type group has no `orchestration` member, create that issue label under
the existing Type group before creating the control Issue. Do not substitute
`design` or leave the control Issue untyped.

The control Issue is a control-plane record, not a work-graph node. Do not add
blocking relations merely to make it a parent or root. Its terminal deliverable
is a human-approved Project run.

Reconstruct state from Linear, Git branches/worktrees/commits, prior findings,
and the latest checkpoint before trusting the comment history. Reconcile stale
checkpoint fields against current external state and post a correction.

Recover or create one isolated orchestration integration worktree through
`wtm-worktree`. Name its branch after the Project outcome, never the Linear
identifier, and record the control Issue in the worktree note. Base a new
integration branch on the repository's normal target branch. This worktree is
owned by the orchestrator; executors never edit it directly.

### 4. Build the execution and assurance graphs

Normalize every non-canceled Project Issue except the control Issue into:

```yaml
issue:
deliverable:
type:
status:
acceptance:
inputs:
dependencies:
workspace:
model_tier:
verification:
integration:
```

Derive logical edges from Linear `blocked by`. A node is ready only when:

- all blockers are Done and their named outcomes are available;
- the Issue is self-complete under `linear-base`;
- its acceptance is observable;
- required human or external inputs exist;
- an executor capability tier and isolated workspace can be assigned.

Logical readiness does not prove safe parallelism. Before placing ready nodes in
one wave, check likely file/module overlap, shared APIs or schemas, migrations,
generated artifacts, integration ordering, and non-isolatable resources.
Serialize nodes whose concurrent changes could invalidate each other.

The assurance graph adds executor self-checks, orchestrator evidence checks,
risk-selected node reviews, exception-triggered graph reviews, mandatory global
review, and final human approval. Reviews are gates, not Linear dependencies,
unless they reveal a real missing work dependency.

### 5. Plan a dynamic wave

Apply the budgets and capability tiers in `model-routing.md`. Choose the largest
safe ready set within executor concurrency. Record:

- nodes selected and why they are ready;
- nodes deliberately serialized and the conflict;
- executor tier per node;
- expected checks and integration order;
- selected adversarial coverage and omitted coverage;
- current budget usage.

Quick mode records this plan and proceeds without a wave-plan approval gate.
Graph changes outside the authority boundary below still require the user.

Before dispatch, call `artifact-review-toolkit-adversarial` with
`scope: graph` when a material scheduling judgment needs an independent check:

- a missing or repaired dependency → `graph.dependency-integrity`;
- a proposed parallel wave with uncertain shared surfaces →
  `graph.parallel-safety`;
- materially different wave/model/budget choices, a high-impact graph change,
  or repeated failure with an unclear cause → `graph.execution-strategy`.

Apply supported findings to the graph or wave, record rejected findings with
evidence, and recompute readiness. If a finding implies scope or acceptance
change outside autonomous authority, park it for the human rather than letting
the reviewer mutate the Project.

### 6. Dispatch one Issue per executor

Give each executor only:

- the complete Issue;
- explicit completed blocker outcomes and binding decisions;
- repository-local instructions;
- its isolated worktree and branch, based on the integration head captured for
  that wave;
- acceptance and required checks;
- the allowed decision boundary;
- a requirement to use `git-helpers-commit`.

Require the executor to return:

- commit(s) produced;
- raw check commands and outcomes;
- acceptance evidence;
- decisions and assumptions made;
- scope deviations;
- remaining uncertainty or inability to finish.

The executor must stop and return a capability-boundary report instead of
guessing when it encounters an unresolved one-way decision, a required graph
change, or unexpected cross-cutting impact.

### 7. Verify and integrate each result

Executor self-check is always required. Independently inspect the branch,
diffs, commits, and raw check evidence. Confirm that the result:

- satisfies each acceptance item;
- remains inside Issue scope;
- preserves unrelated user changes;
- contains no unjustified abstraction or future-only work;
- includes required tests and repository checks;
- can integrate without invalidating completed or parallel nodes.

Select risk-based node adversarial review through
`artifact-review-toolkit-adversarial` when the change has broad blast
radius, low reversibility, weakly observable acceptance, design deviation,
security/data/API impact, repeated failure, or many downstream dependents.

Integrate a verified Issue branch into the orchestration integration branch
using repository conventions and dependency order. Preserve its independently
reviewable commit boundary. Run integration checks, leave the required Linear
completion note, and move the Issue to Done. A PR may be opened when separately
authorized, but is not required.

If verification or integration fails, keep or return the Issue to In Progress
and send actionable evidence to an executor. Allow one routine retry; then
escalate according to `model-routing.md`.

### 8. Recompute and checkpoint

After every completed Issue, finding, retry, or dependency change:

1. reread affected Linear relations and statuses;
2. recompute the ready set and conflict surface;
3. update budget usage;
4. post a proportional checkpoint at wave boundaries or before a session ends.

Quick mode may autonomously add an obvious missing `blocked by` relation,
reorder waves, reassign an Issue to a deeper model, or create a narrowly scoped
remediation Issue inside existing acceptance. Record the evidence and change.

Require human judgment before expanding Project scope, changing acceptance,
replacing a binding design decision, canceling planned work, changing the
Project completion condition, or accepting a material residual risk.

When a blocking decision remains, finish all independent ready work, post a
decision packet, move the control Issue to In Review, and wait. After the user
decides, return it to In Progress and continue.

### 9. Run mandatory global adversarial review

When all target work nodes are Done and integration checks pass, call
`artifact-review-toolkit-adversarial` with `scope: global`.

Always require:

- `global.goal-alignment`;
- `global.integration-consistency`.

Use two fresh adversarial agents by default, one per mandatory global lens.
Never omit global review because earlier node reviews passed. Provide the
original goal, Project acceptance, final graph, integrated artifacts, raw
evidence, decisions, deviations, and prior findings—not the orchestrator's
preferred conclusion.

For `remediation-required`, reopen the affected Issue or create a focused
remediation Issue, return to the execution graph, and repeat global review after
integration. Treat `inconclusive` as a coverage gap, never as pass.

### 10. Request final human approval

Post the final review packet defined in `orchestration-records.md` and move the
control Issue to In Review. Present the packet to the user and ask for explicit
approval.

- Approved: move the control Issue to Done, then complete the Project when all
  other completion conditions hold. Mark the native goal complete only now.
- Corrections requested: return the control Issue to In Progress, update or
  create work nodes, and resume the loop.
- Residual risk accepted: record exactly what the user accepted before Done.

Silence is not approval. No adversarial agent or orchestrator may approve on the
user's behalf.

## Failure and degradation

- Missing Linear access: stop before pretending durable execution state exists.
- Missing llm-wiki: continue only if the Project and repository are
  self-sufficient; disclose the missing knowledge surface.
- Missing worktree support: do not run parallel repository-changing executors.
- Missing economical model: use the least costly available model that meets the
  capability floor and record the substitution.
- Missing independent reviewer capacity: run at least one fresh global reviewer
  covering both mandatory global lenses sequentially and record degraded
  independence; do not skip the global gate.
- Repeated executor failure: stop retrying the same configuration; deepen the
  model, repair the Issue/graph, or request human direction.

## Success criteria

- [ ] The Project's final acceptance table maps every criterion to observable
      integrated evidence or an explicit unresolved gap.
- [ ] Every Done work Issue maps to a verified integrated commit and a Linear
      completion note; no target Issue remains silently outside the graph.
- [ ] The control Issue's latest checkpoint reconstructs the current graph,
      workspaces, decisions, findings, and budget usage without conversation
      history.
- [ ] The final packet exposes every material graph change, autonomous decision,
      adversarial finding, coverage gap, and residual risk.
- [ ] The global review record includes both mandatory lenses after final
      integration.
- [ ] The Project and native goal remain non-terminal until the control Issue
      records explicit human approval.
