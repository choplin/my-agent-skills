# Human reviewability goal

Use human reviewability as the objective behind the structure guidance,
especially when people and AI agree on the domain and use cases together, then
delegate implementation to AI.

## Objective

Structure the codebase so a human can verify an implementation against the
shared domain and use-case model from its static state. Minimize the unnecessary
context, navigation, and inference required to:

- map a change to the shared model and vocabulary;
- locate semantic owners, use-case entry points, and enforcement points;
- follow dependency direction and external boundaries;
- identify consistency boundaries and physical resource ownership;
- determine behavioral impact and find the evidence that verifies it.

Static state includes the source tree, names, types, public surfaces, imports,
visibility, composition, tests, and mechanically enforced dependency rules. A
reviewer should not need undocumented history, the original author, or a
reconstruction of the complete runtime object graph to understand these facts.

Do not minimize essential domain complexity. Make that complexity explicit and
place it with its semantic owner. Minimize accidental cognitive load caused by
ambiguous ownership, hidden connections, vocabulary drift, and unnecessary
indirection.

## States with high cognitive load

Treat these as evidence that the structure requires excessive context or
inference:

- **Ambiguous ownership:** the same rule has several plausible homes, such as a
  model, service, handler, mapper, or repository.
- **Vocabulary drift:** agreed domain or use-case terms are absent, renamed
  inconsistently, or replaced by infrastructure terminology.
- **Hidden control flow:** runtime registration, string keys, callbacks,
  reflection, or dependency-injection machinery must be reconstructed to find
  what executes.
- **Scattered invariants:** one rule or atomic change requires reading many
  distant files whose relationship is not visible from their public surfaces.
- **Mixed change drivers:** code that changes for unrelated domain, use-case,
  and technology reasons shares one module or contract.
- **Provider-shaped dependencies:** consumers receive a provider's complete
  capability set, and test doubles must implement operations their workflows do
  not use.
- **Leaky boundaries:** public types, errors, constraints, or lifecycle
  semantics expose representations owned by a database, driver, framework, or
  protocol.
- **Invisible consistency or resource ownership:** transaction scope,
  connection sharing, startup, or cleanup becomes clear only by tracing runtime
  behavior.
- **Excessive fragmentation:** one coherent rule is split across tiny files,
  interfaces, wrappers, or forwarding layers that add navigation without
  isolating a real change.
- **Convention-only architecture:** dependency rules exist in prose but are not
  visible or constrained through types, imports, visibility, tests, or tooling.
- **Unexplained public code:** a public module, type, or operation cannot be
  traced back to a domain purpose, use case, or boundary responsibility.

## States with high static legibility

A statically legible structure makes these relationships directly observable:

- Shared domain and use-case vocabulary appears consistently in concept types,
  workflow entry points, public capabilities, and behavioral tests.
- Each important rule, invariant, and transition has one discoverable semantic
  owner.
- Each use case has an identifiable entry point, observable result, required
  collaborators, and consistency requirement.
- Imports, visibility, and public surfaces reveal allowed dependency direction;
  adapters and the composition root reveal external connections.
- Shared physical resources have a visible lifecycle owner, without forcing
  their boundary to match every capability they support.
- Public surfaces are closed over caller-appropriate concepts rather than
  leaking technology-owned representations.
- A reviewer can navigate from a model element to its implementation and
  evidence, and from public code back to the purpose it serves.
- A change can be reviewed from context close to its semantic scope; unrelated
  adapters, consumers, and workflows do not need to be understood.
- Representative changes have predictable propagation, and architecture
  violations are mechanically detectable where practical.

These properties do not require one file per concept, one module per use case,
or one port per consumer. Prefer the structure that exposes meaning and limits
unrelated review context with the least justified indirection.

## Compare alternatives

Compare candidate structures by performing the review tasks in the objective.
Prefer the candidate that requires less unrelated context, fewer implicit
connections, and fewer unsupported assumptions while preserving the same domain
meaning and correctness.

Do not use file count, module count, interface count, or layer count as a proxy
for cognitive load. Both a procedural monolith and a highly fragmented
architecture can be difficult to review for different reasons.
