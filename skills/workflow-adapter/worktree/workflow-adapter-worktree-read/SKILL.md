---
name: workflow-adapter-worktree-read
description: >-
  Reads one exact managed repository worktree through its provider-issued
  locator. Use for worktree identity and state inspection without mutation.
---

# Read a repository worktree

## Request

Accept a request mapping with required mapping `input` and optional non-empty
string `provider`; reject other top-level fields. Require exact non-empty provider-issued string
`input.locator`; accept optional non-empty string `input.repository` as an
absolute path or previously returned stable identity. Reject every other field
as `invalid-request`; never construct a locator from a branch or path guess.

## Apply and result

Delegate this validated request to exactly one installed implementation skill
whose description names `workflow-adapter-worktree-read` and whose trigger matches
the request and repository context. If none or more than one match, return
`missing-provider` or `ambiguous-provider`; never try another provider after
delegation.
On success return `status: applied`, `operation: read`, non-empty string
`provider`, and
`value.worktree` containing non-empty canonical string `locator`, absolute
string `path`, enum string `kind` of `main` or `linked`, non-empty string
`branch` or null, hexadecimal string `head`, complete `association_metadata`
JSON value or null when unavailable, and optional JSON object `provider_fields`.
On failure return the complete original mapping `request` with
`status: unapplied`, `operation: read`, optional selected non-empty string
`provider`, non-empty string `reason`, actionable non-empty string `detail`, and
optional non-empty string-list `candidates`. Reasons
are `missing-provider`, `ambiguous-provider`, `invalid-request`, `not-found`,
`ambiguous-match`, `unsupported`, `readiness-failure`, or `provider-failure`.
