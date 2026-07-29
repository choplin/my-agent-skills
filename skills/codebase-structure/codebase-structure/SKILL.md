---
name: codebase-structure
description: Design a production-quality target codebase structure from a shared domain and use-case model by assigning semantic ownership and choosing capability, consistency, resource, representation, module, and dependency boundaries. Use when starting a project or reshaping a target architecture whose concepts or boundaries are not yet decided. Apply matching lang-reference and app-reference skills. Use codebase-structure-review for a read-only evaluation and codebase-structure-refactor when the target structure is already decided.
metadata:
  description-role: trigger
---

# Codebase Structure

Load the `codebase-structure-base` skill. Read its
`references/reviewability-goal.md`, `references/concept-model-template.md`, and
`references/boundary-forces.md` resources before selecting boundaries.

## 1. Model concepts and use cases

Treat a type as more than an input/output container. Make each meaningful type
express a concept, its valid states, and the operations that belong to it.

- Discover domain concepts and use cases from the product language, types,
  schemas, APIs, tests, and procedures. Prefer the shared domain vocabulary to
  technical mechanism names.
- Identify invalid states and prevent them through types, constructors,
  visibility, or validation at a clear boundary where practical.
- Place rules, transformations, and state transitions with the concept that
  owns their meaning. Do not centralize unrelated rules in a generic `service`,
  `store`, `model`, or `util` module.
- Keep behavior near its semantic owner. Pure functions may own a concept's
  behavior when they operate on its explicit type; do not force OO patterns.
- Reserve use-case code for coordination across concepts: input validation,
  authorization or existence checks, transaction boundaries, and ordering
  multiple domain operations.

Fill only the relevant rows in the base skill's concept and use-case model.
Update the model when discovery changes it rather than bending it to match the
current code.

## 2. Select boundaries from the model

Apply the base skill's boundary forces independently, then align them only where
a shared invariant or representative change requires cohesion. Start with
direct concrete dependencies. Add a port only for a concrete change-isolation,
substitution, or test-control need, and shape it around the consumer's
capability.

When an external integration combines external-system discovery or identity,
application-specific selection or normalization, and coordinated persistence,
read the base skill's `references/integration-boundaries.md`.

## 3. Map the target structure

Choose names that fit the repository. Treat concept code, use-case code,
external adapters, transport code, and composition code as responsibilities,
not required directories or layers.

Record a proportional model-to-code map containing:

- each relevant concept's semantic owner and public operations;
- each use case's entry point, result, and required capabilities;
- each consistency and resource-lifecycle owner;
- each external representation and mapping boundary;
- the composition root and allowed dependency directions;
- behavioral evidence and intentionally unresolved decisions.

Prefer types, imports, visibility, public surfaces, tests, and mechanically
enforced dependency rules as evidence. Do not make prose the only place where
the architecture is visible.

## 4. Falsify before concluding

Use `codebase-structure-review` to challenge the target with representative
changes and verify boundary closure, static legibility, traceability, and review
locality. Revise the design or record missing evidence; do not present an
unreviewed target as complete.

## 5. Apply implementation-specific guidance

Identify the implementation languages and apply the matching installed
`lang-reference-<language>` skill when available. Use it for language-specific
style, idioms, and verification.

Identify the application kind and apply the matching installed
`app-reference-<kind>` skill when available. Use it for platform architecture,
framework recommendations, rendering or state boundaries, and
platform-specific verification.

Keep this skill language- and platform-agnostic. Repository configuration and
established conventions take precedence. Do not invent guidance when no
matching reference exists.
