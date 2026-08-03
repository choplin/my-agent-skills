# Orchestration Toolkit

The Orchestration Toolkit carries **already-groomed Linear work** to completion
while keeping judgment, assurance, and final authority in the right places.

Grooming is the entry condition. Once the tracker holds a settled work unit, the
question is no longer *what to build* but *how to carry it out* — and that answer
depends only on scale:

> One Issue is an implementation run. Many interdependent Issues are graph
> execution, not a larger implementation prompt.

Linear describes the work and its `blocked by` edges. llm-wiki holds the design
and decision context that gives the work meaning. Git holds the implementation
evidence. The toolkit connects those systems into a durable execution loop.

Work that is *not* yet groomed belongs elsewhere: `linear-groom` to settle an
Issue's requirements, `inception` to shape an unformed concept, and `exec-plan`
for an ad-hoc task with no tracker Issue behind it.

## Skills

- [`orchestration-toolkit-execute`](./orchestration-toolkit-execute/SKILL.md)
  carries one groomed Issue to Done inline — no delegation, no graph — keeping
  its run record on the Issue and its high-impact decisions in a parking lot.
- [`orchestration-toolkit-orchestrate`](./orchestration-toolkit-orchestrate/SKILL.md)
  drives one ready Linear Project through dependency-aware delegation,
  integration, assurance, and final human approval.

The split is scale, not ambition. A single node needs no wave scheduling, no
integration branch, and no control Issue; paying that cost for one deliverable
buys nothing. When dependencies between Issues appear mid-run, `execute` stops and
hands the Project to `orchestrate` rather than growing into it.

Independent review is not performed here. The orchestrator calls
[`artifact-review-toolkit-adversarial`](../artifact-review-toolkit/README.md),
which owns the review lenses and reviewer independence; this toolkit owns when
and at which scope a review is required.

## Control plane and execution plane

The main session is the sole orchestrator. It owns the control plane:

- interpreting the Project outcome;
- reconstructing and repairing the dependency graph;
- choosing execution waves and model capability tiers;
- deciding which work may run in parallel;
- inspecting evidence and integrating verified commits;
- routing findings and exceptional decisions;
- presenting the final result for human approval.

Subagents own the execution plane. Each executor receives one self-complete
Issue, its explicit completed inputs, an isolated worktree, and observable
acceptance. It does not need the whole Project history and must return rather
than guess when it reaches a decision outside its authority.

This split keeps the most judgment-heavy work in the strongest reasoning
context while allowing bounded implementation to use cheaper models.

## Capability-floor economics

“Economical executor” does not mean “always choose the cheapest model.” It means:

> Choose the least costly available model that can reliably complete this
> self-contained Issue.

Routine implementation with fixed direction, bounded scope, known checks, and
reversible failure belongs on the economical tier. Design, research,
cross-cutting implementation, hard-to-reverse changes, and repeated failures
belong on a high-judgment tier.

Model names are deliberately kept outside the stable policy. A current Codex
host might map these roles to frontier and balanced model tiers; Claude Code
might map them to Opus- and Sonnet-class models. The capability distinction is
the contract. Provider-specific names are a runtime mapping that will age.

## Two graphs

The toolkit operates with two related graphs.

### Work graph

The work graph comes from Linear:

```text
Issue A ──blocks──> Issue C
Issue B ──blocks──> Issue C
```

A node becomes ready only when its blockers are Done and its required outcomes
are available. Logical readiness alone is not enough for parallel execution:
the orchestrator also checks file overlap, shared APIs and schemas, migrations,
generated artifacts, integration order, and non-isolatable resources.

Safe ready nodes form a dynamic execution wave. The graph is recomputed after
every integration, finding, retry, and dependency change.

### Assurance graph

The assurance graph describes what must challenge the work before completion:

```text
executor self-check
        ↓
orchestrator evidence check
        ↓
risk-selected node or graph review
        ↓
mandatory global adversarial review
        ↓
human approval
```

Not every Issue needs an independent adversarial agent. Low-risk leaf work may
stop at self-check plus orchestrator inspection. High-blast-radius,
hard-to-reverse, weakly evidenced, or graph-shaping work receives stronger
independent review.

Global adversarial review is never optional. The final integrated Project must
cover both:

- `global.goal-alignment`;
- `global.integration-consistency`.

Two fresh reviewers are the default. When capacity allows only one, that
reviewer must cover both lenses and the loss of independence must remain visible.

## Selecting review coverage

Every review the orchestrator requests names stable Lens IDs and a scope, and it
records which lenses were selected and which the budget omitted. Coverage is
chosen from risk before reviewer count is considered, so a small budget bundles
lenses rather than quietly examining less.

The lens definitions, the packing rules, and the independence requirements
belong to [`artifact-review-toolkit`](../artifact-review-toolkit/README.md).

## Quick autonomy, durable judgment

Quick mode is the primary operating mode. It does not require humans to approve
every wave:

1. discover the Project, graph, and relevant knowledge;
2. record the intended waves, routing, and assurance;
3. execute the safe frontier autonomously;
4. park non-blocking judgment points;
5. continue all independent work;
6. return once with a consolidated human review surface.

