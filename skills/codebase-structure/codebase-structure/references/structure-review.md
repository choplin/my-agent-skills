# Structure review

Use this after proposing boundaries and before concluding a design or structural
review. Review observable dependency and ownership relationships, not just the
directory tree.

## Falsify with representative changes

Choose scenarios representative of the codebase rather than applying every
prompt mechanically. For each scenario, trace which public surfaces, modules,
tests, adapters, and composition code would have to change.

- Add a use case that needs one existing capability and one new capability.
- Change one invariant or add a new atomic relationship.
- Replace a database driver, external service, framework, or serialization
  format.
- Move one capability to a different adapter while keeping others on the
  existing implementation.
- Add a second implementation or a test double for one consumer.
- Change the lifecycle or sharing policy of a connection, process, filesystem
  handle, or similar resource.

Revise the structure when a scenario forces an unrelated consumer or concern to
change. Do not optimize for hypothetical replaceability without a representative
change driver.

## Check boundary closure

Inspect the complete public surface of each selected boundary:

- Public types and type aliases use representations owned by the boundary.
- Errors express meaning appropriate to the caller rather than exposing a
  driver, protocol, or framework accidentally.
- Generic constraints, callbacks, annotations, generated APIs, and macros do
  not import an external representation through a side door.
- Transaction, retry, streaming, cancellation, and resource-lifecycle
  semantics are explicit at the boundary that owns them.
- A consumer depends only on capabilities required by its workflow.
- Every port or split contract has a concrete change-isolation, substitution,
  or test-control reason; none exists only to mirror a use-case directory.

Source placement alone is not evidence of encapsulation.

## Check static structural legibility

Confirm that a reviewer can determine these facts without reconstructing the
whole runtime object graph:

- the owner of each important concept, invariant, and state transition;
- the entry point and observable result of each relevant use case;
- allowed dependency directions and external boundaries;
- the owner and lifecycle of shared physical resources;
- the coordinator and atomicity boundary for coupled changes;
- the composition root where implementations and resources are connected.

Prefer public surfaces, types, imports, visibility, and mechanically enforced
dependency rules as evidence. Treat prose-only conventions and implicit runtime
registration as weaker evidence.

## Check model-to-code traceability

Navigate in both directions:

1. From each shared domain concept, invariant, and use case, find its semantic
   owner, entry point, collaborators, and behavioral evidence.
2. From each public module, type, capability, and coordinator, explain the
   domain purpose, use case, or boundary responsibility it serves.

Look for:

- model elements with no identifiable implementation or enforcement point;
- public code with no clear model or boundary purpose;
- several equally plausible owners for the same rule;
- domain vocabulary replaced by infrastructure terminology;
- behavioral tests that exercise technical operations without naming the user
  or domain intent.

A mapping may be one-to-many or many-to-one. Require explicit roles, not one file
per concept or use case.

## Check review locality

Select a representative local change and estimate the context needed to verify
it. The structure should keep the review scope close to the semantic scope of
the change.

- Keep code that must change together for one invariant cohesive.
- Avoid requiring unrelated adapters or consumers to be understood.
- Avoid indirection that hides control flow or ownership behind global
  registration, string keys, or convention.
- Avoid file fragmentation that makes one coherent rule require excessive
  navigation.

Record unresolved boundaries, ambiguous ownership, and evidence that could not
be obtained.
