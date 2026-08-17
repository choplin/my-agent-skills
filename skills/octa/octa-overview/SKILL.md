---
name: octa-overview
description: Gives a read-only snapshot of the current Git repository's octa work, grouped by active Project and Project-unassigned Issues, with counts for In Progress, In Review, Todo, and Backlog plus representative work and visible blockers. Use when deciding what is active or next without changing tracker state.
---

# Overview current octa work

Apply `octa-base`. This skill reads and reports only; never create, edit, lock,
or transition a record.

## Flow

1. Confirm `octa` is available and run inside the target Git repository.
2. Read `octa config state list --json` and report any of the six states —
   Backlog, Todo, In Progress, In Review, Done, Canceled — that the store is
   missing, rather than substituting another one for it.
3. Read `octa project list --json` (all Projects, including terminal) for the
   open/closed/total tallies. Then use the repository-overview GraphQL
   document from `octa-base/references/cli-contract.md` to select Issues with
   their Project and labels. Inspect the response `errors` before consuming
   `data`, and paginate when more than 100 records exist.
4. Partition every non-terminal Issue into its Project or **No Project**. Use
   the complete Project result to classify the attached Project. Do not hide
   Issues assigned to a completed/canceled Project; show them under that
   Project and flag the inconsistent context. Never infer terminal state merely
   because a Project was absent from an active-only query.
5. Group by In Progress, In Review, Todo, and Backlog. Tell those states apart
   by name only; the terminal flag is all a state carries besides the starting
   flag, and listing order means nothing.

Within each block, count every Issue and show, most recently updated first:

- working: up to 5;
- review: up to 5;
- Todo: up to 5;
- Backlog: up to 3;
- optional `(Done N)` for Project blocks; exclude Canceled from progress.

For each shown Issue include `#number` and title. Add a short purpose clause
only when the title is unclear. Read `octa issue show <n> --json` for displayed
Todo Issues when blocker status materially affects pickability. Say how many
items were omitted beyond each limit.

Order blocks by activity: In Progress before In Review, then Todo, then
Backlog.
Project-unassigned work remains visible.

Use a compact form:

```text
<Project>
  In Progress  1
    #12 Replace cache path
  In Review    0
  Todo         2
    #14 Remove compatibility layer
  Backlog      4  (Done 9)
    #18 Add diagnostics
    …3 more

No Project
  In Progress  0
  In Review    0
  Todo         1
  Backlog      0
```

Close with a short evidence-based interpretation: what is changing, what is
ready next, and any blocker or concentration of risk. Then route without acting:

- start/resume → `octa-start`;
- groom a Project Backlog → `octa-groom`;
- pause active work → `octa-handoff`.
