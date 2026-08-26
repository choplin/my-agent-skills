---
name: workflow-adapter-impl-llm-wiki-read
description: >-
  Implements workflow-adapter-markdown-read through llm-wiki. Use when
  workflow-adapter-markdown-read is active and the request selects llm-wiki;
  or, with provider omitted, contains a locator already known in the current
  workflow to have been returned by llm-wiki; or, with provider omitted and
  no known-locator cue,
  repository instructions explicitly designate llm-wiki for this operation.
  Never infer the provider from path syntax alone.
---

# Apply read through llm-wiki

Accept one validated request from `workflow-adapter-markdown-read` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `llm-wiki-base` first. If the required llm-wiki skill, `zk`, or initialized notebook is unavailable, return `readiness-failure`; never initialize the notebook or select another provider.

## Apply

Apply `llm-wiki-retrieve`. Retrieve the exact supplied locator and return its stored body, title, and caller-owned metadata without rewriting or normalization.

Return `llm-wiki` as `provider`. In `value.document`, use the scope-relative
note path as `locator` and keep provider-owned slug, frontmatter, and index
details under `provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
