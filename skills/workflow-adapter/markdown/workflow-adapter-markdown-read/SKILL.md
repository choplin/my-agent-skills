---
name: workflow-adapter-markdown-read
description: >-
  Reads one exact durable Markdown document through its selected provider. Use
  when a workflow already has a provider-issued note locator and needs stored
  content without mutation.
---

# Read a durable Markdown document

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require one exact non-empty provider-issued string
`input.locator`; accept optional string `input.repository` as an absolute path
or previously returned stable identity. Reject every other field as
`invalid-request`; never construct a locator from a title or path guess.

## Apply

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-markdown-read` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
Return stored content without rewriting or normalizing it.

## Result

On success return `status: applied`, `operation: read`, non-empty string
`provider`, and
`value.document` containing non-empty string `locator`, exact string `body`,
string `title`, caller-owned `metadata` mapping, and optional provider-owned
`provider_fields` mapping. On failure return `status: unapplied`,
`operation: read`, optional selected non-empty string `provider`, non-empty
string `reason`, actionable non-empty string `detail`, optional non-empty
string-list `candidates`, and the complete original mapping `request`. Reasons are
`missing-provider`, `ambiguous-provider`,
`invalid-request`, `not-found`, `ambiguous-match`, `unsupported`,
`readiness-failure`, or `provider-failure`.
