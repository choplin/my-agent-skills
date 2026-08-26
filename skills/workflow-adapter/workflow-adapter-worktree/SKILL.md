---
name: workflow-adapter-worktree
description: >-
  Routes repository worktree discovery, inspection, creation, and removal to an
  installed worktree provider. Internal entry point for provider-neutral
  workflows that need an isolated workspace or must manage an existing one.
---

# Access repository worktrees

Accept one caller-owned operation:

- `resolve` with repository context, an explicit provider, or an existing
  worktree locator;
- `list` with repository context and optional exact association metadata;
- `read` with one exact locator;
- `create` with a worktree name, new or existing branch, optional base, and
  optional caller-owned association metadata;
- `remove` with one exact locator and an explicit branch disposition of `keep`,
  `delete-if-merged`, or `force-delete`.

The caller decides whether isolation is needed, which branch and base to use,
what association metadata to attach, and whether cleanup is safe. Do not invent
those decisions, turn a readiness failure into current-workspace execution, or
upgrade safe branch deletion to forced deletion.

Honor an explicit provider or provider-owned locator first. Otherwise select a
provider from repository instructions and installed worktree provider adapters.
If more than one remains plausible and they manage different workspace sets,
ask one focused provider question.

Delegate the operation unchanged to the selected provider adapter. Never switch
providers after a readiness or mutation failure. Treat association metadata as
opaque caller content; the provider may map it to a note, label, or equivalent
mechanism but must return it without semantic rewriting.

Return the provider identity and canonical worktree locator, absolute path,
`main` or `linked` kind, branch, HEAD, and association metadata that the provider
can report. For a mutation, also return verification evidence and any unapplied
operation. Stop on an ambiguous match, unsupported operation, dirty-worktree
refusal, or failed verification instead of guessing a target or falling back to
another provider.
