---
name: workflow-adapter-tracker-comment
description: >-
  Appends one exact caller-owned comment to a tracker work record. Use when a
  workflow must add a running record or other prose without changing record
  fields or lifecycle state.
---

# Comment on a tracker work record

## Request

Accept a request mapping with required mapping `input`, optional non-empty string
`provider`, and optional non-empty opaque string `coordination_handle`; reject
other top-level fields. Require `input.record_kind` of `project`, `milestone`, or `issue`, exact
non-empty provider-issued string `locator`, and complete non-empty string `body`.
Accept optional non-empty string `repository` inside `input`. Reject every other
field as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-comment` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Store the
body exactly; do not add headings or status changes. On verified success return
`status: applied`, `operation: comment`, non-empty string `provider`, and
`value.comment` with non-empty canonical string `locator` and exact stored
string `body`. Also return `verification` with non-empty string `method` and
mapping `observed`. On failure return the complete original mapping `request`
with `status: unapplied`, `operation: comment`, optional selected non-empty
string `provider`, non-empty string `reason`, actionable non-empty string
`detail`, and optional non-empty string-list `candidates`. Reasons are
`missing-provider`,
`ambiguous-provider`, `invalid-request`, `not-found`, `unsupported`,
`coordination-required`, `coordination-conflict`, `readiness-failure`,
`provider-failure`, or `verification-failure`.
