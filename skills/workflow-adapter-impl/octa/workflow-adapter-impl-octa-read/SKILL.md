---
name: workflow-adapter-impl-octa-read
description: >-
  Implements workflow-adapter-tracker-read through octa. Use when workflow-adapter-tracker-read is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply read through octa

Accept one validated request from `workflow-adapter-tracker-read` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base` and its CLI and workflow-configuration references. Use the repository-local `octa` CLI. If the configured repository or required command is unavailable, return `readiness-failure`; never groom records or select another provider.

## Apply

Use JSON CLI output or the read-only GraphQL schema to read the exact locator. Honor the requested kind and fields, and inspect GraphQL `errors` even after a successful process exit.

Return `octa` as `provider`. In `value.record`, use the octa repository identity
as `repository`, a record number or ID as `locator`, and keep provider-only
state names, URLs, timestamps, and derived values under `provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
