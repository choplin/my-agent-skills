---
name: workflow-adapter-impl-llm-wiki-create
description: >-
  Implements workflow-adapter-markdown-create through llm-wiki. Use when
  workflow-adapter-markdown-create is active and the request selects llm-wiki;
  or, with provider omitted, repository instructions explicitly designate
  llm-wiki for this operation. Generic provider availability is not a
  designation.
---

# Apply create through llm-wiki

Accept one validated request from `workflow-adapter-markdown-create` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `llm-wiki-base` first. If the required llm-wiki skill, `zk`, or initialized notebook is unavailable, return `readiness-failure`; never initialize the notebook or select another provider.

## Apply

Apply `llm-wiki-capture` mechanics. Preserve the complete `input.metadata`
object in a provider-owned envelope so arbitrary caller keys and JSON types do
not collide with llm-wiki frontmatter. If `input.metadata.tags` is a non-empty
unique string-list, mirror it to llm-wiki's topical tags; otherwise derive one
free topical tag from the title and body as provider metadata, expose it only
as `value.document.provider_fields.tags`, and leave the returned caller-owned
`metadata` unchanged. Resolve the slug and check topic matches and path
collision before writing. Honor only `collision_policy`; never merge or update
an existing note. Reindex, read back, and compare the caller-owned body and
metadata exactly.

Return `llm-wiki` as `provider`. In `value.document`, use the scope-relative
note path as `locator` and keep provider-owned slug, frontmatter, and index
details under `provider_fields`.

For a mutation, a successful command exit is not verification. If readback
cannot confirm the requested state, return `verification-failure` and state
whether the mutation may have occurred. Preserve the complete original request
in every `unapplied` result.
