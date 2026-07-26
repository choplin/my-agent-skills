# Orchestration Toolkit

The Orchestration Toolkit drives a ready Linear Project through delegated
execution while keeping judgment, assurance, and final authority in the right
places.

It is built around a simple premise:

> Large autonomous work is graph execution, not a larger implementation prompt.

Linear already describes the work nodes and their `blocked by` edges. llm-wiki
holds the design and decision context that gives those nodes meaning. Git holds
the implementation evidence. The toolkit connects those systems into a durable
execution loop without asking one agent to carry the entire Project in its
conversation context.

## Skills

- [`orchestration-toolkit-orchestrate`](./orchestration-toolkit-orchestrate/SKILL.md)
  drives one ready Linear Project through dependency-aware delegation,
  integration, assurance, and final human approval.
- [`orchestration-toolkit-adversarial-review`](./orchestration-toolkit-adversarial-review/SKILL.md)
  independently stress-tests a concrete artifact through predefined,
  selectable review lenses.

The orchestration skill calls the adversarial-review skill. Adversarial review
also remains useful on its own.

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

## Predefined adversarial lenses

Adversarial review is not an improvised “be critical” prompt. Every review uses
a stable Lens ID with:

- a falsification objective;
- explicit triggers;
- required inputs;
- concrete checks;
- non-goals;
- severity guidance.

The orchestrator first selects lenses from risk, then packs those lenses into
the available reviewer budget. This separates the assurance coverage decision
from the number of agents available to execute it.

Reviewers receive the artifact, acceptance, constraints, evidence, and assigned
Lens—not the producer's confidence, the orchestrator's preferred verdict, or
another reviewer's result. Their independent passes are aggregated only after
they finish.

This is intentionally different from
`ai-council-adversarial-panel`. A panel debates a contested question through
cross-critique and revision. This toolkit reviews a concrete output through
independent falsification and returns structured findings.

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

### Automatic routing from `dispatch-work`

The toolkit initially relies on explicit invocation and handoff from workflows
that already produce a READY Project, such as MVP Toolkit.

Add automatic `dispatch-work` routing only after real usage establishes a
reliable distinction between:

- one distant goal that native `/goal` should drive;
- one visible near-horizon plan for `exec-plan`;
- one ready multi-Issue Project that needs delegated graph orchestration.

Premature routing would make the new skill trigger on large but non-graph work.

### Root router and shared base skill

The group currently contains two directly usable skills and no
`orchestration-toolkit` root router or `orchestration-toolkit-base`.

Extract a base skill only when at least two group skills need to interpret the
same durable contract independently. Add a root router only when the group gains
enough user-facing operations that callers cannot select the right entry point
from intent. Two skills do not yet justify either abstraction.

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

### Domain-specific Lens catalog

The initial catalog contains generic goal, integration, acceptance, regression,
scope, graph, and decision lenses. It reserves names for security,
authorization, data integrity, migration, API compatibility, concurrency,
performance, and accessibility without defining speculative procedures for all
of them.

Promote a domain Lens into the catalog when:

- a concrete run requires it; or
- the same `custom.*` Lens recurs across runs.

Until then, use a run-local custom Lens with an explicit falsification objective
and record why the generic catalog was insufficient.

### Lens versioning and registry machinery

Lens IDs are stable names, but the initial toolkit does not version Lens
definitions or maintain a machine-readable registry.

Add versioning when review reproducibility must distinguish materially different
definitions under the same Lens ID. Add registry tooling only when the catalog
becomes large enough that manual selection, packing, or validation causes
observed errors.

### Mandatory adversarial review for every Issue

Every Issue always receives executor self-check and orchestrator evidence
inspection. Independent node adversarial review remains risk-based rather than
mandatory.

Reconsider a universal node-review floor only if low-risk Issues repeatedly
produce defects that survive the global review, or if an audit requirement
demands independent review of every deliverable. Until then, spend independent
review capacity on high-blast-radius nodes and the final integrated result.
