---
name: workflow-adapter-impl-llm-wiki-update
description: >-
  Implements workflow-adapter-markdown-update through llm-wiki. Use when
  workflow-adapter-markdown-update is active and the request selects llm-wiki;
  or, with provider omitted, contains a locator already known in the current
  workflow to have been returned by llm-wiki; or, with provider omitted and
  no known-locator cue,
  repository instructions explicitly designate llm-wiki for this operation.
  Never infer the provider from path syntax alone.
---

# Apply update through llm-wiki

Accept one validated request from `workflow-adapter-markdown-update` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `llm-wiki-base` first. If the required llm-wiki skill, `zk`, or initialized notebook is unavailable, return `readiness-failure`; never initialize the notebook or select another provider.

## Apply

Preserve provider-owned frontmatter not named by the caller, apply only requested body and metadata changes, and update llm-wiki's edit timestamp. Rename only when `new_slug` is present. Reindex, read back, and compare the requested changes exactly.

Return `llm-wiki` as `provider`. In `value.document`, use the scope-relative
note path as `locator` and keep provider-owned slug, frontmatter, and index
details under `provider_fields`.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
