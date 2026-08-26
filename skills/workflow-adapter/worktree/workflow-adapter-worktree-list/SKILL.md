---
name: workflow-adapter-worktree-list
description: >-
  Lists managed worktrees for one repository, optionally matching complete
  caller-owned association metadata. Use when zero or multiple worktrees are a
  valid result.
---

# List repository worktrees

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require non-empty string `input.repository` as an
absolute path or previously returned stable identity. Accept optional
`input.association_metadata` as any JSON value; its presence requests exact
whole-value matching, including when empty. Reject every other field as
`invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-worktree-list` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
Return every match and never select among multiples. On success return
`status: applied`, `operation: list`, `provider`, and `value.worktrees`, including
an empty list. Each worktree has canonical `locator`, absolute `path`, `kind` of
`main` or `linked`, non-empty string `branch` or null, hexadecimal string
`head`, complete `association_metadata` JSON value or null when unavailable,
and optional JSON object `provider_fields`. The applied `provider` is a non-empty
string. On failure return the complete original mapping `request` with
`status: unapplied`, `operation: list`, optional selected non-empty string
`provider`, non-empty string `reason`, actionable non-empty string `detail`, and
optional non-empty string-list `candidates`.
Reasons are `missing-provider`, `ambiguous-provider`, `invalid-request`,
`unsupported`, `readiness-failure`, or `provider-failure`.
