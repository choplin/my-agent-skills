# MVP Delivery Model

This is the shared vocabulary and handoff contract for the MVP Toolkit family.
Caller skills own workflow; this model owns the meaning of the records they
exchange.

## Contents

1. MVP Contract
2. Scope Disposition
3. Unknown Class
4. Decision Authority
5. Readiness state machine
6. Durable ownership
7. Linear mapping
8. Issue execution contract
9. Handoff contracts
10. Cross-phase invariants

## 1. MVP Contract

The MVP Contract is the confirmed product boundary against which scope,
research, decisions, and implementation are judged.

| Field | Meaning |
|---|---|
| **Target user** | The specific user or actor whose situation must change. |
| **Problem** | The concrete problem the MVP addresses for that user. |
| **Smallest value loop** | The shortest end-to-end use that delivers real value. |
| **Hypothesis** | What the MVP is intended to prove or disprove. |
| **Evidence** | The observable result that counts as learning or success. |
| **Constraints** | Safety, legal, operational, integration, timing, and other binding limits. |
| **Non-goals** | What this MVP deliberately does not establish or provide. |

The contract has converged when every candidate capability can be judged against
these fields without inventing product direction.

A change is a **planning invalidation** when it materially changes Target user,
Problem, Smallest value loop, Hypothesis, Evidence, a binding Constraint, or the
finite MVP outcome. Phase-local workflows must not repair a planning
invalidation silently.

## 2. Scope Disposition

Assign exactly one disposition to each candidate capability:

| Disposition | Meaning | Operational treatment |
|---|---|---|
| **MVP** | Required for the smallest value loop, its evidence, safe operation, or a constraint with disproportionate reversal cost. | May become executable Linear work. |
| **Deferred** | Potentially valuable but unnecessary for the current hypothesis and safely addable after learning. | Preserve in llm-wiki with exclusion rationale; do not create executable MVP issues. |
| **Rejected** | Inconsistent, duplicated, obsolete, or unjustified. | Preserve rationale only when it prevents re-litigation. |

Deferred is not a shadow backlog. Promote a Deferred capability only through a
new planning decision. A later committed finite outcome belongs in a separate
Project rather than the current MVP Project.

## 3. Unknown Class

Classify uncertainty by the action needed to prevent guessing:

| Class | Meaning | Owner |
|---|---|---|
| **Scope-defining** | The answer changes the MVP Contract or Scope Disposition. | Planning resolves with the user before handoff. |
| **Blocking research** | Evidence is required before feasibility, a material contract, or downstream work can be fixed. | Resolution produces findings. |
| **Blocking design** | One binding choice is required before downstream work can be fixed. | Resolution settles the decision from completed inputs. |
| **Reversible implementation** | Low-impact, easily reversible detail that an executor can choose safely. | Orchestration/implementation; no pre-implementation issue. |

Front-load only genuine blockers. A question needed solely by a later
milestone, or safely answerable within one implementation issue, is not part of
the pre-implementation resolution lane.

Research produces evidence, constraints, and evaluated options. Design consumes
completed evidence and produces one binding decision. The canonical dependency
shape is:

```text
research → design → affected implementation
```

Represent ordering with Linear `blocked by`, not hierarchy.

## 4. Decision Authority

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

## 5. Readiness state machine

Readiness states what autonomous work may start now. It is not schedule,
progress, or confidence.

| State | Meaning | Allowed next autonomous work |
|---|---|---|
| **READY** | No implementation-blocking unknown remains and at least the first implementation work is self-complete. | Implementation orchestration. |
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

The readiness value and a proportional blocker summary live in the Linear
Project description. Detailed rationale lives in llm-wiki and issue records.

## 6. Durable ownership

### llm-wiki owns durable knowledge

- confirmed MVP Contract;
- Scope / Deferred / Rejected disposition and rationale;
- research evidence and constraints;
- binding decisions, alternatives, and rationale;
- planning invalidation evidence;
- links among relevant PRD, design, research, and decision notes.

### Linear owns current executable state

