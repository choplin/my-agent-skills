---
name: workflow-adapter-markdown-create
description: >-
  Creates one durable Markdown document from caller-owned title, body, and
  metadata. Use only when the caller has chosen creation rather than updating
  or merging an existing note.
---

# Create a durable Markdown document

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require non-empty string `input.title`, complete
string `input.body`, and complete `input.metadata` JSON object, which may be
empty. Accept optional string `repository`, non-empty opaque string
`destination_hint`, and `collision_policy` of `reject` (default) or
`create-alongside` inside `input`. Reject every other field as
`invalid-request`.

## Apply

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-markdown-create` and whose trigger
matches the request and repository context. If none or more than one match,
return `missing-provider` or `ambiguous-provider`; never try another provider
after delegation. Treat the body as opaque. Never merge, update, consolidate, archive, insert
links, or retry under a different collision policy.

## Result

On verified success return `status: applied`, `operation: create`, `provider`,
`value.document` containing non-empty string `locator`, exact string `body`,
string `title`, caller-owned `metadata` JSON object, and optional provider-owned
`provider_fields` JSON object. Also return `verification` as a mapping with
non-empty string `method` and mapping `observed`. On failure return
`status: unapplied`, `operation: create`, optional selected string `provider`,
non-empty string `reason`, actionable non-empty string `detail`, optional
non-empty string-list `candidates`, and the complete original mapping `request`.
Reasons are `missing-provider`, `ambiguous-provider`, `invalid-request`,
`collision`, `unsupported`, `readiness-failure`, `provider-failure`, or
`verification-failure`. If storage may have changed, say so in `detail`.
