# Repository workflow setup

Read this before first lifecycle use in a Git repository.

## States

Inspect existing states:

```sh
octa config state list --json
```

A repository with no configured states is seeded with the full lifecycle, and
new Issues start in Backlog:

| State | Status type | Notes |
|---|---|---|
| Backlog | `backlog` | starting state |
| Todo | `unstarted` | |
| In Progress | `started` | |
| In Review | `started` | |
| Done | `completed` | terminal |
| Canceled | `canceled` | terminal |

Seeding runs only for a repository that has no states at all, so a repository
whose states were customized keeps exactly the ones it has. Bring it back to the
set above rather than stacking near-duplicate states on top:

```sh
octa config state set <old> --name <new>        # renaming moves its Issues too
octa config state delete <old> --move-to <new>  # --move-to is required while Issues remain
octa config state create "In Review" --type started
octa config state set-default Backlog
```

Rename where the target name is free, and delete with `--move-to` where it
collides with a state the repository already has.

Two `started` states are intentional: In Progress is work and In Review is
review, and only their names say which is which. States carry no ordinal;
`config state list` derives its order from `status_type` and then name, so there
is nothing to reorder and order never carries meaning.

Backlog is the starting state — the one new Issues enter without an explicit
`--state`. A repository has at most one, enforced by the schema. Move it with
`octa config state set-default <name>`; setting it clears the flag everywhere
else. If a repository has no starting state, `issue create` fails with the
command that fixes it; report a missing or duplicated state instead of guessing
a substitute.

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
    octa issue set-state <number> "In Progress" --lease "$LEASE"
    octa issue unlock <number> --lease "$LEASE"

The CLI returns the lease ID only at acquisition. It may appear in tool output
and command arguments, but do not persist it in Issue comments, worktree notes,
repository files, commits, or user-facing output.
Release it before a cross-session handoff. Use `issue unlock <number> --force`
only for explicit recovery after confirming that no active session still owns
the work; force recovery invalidates the old lease ID immediately.
