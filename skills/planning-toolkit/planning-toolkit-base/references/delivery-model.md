# Delivery Model

This is the shared vocabulary and handoff contract for the Planning Toolkit
family. Caller skills own workflow; this model owns the meaning of the records
they exchange.

## Contents

1. Outcome Contract
2. Scope Policy
3. Scope Disposition
4. Unknown Class
5. Decision Authority
6. Readiness state machine
7. Durable ownership
8. Tracker mapping
9. Issue execution contract
10. Handoff contracts
11. Cross-phase invariants

## 1. Outcome Contract

The Outcome Contract is the confirmed boundary against which scope, research,
decisions, and implementation are judged.

| Field | Meaning |
|---|---|
| **Target user** | The specific user or actor whose situation must change. |
| **Problem** | The concrete problem this outcome addresses for that user. |
| **Outcome** | The finite, completable result. Not a direction or a permanent area of work. |
| **Constraints** | Safety, legal, operational, integration, timing, and other binding limits. |
| **Non-goals** | What this outcome deliberately does not establish or provide. |

An active Scope Policy may require **additional fields** and may constrain how
Outcome is expressed. Those fields are part of the contract while that policy is
in force.

The contract has converged when every candidate capability can be judged against
these fields — generic and policy-added together — without inventing direction.

A change is a **planning invalidation** when it materially changes Target user,
Problem, Outcome, a binding Constraint, or any field the active Scope Policy
requires. Phase-local workflows must not repair a planning invalidation
silently.

## 2. Scope Policy

A Scope Policy is the justification standard applied when cutting scope. Exactly
one policy is in force per planning run, supplied by a caller skill. A policy is
a declaration; it owns no workflow.

A policy declares:

| Element | Meaning |
|---|---|
| **Outcome expression** | How the Outcome field must be phrased to satisfy the policy. |
| **Additional contract fields** | Fields the Outcome Contract must carry under this policy. |
| **Inclusion test** | The bar a capability must clear to be dispositioned In Scope. |
| **Challenge lenses** | The specific inclusions the policy requires be argued against. |
| **Deferred handling** | What must be preserved about excluded capabilities and what would promote them. |

When no policy is supplied, apply the **default policy**:

- **Outcome expression** — a finite, completable result stated as an observable
  end state.
- **Additional contract fields** — none.
- **Inclusion test** — the capability is required to reach the stated Outcome,
  to operate it safely, or by a binding Constraint.
- **Challenge lenses** — work that does not change whether the Outcome is
  reached; abstraction without a present second use; capacity for unobserved
  scale.
- **Deferred handling** — preserve the exclusion rationale durably.

Do not hard-code any single policy's vocabulary into this model or into a
workflow. Read the active policy, apply its elements, and record which policy
was in force in the durable planning record.

## 3. Scope Disposition

Assign exactly one disposition to each candidate capability:

| Disposition | Meaning | Operational treatment |
|---|---|---|
| **In Scope** | Clears the active Scope Policy's inclusion test. | May become executable tracker work. |
| **Deferred** | Potentially valuable but not required by the inclusion test, and safely addable later. | Preserve in llm-wiki with exclusion rationale; do not create executable issues. |
| **Rejected** | Inconsistent, duplicated, obsolete, or unjustified. | Preserve rationale only when it prevents re-litigation. |

Deferred is not a shadow backlog. Promote a Deferred capability only through a
new planning decision. A later committed finite outcome belongs in a separate
Project rather than the current one.

## 4. Unknown Class

Classify uncertainty by the action needed to prevent guessing:

| Class | Meaning | Owner |
|---|---|---|
| **Scope-defining** | The answer changes the Outcome Contract or a Scope Disposition. | Planning resolves with the user before handoff. |
| **Blocking research** | Evidence is required before feasibility, a material contract, or downstream work can be fixed. | Resolution produces findings. |
| **Blocking design** | One binding choice is required before downstream work can be fixed. | Resolution settles the decision from completed inputs. |
| **Reversible implementation** | Low-impact, easily reversible detail that an executor can choose safely. | Execution; no pre-implementation issue. |

Front-load only genuine blockers. A question needed solely by a later milestone,
or safely answerable within one implementation issue, is not part of the
pre-implementation resolution lane.

