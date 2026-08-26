---
name: workflow-adapter-tracker-update
description: >-
  Updates named fields on one exact tracker Project, Milestone, or Issue. Use
  when the caller has selected an existing record and specified every intended
  field change.
---

# Update a tracker work record

## Request

Accept a request mapping with required mapping `input`, optional non-empty string
`provider`, and optional non-empty opaque string `coordination_handle`; reject
other top-level fields. Require `input.record_kind` of `project`, `milestone`, or `issue`, exact
non-empty provider-issued string `locator`, and non-empty JSON object `changes`.
Project fields are `name`, `description`,
`lifecycle_intent`, and `metadata`; Milestones additionally use
`project_locator`; Issue fields are `title`, `description`, `acceptance`,
`project_locator`, `milestone_locator`, `work_type`, `lifecycle_intent`, and
`metadata`. Permit `provider_fields.<name>` only with an explicit provider.
Accept optional non-empty string `repository` inside `input`. Reject every other
field as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-update` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Change only
named fields and preserve all others. On verified success return
`status: applied`, `operation: update`, non-empty string `provider`, and
`value.record` containing enum string `kind`, non-empty canonical string
`locator`, non-empty string `repository`, JSON object `fields`, and optional
JSON object `provider_fields`. Also return `verification` with non-empty string
`method` and mapping `observed`. On failure return the complete original mapping
`request` with `status: unapplied`, `operation: update`, optional selected
non-empty string `provider`, non-empty string `reason`, actionable non-empty
string `detail`, and optional non-empty string-list `candidates`. Reasons are
`missing-provider`, `ambiguous-provider`, `invalid-request`, `not-found`,
`ambiguous-match`, `unsupported`, `coordination-required`,
`coordination-conflict`, `readiness-failure`, `provider-failure`, or
`verification-failure`.
