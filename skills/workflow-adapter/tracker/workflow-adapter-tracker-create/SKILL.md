---
name: workflow-adapter-tracker-create
description: >-
  Creates one tracker Project, Milestone, or Issue from complete caller-owned
  fields. Use only after the caller has decided the record's content, placement,
  work type, and lifecycle intent.
---

# Create a tracker work record

## Request

Accept a request mapping with required mapping `input`, optional non-empty string
`provider`, and optional non-empty opaque string `coordination_handle`; reject
other top-level fields. Require `input.record_kind` of `project`, `milestone`, or `issue` and
non-empty JSON object `fields`.
Project fields are `name`, `description`,
`lifecycle_intent`, and `metadata`. Milestones additionally use
`project_locator`. Issue fields are `title`, `description`, `acceptance`,
`project_locator`, `milestone_locator`, `work_type`, `lifecycle_intent`, and
`metadata`. Permit `provider_fields.<name>` only with an explicit provider. A
structurally valid request may still receive `invalid-request` when its selected
provider requires another field; never infer it.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-create` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Do not fill
missing content or discard unsupported fields. On verified success return
`status: applied`, `operation: create`, non-empty string `provider`, and
`value.record` containing enum string `kind`, non-empty canonical string
`locator`, non-empty string `repository`, JSON object `fields`, and optional
JSON object `provider_fields`. Also return `verification` with non-empty string
`method` and mapping `observed`. On failure return the complete original mapping
`request` with `status: unapplied`, `operation: create`, optional selected
non-empty string `provider`, non-empty string `reason`, actionable non-empty
string `detail`, and optional non-empty string-list `candidates`. Reasons are
`missing-provider`, `ambiguous-provider`, `invalid-request`, `unsupported`,
`coordination-required`, `coordination-conflict`, `readiness-failure`,
`provider-failure`, or `verification-failure`.
