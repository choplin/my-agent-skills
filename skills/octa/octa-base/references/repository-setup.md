# Repository workflow setup

Read this before first lifecycle use in a Git repository.

## States

Inspect existing states:

```sh
octa config state list --json
```

octa initially seeds compatibility states `open` (`unstarted`), `in_progress`
(`started`), and `closed` (`completed`). Reuse them as Todo, In Progress, and
Done. Create only the missing lifecycle distinctions:

```sh
octa config state create Backlog --type backlog
octa config state create "In Review" --type started
octa config state create Canceled --type canceled --terminal
```

Do not add duplicate Todo/In Progress/Done states merely to obtain friendlier
names: current octa does not rename or remove the compatibility states, and
duplicates make state selection ambiguous. In an already-configured repository,
resolve by type and configured order; names may differ. If multiple states of a
single-valued type (`backlog`, `unstarted`, `completed`, or `canceled`) already
exist, show the ambiguity instead of guessing. Two `started` states are
intentional: the earlier one is work and the later one is review.

## Type labels

Inspect first, then create missing Issue definitions:

```sh
octa config label-group create Type --target issue --selection single
octa config label create impl --target issue --group Type
octa config label create design --target issue --group Type
octa config label create research --target issue --group Type
```

Labels are repository-local. Do not create Repo labels: octa scopes records by
the Git repository identity. Do not reserve any taxonomy beyond this operating
convention in product code.

Do not add `orchestration` by default. Introduce it only together with an
octa-aware planning/orchestration workflow that defines how its control Issue
is created, resumed, and completed.

## Lease handles

Issue mutation ownership uses a non-expiring lease rather than an actor name.
The returned three-word ID is a non-secret coordination handle. Capture it and
pass it to protected commands:

    LEASE=$(octa issue lock <number>)
    octa issue set-state <number> in_progress --lease "$LEASE"
    octa issue unlock <number> --lease "$LEASE"

The CLI returns the lease ID only at acquisition. It may appear in tool output
and command arguments, but do not persist it in Issue comments, worktree notes,
repository files, commits, or user-facing output.
Release it before a cross-session handoff. Use `issue unlock <number> --force`
only for explicit recovery after confirming that no active session still owns
the work; force recovery invalidates the old lease ID immediately.
