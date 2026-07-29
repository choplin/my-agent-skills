---
name: codebase-structure-review
description: Review a proposed or implemented codebase structure without changing it. Use when evaluating semantic ownership, module or port boundaries, dependency direction, transaction and resource ownership, external representations, change propagation, static legibility, or model-to-code traceability. Return evidence-backed findings and unresolved questions. Use codebase-structure to design a replacement and codebase-structure-refactor to implement one.
metadata:
  description-role: documentation
---

# Codebase Structure Review

Perform a read-only structural review. Do not turn findings into file changes,
external writes, or a migration unless the user separately authorizes that work.

Load the `codebase-structure-base` skill. Read its
`references/reviewability-goal.md` and `references/boundary-forces.md`
resources, then read
[the structure review checklist](references/structure-review-checklist.md).

## 1. Establish the review model

Identify the target concepts, use cases, public surfaces, external systems,
shared resources, persistence operations, and composition roots. Use the base
skill's `references/concept-model-template.md` when the shared model is absent
or too implicit to review ownership and traceability.

Distinguish observed evidence from assumptions. Record missing source, tests,
runtime configuration, or domain context instead of treating it as verified.

## 2. Select representative changes

Choose a small set of changes that exercise the important boundaries in this
codebase. Trace the public surfaces, modules, tests, adapters, and composition
code each change would affect. Do not optimize for hypothetical replaceability
without a representative driver.

For external integrations that combine native discovery or identity,
application-specific projection, and persistence coordination, also read the
base skill's `references/integration-boundaries.md`.

## 3. Review observable structure

Apply the checklist to:

- semantic ownership and use-case entry points;
- boundary closure across types, errors, constraints, and lifecycle semantics;
- consumer-shaped capabilities and justified polymorphism;
- consistency and resource-lifecycle ownership;
- dependency direction, external representations, and composition;
- model-to-code traceability and review locality.

Judge the complete public surface rather than source placement alone. Prefer
evidence visible in types, imports, visibility, tests, and dependency rules over
prose-only conventions.

## 4. Report findings

Lead with findings, ordered by impact. For each material finding, report:

- the violated or ambiguous structural property;
- concrete evidence and its location;
- a representative change or failure mode that exposes the cost;
- the affected concepts, consumers, or boundaries;
- a recommended direction, without implementing it;
- unresolved evidence that could change the conclusion.

Also record strengths worth preserving and intentionally unresolved boundaries.
If no material issue is found, state the review coverage and remaining evidence
gaps rather than claiming the structure is universally correct.
