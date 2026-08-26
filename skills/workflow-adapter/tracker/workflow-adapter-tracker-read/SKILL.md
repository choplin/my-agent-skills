---
name: workflow-adapter-tracker-read
description: >-
  Reads one exact tracker Project, Milestone, or Issue through a provider-issued
  locator. Use for a single work-record read without mutation.
---

# Read a tracker work record

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require `input.record_kind` of `project`, `milestone`,
or `issue` and exact non-empty provider-issued string `locator`. Project fields are
`name`, `description`, `lifecycle_intent`, and `metadata`; Milestones
additionally use `project_locator`; Issue fields are `title`, `description`,
`acceptance`, `project_locator`, `milestone_locator`, `work_type`,
`lifecycle_intent`, and `metadata`. Accept optional non-empty string `repository`
and non-empty unique string-list `fields` inside `input`. Permit
`provider_fields.<name>` only with an explicit provider.
Reject every other field as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-tracker-read` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
On success return `status: applied`, `operation: read`, non-empty string
`provider`, and
`value.record` containing enum string `kind`, non-empty canonical string
`locator`, non-empty string `repository`, JSON object `fields`, and optional
JSON object `provider_fields`. On failure return the complete original mapping
`request` with `status: unapplied`, `operation: read`, optional selected
non-empty string `provider`, non-empty string `reason`, actionable non-empty
string `detail`, and optional non-empty string-list `candidates`. Reasons
are `missing-provider`, `ambiguous-provider`, `invalid-request`, `not-found`,
`ambiguous-match`, `unsupported`, `readiness-failure`, or `provider-failure`.
