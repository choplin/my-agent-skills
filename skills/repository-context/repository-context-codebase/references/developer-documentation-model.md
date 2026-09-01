# Developer Documentation Model

Developer documentation under `docs/` supports people changing the repository.
Its top level is a compressed mental model; exact design contracts, their
rationale, and decision history live in distinct layers. It is not product-user
documentation, a file catalog, an issue tracker, or a collection of ADRs.

## Contents

- [The inclusion test](#the-inclusion-test)
- [Comprehension facets](#comprehension-facets)
- [Conditional facets](#conditional-facets)
- [What to leave out](#what-to-leave-out)
- [Evidence and rationale](#evidence-and-rationale)
- [Documentation structure](#documentation-structure)
- [Placement test](#placement-test)
- [Maintenance contract](#maintenance-contract)
- [Completion criteria](#completion-criteria)

## The inclusion test

Include a claim only when the first three conditions and one layer-specific
condition hold:

1. **It changes understanding or action.** It helps a reader predict where a
   behavior belongs, identify ownership, trace an important path, or preserve a
   boundary or invariant during change.
2. **It is stable enough to maintain.** It describes a durable concept,
   responsibility, relationship, flow, or constraint rather than incidental
   implementation detail.
3. **It is established now.** Current code, configuration, tests, or explicit
   repository decisions support it as present behavior or accepted direction.
   A plausible inference or an agent-proposed design is not a shared fact.
4. **Its layer needs it.** Apply the matching test:
   - At the top level, reconstructing the claim from code would require joining
     evidence across modules or guessing at ownership, intent, or relationships.
   - In `design/`, the claim is part of the exact current contract, rationale,
     rejected alternatives, or explanatory history for one design topic and is
     needed to implement, verify, or judge that topic.
   - In the decision log, the claim records when a decision was made or changed
     and points to the current document that owns the resulting rule.

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
- open work, milestones, migration progress, and implementation gaps;
- a chronological record of decisions or alternatives no longer binding; put
  that sequence in the repository's decision log when it has continuing value;
- low-level call graphs or diagrams whose upkeep follows code churn;
- claims copied from stale docs without checking the implementation.

## Evidence and rationale

Prefer direct evidence in current code, configuration, and tests for
implemented behavior. Treat existing documentation and accepted decisions as
evidence of established direction. If implementation and established
architecture differ, document the architecture without annotating the gap;
track the work to close it outside canonical documentation. If neither behavior
nor direction can be established, do not invent one.

Attach current rationale to the choice it explains. For example:

> The application layer depends on ports rather than adapters so CLI and HTTP
> entry points share the same use cases.

The first half is a boundary; the second makes the boundary predictable. Keep
the rationale only while that reason remains true and relevant. Keep the
current rule and rationale in their canonical design document. When the order
of decisions has continuing value, record a concise chronological entry in the
decision log and link back to that canonical document; do not make the log a
second explanation of the current design.

Use stable anchors such as `internal/orders`, `OrderRepository`, or a manifest
name. Avoid line coordinates, commit-pinned links, and lists of every participant
in a pattern. The documentation must remain useful across ordinary refactors.

## Documentation structure

Use the repository's existing developer-documentation structure when it has
clear equivalents for these responsibilities. Otherwise use:

```text
docs/
├── README.md
├── architecture.md
├── <unit>.md
├── design/
│   └── <topic>.md
└── decision-log.md
```

### `docs/README.md`: organization policy

Define who `docs/` is for, what each layer owns, and how to choose placement.
Do not list or summarize individual documents. Adding or removing a document
must not require editing this file.

### Top level: the mental model

Use `docs/architecture.md` as the entry point. Let every other top-level
document cover one coherent architectural unit, such as a component, module,
or subsystem, and make it reachable by following links from the entry point.

A top-level document states the unit's shape, relationships, governing
principles, background, and goals at the depth needed to hold its mental model.
It is deliberately not exhaustive. It describes the architecture the
repository is built toward when that direction is established. Do not annotate
it with temporary implementation gaps; track those as work. Do not use it to
defend the chosen shape against rejected alternatives; that rationale belongs
to the relevant design topic.

A useful reading order for the entry point is:

1. summary and design priorities;
2. core concepts;
3. component and ownership map;
4. boundaries and invariants;
5. representative flows;
6. guidance for common changes.

### `docs/design/`: one topic in full

Give each file one design topic: a question that could reasonably have been
answered another way. State the exact rule, its rationale, rejected
alternatives, and past history only where that history explains the current
choice. Include precise procedures, edge cases, canonical forms, and worked
examples when implementers, reviewers, or evaluators need them.

Split by design topic, not by the top-level document that links to it. One
top-level document may link to several design topics, and one design topic may
support several architectural units.

Design documents are not ADRs. When a decision changes, rewrite the topic in
place so it continues to describe the present rule and rationale.

Do not introduce ADRs by default. When a repository already uses them, follow
its convention, but do not let an ADR replace the design topic that owns the
current rule or the decision log that owns chronology.

### `docs/decision-log.md`: history

Maintain a chronological table of decisions made or changed. Link each entry to
the current document that owns the resulting rule. The log records when a
decision happened and what it replaced; it does not become a second source of
current design truth.

### Single source of truth

Give every settled claim exactly one canonical home. A top-level document may
summarize a rule at the depth needed for the mental model and link to `design/`
for its precise form and rationale. The design document owns that detail and
does not restate the structural summary.

## Placement test

Put a passage at the top level when a reader needs it to hold the shape of an
architectural unit in mind. Put it in `design/` when the reader can understand
the shape without it but needs it to implement, verify, or judge whether the
rule should change. Put the timing of a decision in `decision-log.md`. Put an
implementation gap or migration step in the work tracker.

Diagrams are optional. Use one when it makes a relationship, ownership model,
or multi-step flow materially easier to understand than prose. Keep its source
with the documentation and verify it whenever the described structure changes.

## Maintenance contract

The documentation describes established architecture and current design rules.
Therefore:

- change a documented claim in the same changeset as the decision that
  invalidates it;
- rewrite or remove superseded material rather than retaining before/after
  narration;
- merge duplicate explanations into one canonical location and link to it;
- preserve useful local detail in code comments or reference docs instead of
  expanding the top-level mental model;
- keep implementation-gap narration in the tracker rather than canonical
  architecture documents;
- periodically compare the documents with implementation and accepted
  decisions so accidental drift is visible.

Git already records document history; a maintained `last updated` date does not
prove freshness and is not required.

## Completion criteria

The documentation set is sufficient when a developer unfamiliar with the
implementation can:

- identify the documentation layers and place a new passage without consulting
  an inventory of current files;
- reach every top-level architectural-unit overview from the architecture entry
  point;
- verify that each top-level unit document contains one coherent mental model
  without implementer-level detail or a defense of rejected alternatives;
- verify that each design document treats one design topic in full: its precise
  rule, rationale, rejected alternatives, and only history that explains the
  current choice;
- verify that the decision log records chronology and links to current truth
  without restating it;
- verify that implementation gaps and tentative proposals remain in the work
  tracker and that each settled claim has one canonical home;
- state the system's structural priorities and core vocabulary;
- identify the owner of the major decisions, state, and side effects;
- predict the allowed direction across important boundaries;
- trace at least one representative behavior end to end;
- locate the starting points for a common change and name the invariants it must
  preserve;
- locate the exact contract and rationale for a design topic;
- distinguish current design truth, decision history, and implementation work.

More pages, components, and diagrams do not improve the documentation unless
they close one of these comprehension gaps.
