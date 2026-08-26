---
name: workflow-adapter-markdown-find
description: >-
  Finds durable Markdown documents by title, keywords, or an existing locator.
  Use when a workflow needs candidate notes without selecting or changing one.
---

# Find durable Markdown documents

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Inside `input`, require at
least one of non-empty
string `title`, non-empty unique string-list `keywords`, or exact non-empty
provider-issued string `locator`. Accept optional string `repository` and opaque
non-empty string `destination_hint`. Reject every other field as
`invalid-request`.

## Apply

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-markdown-find` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
Return every match; do not merge candidates or choose an update target by
similarity.

## Result

On success return `status: applied`, `operation: find`, non-empty string
`provider`, and
`value.matches`, including an empty list. Each match contains canonical
non-empty string `locator`, string `title`, caller-owned `metadata` mapping, and
optional provider-owned `provider_fields` mapping. On failure return
`status: unapplied`, `operation: find`, optional selected non-empty string
`provider`, non-empty string `reason`, actionable non-empty string `detail`,
optional non-empty string-list `candidates`, and the complete original
mapping `request`. Reasons are
`missing-provider`, `ambiguous-provider`, `invalid-request`, `unsupported`,
`readiness-failure`, or `provider-failure`.
