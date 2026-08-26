---
name: workflow-adapter-markdown-resolve
description: >-
  Resolves the durable Markdown provider and destination for a concern,
  destination hint, or existing locator. Use before Markdown access when the
  caller does not yet have a confirmed durable destination.
---

# Resolve a durable Markdown destination

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Inside `input`, require exactly
one non-empty string
among `concern`, opaque `destination_hint`, and exact provider-issued `locator`.
Accept optional string `repository` as an absolute path inside the target Git
repository or a stable identity previously returned by an adapter. Reject every
other field as `invalid-request`.

## Apply

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-markdown-resolve` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
Do not claim an arbitrary scope when repository context is insufficient.

## Result

On success return `status: applied`, `operation: resolve`, non-empty string
`provider`, and
`value.destination` containing non-empty string `scope` and optional single
non-empty canonical string `locator`. On failure return `status: unapplied`,
`operation: resolve`, optional selected non-empty string `provider`, non-empty
string `reason`, actionable non-empty string `detail`, optional
non-empty string-list `candidates`, and the complete original mapping `request`.
Reasons are `missing-provider`,
`ambiguous-provider`, `invalid-request`, `not-found`, `unsupported`,
`readiness-failure`, or `provider-failure`.
