# Octa CLI contract used by lifecycle skills

Read this reference before constructing Issue list, GraphQL query, or
lease-protected mutation commands. Inspect `octa --help` and the relevant
nested help when the installed binary differs from these examples.

This file records product mechanics. Lifecycle states, Issue authoring,
ownership duration, review gates, and handoff policy remain in `octa-base` and
its workflow skills.

## State types

A configured state carries exactly one classification: its `type`, one of
`open`, `in progress`, or `closed`. An Issue is closed when its state's type is
`closed`; that is derived from the type, not a separate stored flag. Why an
Issue closed is a reason carried by the state name, which is why a store can
hold two `closed` states without the axis gaining a fourth value.

A type that holds any state has exactly one default, the state a transition
verb resolves to when given no explicit target. `config state list --json`
returns each state's `name`, `type`, and `is_default`.

## Issue transitions

Each verb moves the Issue to its own type's default state:

| Command | Moves to |
|---|---|
| `issue open` (alias `create`) | the `open` default |
| `issue start` | the `in progress` default |
| `issue close` | the `closed` default |
| `issue reopen` | the `open` default |

`--as <state>` reaches another state of that verb's own type and rejects any
other type. `issue start` takes no `--as`. `issue set --as <state>` is the only
unconstrained move and reaches any configured state of any type.

    octa issue open --title <title> --json          # into the open default
    octa issue open --title <title> --as Todo --json
    octa issue start 12 --lease "$LEASE"
    octa issue set 12 --as "In Review" --lease "$LEASE"
    octa issue close 12 --lease "$LEASE"
    octa issue close 12 --as Canceled --lease "$LEASE"

## Issue list selectors

`issue list` with no selector returns Issues outside the `closed` type.
`--state <names>` matches configured state names and `--state-type <types>`
matches state types, both comma-separated and matching any listed value.
`--all` applies no filter.

The three selectors are mutually exclusive, because a state name already fixes
its type. States are global configuration, so `--state` and `--state-type` also
work under `--all-repos`.

    octa issue list --json
    octa issue list --state-type "in progress" --json
    octa issue list --state-type "open,in progress" --json
    octa issue list --state "In Progress,In Review" --json
    octa issue list --all --json

`--label`, `--project`, `--milestone`, `--related-to`, and `--unblocked`
narrow the result further and require one repository.

## Read-only GraphQL query

`octa query` reads a GraphQL document from stdin or `--file` and accepts
variables as a JSON object. Use it when one read needs selected fields across
related entities. `octa query --schema` prints the versioned public schema;
read it instead of guessing at fields.

    octa query --variables '{"number": 12}' <<'GRAPHQL'
    query IssueContext($number: Int!) {
      issue(number: $number) {
        number
        title
        state
        stateType
        leased
        project { id name state isClosed }
        labels { name group }
        blockedBy { number state stateType }
        pullRequests { number branch state }
      }
    }
    GRAPHQL

The response is a GraphQL JSON envelope. Inspect `errors` even when the
process exits successfully; read `data` only when the requested operation
succeeded. `extensions.dbAccesses` reports executed database queries.

For a repository overview, one document can select Projects and the unfinished
Issues with their Project relation:

    octa query <<'GRAPHQL'
    {
      projects(limit: 100) {
        id
        name
        state
        isClosed
      }
      issues(filter: { stateType: ["open", "in progress"] }, limit: 100) {
        number
        title
        state
        stateType
        updatedAt
        leased
        project { id name }
        labels { name }
        blockedBy { number state stateType }
      }
    }
    GRAPHQL

`IssueFilter` takes `state`, `stateType`, `label`, and `projectId`; `state` and
`stateType` each accept one value or a list and match an Issue carrying any
listed value. `ProjectFilter` takes `isClosed` and `label`. `Project.isClosed`
is a separate axis from Issue state types and is unrelated to them. Neither the
objects nor the filters carry a priority or a status category.

List fields default to 50 and accept at most 100 records. Use pagination rather
than assuming one response contains a larger repository. Query depth is limited
to 8 and complexity to 500. The schema is read-only; use existing CLI commands
for mutations.

## Project tallies

`project list --json` includes every Project, closed ones included; `--active`
filters to Projects that are not closed. Each Project carries a `tally` with
`open`, `closed`, and `total`. That `open` counts every Issue outside the
`closed` type, so it merges the `open` and `in progress` types; derive the
three-way split from the Issues themselves rather than from the tally.

## Issue leases

`issue lock <number>` atomically acquires a non-expiring lease and prints a
readable three-word lease ID such as `amber-otter-lantern`. It coordinates
local ownership and is not a security boundary. Retain it in the live session
for later protected commands:

    LEASE=$(octa issue lock 12)

`issue list`, `issue show`, and GraphQL expose only `leased`, never the lease
ID. When `leased` is true and the current live session does not retain the
lease ID, stop and report the contention. Do not infer an owner and do not
force-release it.

The lease ID may appear in tool output and command arguments. Do not copy it
into Issue comments, worktree notes, repository files, commits, or other
durable project artifacts.

The matching `--lease` is required for:

- `issue start`, `close`, `reopen`, `set`, `unset`, `add`, and `remove`;
- normal `issue unlock`;
- Issue–PR link changes through `pr create --issue`, `pr add`, and
  `pr remove`.

The lease ID is not required for:

- Issue creation, Issue comments, reads, or lease acquisition;
- unlinked PR creation, PR comments, PR metadata/state changes;
- Project, Milestone, Wiki, or config operations.

Use the lease ID on every protected mutation and release it normally:

    octa issue add 12 --label impl --lease "$LEASE"
    octa issue start 12 --lease "$LEASE"
    octa issue unlock 12 --lease "$LEASE"

If the lease ID is irretrievably lost, `issue unlock 12 --force` is an
explicit recovery action. Confirm that no active session still owns the work
before using it. Force recovery invalidates the old lease ID, and a later
session must acquire a fresh lease.
