---
name: planning-toolkit-mvp
description: >-
  The MVP scope policy: the justification standard applied when the goal is to
  prove or disprove a hypothesis with the smallest thing that can be built.
  Declares the policy and hands the workflow on; it defines no steps of its
  own. Applies when work is framed as an MVP, a first version, a proof of
  concept, a pilot, or the smallest slice worth learning from, and the
  planning has to defend that narrowness.
metadata:
  description-role: trigger
---

# MVP Scope Policy

The MVP and its hypothesis arrive already decided. This policy governs only what
gets built to test them: the build exists to produce **evidence**, so a
capability that does not serve that evidence has no claim on the scope.

This skill is a declaration. It owns no workflow.

1. Load `planning-toolkit-base` and apply its `references/delivery-model.md`.
2. Declare this policy as the Scope Policy in force.
3. Run `planning-toolkit-plan`, which consumes the policy elements below.

Do not restate or summarize the planning workflow here or in the session; run it
from `planning-toolkit-plan` so the two never drift.

## Policy declaration

### Outcome expression

State the Outcome as the **smallest value loop**: the shortest end-to-end use
that delivers real value to the target user. Not a feature list, not a component,
and not a phase of a larger build.

### Additional contract fields

| Field | Meaning |
|---|---|
| **Hypothesis** | What this MVP is intended to prove or disprove. |
| **Evidence** | The observable result that counts as learning or success. |

Both are required, and both are given. Take them from the source material, or
from the user when the sources leave them implicit. This policy records them and
cuts scope against them; whether the bet itself is worth making was settled
before planning started.

### Inclusion test

A capability is In Scope only when at least one holds:

- the smallest value loop cannot run end to end without it;
- the Evidence cannot be observed without it;
- it is required to operate the MVP safely or legally;
- a binding Constraint requires it;
- omitting it would cost disproportionately more to reverse later than building
  it now.

A capability that merely makes the MVP better, faster, or more complete fails
this test.

### Challenge lenses

Argue every inclusion against all of these before accepting it:

- abstractions with only one current implementation;
- flexibility for hypothetical future variants;
- optimization for unobserved scale;
- completeness that does not change the Evidence;
- infrastructure whose only benefit is making later work cleaner;
- feature parity beyond the smallest value loop.

Prefer a temporary manual step or a deliberately narrow implementation when it
can test the same hypothesis without unacceptable risk. "We will have to build it
eventually" is not a reason to build it now.

### Deferred handling

For every Deferred capability, preserve the exclusion rationale **and the
evidence that would promote it** — the specific learning from this MVP that would
make it worth building. Deferred items stay durable knowledge; they never become
executable issues in this Project.

## After planning

The policy stays in force for the whole delivery. It is recorded durably by
`planning-toolkit-plan`, so `planning-toolkit-resolve` reads it from the planning
record rather than from this conversation — a resolution decision is judged
against the same inclusion test.

Return to planning when evidence invalidates the Hypothesis or the Evidence
becomes unobservable. Under this policy those are contract fields, so a change to
either is a planning invalidation, not a local adjustment.

## Gotchas

- **Small is not the same as partial.** A vertical slice that a user can complete
  beats a horizontal layer that no one can use.
- **Do not relitigate the bet.** Whether the hypothesis is worth testing was
  decided upstream; this policy takes it as given and cuts scope against it.
- **Do not let the Deferred list become the plan.** Its size is not progress.
- **Do not carry this policy into unrelated work.** A migration or a hardening
  project has no hypothesis; forcing one distorts the scope cut.
