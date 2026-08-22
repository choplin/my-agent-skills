# Planning Output Contract

Read this reference when drafting the user preview or persisting the approved
plan. Keep the content proportional; omit empty optional sections rather than
filling them with generic prose.

## Proposal preview

```markdown
# Planning Proposal

## Scope Policy

<policy name, or "default (outcome necessity)">

## Outcome Contract

- Target user:
- Problem:
- Outcome:
- Constraints:
- Non-goals:
- <policy-required field>:

## Scope Cut

| Candidate | Disposition | Reason |
|---|---|---|
| ... | In Scope / Deferred / Rejected | ... |

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

### Durable Markdown

- Notes to create:
- Notes to update:

### Tracker

- Project:
- Milestones:
- Issues:
- Statuses and dependencies:

## Remaining Human Choices

- ...
```

## Durable planning record

Prefer updating an authoritative existing note. When no note clearly owns the
outcome, create one linked note under the current repository scope:

```markdown
# Outcome Contract

Scope policy: <policy name, or "default (outcome necessity)">

## Target User and Problem

...

## Outcome

...

## <policy-required field>

...

## Scope

### In Scope

- <capability> — <why the inclusion test is met>

### Deferred

- <capability> — <why it is safe to defer and what would promote it>

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

Add a policy tag alongside `planning` when the active policy names one, so the
record can be found by the standard it was cut against.

Pass the completed Markdown and requested tags to
`workflow-adapter-markdown`; request the `planning` tag separately rather than
embedding storage metadata in the body. Link source PRD/design/decision notes
using provider-supported note locators.

Use the Project, Milestone, Issue, and readiness formats in
`planning-toolkit-base`'s `references/delivery-model.md`. Those are shared
handoff contracts, not planning-specific templates.
