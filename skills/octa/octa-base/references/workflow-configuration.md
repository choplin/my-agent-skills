# Workflow configuration

Read this before first lifecycle use of an octa store. States, labels, and
label groups are configured once for the whole store and govern every
repository in it; `octa config` rejects `--repo` and `--all-repos`. A rename or
deletion here moves or retires Issues in every repository, so inspect before
changing anything.

## States

Inspect existing states:

```sh
octa config state list --json
```

A store with no configured states is seeded with the full lifecycle, and new
Issues start in Backlog:

| State | Flags | Notes |
|---|---|---|
| Backlog | starting | new Issues enter here |
| Todo | — | |
| In Progress | — | |
| In Review | — | |
| Done | terminal | |
| Canceled | terminal | |

Seeding runs only when no state is configured at all, so a customized store
keeps exactly the states it has. Bring it back to the set above rather than
stacking near-duplicate states on top:

```sh
octa config state set <old> --name <new>        # renaming moves its Issues too
octa config state delete <old> --move-to <new>  # --move-to is required while Issues remain
octa config state create "In Review"
octa config state set-default Backlog
```

Rename where the target name is free, and delete with `--move-to` where it
collides with a state the store already has. `config state create` takes
`--starting` and `--terminal`, which are mutually exclusive; `config state set`
changes `--name` or `--terminal`.

Two non-terminal working states are intentional: In Progress is work and In
Review is review, and only their names say which is which. States carry no
ordinal; `config state list` derives its order from the two flags and then
name, so there is nothing to reorder and order never carries meaning.

Backlog is the starting state — the one new Issues enter without an explicit
`--state`. The store has at most one, enforced by the schema. Move it with
`octa config state set-default <name>`; setting it clears the flag everywhere
else. With no starting state, `issue create` fails with the command that fixes
it; report a missing or duplicated state instead of guessing a substitute.

## Type labels

Inspect first, then create missing Issue definitions:

```sh
octa config label-group create Type --target issue --selection single
octa config label create impl --target issue --group Type
octa config label create design --target issue --group Type
octa config label create research --target issue --group Type
```

Labels are store-wide and require `--target issue` or `--target project`. Do
not create Repo labels: octa scopes records by the Git repository identity. Do
not reserve any taxonomy beyond this operating convention in product code.

Do not add `orchestration` by default. Introduce it only together with an
octa-aware planning/orchestration workflow that defines how its control Issue
is created, resumed, and completed.

octa has no built-in priority. If ranking ever has to be recorded, it is a
`single` label group like any other classification, and it is not part of this
operating convention.

## Lease handles

Issue mutation ownership uses a non-expiring lease rather than an actor name.
The returned three-word ID coordinates local ownership and is not a security
boundary. Capture it and pass it to protected commands:

    LEASE=$(octa issue lock <number>)
    octa issue set-state <number> "In Progress" --lease "$LEASE"
    octa issue unlock <number> --lease "$LEASE"

The CLI returns the lease ID only at acquisition. It may appear in tool output
and command arguments, but do not persist it in Issue comments, worktree notes,
repository files, commits, or user-facing output.
Release it before a cross-session handoff. Use `issue unlock <number> --force`
only for explicit recovery after confirming that no active session still owns
the work; force recovery invalidates the old lease ID immediately.
