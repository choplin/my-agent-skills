---
name: workflow-adapter-tracker-list
description: >-
  Lists tracker Projects, Milestones, or Issues using an explicit neutral
  filter. Use for collection reads that may validly return zero or many work
  records.
---

# List tracker work records

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require `input.record_kind` of `project`, `milestone`,
or `issue`, plus non-empty JSON object `filter`. The filter maps neutral record
field names to exact JSON scalar or non-empty list matches. Project fields are `name`,
`description`, `lifecycle_intent`, and `metadata`; Milestones additionally use
`project_locator`; Issue fields are `title`, `description`, `acceptance`,
`project_locator`, `milestone_locator`, `work_type`, `lifecycle_intent`, and
`metadata`. Accept optional non-empty string `repository` and a non-empty unique
string-list `fields`. Keep them inside `input`. Permit
`provider_fields.<name>` only with an explicit provider. Reject every other
field as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-list` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
On success return `status: applied`, `operation: list`, non-empty string
`provider`, and
`value.records`, including an empty list. Each record contains enum string
`kind`, non-empty canonical string `locator`, non-empty string `repository`,
JSON object `fields`, and optional JSON object `provider_fields`. On failure
return the complete original mapping `request` with `status: unapplied`,
`operation: list`, optional selected non-empty string `provider`, non-empty
string `reason`, actionable non-empty string `detail`, and optional non-empty
string-list `candidates`. Reasons are `missing-provider`,
`ambiguous-provider`, `invalid-request`, `unsupported`, `readiness-failure`, or
`provider-failure`.