The orchestrator may autonomously repair an obvious missing dependency, reorder
waves, deepen an executor model, or create a narrowly scoped remediation Issue
inside existing acceptance. It may not silently expand Project scope, replace a
binding design decision, change acceptance, cancel planned work, or accept a
material residual risk.

Those boundaries preserve speed without treating autonomy as authority over
product direction.

## The Orchestration Issue

Every run creates or resumes one `Type/orchestration` Issue inside the target
Project. It is a control-plane record, not a root node in the work graph.

The Issue records:

- the Project outcome and execution policy;
- graph snapshots and dynamic waves;
- model and assurance allocation;
- autonomous decisions and graph repairs;
- retries, findings, and coverage gaps;
- cross-session checkpoints;
- the final human review packet.

Its comments are the durable reconstruction surface for a fresh orchestrator.
The current graph and Git state still outrank a stale checkpoint; resume always
reconciles the record against external reality.

The control Issue stays In Progress while autonomous work continues. It moves
to In Review when a blocking human decision or final approval is required. A
correction returns it to In Progress.

## Git topology

One `impl` Issue produces one coherent, independently reviewable change on one
branch. A PR is optional.

Parallel executors use isolated worktrees based on the integration head captured
for their wave. The orchestrator alone owns the integration worktree and
integrates only verified commits in dependency order.

Linear identifiers remain in Linear and local worktree notes. They do not enter
branch names, commits, repository files, or PR text.

## Final authority stays human

Completion has two distinct meanings:

- **Machine-complete:** all target work is integrated, checks pass, and mandatory
  global adversarial coverage has produced no unresolved blocking result.
- **Project-complete:** a human has reviewed the final packet and explicitly
  approved completion or accepted the named residual risks.

The orchestrator may reach the first state autonomously. It may never infer the
second from silence.

If a native host goal is active, it supplies the persistent terminal outcome.
The toolkit supplies the graph execution method. The goal is marked complete
only after the same final human gate.

## Why the boundaries matter

The toolkit deliberately avoids several tempting collapses:

- The orchestrator does not implement the Project itself; doing so mixes global
  judgment with local coding context.
- Executors do not schedule downstream work; they lack the full graph and
  authority.
- Adversarial reviewers do not repair artifacts or accept risk; review and
  resolution remain separate.
- Linear does not become a knowledge base; durable rationale stays in llm-wiki.
- llm-wiki does not become a task tracker; current status and dependencies stay
  in Linear.
- Agent count does not stand in for assurance; independent lenses and concrete
  evidence determine review value.

These separations make the run inspectable, restartable, and economical without
weakening the final human decision.

## Deferred by design

The following ideas are deliberately postponed. They are not missing
requirements for the initial toolkit; adding them before real runs expose the
need would make the control model harder to understand and maintain.

### Governed orchestration profile

A heavier profile could ask the human to approve the graph, execution waves,
parallelism, model allocation, and selected gates before execution.

The initial toolkit keeps Quick mode as the primary path: it records those
choices but proceeds autonomously inside the authority boundary. Add a Governed
profile only after real Projects show recurring cases where the final human gate
is too late to prevent expensive rework.

### Optional Orchestration Issues

Every run currently creates or resumes a `Type/orchestration` Issue. This gives
the toolkit one dependable audit and recovery surface while usage patterns are
still unknown.

Consider making it optional only if repeated short runs show that the control
Issue adds noise without improving review, recovery, or judgment capture. Do not
remove it from long-running, cross-session, or human-gated runs.

### Root router and shared base skill

The group contains two directly usable skills and no `orchestration-toolkit`
root router or `orchestration-toolkit-base`.

Callers select between them from scale alone — one Issue or a Project — and
`linear-start` already routes on that basis, so a router would add a hop without
adding a decision. The two skills do share contracts that are currently restated
rather than centralized: the risk criteria that select adversarial review, the
Linear/llm-wiki/repository authority split, and the scope-discipline checks.
Extract `orchestration-toolkit-base` when those restatements start drifting apart,
not before.

### Exact monetary and token budgets

The initial budget controls observable execution resources: concurrency, retry
count, Lens coverage, and reviewer count. It does not pretend to calculate a
portable currency or token ceiling.

Add financial or token accounting only when the active hosts expose reliable,
comparable usage data and a real workflow needs a hard spend limit. Until then,
false precision would be less useful than capability-aware allocation.

### Complete provider/model matrices

The stable contract defines orchestrator, economical executor, deep executor,
and adversary capability floors. The current reference gives illustrative host
mappings, not an exhaustive model catalog.

Expand provider-specific mappings only when another host is actually used or an
existing mapping repeatedly selects the wrong capability tier. Verify mappings
at runtime rather than treating a checked-in model name as permanent truth.

### Mandatory adversarial review for every Issue

Every Issue always receives executor self-check and orchestrator evidence
inspection. Independent node adversarial review remains risk-based rather than
mandatory.

Reconsider a universal node-review floor only if low-risk Issues repeatedly
produce defects that survive the global review, or if an audit requirement
demands independent review of every deliverable. Until then, spend independent
review capacity on high-blast-radius nodes and the final integrated result.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
