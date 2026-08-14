# Octa CLI contract used by lifecycle skills

Read this reference before constructing Issue list, GraphQL query, or
lease-protected mutation commands. Inspect `octa --help` and the relevant
nested help when the installed binary differs from these examples.

This file records product mechanics. Lifecycle states, Issue authoring,
ownership duration, review gates, and handoff policy remain in `octa-base` and
its workflow skills.

## Issue list selectors

`issue list` with no selector and `--open` return non-terminal Issues.
`--closed` returns terminal Issues, and `--all` returns both.
`--state <name>` matches one configured state name exactly.

`--open`, `--closed`, `--all`, and `--state` are mutually exclusive.
Do not use the legacy forms `--state all` or `--state open` to express
terminal filtering.

    octa issue list --open --json
    octa issue list --closed --json
    octa issue list --all --json
    octa issue list --state "In Progress" --json

## Read-only GraphQL query

`octa query` reads a GraphQL document from stdin or `--file` and accepts
variables as a JSON object. Use it when one read needs selected fields across
related entities.

    octa query --variables '{"number": 12}' <<'GRAPHQL'
    query IssueContext($number: Int!) {
      issue(number: $number) {
        number
        title
        state
        statusType
        leased
        project { id name state statusType }
        labels { name }
        blockedBy { number state statusType }
        pullRequests { number branch state }
      }
    }
    GRAPHQL

The response is a GraphQL JSON envelope. Inspect `errors` even when the
process exits successfully; read `data` only when the requested operation
succeeded. `extensions.dbAccesses` reports executed database queries.

For a repository overview, one document can select Projects and Issues with
their Project relation:

    octa query <<'GRAPHQL'
    {
      projects(limit: 100) {
        id
        name
        state
        statusType
        priority
      }
      issues(limit: 100) {
        number
        title
        state
        statusType
        priority
        leased
        project { id name }
        labels { name }
        blockedBy { number state statusType }
      }
    }
    GRAPHQL

List fields default to 50 and accept at most 100 records. Use pagination rather
than assuming one response contains a larger repository. The schema is
read-only; use existing CLI commands for mutations.

## Issue leases

`issue lock <number>` atomically acquires a non-expiring lease and prints a
human-readable three-word lease ID such as `amber-otter-lantern`. It is a
non-secret coordination handle, not a security credential. Retain it in the
live session for later protected commands:

    LEASE=$(octa issue lock 12)

`issue list` and `issue show` expose only `leased`, never the lease ID.
When `leased` is true and the current live session does not retain the
lease ID, stop and report the contention. Do not infer an owner and do not
force-release it.

The lease ID may appear in tool output and command arguments. Do not copy it
into Issue comments, worktree notes, repository files, commits, or other
durable project artifacts.

The matching `--lease` is required for:

- `issue set-state`, `set`, `unset`, `add`, and `remove`;
- normal `issue unlock`;
- Issue–PR link changes through `pr create --issue`, `pr add`, and
  `pr remove`.

The lease ID is not required for:

- Issue creation, Issue comments, reads, or lease acquisition;
- unlinked PR creation, PR comments, PR metadata/state changes;
- Project, Milestone, Wiki, or config operations.

Use the lease ID on every protected mutation and release it normally:

    octa issue set 12 --priority 2 --lease "$LEASE"
    octa issue set-state 12 "In Progress" --lease "$LEASE"
    octa issue unlock 12 --lease "$LEASE"

If the lease ID is irretrievably lost, `issue unlock 12 --force` is an
explicit recovery action. Confirm that no active session still owns the work
before using it. Force recovery invalidates the old lease ID, and a later
session must acquire a fresh lease.