Research produces evidence, constraints, and evaluated options. Design consumes
completed evidence and produces one binding decision. The canonical dependency
shape is:

```text
research → design → affected implementation
```

Represent ordering with the tracker's `blocked by` relation, not hierarchy.

## 5. Decision Authority

Every blocking design issue names exactly one authority:

| Authority | Meaning |
|---|---|
| **AI** | AI may choose the best-supported option within the confirmed contract and record rationale. |
| **Human** | AI prepares evidence, viable options, consequences, and a recommendation; the user chooses. |
| **External** | A named external owner or artifact must supply the choice or input. |

Authority is not a confidence level. Do not substitute AI authority merely
because a human or external answer is slow.

Every decision record contains:

- chosen option;
- rejected viable alternatives;
- rationale grounded in contract and evidence;
- affected downstream work;
- scope effect, including whether Planning was invalidated.

## 6. Readiness state machine

Readiness states what autonomous work may start now. It is not schedule,
progress, or confidence.

| State | Meaning | Allowed next autonomous work |
|---|---|---|
| **READY** | No implementation-blocking unknown remains and at least the first implementation work is self-complete. | Execution. |
| **READY_AFTER_RESOLUTION** | The resolution lane is self-complete and executable, but implementation is not. | Blocking research/design resolution only. |
| **BLOCKED** | No useful autonomous work can proceed without named human/external input or a new Planning decision. | Obtain the named input or return to Planning. |

Legal transitions:

```text
Planning ──→ READY
         ├─→ READY_AFTER_RESOLUTION
         └─→ BLOCKED

READY_AFTER_RESOLUTION ──Resolution──→ READY
                       └─────────────→ BLOCKED

BLOCKED ──input supplied / Planning──→ any valid readiness state
```

Do not mark READY merely because unknowns have issues. Do not mark
READY_AFTER_RESOLUTION unless the resolution issues themselves are executable
without hidden context.

The readiness value and a proportional blocker summary live in the tracker
Project description. Detailed rationale lives in llm-wiki and issue records.

## 7. Durable ownership

### llm-wiki owns durable knowledge

- the confirmed Outcome Contract and the Scope Policy in force;
- Scope Disposition and rationale for In Scope, Deferred, and Rejected;
- research evidence and constraints;
- binding decisions, alternatives, and rationale;
- planning invalidation evidence;
- links among relevant PRD, design, research, and decision notes.

### The tracker owns current executable state

- the finite Project and its readiness summary;
- observable delivery Milestones;
- atomic research, design, and implementation Issues;
- work type, lifecycle state, placement, and `blocked by` relations;
- issue-local Inputs, Acceptance, Constraints, completion notes, and handoffs;
- the next unblocked work.

Keep knowledge and execution consistent without copying entire notes between
systems. The tracker may use internal Issue identifiers and links. Do not write those
identifiers or URLs into llm-wiki.

Use `workflow-adapter-markdown` for durable Markdown writes and
`workflow-adapter-tracker` for Project, Milestone, Issue, relation, and
transition operations. Provider mechanics stay behind those adapters.

## 8. Tracker mapping

| Planning concept | Tracker primitive | Rule |
|---|---|---|
| Finite outcome | **Project** | One completable outcome, not a permanent repo bucket. |
| Observable delivery stage | **Milestone** | Use only when distinct stages earn structure; never solely as a review gate. |
| Atomic deliverable | **Issue** | One coherent, independently verifiable outcome sized for one focused session. |
| Deliverable kind | **Type label** | `research`, `design`, or `impl`. |
| Execution order | **`blocked by`** | Use only when an outcome is a real input to later work. |

Milestones describe reviewable increments. Whether execution pauses for human
review is an execution policy and does not create a dependency by itself.

Git packaging is also an execution policy. Planning Toolkit Issues do not
prescribe how atomic deliverables map to commits, branches, or PRs.

The Project description carries the compact execution-facing contract:

```markdown
## Goal

<finite outcome>

## Target User and Problem

<who, and what changes for them>

## Scope

- ...

## Out of Scope

- ...

## Constraints

- ...

## Readiness

READY / READY_AFTER_RESOLUTION / BLOCKED

<blocking summary when not READY>
```

When the active Scope Policy requires additional contract fields, add one
section per field directly after `Target User and Problem`.

Each Milestone carries:

