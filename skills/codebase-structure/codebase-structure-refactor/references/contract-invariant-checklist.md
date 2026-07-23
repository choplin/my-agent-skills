# Contract and invariant checklist

Use this before and after each behavior-affecting restructuring. Mark an item as
verified only by inspection, test, or an explicit known limitation.

## External contract

- CLI commands, flags, argument interpretation, and help text
- HTTP route, method, status, request/response shape, and JSON field behavior
- Error type, message, and mapping where callers or tests depend on them
- Ordering, pagination, filtering, scoping, and default values
- Empty results, absent/optional state, and not-found behavior
- Idempotence and retry behavior
- Permission boundaries and all-scope restrictions

## Domain and persistence invariants

- Valid states cannot be bypassed through public construction or mutation
- Every state transition has one clearly owned rule
- Cross-concept policy is visible in a use case rather than hidden in a mapper
- Writes that jointly preserve an invariant share one transaction
- Failure or retry cannot leave an unintended partial state
- Domain values do not expose database rows, query results, ORM models, or SQL
- Query cache, offline metadata, or generated SQL artifacts match the queries

## Evidence record

| Concern | Evidence | Result / limitation |
| --- | --- | --- |
| Contract | Test, fixture, manual invocation, or diff inspection | Preserved / known difference |
| Invariant | Test, transaction inspection, or failure-path review | Preserved / follow-up |
