---
name: codebase-structure
description: Guide production-quality codebase structure by modeling domain concepts, types, invariants, and state transitions before defining module boundaries. Use when starting a new project or reviewing an implementation that needs its core concepts, ownership, module boundaries, or dependency direction designed or reshaped. Apply matching lang-reference skills for language-specific conventions. Do not use for a small localized change, a formatting-only request, or a refactor whose target structure is already decided; use codebase-structure-refactor for the latter.
---

# Codebase Structure

Write code around the concepts the program represents, not around a list of
procedures. Let types, invariants, and state transitions determine module
boundaries; use layers to protect those boundaries.

## Model concepts first

Treat a type as more than an input/output container. Each meaningful type should
express a concept, its valid states, and the operations that belong to it.

- Discover domain concepts from types, schemas, APIs, tests, and procedures.
  Name concepts rather than technical mechanisms.
- Identify invalid states and prevent them through types, constructors,
  visibility, or validation at a clear boundary where practical.
- Place rules, transformations, and state transitions with the concept that
  owns their meaning. Do not centralize unrelated rules in a generic `service`,
  `store`, `model`, or `util` module.
- Keep behavior near the type that owns it. Pure functions may own a concept's
  behavior when they operate on its explicit type; do not force OO patterns.
- Reserve application/use-case code for coordination across concepts: input
  handling, authorization or existence checks, transaction boundaries, and
  ordering multiple domain operations.

Use [the concept-model template](references/concept-model-template.md) before
choosing file or layer boundaries. This prevents the current placement of code
from accidentally becoming the architecture.

## Structure modules by responsibility

Organize files around domain concepts and their ownership. Make a module name
answer “what concept is this?” rather than “what technical operation happens
here?” Do not create a module until its owned types and public surface are clear.

Use names that fit the repository. The following are responsibilities, not
required directory or layer names:

- **concept code** owns public models, value objects, pure rules, and
  conversions. Keep it independent from transport, database, and framework APIs.
- **coordination code** validates input, resolves scope and dependencies,
  combines concepts, applies cross-concept policy, and defines transaction bounds.
- **external adapters** contain SQL, database-access APIs, private rows, and
  other I/O-specific mapping. Do not leak those representations into concept code.
- **transport code** interprets CLI or HTTP input, formats output, and calls
  coordination code.
- **composition code** limits itself to startup, configuration, dependency
  construction, and top-level error handling.

Keep dependencies pointing from outer concerns toward concept code, so concepts
remain testable and usable without a particular transport, database, or framework.
Map persistence representations to domain concepts at the adapter boundary.
Prefer a direct, readable model over an abstraction created only to remove a
small amount of duplication.

## Apply language-specific guidance

Identify the implementation languages and apply the matching installed
`lang-reference-<language>` skill when available. Use it for language-specific
style, idioms, and verification; keep this skill language-agnostic. Repository
configuration and established conventions take precedence.

Do not invent a language rule when no matching reference exists.

## Check the resulting structure

Before concluding an implementation or review, confirm that every relevant
concept has a named representation, owner, and stated invariant or permitted
transition; every selected responsibility has an intentional public surface and
dependency boundary; and external representations do not appear in concept code.
Record any intentionally unresolved boundary or missing language guidance rather
than treating it as complete.
