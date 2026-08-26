---
name: workflow-adapter-tracker-transition
description: >-
  Applies one caller-owned lifecycle transition to an exact tracker Project,
  Milestone, or Issue. Use when the desired state or transition intent is
  already decided.
---

# Transition a tracker work record

## Request

Accept a request mapping with required mapping `input`, optional non-empty string
`provider`, and optional non-empty opaque string `coordination_handle`; reject
other top-level fields. Require `input.record_kind` of `project`, `milestone`, or `issue`, exact
non-empty provider-issued string `locator`, and non-empty string
`lifecycle_intent` naming the exact desired state or transition intent. Accept
optional non-empty string `repository` inside `input`. Reject every other field
as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-transition` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Do not
choose a nearby or default state unless the caller named that intent. On
verified success return `status: applied`, `operation: transition`, non-empty
string `provider`, and `value.record` containing enum string `kind`, non-empty
canonical string `locator`, non-empty string `repository`, JSON object `fields`,
and optional JSON object `provider_fields`. Also return `verification` with
non-empty string `method` and mapping `observed`. On failure return the complete
original mapping `request` with `status: unapplied`, `operation: transition`,
optional selected non-empty string `provider`, non-empty string `reason`,
actionable non-empty string `detail`, and optional non-empty string-list
`candidates`. Reasons are `missing-provider`, `ambiguous-provider`,
`invalid-request`, `not-found`, `unsupported`, `coordination-required`,
`coordination-conflict`, `readiness-failure`, `provider-failure`, or
`verification-failure`.
