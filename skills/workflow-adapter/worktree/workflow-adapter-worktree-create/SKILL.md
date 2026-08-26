---
name: workflow-adapter-worktree-create
description: >-
  Creates one managed repository worktree with explicit name and branch intent.
  Use after the caller has decided isolation, branch, base, and any association
  metadata.
---

# Create a repository worktree

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require non-empty string `repository`, non-empty
string `name`, and `branch` containing exactly one non-empty string field:
`new` or `existing`. Accept non-empty string `base` as an exact caller-selected
Git ref only with a new branch. Accept optional `association_metadata` as any
JSON value. Keep all these fields inside `input`. Reject every other field as
`invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-worktree-create` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Do not derive
a branch or base, reuse a collision, or retry without metadata. On verified
success return `status: applied`, `operation: create`, `provider`, and
`value.worktree` containing non-empty canonical string `locator`, absolute
string `path`, enum string `kind` of `main` or `linked`, non-empty string
`branch` or null, hexadecimal string `head`, complete `association_metadata`
JSON value or null when unavailable, and optional JSON object `provider_fields`.
Also return `verification` with non-empty string `method` and mapping `observed`.
On failure return the complete original mapping `request` with
`status: unapplied`, `operation: create`, optional selected non-empty string
`provider`, non-empty string `reason`, actionable non-empty string `detail`, and
optional non-empty string-list `candidates`. Reasons are `missing-provider`, `ambiguous-provider`,
`invalid-request`, `collision`, `unsupported`, `readiness-failure`,
`provider-failure`, or `verification-failure`. If creation may have occurred,
say so in `detail`.
