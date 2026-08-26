---
name: workflow-adapter-impl-llm-wiki-resolve
description: >-
  Implements workflow-adapter-markdown-resolve through llm-wiki. Use when
  workflow-adapter-markdown-resolve is active and the request selects llm-wiki;
  or, with provider omitted, contains a locator already known in the current
  workflow to have been returned by llm-wiki; or, with provider omitted and
  no known-locator cue,
  repository instructions explicitly designate llm-wiki for this operation.
  Never infer the provider from path syntax alone.
---

# Apply resolve through llm-wiki

Accept one validated request from `workflow-adapter-markdown-resolve` and return that skill's exact
`applied` or `unapplied` result shape. Do not add, omit, or reinterpret
caller-owned fields.

## Readiness

Apply `llm-wiki-base` first. If the required llm-wiki skill, `zk`, or initialized notebook is unavailable, return `readiness-failure`; never initialize the notebook or select another provider.

## Apply

For `locator`, resolve that exact known llm-wiki note. For `destination_hint`,
interpret the opaque hint only through configured llm-wiki placement rules. For
`concern`, combine the supplied concern with the repository scope defined by
`llm-wiki-base`; do not turn the concern itself into a guessed path. Outside
Git, leave the scope unresolved unless the caller already confirmed it. Return
the exact destination contract.

Return `llm-wiki` as `provider`. When the destination identifies an existing
note, use its scope-relative path as `value.destination.locator`. The neutral
resolve result has no `provider_fields` slot; omit provider-only details.

Preserve the complete original request in every `unapplied` result. Do not
return mutation verification fields or mutation-only failure reasons.
