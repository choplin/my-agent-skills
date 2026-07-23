# Concept model template

Use this before deciding responsibility boundaries. Fill only the rows necessary
to explain the target area; update it when discovery changes the model.

| Concept / type | Valid states and invariants | Owned rules and transitions | Relationships and ownership | Domain / external / persistence representations |
| --- | --- | --- | --- | --- |
| `Example` | What must always be true; illegal combinations | Creation, validation, conversions, transitions | Related concepts; which side controls the relation | Public type, request/response type, private row type |

Then answer:

1. Which generic primitives, maps, rows, or IDs currently conceal a distinct
   concept?
2. Which procedures are really rules or transitions of one concept?
3. Which operations coordinate several concepts and therefore belong to a use
   case rather than one domain type?
4. Which relationships must change atomically?
5. What module name describes each concept without referring to a technical
   bucket such as `util`, `service`, or `store`?

## Responsibility map

Use this map to decide ownership and dependency direction. It does not prescribe
directory names or a layer scheme. Record an existing or intended location only
when that helps make the chosen boundary concrete.

| Responsibility / concept | Owns | Public surface | Must not depend on | Location (optional) |
| --- | --- | --- | --- | --- |
| `<concept>` | Type(s), invariants, pure behavior | Intentional concept API | Transport, database APIs, composition | Existing or chosen module |
| `<cross-concept workflow>` | Coordination and transaction boundary | Workflow input/output | Private rows and raw queries | Existing or chosen module |
| `<external adapter>` | Queries, rows, I/O mapping | Adapter API | Transport formatting and concept-internal policy | Existing or chosen module |
| `<transport boundary>` | Scope, dependency resolution, I/O mapping | CLI/HTTP contract | Concept implementation details | Existing or chosen module |
