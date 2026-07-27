# Boundary forces

Analyze the following forces independently before aligning them:

- **semantic ownership** — which concept owns each rule, invariant, and state
  transition;
- **consumer capabilities** — what each consumer needs to complete its
  workflow;
- **consistency requirements** — what must succeed or fail together;
- **resource ownership and lifecycle** — who creates, shares, scopes, and
  releases a connection, process, filesystem handle, or similar resource;
- **external representations** — where database rows, driver errors, wire
  formats, framework types, and other technology-specific forms are owned;
- **change drivers** — which parts change together and which must remain
  independent.

Do not assume that one concept, module, port, object, transaction, and physical
resource must share the same boundary. Align forces only where a shared
invariant or representative change requires cohesion. A shared physical
resource may satisfy several consumer-facing capabilities without forcing those
capabilities into one public contract.

## Shape boundaries by change propagation

- Keep code together when it must change together to preserve one invariant.
- Prevent a change to one concept, use case, or technology from forcing
  unrelated consumers or modules to change.
- Start with direct concrete dependencies. Introduce or split a port only when
  consumers need meaningfully different change isolation, substitution, or test
  control.
- Shape a port around consumer capabilities rather than the complete operation
  set a provider can offer. Do not create one interface per use case by default;
  one adapter may satisfy several justified contracts.
- Judge encapsulation by the complete public surface. Keep public types, errors,
  constraints, callbacks, and lifecycle semantics understandable without
  depending on representations owned behind the boundary.
- Prefer a direct, readable model over an abstraction created only to remove a
  small amount of duplication.

## Make the structure statically legible

- Give every relevant concept, invariant, and workflow an identifiable semantic
  owner or entry point.
- Reuse the model's vocabulary in types, module names, use-case entry points,
  public capabilities, and behavioral tests.
- Make dependency direction, external boundaries, resource ownership, and
  composition visible through public surfaces, types, imports, and visibility.
- Keep the mapping between model and code discoverable in both directions.
- Keep one coherent rule readable without excessive file navigation.
- Prefer mechanically constrained dependencies over convention-only
  architecture where practical.

## Treat modules as implementation choices

Treat the following as responsibilities, not required directory or layer names:

- **concept code** owns public models, value objects, pure rules, and
  transitions independent from transport, database, and framework APIs;
- **use-case code** coordinates concepts and capabilities, applies
  cross-concept policy, and defines consistency boundaries;
- **external adapters** own I/O-specific operations, private representations,
  mappings, and technology-specific failures;
- **transport code** interprets CLI or HTTP input, formats output, and invokes
  use cases;
- **composition code** owns startup, configuration, dependency construction,
  shared resource lifecycle, and top-level error handling.

Keep dependencies pointing from outer concerns toward concept code. Map external
representations to application or domain concepts at an explicit boundary. Do
not create one module per responsibility when their invariants and change
drivers remain cohesive.
