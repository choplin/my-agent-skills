---
name: workflow-adapter-impl-wtm-create
description: >-
  Implements workflow-adapter-worktree-create through wtm. Use when workflow-adapter-worktree-create is active
  and the request selects wtm; or, with provider omitted, repository
  instructions explicitly designate wtm for this operation. Generic provider
  availability is not a designation.
---

# Apply create through wtm

Accept one validated request from `workflow-adapter-worktree-create` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `wtm-worktree` first. If that skill, `wtm`, or the target Git repository is unavailable, return `readiness-failure`; never install or configure wtm, fall back to bare `git worktree`, or select another provider.

## Apply

Map a new branch and optional base to `wtm add --branch --base`, and an existing branch to `wtm add --checkout`. Preserve association metadata exactly. Never derive a branch or base, reuse a collision, or retry without metadata after a hook failure. List again and verify presence.

Return `wtm` as `provider`. In `value.worktree`, use the wtm name as `locator`
and keep creation time and other wtm-only data under `provider_fields`.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
