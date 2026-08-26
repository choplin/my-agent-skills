---
name: workflow-adapter-impl-wtm-read
description: >-
  Implements workflow-adapter-worktree-read through wtm. Use when workflow-adapter-worktree-read is active
  and the request selects wtm; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by wtm; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate wtm for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply read through wtm

Accept one validated request from `workflow-adapter-worktree-read` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `wtm-worktree` first. If that skill, `wtm`, or the target Git repository is unavailable, return `readiness-failure`; never install or configure wtm, fall back to bare `git worktree`, or select another provider.

## Apply

Show the exact wtm worktree in machine-readable form. Derive `kind` from Git common-directory metadata when wtm omits it, and return the complete stored association metadata.

Return `wtm` as `provider`. In `value.worktree`, use the wtm name as `locator`
and keep creation time and other wtm-only data under `provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
