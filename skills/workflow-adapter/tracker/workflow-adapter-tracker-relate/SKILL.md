---
name: workflow-adapter-tracker-relate
description: >-
  Adds or removes one exact relation between tracker work records. Use for
  caller-selected dependency or placement relationships that the provider must
  represent faithfully.
---

# Change a tracker record relation

## Request

Accept a request mapping with required mapping `input`, optional non-empty string
`provider`, and optional non-empty opaque string `coordination_handle`; reject
other top-level fields. Require `input.action` of `add` or `remove`, non-empty caller-owned
string `relation`, and exact `source` and `target`. Each reference contains only
`record_kind` of `project`, `milestone`, or `issue` and exact non-empty
provider-issued string `locator`. Accept optional non-empty string `repository`
inside `input`. Reject every other field as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-relate` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Never emulate
an unsupported relation with labels or prose. On verified success return
`status: applied`, `operation: relate`, non-empty string `provider`, and
`value.relation` containing enum `action`, string `relation`, and canonical
`source` and `target` record references in the request shape. Also return
`verification` with non-empty string `method` and mapping `observed`. On failure
return the complete original mapping `request` with `status: unapplied`,
`operation: relate`, optional selected non-empty string `provider`, non-empty
string `reason`, actionable non-empty string `detail`, and optional non-empty
string-list `candidates`. Reasons are `missing-provider`,
`ambiguous-provider`, `invalid-request`, `not-found`, `unsupported`,
`coordination-required`, `coordination-conflict`, `readiness-failure`,
`provider-failure`, or `verification-failure`.
