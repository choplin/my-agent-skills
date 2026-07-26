---
name: codebase-structure
description: Guide production-quality codebase structure from a shared domain and use-case model by assigning semantic ownership, separating design forces, controlling change propagation, and keeping the implementation statically legible and traceable. Use when starting a project or reviewing an implementation whose concepts, ownership, module boundaries, public capabilities, consistency boundaries, resource ownership, or dependency direction need to be designed or reshaped. Apply matching lang-reference skills for language conventions and app-reference skills for application-specific architecture. Do not use for a small localized change, a formatting-only request, or a refactor whose target structure is already decided; use codebase-structure-refactor for the latter.
---

# Codebase Structure

Write code around the concepts and use cases the program represents, not around
a list of procedures or the capability set of its infrastructure. Preserve the
shared model in the code so a reviewer can navigate from an agreed concept or
workflow to its implementation and back again.

## Model concepts and use cases first

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

Use [the concept and use-case model](references/concept-model-template.md)
before choosing file or layer boundaries. Update it when discovery changes the
model rather than bending the model to match the current code.

## Separate design forces before aligning boundaries

Do not assume that one concept, module, port, object, transaction, and physical
resource must share the same boundary. Analyze these forces separately:

- **semantic ownership** — which concept owns each rule, invariant, and state
  transition;
- **use-case capabilities** — what each consumer needs to complete its workflow;
- **consistency requirements** — what must succeed or fail together;
- **resource ownership and lifecycle** — who creates, shares, and releases a
  connection, process, filesystem handle, or similar resource;
- **external representations** — where database rows, driver errors, wire
  formats, framework types, and other technology-specific forms are owned.

Align forces only where a shared invariant or change driver requires cohesion.
For example, one adapter may own a shared connection while satisfying several
consumer-facing capabilities. Separating a capability does not require
duplicating the physical resource.

## Shape boundaries by change propagation

Evaluate a boundary by the changes it contains and prevents, not by file size or
taxonomy alone.

- Keep code together when it must change together to preserve one invariant.
- Prevent a change to one concept, use case, or technology from forcing
  unrelated consumers or modules to change.
- Start with direct concrete dependencies. Introduce or split a port only when
  consumers need meaningfully different change isolation, substitution, or test
  control. Then shape the contract around consumer capabilities rather than the
  complete operation set a provider can offer. Do not create one interface per
  use case by default; one adapter may satisfy several justified contracts.
- Judge encapsulation by the complete public surface, not source placement.
  Keep public types, errors, constraints, callbacks, and lifecycle semantics
  understandable without depending on representations owned behind the
  boundary.
- Prefer a direct, readable model over an abstraction created only to remove a
  small amount of duplication.

## Preserve static legibility and traceability

Optimize the structure for local human review, especially when a shared model
is designed collaboratively and implementation is delegated.

- Give every relevant concept, invariant, and workflow an identifiable semantic
  owner or entry point.
- Reuse the model's vocabulary in types, module names, use-case entry points,
  public capabilities, and behavioral tests.
- Make dependency direction, external boundaries, resource ownership, and
  composition visible through public surfaces, types, imports, and visibility.
  Prefer explicit connections and mechanically constrained dependencies over
  implicit registration or convention-only boundaries.
- Keep the mapping between model and code discoverable in both directions. It
  need not be one-to-one, but a reviewer should be able to find the
  implementation of a model element and explain the domain purpose of public
  code.
- Do not fragment code merely to make the directory tree look architectural. A
  boundary improves legibility only when it reduces the context needed to
  understand or verify a change.

## Structure modules by responsibility

Use names that fit the repository. Treat the following as responsibilities, not
required directory or layer names:

- **concept code** owns public models, value objects, pure rules, and
  transitions, independent from transport, database, and framework APIs;
- **use-case code** coordinates concepts and capabilities, applies
  cross-concept policy, and defines consistency boundaries;
- **external adapters** own I/O-specific operations, private representations,
  mapping, and technology-specific failures;
- **transport code** interprets CLI or HTTP input, formats output, and invokes
  use cases;
- **composition code** owns startup, configuration, dependency construction,
  shared resource lifecycle, and top-level error handling.

Keep dependencies pointing from outer concerns toward concept code. Map external
representations to domain concepts at the adapter boundary.

## Falsify and review the structure

Read [the structure review](references/structure-review.md) before concluding a
design or structural review. Challenge the proposed boundaries with
representative changes, then inspect whether ownership, dependency direction,
resource lifecycle, and model-to-code traceability remain statically
discoverable. Revise a boundary when unrelated concerns must change together or
when verifying a local change requires reconstructing the whole runtime design.

Record intentionally unresolved boundaries and missing evidence rather than
treating the structure as complete.

## Apply language- and application-specific guidance

Identify the implementation languages and apply the matching installed
`lang-reference-<language>` skill when available. Use it for language-specific
style, idioms, and verification.

Identify the application kind and apply the matching installed
`app-reference-<kind>` skill when available. Use it for platform architecture,
framework recommendations, rendering or state boundaries, and platform-specific
verification.

Keep this skill language- and platform-agnostic. Repository configuration and
established conventions take precedence. Do not invent guidance when no matching
reference exists.
