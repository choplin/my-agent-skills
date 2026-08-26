---
name: workflow-adapter-impl-octa-update
description: >-
  Implements workflow-adapter-tracker-update through octa. Use when workflow-adapter-tracker-update is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply update through octa

Accept one validated request from `workflow-adapter-tracker-update` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base` and its CLI and workflow-configuration references. Use the repository-local `octa` CLI. If the configured repository or required command is unavailable, return `readiness-failure`; never groom records or select another provider.

## Apply

Apply only named changes and preserve all other fields. Use a supplied Issue lease when required; never acquire a second lease. Return `coordination-required` without a required lease and `coordination-conflict` when another lease is active. Re-read and verify.

Return `octa` as `provider`. In `value.record`, use the octa repository identity
as `repository`, a record number or ID as `locator`, and keep provider-only
state names, URLs, timestamps, and derived values under `provider_fields`.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
