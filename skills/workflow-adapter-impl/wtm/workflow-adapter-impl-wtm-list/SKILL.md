---
name: workflow-adapter-impl-wtm-list
description: >-
  Implements workflow-adapter-worktree-list through wtm. Use when workflow-adapter-worktree-list is active
  and the request selects wtm; or, with provider omitted, repository
  instructions explicitly designate wtm for this operation. Generic provider
  availability is not a designation.
---

# Apply list through wtm

Accept one validated request from `workflow-adapter-worktree-list` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `wtm-worktree` first. If that skill, `wtm`, or the target Git repository is unavailable, return `readiness-failure`; never install or configure wtm, fall back to bare `git worktree`, or select another provider.

## Apply

Use machine-readable wtm output. If exact association metadata is supplied but omitted from list output, inspect each candidate's complete stored note. Return every match and never choose among multiples.

Return `wtm` as `provider`. In every `value.worktrees` entry, use the wtm name
as `locator` and keep creation time and other wtm-only data under
`provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
