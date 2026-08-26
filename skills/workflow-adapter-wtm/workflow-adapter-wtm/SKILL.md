---
name: workflow-adapter-wtm
description: >-
  Implements workflow-adapter-worktree operations through the wtm CLI. Use as
  the provider adapter when a caller selects wtm, supplies a wtm worktree
  locator, or repository instructions designate wtm for worktree management.
---

# Access repository worktrees through wtm

Accept one complete operation from `workflow-adapter-worktree`. Apply it through
the installed `wtm-worktree` skill. Own only wtm names, `.wtm/` placement, CLI
flags, note storage, and readback mechanics. If `wtm`, its skill, or the target
Git repository is unavailable, report the readiness failure and stop. Never
install or configure wtm, use bare `git worktree` as a fallback, or choose
another provider.

## Apply operations

- **Resolve:** use the explicit wtm name or a path already reported by wtm. For
  repository-only context, resolve the repository through `wtm list`; do not
  claim an arbitrary linked worktree that wtm does not manage.
- **List:** use machine-readable wtm output. When exact association metadata is
  supplied, inspect each candidate whose list output omits its note, compare
  the complete stored note, and return every match; do not select among
  multiple matches.
- **Read:** show the exact wtm worktree in machine-readable form and return its
  name as the locator, absolute path, `main` or `linked` kind, branch, HEAD,
  creation time, and complete note as association metadata. Derive kind from
  Git's common-directory metadata when wtm output does not include it.
- **Create:** require the caller's worktree name and branch intent. Map a new
  branch and optional base to `wtm add --branch --base`; map an existing branch
  to `wtm add --checkout`. Map association metadata unchanged to the wtm note.
  Do not derive a branch or base, reuse a colliding name, or retry without
  metadata after a hook failure.
- **Remove:** resolve the exact name and inspect status before removal. Map
  `keep` to worktree-only removal, `delete-if-merged` to safe branch deletion,
  and `force-delete` to forced branch deletion. Use wtm's non-interactive
  confirmation flag only after the caller has requested removal; it does not
  authorize discarding dirty files. Forced branch deletion must already be
  explicit in the operation. Run removal from outside the target worktree and
  preserve any refusal caused by uncommitted files.

After create or remove, list worktrees again and verify the requested presence
or absence. A successful command exit alone is not verification. Return `wtm`
as the provider, the wtm name as canonical locator, all requested worktree
fields available from wtm, verification evidence, and any unapplied operation.
