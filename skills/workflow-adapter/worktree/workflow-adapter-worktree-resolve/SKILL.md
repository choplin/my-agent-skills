---
name: workflow-adapter-worktree-resolve
description: >-
  Resolves a worktree provider and repository or one exact managed worktree.
  Use before worktree access when the provider or canonical locator is not yet
  confirmed.
---

# Resolve a repository worktree

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Inside `input`, require exactly
one non-empty string:
`repository` as an absolute path or previously returned stable identity, or
exact provider-issued `locator`. Reject every other field as `invalid-request`.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-worktree-resolve` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
On success return `status: applied`, `operation: resolve`, non-empty string
`provider`, and non-empty string `value.repository`. When resolving a locator,
also return exactly one `value.worktree` containing non-empty canonical string
`locator`, absolute string `path`, enum string `kind` of `main` or `linked`,
non-empty string `branch` or null, hexadecimal string `head`, complete
`association_metadata` JSON value or null when unavailable, and optional JSON
object `provider_fields`. On failure return `status: unapplied`,
`operation: resolve`, optional selected non-empty string `provider`, non-empty
string `reason`, actionable non-empty string `detail`, optional non-empty
string-list `candidates`, and the complete original mapping `request`. Reasons are `missing-provider`,
`ambiguous-provider`, `invalid-request`, `not-found`, `ambiguous-match`,
`unsupported`, `readiness-failure`, or `provider-failure`.