```markdown
Outcome: <observable state>
Included: <bounded scope>
Excluded: <explicit non-scope>
Acceptance: <demo, behavior, or check>
Becomes assessable: <risk or decision, plus anything the active policy makes assessable>
```

## 9. Issue execution contract

A context-free executor starts from:

1. the Issue description;
2. the current repository;
3. explicitly named, completed blocker outcomes under Inputs.

It must not need the originating chat or an unresolved blocker.

Every self-complete Todo issue contains:

```markdown
## What and Why

<one coherent deliverable and why it matters>

## Where

<repository and relevant areas or entry points>

## Inputs

- <completed blocker outcome, durable decision, or external artifact>

## Acceptance

- [ ] <observable completion condition>

Verification: `<command or concrete inspection>`

## Constraints

- <patterns, APIs, safety limits, and scope exclusions>
```

Omit Inputs only when the repository and Issue contain everything required.

Additional Type contracts:

- **research** — one question, required evidence, and findings/constraints output;
- **design** — one decision, completed inputs, authority, and required decision
  record;
- **impl** — resulting observable behavior and explicit Out of Scope.

Use these additions:

```markdown
## Question

<one research question that can change feasibility, contract, or sequencing>

## Required Evidence

- ...

## Output

<findings, constraints, and evaluated options>
```

```markdown
## Decision

<one binding choice>

## Authority

AI / Human / External: <owner when applicable>

## Required Record

- chosen option;
- rejected alternatives;
- rationale;
- affected downstream work;
- scope effect.
```

```markdown
## Behavior

<user-visible or system-observable implementation behavior>

## Out of Scope

- ...
```

An implementation issue that depends on unresolved outcomes remains Backlog.
Move it to Todo only after its Inputs and Acceptance are fixed. A
READY_AFTER_RESOLUTION Project normally has Todo research/design work and
provisional Backlog implementation work. A READY Project has at least its first
unblocked implementation work in Todo.

## 10. Handoff contracts

### Planning → Resolution

Required when readiness is READY_AFTER_RESOLUTION:

- confirmed Outcome Contract, Scope Policy, and Scope Disposition in llm-wiki;
- tracker Project with readiness summary;
- unknown register;
- self-complete Todo research/design issues;
- provisional affected implementation issues in Backlog;
- complete `blocked by` graph;
- Decision Authority for every design issue;
- explicit human/external inputs and owners.

### Planning → Execution

Allowed only when readiness is READY:

- confirmed contract, policy, and scope;
- observable milestones when useful;
- self-complete implementation issues;
- first unblocked Todo work;
- no implementation-critical unresolved input.

### Resolution → Execution

Allowed only when readiness is READY:

- every blocking research/design issue Done or canceled with rationale;
- durable findings and decisions;
- outcomes applied to affected implementation issues;
- obsolete work canceled and incorrectly sized work reshaped;
- implementation Inputs and Acceptance fixed;
- first unblocked implementation work in Todo;
- Project readiness summary updated.

Execution lives outside this family. This handoff is complete when the Project
is READY and the first unblocked work is named. Do not encode which execution
skill takes it from there: that choice belongs to the executor's own routing,
and naming it here would couple planning to an arrangement that can change
without the delivery model changing.

Use this proportional handoff summary:

```markdown
Readiness: <state>
First unblocked work: <issue or "none">

Blocking unknowns:
- <unknown> → <research/design chain> → <affected implementation>

Human/external inputs:
- <input, owner, and when it is needed>

Next route:
- READY_AFTER_RESOLUTION → planning-toolkit-resolve
- READY → execution may start; hand the named work to the executor
- BLOCKED → obtain the named input or return to planning-toolkit-plan
```

## 11. Cross-phase invariants

- Judge every inclusion against the active Scope Policy's test, not against
  feature count or completeness.
- Preserve Deferred rationale without creating executable Deferred work.
- Resolve scope-defining choices in Planning, genuine blockers in Resolution,
  and reversible details during execution.
- Do not let a phase cross its authority boundary to keep work moving.
- Do not treat issue closure as outcome propagation; apply results downstream.
- Keep milestones observable but separate reviewability from review gating.
- Keep the Project, llm-wiki, and issue graph mutually consistent.
- Return to Planning when the confirmed Outcome Contract is materially
  invalidated.
