---
name: workflow-adapter-impl-wtm-remove
description: >-
  Implements workflow-adapter-worktree-remove through wtm. Use when workflow-adapter-worktree-remove is active
  and the request selects wtm; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by wtm; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate wtm for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply remove through wtm

Accept one validated request from `workflow-adapter-worktree-remove` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `wtm-worktree` first. If that skill, `wtm`, or the target Git repository is unavailable, return `readiness-failure`; never install or configure wtm, fall back to bare `git worktree`, or select another provider.

## Apply

Resolve the exact name and inspect status first. Map `keep`, `delete-if-merged`, and `force-delete` exactly, and run outside the target worktree. Non-interactive confirmation never authorizes discarding dirty files. List again and verify absence.

Return `wtm` as `provider` and the removed wtm name only as `value.locator`.
The neutral remove result has no `provider_fields` slot; do not add one.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
