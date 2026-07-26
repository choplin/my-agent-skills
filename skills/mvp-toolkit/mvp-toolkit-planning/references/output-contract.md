# MVP Planning Output Contract

Read this reference when drafting the user preview or persisting the approved
plan. Keep the content proportional; omit empty optional sections rather than
filling them with generic prose.

## Proposal preview

```markdown
# MVP Planning Proposal

## MVP Contract

- Target user:
- Problem:
- Smallest value loop:
- Hypothesis:
- Evidence:
- Constraints:
- Non-goals:

## Scope Cut

| Candidate | Disposition | Reason |
|---|---|---|
| ... | MVP / Deferred / Rejected | ... |

## Unknown Register

Readiness: READY / READY_AFTER_RESOLUTION / BLOCKED

| Unknown | Class | Why it matters | Resolution | Decider | Blocks |
|---|---|---|---|---|---|
| ... | scope / research / design / implementation | ... | ... | AI / human / external | ... |

## Delivery

### Milestone: <observable outcome>

- Outcome:
- Included:
- Excluded:
- Acceptance or demo:
- Becomes assessable:
- Issues:

## Dependency Graph

<compact text graph or ordered edge list>

## Durable Writes

### llm-wiki

- Notes to create:
- Notes to update:

### Linear

- Project:
- Milestones:
- Issues:
- Statuses and dependencies:

## Remaining Human Choices

- ...
```

## llm-wiki MVP planning record

Prefer updating an authoritative existing note. When no note clearly owns the
MVP scope, create one linked note under the current repository scope:

```markdown
---
<frontmatter created by llm-wiki's template>
tags: [mvp]
---

# MVP Contract

## Target User and Problem

...

## Smallest Value Loop

...

## Hypothesis and Evidence

...

## Scope

### MVP

- <capability> — <why it is required now>

### Deferred

- <capability> — <why it is safe to defer and what evidence would promote it>

### Rejected

- <capability> — <why it no longer belongs>

## Constraints and Non-goals

...

## Blocking Unknowns

- <unknown> — <resolution path and affected work>

## Decisions

- <decision> — <chosen option, rejected alternatives, rationale>

## Delivery Shape

- <milestone> — <observable outcome>
```

Use llm-wiki's template and write verbs; do not hand-author incompatible
frontmatter. Link source PRD/design/decision notes using slug-form wikilinks.

## Linear Project description

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

Keep detailed rationale in llm-wiki. The Project description contains enough
context to orient execution without duplicating the knowledge base.

## Milestone definition

```markdown
Outcome: <observable state>
Included: <bounded scope>
Excluded: <explicit non-scope>
Acceptance: <demo, behavior, or check>
Becomes assessable: <hypothesis, risk, or decision>
```

Do not create a milestone solely to group technical layers or to force a routine
human review.

## Issue descriptions

Every issue begins with the shared contract:

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

Omit `Inputs` only when the repository and issue contain everything needed.

### Research issue addition

```markdown
## Question

<one question whose answer can change feasibility, contract, or sequencing>

## Required Evidence

- ...

## Output

<findings, constraints, and evaluated options; no hidden implementation>
```

### Design issue addition

```markdown
## Decision

<one binding choice to settle>

## Inputs

- <research finding or established constraint>

## Required Record

- chosen option;
- rejected alternatives;
- rationale;
- affected downstream issues;
- whether the result changes MVP scope.
```

### Implementation issue addition

```markdown
## Behavior

<the user-visible or system-observable behavior produced>

## Out of Scope

- ...
```

Do not prescribe branch, commit, or PR topology. The execution workflow owns
that mapping.

## Readiness summary

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
- BLOCKED → obtain the named input before autonomous work
```
