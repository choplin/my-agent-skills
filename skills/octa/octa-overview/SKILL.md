---
name: octa-overview
description: Gives a read-only snapshot of the current Git repository's octa work as a Markdown section per Project plus Project-unassigned Issues, with open, in progress, and closed counts and a list of the unfinished Issues by most recent update. Use when deciding what is active or next without changing tracker state.
metadata:
  description-role: documentation
---

# Overview current octa work

Apply `octa-base`. This skill reads and reports only; never create, edit, lock,
or transition a record.

## Flow

### 1. Confirm the store

Confirm `octa` is available and run inside the target Git repository.

Read `octa config issue state list --json`. Each row carries `name`, `type`, and
`is_default`. Report any of the six states — Backlog, Todo, In Progress, In
Review, Done, Canceled — that the store is missing, rather than substituting
another one for it. Keep the returned name-to-type mapping: it is what turns a
state name into a count column, and it is store configuration rather than
something to assume.

### 2. Read the Projects

Read `octa project list --json`, which returns every Project including closed
ones. Keep each Project's `name`, `state`, `state_type`, and `tally`.

The tally's `open` counts every Issue outside the `closed` type, so it merges
the `open` and `in progress` types and cannot supply the three-way split. Take
only `tally.closed` and `tally.total` from it.

### 3. Read the unfinished Issues

Use the repository-overview GraphQL document from
`octa-base/references/cli-contract.md` to select the `open` and `in progress`
Issues with their Project and labels:

```graphql
{
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
```

Inspect the response `errors` before consuming `data`, and paginate with
`offset` when more than 100 records exist.

### 4. Partition and count

Partition every returned Issue into its Project or **No Project**. Use the
complete Project result from step 2 to classify the attached Project. Do not
hide Issues assigned to a closed Project; show them under that Project and flag
the inconsistent context. A Project is closed when its `state_type` is
`closed`; never infer it from absence in an active-only query.

Derive each block's `open` and `in progress` counts from the Issues themselves,
using the state-to-type mapping from step 1. Take `closed` from the Project's
tally. The **No Project** block has no tally, so read its closed count with a
minimal query and count the Issues whose `project` is null:

```graphql
{
  issues(filter: { stateType: "closed" }, limit: 100) {
    number
    project { id }
  }
}
```

Paginate it the same way. If the store is large enough that paginating it is not
worthwhile, omit the No Project closed count and say it was not counted; do not
substitute a repository-wide number for it.

## Report

Write Markdown. Project is the top axis, so each Project is its own `##`
section and the Issues inside it are a list. Do not write the report as prose,
and do not use tables: the pipes and header rows are overhead the reader does
not need. Structure comes from the list, one line per Issue.

Order the sections by activity: a Project with `in progress` work outranks one
sitting entirely in `open`. Keep the **No Project** section last, and keep it
even when its only content is a zero row.

For each section:

1. A counts line: `**open** N · **in progress** N · **closed** N (total N)`.
2. One list of that block's `open` and `in progress` Issues, most recently
   updated first, up to **10 items**. Both types share one list so the
   ordering is a single activity axis; the State field keeps the six states
   apart.
3. When items were omitted, a line saying how many.

Each item is one line, fields in a fixed order separated by ` · ` (middle dot):
`#number` and the title verbatim first, then State, then the Updated date, then
Notes only when it is non-empty. Add a short purpose clause after the title
only when the title is unclear. Keeping the field order and separator constant
is what lets the reader scan the list as columns without a table.

Updated is the `updatedAt` date. Order on the full timestamp, and when every
displayed date in a block is the same day, show the time too — otherwise the
list asserts a recency ranking the reader cannot see. A block whose Issues
were all touched in one bulk import has no meaningful recency order at all; say
so rather than presenting the order as activity.

Notes carries what changes pickability and nothing else: the Type label
(`impl`, `design`, `research`) when it is set, `leased` when the Issue is
claimed, and `blocked by #N` for each blocker outside the `closed` type. Cap the
blockers at three and append `+N more`, so one heavily blocked Issue does not
crowd out the rest of the list. Read `octa issue show <n> --json` for a
displayed Issue only when blocker status materially affects whether it can be
picked up.

```markdown
## Replace the cache path

**open** 6 · **in progress** 2 · **closed** 11 (total 19)

- #12 Replace the cache path · In Progress · 2026-08-17 · impl, leased
- #18 Add cache diagnostics · In Review · 2026-08-16 · impl
- #14 Remove the compatibility layer · Todo · 2026-08-15 · impl, blocked by #12
- #21 Decide the invalidation contract · Backlog · 2026-08-11 · design

4 more open Issues not shown.

## No Project

**open** 1 · **in progress** 0 · **closed** 3 (total 4)

- #30 Refresh the contributor guide · Backlog · 2026-08-09
```

If neither a Project nor a Project-unassigned unfinished Issue exists, say that
no current work was found in this repository rather than printing empty
sections.

Close with a short evidence-based interpretation under its own `##` heading:
what is changing, what is ready next, and any blocker or concentration of risk.
Ground it in the shown Issues rather than restating the counts. In Progress and
In Review rows are the resume candidates; Todo rows are the pickable ones.

Then route without acting:

- start/resume → `octa-start`;
- groom a Project Backlog → `octa-groom`;
- groom a **No Project** Backlog Issue → pick it through `octa-start`, which
  applies the single-Issue grooming gate before execution;
- pause active work → `octa-handoff`.
