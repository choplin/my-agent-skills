# Workflow configuration

Read this before first lifecycle use of an octa store. States, labels, and
label groups are configured once for the whole store and govern every
repository in it; `octa config` rejects `--repo` and `--all-repos`. A rename or
deletion here moves or retires Issues in every repository, so inspect before
changing anything.

## Issue states

Inspect existing states:

```sh
octa config issue state list --json
```

Each row carries `name`, `type`, and `is_default`. The type is `open`,
`in progress`, or `closed`, and it is the only classification a state has.

Projects carry their own states under `octa config project state`, over a
two-value type axis. They are a separate configuration; see below.

### The lifecycle this convention configures

octa's own seed is one state per type plus a second way work ends. This
operating convention splits capture from grooming and execution from review, so
it configures six states across the same three types:

| State | Type | Default | Notes |
|---|---|---|---|
| Backlog | open | yes | new Issues enter here |
| Todo | open | | |
| In Progress | in progress | yes | |
| In Review | in progress | | |
| Done | closed | yes | |
| Canceled | closed | | |

Two `in progress` states are intentional: In Progress is work and In Review is
review, and only their names say which is which. Two `closed` states are
intentional for the same reason: Done and Canceled are both closed, and the
name carries why.

### Bringing a store to it

A store with no configured states is seeded with `open`, `in progress`,
`closed`, and `not planned`, one default per type. Seeding runs only when no
state is configured at all, so a customized store keeps exactly the states it
has. Rename the seeded states into the set above rather than stacking
near-duplicates beside them:

```sh
octa config issue state set "open" --name Backlog          # renaming moves its Issues too
octa config issue state set "in progress" --name "In Progress"
octa config issue state set "closed" --name Done
octa config issue state set "not planned" --name Canceled
octa config issue state create Todo --type open
octa config issue state create "In Review" --type "in progress"
```

Renaming carries each type's existing default with it, so Backlog, In Progress,
and Done end up as the defaults without a further command.

For a store that already holds other states, rename where the target name is
free and delete with `--move-to` where it collides with a state the store
already has:

```sh
octa config issue state delete <old> --move-to <new>  # --move-to is required while Issues remain
```

The schema refuses to delete a state that still holds Issues without
`--move-to`, and deleting a state never deletes Issues.

### Types and their defaults

`config issue state create <name>` takes `--type open|in progress|closed` (default
`open`) and `--default`. `config issue state set <name>` changes `--name` or
`--type`, and `--default` makes the state its own type's default. The default
needs no type argument anywhere, since a state already carries exactly one
type.

The first state of an empty type becomes that type's default whether or not
`--default` was passed, and the command says so. A type's default cannot be
deleted or retyped while another state of that type remains — move the default
first. The `open` and `closed` types must stay populated, since every Issue has
to be able to start and to end. The `in progress` type may be emptied, and then
`issue start` reports that it has nowhere to go.

States carry no ordinal. `config issue state list` derives its order from type
(`open`, then `in progress`, then `closed`), then the type's default, then
name, so there is nothing to reorder and order never carries meaning.

If the store is missing one of the six states above, report that instead of
substituting another one.

## Project states

Projects carry a configured state the same way Issues do, under a separate
command tree and a narrower type axis:

```sh
octa config project state list --json
```

The type is `open` or `closed`, and there is no `in progress`. A Project is an
outcome that is either still open or finished with, and whether work is under
way inside it is already readable from its Issue tally. Name a Project state
`Planned` or `In Progress` when that distinction matters; both are `open`.

A store with no configured Project states is seeded with `open`, `closed`, and
`not planned`, one default per type. The verbs, defaults, and delete rules match
the Issue side:

```sh
octa config project state create Planned --type open
octa config project state set Planned --default
octa config project state delete Planned --move-to open
```

Both types must stay populated, since every Project has to be able to start and
to end.

This operating convention prescribes no particular Project state set. Unlike the
Issue lifecycle, nothing here depends on specific Project state names, so leave
the seeded set alone unless a repository needs more.

## Type labels

Inspect first, then create missing Issue definitions:

```sh
octa config issue label-group create Type --selection single
octa config issue label create impl --group Type
octa config issue label create design --group Type
octa config issue label create research --group Type
```

Labels are store-wide, and the record they classify is part of the command
name: `octa config issue label ...` and `octa config project label ...`. Do
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
    octa issue start <number> --lease "$LEASE"
    octa issue unlock <number> --lease "$LEASE"

The CLI returns the lease ID only at acquisition. It may appear in tool output
and command arguments, but do not persist it in Issue comments, worktree notes,
repository files, commits, or user-facing output.
Release it before a cross-session handoff. Use `issue unlock <number> --force`
only for explicit recovery after confirming that no active session still owns
the work; force recovery invalidates the old lease ID immediately.
