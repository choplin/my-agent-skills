---
name: mvp-toolkit-base
description: >-
  Shared domain model and handoff contract for the MVP Toolkit skill family.
  Defines the MVP Contract, scope and unknown classifications, decision
  authority, readiness state machine, llm-wiki/Linear ownership boundary,
  MVP-specific Project/Milestone/Issue mapping, atomic execution contract, and
  Planning-to-Resolution-to-Orchestration handoffs. Use when another
  mvp-toolkit skill needs to create, interpret, validate, or transition an MVP
  delivery graph. Not typically invoked on its own and does not plan, research,
  decide, or implement work.
---

# MVP Toolkit Base

Apply the shared MVP delivery model before running another `mvp-toolkit-*`
workflow. This skill owns vocabulary and invariants; caller skills own actions.

Read
[references/mvp-delivery-model.md](references/mvp-delivery-model.md) in full
before creating or interpreting an MVP Project, assigning readiness, or handing
work to another MVP Toolkit skill.

## Ownership

This skill owns:

- the fields and convergence condition of the MVP Contract;
- Scope Disposition, Unknown Class, and Decision Authority vocabularies;
- the three readiness states and their legal transitions;
- what belongs durably in llm-wiki versus operationally in Linear;
- MVP-specific meanings for Project, Milestone, Issue, and dependency relations;
- the issue execution contract used across phases;
- the minimum handoff payload between Planning, Resolution, and Orchestration.

This skill does not:

- conduct product dialogue or cut scope;
- execute research or settle a decision;
- groom or mutate Linear by itself;
- write llm-wiki notes by itself;
- choose agents, commits, branches, PRs, or review cadence;
- define implementation progress or completion states for the future
  Orchestration workflow.

Apply `linear-base` for generic Linear mechanics and the installed llm-wiki
skills for knowledge-base mechanics. The model here adds MVP semantics; it does
not duplicate those skills.

## Delegation

- `mvp-toolkit-planning` creates and confirms the contract and delivery graph.
- `mvp-toolkit-resolution` consumes the resolution handoff, closes blocking
  uncertainty, applies outcomes downstream, and transitions readiness.
- `mvp-toolkit-orchestration` will consume READY implementation work when that
  skill exists.

If this base skill is unavailable, dependent MVP Toolkit skills must stop before
persisting or transitioning work. Reconstructing the shared contract ad hoc can
create an incompatible handoff.

## Change discipline

Add a concept here only when at least two MVP Toolkit skills must interpret it
identically. Keep phase-specific procedures and templates in their owning skill.
Do not anticipate Orchestration details before that skill establishes a real
shared need.
