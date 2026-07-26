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

Use the Project, Milestone, Issue, and readiness formats in
`mvp-toolkit-base`'s `references/mvp-delivery-model.md`. Those are shared
handoff contracts, not Planning-specific templates.
