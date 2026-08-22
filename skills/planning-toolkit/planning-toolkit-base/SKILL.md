---
name: planning-toolkit-base
description: >-
  The shared domain model behind planning work: the Outcome Contract, the
  Scope Policy plug point, scope and unknown classifications, decision
  authority, the readiness state machine, the boundary between durable
  knowledge and tracker state, Project/Milestone/Issue mapping, the atomic
  execution contract, and the handoffs from planning through resolution to
  execution. Applies whenever a delivery graph is created, interpreted,
  validated, or transitioned.
user-invocable: false
metadata:
  description-role: trigger
---

# Planning Toolkit Base

Apply the shared delivery model before running another `planning-toolkit-*`
workflow. This skill owns vocabulary and invariants; caller skills own actions.

Read [references/delivery-model.md](references/delivery-model.md) in full before
creating or interpreting a Project, assigning readiness, or handing work to
another Planning Toolkit skill.

## Ownership

This skill owns:

- the fields and convergence condition of the Outcome Contract;
- the elements a Scope Policy declares, and the default policy applied when a
  caller supplies none;
- Scope Disposition, Unknown Class, and Decision Authority vocabularies;
- the three readiness states and their legal transitions;
- what belongs in durable Markdown versus operationally in the tracker;
- the meanings of Project, Milestone, Issue, and dependency relations;
- the issue execution contract used across phases;
- the minimum handoff payload between Planning, Resolution, and Execution.

This skill does not:

- conduct dialogue or cut scope;
- supply a scope policy of its own beyond the default;
- execute research or settle a decision;
- groom or mutate tracker records by itself;
- write durable Markdown notes by itself;
- choose agents, commits, branches, PRs, or review cadence;
- define implementation progress or completion states, which belong to the
  execution skills.

Use `workflow-adapter-tracker` for tracker operations and
`workflow-adapter-markdown` for durable Markdown access. The model here adds
planning semantics; it does not duplicate provider mechanics.

## Delegation

- `planning-toolkit-plan` creates and confirms the contract and delivery graph.
- `planning-toolkit-resolve` consumes the resolution handoff, closes blocking
  uncertainty, applies outcomes downstream, and transitions readiness.
- `planning-toolkit-mvp` is a scope policy, not a phase. It declares the policy
  elements defined here and delegates the workflow to `planning-toolkit-plan`.
- Execution lives outside this family. Planning Toolkit certifies readiness and
  names the first unblocked work; which execution skill picks it up is not its
  concern.

If this base skill is unavailable, dependent Planning Toolkit skills must stop
before persisting or transitioning work. Reconstructing the shared contract ad
hoc can create an incompatible handoff.

## Change discipline

Add a concept here only when at least two Planning Toolkit skills must interpret
it identically. A scope policy's own vocabulary belongs to that policy, never
here; this skill knows only the shape a policy declares. Keep phase-specific
procedures and templates in their owning skill.