- the finite MVP Project and its readiness summary;
- observable delivery Milestones;
- atomic research, design, and implementation Issues;
- Type/Repo labels, statuses, priorities, and `blocked by` relations;
- issue-local Inputs, Acceptance, Constraints, completion notes, and handoffs;
- the next unblocked work.

Keep knowledge and execution consistent without copying entire notes between
systems. Linear may use internal issue identifiers and links. Do not write those
identifiers or URLs into llm-wiki.

Apply `llm-wiki-base` for scope, frontmatter, slug links, setup, and write
mechanics. Apply `linear-base` for generic lifecycle, labels, grouping,
completion notes, and repository resolution.

## 7. Linear mapping

| MVP concept | Linear primitive | Rule |
|---|---|---|
| Finite MVP outcome | **Project** | One completable outcome, not a permanent repo bucket. |
| Observable delivery stage | **Milestone** | Use only when distinct stages earn structure; never solely as a review gate. |
| Atomic deliverable | **Issue** | One coherent, independently verifiable outcome sized for one focused session. |
| Deliverable kind | **Type label** | `research`, `design`, or `impl`. |
| Execution order | **`blocked by`** | Use only when an outcome is a real input to later work. |

Milestones describe reviewable increments. Whether execution pauses for human
review is an Orchestration policy and does not create a dependency by itself.

Git packaging is also an execution policy. MVP Toolkit Issues do not prescribe
how atomic deliverables map to commits, branches, or PRs.

The Project description carries the compact execution-facing contract:

```markdown
## Goal

<finite MVP outcome>

## Target User and Value Loop

<who, problem, and shortest end-to-end value>

## Hypothesis and Evidence

<what is tested and how the result is observed>

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

Each Milestone carries:

```markdown
Outcome: <observable state>
Included: <bounded scope>
Excluded: <explicit non-scope>
Acceptance: <demo, behavior, or check>
Becomes assessable: <hypothesis, risk, or decision>
```

## 8. Issue execution contract

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

## 9. Handoff contracts

### Planning → Resolution

Required when readiness is READY_AFTER_RESOLUTION:

- confirmed MVP Contract and Scope Disposition in llm-wiki;
- Linear Project with readiness summary;
- unknown register;
- self-complete Todo research/design issues;
- provisional affected implementation issues in Backlog;
- complete `blocked by` graph;
- Decision Authority for every design issue;
- explicit human/external inputs and owners.

### Planning → Orchestration

Allowed only when readiness is READY:

- confirmed contract and scope;
- observable milestones when useful;
- self-complete implementation issues;
- first unblocked Todo work;
- no implementation-critical unresolved input.

### Resolution → Orchestration

Allowed only when readiness is READY:

- every blocking research/design issue Done or canceled with rationale;
- durable findings and decisions;
- outcomes applied to affected implementation issues;
- obsolete work canceled and incorrectly sized work reshaped;
- implementation Inputs and Acceptance fixed;
- first unblocked implementation work in Todo;
- Project readiness summary updated.

Use this proportional handoff summary:

```markdown
Readiness: <state>
First unblocked work: <issue or "none">

Blocking unknowns:
- <unknown> → <research/design chain> → <affected implementation>

Human/external inputs:
- <input, owner, and when it is needed>

Next route:
- READY_AFTER_RESOLUTION → mvp-toolkit-resolution
- READY → mvp-toolkit-orchestration
- BLOCKED → obtain the named input or return to mvp-toolkit-planning
```

## 10. Cross-phase invariants

- Optimize for the smallest end-to-end value loop, not feature count.
- Preserve Deferred rationale without creating executable Deferred work.
- Resolve scope-defining choices in Planning, genuine blockers in Resolution,
  and reversible details during implementation.
- Do not let a phase cross its authority boundary to keep work moving.
- Do not treat issue closure as outcome propagation; apply results downstream.
- Keep milestones observable but separate reviewability from review gating.
- Keep the Project, llm-wiki, and issue graph mutually consistent.
- Return to Planning when the confirmed MVP Contract is materially invalidated.
