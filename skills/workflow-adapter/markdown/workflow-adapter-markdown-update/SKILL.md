---
name: workflow-adapter-markdown-update
description: >-
  Updates one exact durable Markdown document with a complete replacement or
  explicit text patch and named metadata changes. Use only after the caller has
  selected an existing provider-issued locator.
---

# Update a durable Markdown document

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require exact non-empty provider-issued string
`input.locator` plus exactly one of complete string `replacement_body` or
non-empty ordered list `body_patch`. Each patch item contains string `old_text`,
string `new_text`, and positive integer `expected_occurrences`. Accept optional
string `repository`, non-empty string `new_slug`, and JSON object
`metadata_changes`; `null` removes a key. Keep them inside `input`. Reject every
other field as `invalid-request`.

## Apply

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-markdown-update` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
Change only the named body and metadata fields. Preserve provider-owned
metadata and do not rename without `new_slug`.

## Result

On verified success return `status: applied`, `operation: update`, `provider`,
`value.document` containing non-empty string `locator`, exact string `body`,
string `title`, caller-owned `metadata` JSON object, and optional provider-owned
`provider_fields` JSON object. Also return `verification` as a mapping with
non-empty string `method` and mapping `observed`. On failure return
`status: unapplied`, `operation: update`, optional selected string `provider`,
non-empty string `reason`, actionable non-empty string `detail`, optional
non-empty string-list `candidates`, and the complete original mapping `request`.
Reasons are `missing-provider`, `ambiguous-provider`, `invalid-request`,
`not-found`, `ambiguous-match`, `unsupported`, `readiness-failure`,
`provider-failure`, or `verification-failure`. If storage may have changed, say
so in `detail`.
