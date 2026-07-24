---
name: dispatch-work
description: >-
  Single front door for STARTING work when the execution mode has not been chosen.
  Invoked explicitly (for example /dispatch-work) or delegated to by a routing skill
  such as linear-start; do not auto-activate on unrelated in-progress work. First
  separates fuzzy concept shaping from executable work. For executable work, asks
  whether humans should gate progress through approved specs and reviews or the agent
  should drive autonomously, then recommends dev-workflow-kickoff, the host's native
  /goal, exec-plan, or direct in-session implementation. Not an executor: the user
  chooses one route, then this skill hands off.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Skill
user-invocable: true
---

# Dispatch Work

Choose the control model for one new work unit, then hand off. This skill does not
interview for requirements, write artifacts, or implement the work.

## Responsibility boundary

`dispatch-work` is the **only cross-family mode selector**:

- `inception` shapes a fuzzy What before execution.
- `dev-workflow-kickoff` starts work whose phases are gated by human approval of a
  durable spec, plan, and review.
- Native `/goal` and `exec-plan` are autonomous modes. They differ in how
  completion and exceptional decisions are handled.
- Direct in-session implementation is the cheap route for a trivial change.

Once `dev-workflow-kickoff` is chosen, that choice is settled: kickoff must not
redirect the work back to an autonomous mode based on issue contents. Likewise,
do not present `inception` beside execution modes. It is a preceding stage, not
another execution preference.

## Decision tree

Evaluate these gates in order.

### Gate 1 — Is the What shaped enough to execute?

If the user still does not know what should be built, or foundational product
questions remain open, recommend **`inception` alone**. Do not list `/goal`,
`exec-plan`, `dev-workflow-kickoff`, or direct implementation as alternatives in
the same prompt. Inception finishes and finalizes the footing first; concrete
actions can return to `dispatch-work` afterward.

If the What is clear enough to execute, do not offer `inception`. Continue to the
control-model gate.

### Gate 2 — Who gates progress?

The primary execution question is:

> Should approved specs and human review gate the phases of this work, or should
> the agent drive autonomously after the direction is set?

- **Human-gated** → `dev-workflow-kickoff`. Choose this when the user wants an
  approved spec and plan to be the contract, wants explicit checkpoints before
  later phases, or wants final human acceptance to be part of the workflow.
  This preference wins even if the issue looks small or every criterion could be
  tested by a command.
- **Autonomous** → continue to Gate 3. Human involvement may still occur at the
  beginning or end, but it is not a phase-by-phase progress gate.
- **Trivial** → direct implementation is available only when the change is small,
  obvious, low-risk, and self-evidently complete.

Do not infer the control model solely from the Linear issue's wording, size,
labels, or apparent testability. Those inform the recommendation, but the user's
desired mode of involvement decides this gate.

### Gate 3 — Which autonomous mode?

Use **distance and planning horizon** to distinguish the two autonomous routes:

- **Native `/goal`** — the outcome is clear, but it is a distant or multi-stage
  target whose route may need to be discovered, revised, or organized into
  workflows while work continues. The persistent goal keeps the active chat
  pointed at the outcome across those intermediate plans and continuations.
  Prefer this for migrations, broad ports, repository-wide transformations, or
  "keep working until this larger outcome is achieved."
- **`exec-plan`** — the goal and direction are already concrete enough to write
  a self-contained execution plan now. The work is comparatively light or
  near-horizon: most of the route is visible, and the few high-impact decisions
  can be parked without blocking most progress. The agent drives the plan
  inline and batch-reviews those decisions at the end.

If most steps require human judgment, the work is not autonomous: return to the
human-gated choice. If the direction itself is still unsettled, return to
`inception`. If parked decisions would block most of the visible plan, prefer
native `/goal` only when the larger outcome can guide useful route discovery;
otherwise return to the human-gated choice.

## Present one stage at a time

Use one `AskUserQuestion` for the active gate.

- At Gate 1, when fuzzy, present only the recommendation to shape the concept
  with `inception` (plus the user's ability to decline through free-form input).
- At Gate 2, present **human-gated dev-workflow** versus **autonomous execution**;
  include direct implementation only when the work is genuinely trivial.
- At Gate 3, present native `/goal` versus `exec-plan`.

Put the recommendation first and explain it in one line. The user owns the
choice, but each prompt is single-stage and mutually exclusive; never flatten
`inception`, control-model choices, and autonomous-engine choices into one list.

## Handoff

After the user chooses:

- `inception`, `exec-plan`, or `dev-workflow-kickoff` → invoke that skill.
- direct implementation → return control to the ordinary session and implement.
- native `/goal` → use the host's built-in goal mechanism. If the host exposes it
  only as a user command, provide a compact goal statement and ask the user to run
  `/goal`; do not substitute a repository skill or invent a portable loop.

The destination receives the task context from session history. Do not perform
its intake inside this router.

## Anti-patterns

- Do not present `inception` alongside execution modes.
- Do not choose human-gated versus autonomous solely from issue-content/skill
  similarity.
- Do not send a user who selected human gates through another autonomous-fit
  assessment in kickoff.
- Do not equate "has tests" with "must be autonomous"; control preference comes
  first.
- Do not run a requirements interview or implementation inside this skill.
- Do not silently dispatch before the user chooses.
