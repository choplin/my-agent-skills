---
name: workflow-adapter-impl-octa-resolve
description: >-
  Implements workflow-adapter-tracker-resolve through octa. Use when workflow-adapter-tracker-resolve is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply resolve through octa

Accept one validated request from `workflow-adapter-tracker-resolve` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base` and its CLI and workflow-configuration references. Use the repository-local `octa` CLI. If the configured repository or required command is unavailable, return `readiness-failure`; never groom records or select another provider.

## Apply

Resolve through octa's repository identity or an exact octa locator. Do not infer a repository from a similarly named record.

Return `octa` as `provider` and the octa repository identity as
`value.repository`. The neutral resolve result has no record or
`provider_fields` slot; omit provider-only details.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
