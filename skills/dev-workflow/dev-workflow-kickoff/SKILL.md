---
name: dev-workflow-kickoff
description: >-
  Start a new human-gated development workflow after the user has chosen to use
  approved specs, plans, and reviews as phase gates. Invoked explicitly when the
  user asks for that workflow or delegated to by dispatch-work. Clarifies Why and
  What without AI filling, then routes a single gated work unit to
  dev-workflow-create-spec or multiple independent work units to
  dev-workflow-create-epic. Does not assess or redirect to autonomous execution
  modes.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Skill
user-invocable: true
---

# Dev Workflow Kickoff

Start work whose control model has already been chosen: a durable spec and plan
are reviewed by a human, implementation is checked against that contract, and
human review gates completion.

`dispatch-work` owns the choice between human-gated and autonomous execution.
Invocation of this skill therefore means **human-gated is settled**. Never route
to native `/goal`, `exec-plan`, or direct implementation because the issue looks
small, obvious, or machine-verifiable.

## Purpose

Clarify the user's Why and What, then decide only the gated work's shape:

- **Story** — one independently reviewable deliverable. Size does not matter; a
  small change is still a Story when the user chose the gated workflow.
- **Epic** — multiple independent Stories that can be specified, implemented,
  and reviewed separately.

The question is no longer whether the work "deserves" a spec. The user already
chose that contract. The only routing question is whether one spec is coherent
or the work must be decomposed.

## Critical anti-pattern: AI filling

Every authored statement must be traceable to user confirmation.

- Never fill gaps with generic best practices or "reasonable assumptions".
- Mark non-critical unknowns `TBD`.
- Ask about critical unknowns.
- Label proposals as `[AI suggestion]` until the user confirms them.

This rule matters because the approved spec survives the session and becomes the
implementation contract.

## Interview

Invoke `discuss-toolkit-dig` to clarify:

- **Subject**: the development outcome to put through the human-gated workflow.
- **Purpose**: understand Why (motivation/problem) and What (desired outcome and
  essential acceptance) well enough to author one Story spec or decompose an
  Epic.
- **Quality bar**: confirmed user intent only; unresolved items stay explicit.

Do not conduct an autonomous-mode or executable-oracle assessment. Individual
acceptance criteria may later use executable `Verify:` commands, but those are
evidence inside dev-workflow, not a reason to leave it.

## Shape assessment

After the interview, ask:

> Can this outcome be specified, implemented, and reviewed as one independent
> deliverable?

- **Yes → Story.** Invoke `dev-workflow-create-spec`.
- **No → Epic.** Invoke `dev-workflow-create-epic` to decompose it into
  independent Stories.

Use Epic only when there are genuinely multiple deliverables, not merely many
steps or files. A Story may span sessions and contain several implementation
steps while still producing one coherent outcome.

### Existing Linear issue

When entered through `linear-start → dispatch-work`, the chosen Issue already
exists and the workspace is ready:

- Story → invoke `dev-workflow-create-spec` in adopt mode on that Issue.
- Epic → do not silently replace the Issue with a Project. Present the proposed
  decomposition and let `dev-workflow-create-epic` follow Linear's approval and
  provenance rules.

## Output

Before handing off, state:

- confirmed Why;
- confirmed What;
- Story or Epic;
- why the work is one deliverable or several.

Then invoke the corresponding skill. Do not author the spec or Epic inline.

## Success criteria

- [ ] Human-gated execution was treated as an established choice.
- [ ] No autonomous-mode recommendation or redirect was performed.
- [ ] Why and What contain only user-confirmed information or explicit TBDs.
- [ ] The Story/Epic decision is based on independent deliverables, not apparent
      implementation difficulty.
- [ ] Story routed to `dev-workflow-create-spec`; Epic routed to
      `dev-workflow-create-epic`.
