---
name: workflow-adapter-impl-octa-create
description: >-
  Implements workflow-adapter-tracker-create through octa. Use when workflow-adapter-tracker-create is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply create through octa

Accept one validated request from `workflow-adapter-tracker-create` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base` and its CLI and workflow-configuration references. Use the repository-local `octa` CLI. If the configured repository or required command is unavailable, return `readiness-failure`; never groom records or select another provider.

## Apply

Create only Projects, Milestones, and Issues supported by the contract, with exactly the supplied fields and placement. Map work type only to the configured type label. Return any unrepresentable field as `unsupported`. Re-read and verify the created record.

Return `octa` as `provider`. In `value.record`, use the octa repository identity
as `repository`, a record number or ID as `locator`, and keep provider-only
state names, URLs, timestamps, and derived values under `provider_fields`.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
