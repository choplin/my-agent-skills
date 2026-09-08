---
name: workflow-adapter-impl-octa-list
description: >-
  Implements workflow-adapter-tracker-list through octa. Use when workflow-adapter-tracker-list is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply list through octa

Accept one validated request from `workflow-adapter-tracker-list` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base`. Use the repository-local `octa` CLI. If the configured
repository or required command is unavailable, return `readiness-failure`;
never groom records or select another provider.

## Apply

Use the `octa` product skill to choose JSON CLI output or the read-only GraphQL
schema. Honor the supplied record kind, filters, and requested fields. Complete
all provider pagination and return every match.

Return `octa` as `provider`. In every `value.records` entry, use the octa
repository identity as `repository`, a record number or ID as `locator`, and
keep provider-only state names, URLs, timestamps, and derived values under
`provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
