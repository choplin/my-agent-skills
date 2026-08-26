---
name: workflow-adapter-impl-octa-comment
description: >-
  Implements workflow-adapter-tracker-comment through octa. Use when workflow-adapter-tracker-comment is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply comment through octa

Accept one validated request from `workflow-adapter-tracker-comment` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base` and its CLI and workflow-configuration references. Use the repository-local `octa` CLI. If the configured repository or required command is unavailable, return `readiness-failure`; never groom records or select another provider.

## Apply

Append the exact body to the identified supported record kind. Do not add headings or lifecycle changes. Return `unsupported` if octa cannot comment on that kind, then re-read and verify the stored comment.

Return `octa` as `provider` and the exact stored body and canonical comment
locator under `value.comment`. The neutral result has no repository or
`provider_fields` slot; do not add either.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
