---
name: workflow-adapter-impl-octa-relate
description: >-
  Implements workflow-adapter-tracker-relate through octa. Use when workflow-adapter-tracker-relate is active
  and the request selects octa; or, with provider omitted, contains a locator
  already known in the current workflow to have been returned by octa; or, with
  provider omitted and no known-locator cue, repository instructions explicitly
  designate octa for this
  operation. Never infer the provider from locator syntax alone.
---

# Apply relate through octa

Accept one validated request from `workflow-adapter-tracker-relate` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `octa-base` and its CLI and workflow-configuration references. Use the repository-local `octa` CLI. If the configured repository or required command is unavailable, return `readiness-failure`; never groom records or select another provider.

## Apply

Add or remove only relations octa represents faithfully, including Issue blocking relations. Never approximate an unsupported relation with labels or prose. Respect any supplied Issue lease and re-read both sides to verify.

Return `octa` as `provider` and the verified action, relation, source, and target
under `value.relation`. The neutral result has no repository or
`provider_fields` slot; do not add either.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
