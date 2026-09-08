---
name: octa-overview
description: Gives a read-only snapshot of the current Git repository's octa work as a Markdown section per active Project plus Project-unassigned Issues, with open, in progress, and closed counts and a list of the unfinished Issues by most recent update. Use when deciding what is active or next without changing tracker state.
metadata:
  description-role: documentation
---

# Overview current octa work

Apply `octa-base`. This skill reads and reports only; never create, edit, lock,
or transition a record.

The point of this skill is the report, not the reading. Its goal is that a
reader takes in the whole state of the repository's work at a glance, at the
lowest cognitive load the medium allows — which Project is moving, what is
ready to pick up, what is stuck. Every rule in `## Report` exists to serve
that, and the layout is load-bearing rather than cosmetic: a change that makes
the output flatter, longer, or more uniform defeats the skill even when every
fact in it stays correct. When a formatting decision is open, resolve it
towards what the eye can separate without reading.

## Flow

### 1. Read everything in one query

The overview always needs the same fields, so it is one fixed read. Run this
document verbatim. Do not consult `octa query --schema`, do not probe the CLI
for available fields, and do not assemble a different document — the shape
below is the contract this skill is written against.

```
octa query <<'GRAPHQL'
{
  projects(limit: 100) { id name summary state stateType }
  unfinished: issues(filter: { stateType: ["open", "in progress"] }, limit: 100) {
    number title state stateType updatedAt leased
    project { id }
    labels { name }
    blockedBy { number stateType }
  }
  closed: issues(filter: { stateType: "closed" }, limit: 100) {
    number
    project { id }
  }
}
GRAPHQL
```

One response covers the whole report. `state` and `stateType` arrive together
on every Issue, so no separate read of the state configuration is needed to
turn a state into a count column; and the closed Issues arrive carrying their
Project id, so no Project tally is needed either.

Inspect the response `errors` before consuming `data`; the process can exit
successfully on a failed operation. When a list comes back holding exactly 100
entries, re-run that one list with `offset` until it returns fewer, and merge —
`projects` and `closed` are the ones that realistically overflow.

If `octa` is not on PATH, or the command fails because the working directory is
not a Git repository octa knows, report that and stop rather than falling back
to another command.

### 2. Partition and count

Discard Projects whose `stateType` is `closed` before building the report.
Never render a section for a closed Project, including when it has unfinished
Issues. Do not move those Issues into **No Project**; they remain assigned to
the closed Project and are outside this overview of current work.

Partition the remaining `unfinished` Issues into their active Project or
**No Project**, matching on `project.id` against the `projects` result.

Count each block from the same response: `open` and `in progress` from the
`unfinished` Issues by `stateType`, and `closed` from the `closed` Issues,
grouped by `project.id`, with the null-Project ones forming the **No Project**
count. If `closed` was too large to paginate through, omit the closed count and
say it was not counted; do not substitute a repository-wide number for it.

An active Project's `summary` is the purpose line. An active Project with no
Issue in any of the three counts is still current work; report it with its zero
row.

## Report

Write Markdown. Active Project is the top information axis: group each active
Project's counts, purpose, and unfinished Issues together. Keep **No Project**
as a distinct final group, including when its counts are zero.

Order Project groups by activity, with Projects carrying `in progress` work before
those whose unfinished work is all `open`.

For each Project, include:

- its name and `open`, `in progress`, and `closed` counts;
- its summary when the name alone does not convey the purpose;
- its `open` and `in progress` Issues together, ordered by the full `updatedAt`
  timestamp, most recent first, with at most 10 displayed;
- the number omitted when more than 10 Issues exist.

For every displayed Issue, include the information needed to identify it and
judge recency and pickability:

- update date;
- state, preserving the distinction among In Progress, In Review, Todo, and
  Backlog;
- Type (`impl`, `design`, or `research`) when set;
- lease status when claimed;
- blockers outside the `closed` type.

The state continues to name lifecycle state only: a blocked Todo is still Todo,
with its blocker shown separately.

For example:

```markdown
## Replace the cache path — 2 open · 2 wip · 11 closed
Swap the cache path for the new resolver

- `#12` Point the resolver at the new cache root — 08-17 · `wip` `impl` `leased`
- `#18` Add cache diagnostics — 08-16 · `review` `impl`
- `#14` Remove the compatibility layer — 08-15 · `todo` `impl` `blocked by #12, #18`
- `#21` Decide the invalidation contract — 08-11 · `backlog` `design`

────────────────────

## No Project — 1 open · 0 wip · 3 closed

- `#30` Refresh the contributor guide — 08-09 · `backlog`

────────────────────

The cache-path replacement is under way in #12, while #14 is waiting for both
active changes. Resume #12 with `octa-start`, or use it to groom the unassigned
Backlog Issue #30.
```

If neither an active Project nor a Project-unassigned unfinished Issue exists,
say that no current work was found in this repository rather than printing
empty sections. Closed Projects do not prevent this empty result.

After the Project groups, close with a short evidence-based interpretation of
what is changing, what is ready next, and any blocker or concentration of risk.
Ground it in the shown Issues rather than restating the counts. In Progress and
In Review Issues are resume candidates; Todo Issues are pickable when their
blockers are closed.

Then route without acting:

- start/resume → `octa-start`;
- groom a Project Backlog → `octa-groom`;
- groom a **No Project** Backlog Issue → pick it through `octa-start`, which
  applies the single-Issue grooming gate before execution;
- pause active work → `octa-handoff`.
