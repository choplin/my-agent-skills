# Integration boundaries

Use this guidance when one external integration combines native discovery or
identity, application-specific selection or normalization, and coordinated
persistence. It is a diagnostic model, not a required three-layer architecture.

## Distinguish meaning at one I/O boundary

An external system can carry two different kinds of meaning:

- knowledge and operations that remain true without the consuming application;
- application-specific rules for selecting, normalizing, bounding, diagnosing,
  or accepting data from that system.

Do not collapse them merely because they share an I/O boundary. Separate them
when representative changes have different semantic owners:

- **external-system-native knowledge** may own identity, configuration
  precedence, source layout, native discovery, validation, and native
  representations;
- **application projection** may own selection, normalization, bounds,
  diagnostics, and application-facing outcomes;
- **use-case coordination** may own invocation, consistency, persistence,
  aggregate reporting, and resource lifecycle.

These are responsibilities, not required modules or type names. Keep them
together when their change drivers and invariants remain cohesive.

## Derive call direction from the use case

Identify the concept that initiates the use case and owns its observable result.
Let that coordinator invoke the external capability and retain control of
coupled writes and transaction scope.

Hiding a database type behind a repository or sink does not establish a correct
boundary if it lets an external adapter initiate application persistence,
choose atomicity, or control retries that affect application consistency.
Passing persistence capability to an adapter is evidence to inspect, not an
automatic violation; it may be valid when that adapter is itself the use-case
owner.

## Place polymorphism at the consumed capability

Introduce a shared port only when a consumer needs a uniform capability for
change isolation, substitution, or test control. Do not require native models
to implement a common interface when their meaningful operations differ.

Keep the coordinator free of implementation-specific branching only when the
implementations genuinely share the same application-facing workflow. A fixed
set of providers or provider-specific coordination can justify explicit
branches; record that change driver rather than hiding it behind an artificial
port.

## Separate knowledge from execution state

Separate long-lived native knowledge from per-execution state when their
lifecycles differ. For example, a provider model may own root-resolution and
source-layout rules while a scanner creates a single-pass cursor for one
application scan.

This separation does not require accumulating all outcomes in memory. Make
streaming, cancellation, retry, cleanup, and single-pass semantics explicit at
the boundary that owns them.

## Review the direction

Ask:

- Which rules would still exist if the consuming application disappeared?
- Which rules exist only because the application selects, normalizes, or
  accepts external data?
- Which concept initiates the use case and owns its observable result?
- Which writes must succeed or fail together, and does that owner control the
  transaction?
- Does an external adapter receive a connection, repository, or sink that lets
  it choose application consistency?
- Would replacing persistence unexpectedly change external-system-native or
  projection code?
- Would adding another implementation unexpectedly require
  implementation-specific branching in the coordinator?
- Does a shared interface contain operations needed only by diagnostics,
  composition, or another consumer?

Revise the boundary when external-system knowledge leaks into orchestration,
application persistence leaks into an external capability, or a consumer
depends on operations its workflow does not use.
