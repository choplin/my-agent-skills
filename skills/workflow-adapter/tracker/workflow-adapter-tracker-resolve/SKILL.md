---
name: workflow-adapter-tracker-resolve
description: >-
  Resolves the tracker provider and repository identity from repository context
  or an existing record locator. Use before work-record access when the tracker
  destination is not yet confirmed.
---

# Resolve a tracker destination

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Inside `input`, require exactly
one non-empty string:
`repository` as an absolute path or previously returned stable identity, or an
exact provider-issued record `locator`. Reject every other field as
`invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-resolve` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
On success return `status: applied`, `operation: resolve`, non-empty string
`provider`, and
non-empty string `value.repository`. On failure return `status: unapplied`,
`operation: resolve`, optional selected non-empty string `provider`, non-empty
string `reason`, actionable non-empty string `detail`, optional non-empty
string-list `candidates`, and the complete original mapping `request`. Reasons are
`missing-provider`, `ambiguous-provider`, `invalid-request`, `not-found`,
`unsupported`, `readiness-failure`, or `provider-failure`.
