# Concept and use-case model

Use this before deciding responsibility boundaries. Fill only the rows needed
to explain the target area. Keep domain meaning separate from current file,
class, database, and framework placement.

## Concept model

| Concept / type | Valid states and invariants | Owned rules and transitions | Relationships and ownership | Domain / external / persistence representations |
| --- | --- | --- | --- | --- |
| `Example` | What must always be true; illegal combinations | Creation, validation, conversions, transitions | Related concepts; which side controls the relation | Public type, request/response type, private row type |

Then answer:

1. Which generic primitives, maps, rows, or IDs conceal a distinct concept?
2. Which procedures are rules or transitions of one concept?
3. Which relationships must remain consistent?
4. Which concept owns each invariant rather than merely checking it?
5. Which terms from the shared domain language are missing or used
   inconsistently in the code?

## Use-case model

Model workflows from the consumer's intent rather than from operations already
offered by a database, service, or adapter.

| Use case / actor intent | Entry point | Concepts and rules coordinated | Required capabilities | Consistency requirement | Observable result |
| --- | --- | --- | --- | --- | --- |
| `<workflow>` | Command, handler, or application operation | Concepts read or changed | Minimum reads, writes, or external actions needed | What must succeed or fail together | Output, event, or externally visible state |

Then answer:

1. Which operations coordinate several concepts and belong to a use case?
2. Does each required capability describe the consumer's need, or copy a
   provider's complete API?
3. Can the use case depend directly on a concrete collaborator? If not, which
   change-isolation, substitution, or test need justifies a port?
4. Which use cases need the same capability but not the same coordinator?
5. Which failures and retries can expose an intermediate state?
6. Which behavioral test demonstrates the actor's intended result?

## Boundary forces

Analyze these independently before deciding which ones should align.

| Force | Questions | Decision |
| --- | --- | --- |
| Semantic ownership | Who owns each rule, invariant, and transition? | Concept or policy owner |
| Consumer capability | Who needs which minimal ability? | Consumer-facing public surface |
| Consistency | What must commit, roll back, or remain valid together? | Atomicity boundary and coordinator |
| Resource lifecycle | Who creates, shares, scopes, and releases physical resources? | Resource owner and composition |
| External representation | Where are technology-specific types, errors, and lifecycle semantics translated? | Adapter boundary |
| Change driver | Which parts change for the same reason, and which must remain independent? | Cohesion and separation choices |

Do not turn each row into a separate module automatically. Align rows only where
their invariants or representative changes require the same owner. Record why
any non-obvious forces share a boundary.

## Model-to-code map

Create this map after selecting boundaries and keep it proportional to the
decision. Record a location only when it makes ownership or navigation clearer.

| Model element | Semantic owner / entry point | Public surface | Collaborators or representations | Evidence / location |
| --- | --- | --- | --- | --- |
| `<concept>` | Type, module, or pure operation | Intentional concept API | Related concepts; private mappings | Invariant test or module |
| `<use case>` | Coordinator operation | Workflow input/output | Required consumer capabilities | Behavioral test or entry point |
| `<external adapter>` | Adapter or resource owner | Capability implementation | Private rows, wire types, driver APIs | Integration test or module |

Verify the map in both directions:

- Every relevant concept, invariant, and use case has an identifiable owner,
  entry point, or enforcement location.
- Every public module, type, and capability has an explainable domain purpose,
  use-case role, or boundary responsibility.
- A many-to-many mapping states which part owns meaning and which parts only
  coordinate, represent, or persist it.
