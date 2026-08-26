---
name: workflow-adapter-impl-wtm-resolve
description: >-
  Implements workflow-adapter-worktree-resolve through wtm. Use when workflow-adapter-worktree-resolve is active
  and the request selects wtm; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by wtm; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate wtm for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply resolve through wtm

Accept one validated request from `workflow-adapter-worktree-resolve` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `wtm-worktree` first. If that skill, `wtm`, or the target Git repository is unavailable, return `readiness-failure`; never install or configure wtm, fall back to bare `git worktree`, or select another provider.

## Apply

Use an explicit wtm name or a path already reported by wtm. For repository-only context, resolve through `wtm list`; never claim an arbitrary linked worktree that wtm does not manage.

Return `wtm` as `provider` and the stable Git repository identity as
`value.repository`. For locator resolution, also return the exact worktree and
use the wtm name as its canonical locator; only that worktree may carry
wtm-only data under `provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
