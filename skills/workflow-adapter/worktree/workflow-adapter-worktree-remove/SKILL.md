---
name: workflow-adapter-worktree-remove
description: >-
  Removes one exact managed repository worktree with an explicit branch
  disposition. Use only after the caller has selected the target and decided
  whether its branch must be kept or deleted.
---

# Remove a repository worktree

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require exact non-empty provider-issued string
`input.locator` and `input.branch_disposition` of `keep`, `delete-if-merged`, or
`force-delete`. Accept optional non-empty string `input.repository` as an
absolute path or previously returned stable identity. Reject every other field
as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-worktree-remove` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation. Inspect the
target before removal. Never discard dirty files, upgrade branch disposition,
or guess a target. On verified success return `status: applied`,
`operation: remove`, non-empty string `provider`, and non-empty canonical string
`value.locator`. Return `verification` with non-empty string `method` and
`observed: {absent: true}`. On failure return the complete original mapping
`request` with `status: unapplied`, `operation: remove`, optional selected
non-empty string `provider`, non-empty string `reason`, actionable non-empty
string `detail`, and optional non-empty string-list `candidates`. Reasons are `missing-provider`,
`ambiguous-provider`, `invalid-request`, `not-found`, `ambiguous-match`,
`dirty-worktree`, `unsafe-branch-disposition`, `unsupported`,
`readiness-failure`, `provider-failure`, or `verification-failure`. If removal
may have occurred, say so in `detail`.
