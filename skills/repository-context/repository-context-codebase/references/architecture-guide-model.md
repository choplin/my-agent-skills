# Architecture Guide Model

An Architecture Guide is living developer documentation for understanding and
changing the current codebase. It is a compressed mental model, not a frozen
explanation, file catalog, design proposal, or historical ledger.

## Contents

- [The inclusion test](#the-inclusion-test)
- [Comprehension facets](#comprehension-facets)
- [Conditional facets](#conditional-facets)
- [What to leave out](#what-to-leave-out)
- [Evidence and rationale](#evidence-and-rationale)
- [Placement and shape](#placement-and-shape)
- [Maintenance contract](#maintenance-contract)
- [Completion criteria](#completion-criteria)

## The inclusion test

Include a claim only when all four conditions hold:

1. **It changes understanding or action.** It helps a reader predict where a
   behavior belongs, identify ownership, trace an important path, or preserve a
   boundary or invariant during change.
2. **Code does not reveal it cheaply and safely.** Reconstructing it requires
   joining evidence across modules, discovering implicit conventions, or
   guessing at intent or responsibility.
3. **It is stable enough to maintain.** It describes a durable concept,
   responsibility, relationship, flow, or constraint rather than incidental
   implementation detail.
4. **It is verifiable now.** Current code, configuration, tests, or explicit
   repository documentation supports it. A plausible inference alone is not a
   shared fact.

Use the test at claim level. A useful section can still contain one line that
does not earn its maintenance cost.

## Comprehension facets

These are facets of the mental model, not mandatory headings. Combine, rename,
or omit them when the repository makes a facet trivial.

### Purpose and design priorities

State the system or subsystem role and the qualities that actually shape its
structure. Name trade-offs concretely: for example, deterministic local
execution over horizontal scale, or centralized policy over extension freedom.
Do not repeat product positioning from the README.

### Core concepts

Define the small vocabulary needed to reason about the system. Relate domain
concepts to their code representations where the mapping is not obvious. Avoid
a glossary of every type.

### Components and ownership

Map the major components and the decisions, state, or capabilities each owns.
Explain why a boundary exists when that reason still constrains changes. Use
directories and important symbols as anchors, not as the organizing principle.

### Boundaries, dependencies, and invariants

State allowed dependency directions, prohibited coupling, side-effect
boundaries, data ownership, and rules that must remain true. Prefer rules a
developer can apply to a new change over descriptions of today's imports.

### Representative flows

Trace only the few end-to-end paths that make the architecture legible. Start
at an external or user-visible entry, cross orchestration and policy, identify
state transitions and side effects, and finish at observable output or failure.
Choose flows for explanatory coverage, not feature coverage.

### Change map

For recurring classes of change, identify the owning concepts and components,
the usual extension points, and the constraints to preserve. Do not turn this
into a recipe for every possible task or duplicate contribution instructions.

## Conditional facets

Add a focused section only when it materially changes the mental model:

- data ownership and lifecycle;
- external integration boundaries;
- runtime or deployment topology;
- security and trust boundaries;
- concurrency, consistency, or failure semantics;
- generated-code or build-time boundaries.

## What to leave out

- exhaustive directory, file, class, endpoint, or schema inventories;
- API details already owned by generated reference or source-level docs;
- tentative hypotheses, unresolved discussion, and session narration;
- open work, milestones, migration progress, and future architecture;
- a chronological record of decisions or alternatives no longer binding;
- low-level call graphs or diagrams whose upkeep follows code churn;
- claims copied from stale docs without checking the implementation.

## Evidence and rationale

Prefer direct evidence in current code, configuration, and tests. Treat existing
documentation as evidence of intent, then verify that the implementation still
expresses it. If intent cannot be established, document the observable
responsibility or constraint without inventing a reason.

Attach current rationale to the choice it explains. For example:

> The application layer depends on ports rather than adapters so CLI and HTTP
> entry points share the same use cases.

The first half is a boundary; the second makes the boundary predictable. Keep
the rationale only while that reason remains true and relevant. Put detailed
history in the repository only when local conventions require it or future
contributors need the history itself, rather than the current constraint.

Use stable anchors such as `internal/orders`, `OrderRepository`, or a manifest
name. Avoid line coordinates, commit-pinned links, and lists of every participant
in a pattern. The guide must remain useful across ordinary refactors.

## Placement and shape

Use the repository's existing developer-documentation structure. If none
exists, start with one `docs/architecture.md`. A useful default reading order is:

1. summary and design priorities;
2. core concepts;
3. component and ownership map;
4. boundaries and invariants;
5. representative flows;
6. guidance for common changes.

Split only when readers can enter through one overview and the extracted topic
is independently coherent. A typical split retains `docs/architecture/README.md`
as the entry point and moves concepts, boundaries, or flows into adjacent files.

Diagrams are optional. Use one when it makes a relationship, ownership model,
or multi-step flow materially easier to understand than prose. Keep its source
with the documentation and verify it whenever the described structure changes.

## Maintenance contract

The guide describes the current implementation. Therefore:

- change a documented claim in the same changeset as the code that invalidates
  it;
- rewrite or remove superseded material rather than retaining before/after
  narration;
- merge duplicate explanations into one canonical location and link to it;
- preserve useful local detail in code comments or reference docs instead of
  expanding the architectural entry point;
- periodically compare the guide with code when ownership or boundaries have
  moved without an obvious documentation edit.

Git already records document history; a maintained `last updated` date does not
prove freshness and is not required.

## Completion criteria

A guide is sufficient when a developer unfamiliar with the implementation can:

- state the system's structural priorities and core vocabulary;
- identify the owner of the major decisions, state, and side effects;
- predict the allowed direction across important boundaries;
- trace at least one representative behavior end to end;
- locate the starting points for a common change and name the invariants it must
  preserve;
- distinguish documented fact and intent from anything still unknown.

More pages, components, and diagrams do not improve the guide unless they close
one of these comprehension gaps.
