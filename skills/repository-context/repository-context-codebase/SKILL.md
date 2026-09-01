---
name: repository-context-codebase
description: >-
  Creates, refreshes, or reviews repository-owned developer documentation that
  gives developers a durable architectural mental model, gives each detailed
  design topic one full canonical treatment, and keeps decision chronology
  separate. Use when developers or coding agents need shared context for
  understanding, implementing, verifying, or safely changing a repository.
---

# Maintain codebase developer documentation

Create or maintain developer documentation that first gives readers a coherent
mental model, then lets them reach the exact design contracts and decision
history they need. Keep those layers distinct and give each settled claim one
canonical home.

Apply `repository-context-base`, then read
[references/developer-documentation-model.md](references/developer-documentation-model.md)
in full. Repository-local rules and existing canonical documentation take
precedence over the default shape here. If the base skill is unavailable, stop
before changing or judging the canonical developer documentation.

## Establish the operation

Infer the operation from the request:

- **Create** — no canonical developer-documentation set exists; establish the
  smallest useful entry path and its governing policy.
- **Refresh** — compare existing documents with the implementation and settled
  design direction, then correct drift without rewriting material that remains
  useful.
- **Review** — report inaccuracies and comprehension gaps without changing files
  unless the user also asks for revision.

Treat the current worktree, including in-scope uncommitted changes, as the
implementation under examination unless the user names another snapshot. This
does not authorize unrelated dirty changes to redefine the documentation;
distinguish them and keep them out of scope. A documented target architecture
must be established repository direction, not an agent's proposal. Use
`codebase-explainer` instead when the requested deliverable is a standalone,
snapshot-specific explanation of one question. Use `codebase-structure` when
the task is to design or implement a target structure rather than document the
one the repository has already established.

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
- **established direction** — stated by canonical repository documentation or
  accepted decisions, whether already implemented or still tracked as work;
- **unknown** — plausible rationale or ownership that the evidence does not
  establish.

Resolve material unknowns through further repository evidence or leave them out.
Never present an inference as established direction. Attach rationale only when
it still explains a binding choice, constraint, or trade-off.

## Select the canonical shape

Apply the reference's documentation structure and placement test. Extend the
repository's existing equivalents; when none exist, use the reference's default
shape. Use its claim-level inclusion test and comprehension facets as selection
tools, not mandatory headings. Prefer stable repository-relative paths and
symbols over line numbers, commit-pinned links, or exhaustive file lists.

## Author or review

For **Create**, write the smallest documentation set that meets the
comprehension criteria and makes the layers unambiguous. For **Refresh**, verify
every material existing claim, remove obsolete narration, merge duplicate
explanations, and add only newly necessary context. Preserve the documents'
established vocabulary and useful reading path.

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
documentation entry point does not require rewriting the README workflow.

## Verify and deliver

Before completing a write:

1. re-check each architectural claim against implementation or explicit,
   established repository direction;
2. confirm source anchors, document links, and diagram paths resolve;
3. apply every completion criterion in the reference to the finished
   documentation set;
4. read the entry path once from the perspective of a developer locating a
   common change.

Report the canonical entry-point path, the operation performed, the principal
placement decisions, evidence examined, and any material area that could not be
verified. Do not claim the documentation covers the entire repository when the
investigation was scoped.
