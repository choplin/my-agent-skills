---
name: codebase-structure-base
description: Provides the shared reviewability objective and modeling resources used by the codebase-structure family. Use when another codebase-structure skill asks for its concept model, boundary forces, integration guidance, or human-reviewability criteria. Not typically invoked on its own.
user-invocable: false
---

# Codebase Structure Base Resources

Use these resources as the shared decision model for the `codebase-structure`
family. Resolve each path relative to this skill's installed directory rather
than a plugin or repository root.

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
