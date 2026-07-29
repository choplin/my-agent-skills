---
name: codebase-structure-base
description: >-
  The reviewability objective and modeling resources behind codebase structure
  work: the concept model, the boundary forces, integration guidance, and the
  human-reviewability criteria. Applies whenever a codebase structure is being
  designed, reviewed, or restructured, so every step judges boundaries by the
  same criteria.
user-invocable: false
metadata:
  description-role: trigger
---

# Codebase Structure Base Resources

Use these resources as the shared decision model for the `codebase-structure`
family. Resolve each path relative to this skill's installed directory rather
than a plugin or repository root.

## Which skill does what

| The work at hand | Skill |
|---|---|
| The concepts and boundaries are not decided yet — design a target structure | `codebase-structure` |
| A structure exists, proposed or implemented, and needs judging without being changed | `codebase-structure-review` |
| The target is already decided and existing code has to be moved toward it without changing behavior | `codebase-structure-refactor` |

The three compose in either direction: a design is worth reviewing before it is
implemented, and a refactor is worth reviewing after. Design and refactor both
apply the language and application conventions for the stack in use; this family
decides boundaries, not idiom.

## Objective

Optimize for human reviewability: make it possible to verify an implementation
against the shared domain and use-case model from static evidence. Do not
minimize essential domain complexity; minimize ambiguous ownership, hidden
connections, vocabulary drift, and unjustified indirection.

Read `references/reviewability-goal.md` before choosing between otherwise valid
structures.

## Shared resources

| Resource | Load when |
| --- | --- |
| `references/reviewability-goal.md` | Designing, reviewing, or comparing structures |
| `references/concept-model-template.md` | Modeling a target or mapping an implementation before structural decisions |
| `references/boundary-forces.md` | Choosing or reviewing ownership, capability, consistency, resource, representation, or module boundaries |
| `references/integration-boundaries.md` | An external integration combines native knowledge, application projection, and persistence coordination |

Other skills refer to these as the `codebase-structure-base` skill's
`references/<file>` resource. Load only the resources required by the current
workflow, except that the reviewability goal is mandatory for every structural
design or review.
