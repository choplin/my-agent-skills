---
name: repository-context-codebase
description: >-
  Creates, refreshes, or reviews a repository-owned Architecture Guide that
  gives developers a durable mental model of the current codebase: its design
  priorities, concepts, responsibilities, boundaries, invariants,
  representative flows, and common change paths. Use when developers or coding
  agents need shared architecture context that stays with the repository and
  evolves with the implementation.
---

# Maintain a codebase Architecture Guide

Create or maintain living developer documentation that lets a reader predict
where behavior belongs, which component owns a decision or state, how important
paths cross boundaries, and which constraints a change must preserve.

Apply `repository-context-base`, then read
[references/architecture-guide-model.md](references/architecture-guide-model.md)
in full. Repository-local rules and existing canonical documentation take
precedence over the default shape here. If the base skill is unavailable, stop
before changing or judging the canonical guide.

## Establish the operation

Infer the operation from the request:

- **Create** — no canonical guide exists; establish the smallest useful one.
- **Refresh** — compare an existing guide with the current implementation and
  correct drift without rewriting material that remains useful.
- **Review** — report inaccuracies and comprehension gaps without changing files
  unless the user also asks for revision.

Treat the current worktree, including in-scope uncommitted changes, as the
implementation under examination unless the user names another snapshot. This
does not authorize unrelated dirty changes to redefine the guide; distinguish
them and keep them out of scope. This guide describes current shared truth, not
one frozen revision. Use
`codebase-explainer` instead when the requested deliverable is a standalone,
snapshot-specific explanation of one question. Use `codebase-structure` when
the task is to design or implement a target structure rather than document the
one that exists.

## Inspect before authoring

Read repository instructions and inventory the existing README, developer docs,
architecture documents, ADRs, manifests, module boundaries, generated-code
markers, entry points, configuration, and representative tests. Load an
installed `lang-reference-<language>` skill for the dominant implementation
language when available.

Start broad and shallow. Identify the smallest set of components and flows that
reveals:

- the system purpose and structural priorities;
- the core vocabulary and its code representations;
- owners of decisions, state, capabilities, and side effects;
- allowed dependency directions and binding invariants;
- representative end-to-end behavior;
- the starting points and constraints for recurring classes of change.

Then inspect definitions, construction or registration, important call sites,
configuration, and tests together before assigning responsibility. Do not read
every file or infer architecture from the directory tree alone.

## Build an evidence map

Separate:

- **observed implementation** — supported directly by current code,
  configuration, or tests;
- **documented intent** — stated by current repository documentation, comments,
  or decisions and still expressed by the implementation;
- **unknown** — plausible rationale or ownership that the evidence does not
  establish.

Resolve material unknowns through further repository evidence or leave them out.
Never present an inference as design intent. Attach rationale only when it still
explains a currently binding choice, constraint, or trade-off.

## Select the canonical shape

Extend the repository's existing source of truth. If none exists, default to one
`docs/architecture.md`. Split only when independently useful topics have
different owners or change cadence, or when one guide no longer provides a
coherent entry path. Keep one canonical overview when splitting.

Use the reference's claim-level inclusion test and comprehension facets. They
are selection tools, not mandatory headings. Prefer stable repository-relative
paths and symbols over line numbers, commit-pinned links, or exhaustive file
lists.

## Author or review

For **Create**, write the smallest guide that meets the comprehension criteria.
For **Refresh**, verify every material existing claim, remove obsolete narration,
merge duplicate explanations, and add only newly necessary context. Preserve
the document's established vocabulary and useful reading path.

For **Review**, return prioritized findings. For each one, state the unsupported
or missing claim, current repository evidence, its effect on developer
understanding or safe change, and the smallest correction. Do not turn style
preferences into architecture findings.

Add a diagram only when a relationship, ownership model, or multi-step flow is
materially harder to understand in prose. First define and obtain approval for
its communication brief and intended document placement. Then apply
`repository-context-pen-design`; do not improvise its visual workflow here.

If the main README needs a substantial content or reader-journey revision, apply
`repository-context-readme`. A small, factual link to the canonical developer
guide does not require rewriting the README workflow.

## Verify and deliver

Before completing a write:

1. re-check each architectural claim against current evidence;
2. confirm source anchors, document links, and diagram paths resolve;
3. confirm tentative work, future design, and unverified rationale are absent;
4. confirm the guide explains ownership and constraints rather than cataloging
   code;
5. read the guide once from the perspective of a developer locating a common
   change.

Report the canonical document path, the operation performed, the principal
mental-model decisions, evidence examined, and any material area that could not
be verified. Do not claim the guide covers the entire repository when the
investigation was scoped.
