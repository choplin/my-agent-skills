---
name: workflow-adapter-impl-llm-wiki-find
description: >-
  Implements workflow-adapter-markdown-find through llm-wiki. Use when
  workflow-adapter-markdown-find is active and the request selects llm-wiki;
  or, with provider omitted, contains a locator already known in the current
  workflow to have been returned by llm-wiki; or, with provider omitted and
  no known-locator cue,
  repository instructions explicitly designate llm-wiki for this operation.
  Never infer the provider from path syntax alone.
---

# Apply find through llm-wiki

Accept one validated request from `workflow-adapter-markdown-find` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `llm-wiki-base` first. If the required llm-wiki skill, `zk`, or initialized notebook is unavailable, return `readiness-failure`; never initialize the notebook or select another provider.

## Apply

Apply `llm-wiki-retrieve`. Search using only the supplied title, keywords,
exact locator, repository scope, and destination hint. Return every matching
scope-relative path; never merge candidates or choose an update target by
similarity.

Return `llm-wiki` as `provider`. In every `value.matches` entry, use the
scope-relative note path as `locator` and keep provider-owned slug, frontmatter,
and index details under `provider_fields`.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
