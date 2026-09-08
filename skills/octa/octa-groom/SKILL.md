---
name: octa-groom
description: >-
  Prepares one active octa Project's Backlog for context-free execution by
  working oldest first with the user, producing self-complete Todo Issues and
  splitting oversized work or recording dependencies when needed.
metadata:
  description-role: documentation
---

# Groom an octa Backlog

Apply `octa-base`, especially its Todo authoring standard, grouping rules, Type
labels, and state mapping.

## Flow

### 1. Select one active Project

Run `octa project list --active --json` in the current repository.

- none: report that no active Project exists and stop;
- one: select it silently;
- several: show their names, state, and the `open`/`closed`/`total` tally, then
  ask the user which Project to groom. That tally's `open` merges the `open` and
  `in progress` types; do not present it as unstarted work.

### 2. Survey the queue

Query the selected Project's Backlog Issues by numeric ID:

```graphql
query GroomQueue($projectId: Int!, $offset: Int!) {
  issues(
    filter: { state: "Backlog", projectId: $projectId }
    offset: $offset
    limit: 100
  ) {
    number
    title
    leased
    labels { name }
    blockedBy { number state stateType }
  }
}
```

Run it with
`octa query --variables '{"projectId": <id>, "offset": 0}'` and inspect the
response `errors`. Append that page's `data.issues` to one Backlog list. When
the page contains exactly 100 Issues, add 100 to `offset` and run the same
document again; when it contains fewer than 100, stop. Thus 100 and 200 total
records require final empty reads at offsets 100 and 200, while 101 and 201
stop after the one-record pages at offsets 100 and 200. Merge all pages before
ordering, selecting, or reporting any Issue.

Order by Issue number, oldest first, and let the Milestone placement and
blocker graph override that where they say more. Show number, title, and Type
label when present; show untyped Issues explicitly rather than inferring a
Type. If empty, say so and stop.

An Issue is not groomable when its description depends on an unresolved
blocker or undecided external input. Use `blockedBy` for the initial check, then
`octa issue show <n> --json` to read the selected Issue's body, relations, and
comments. Skip blocked items and state what they await.

### 3. Groom one Issue at a time

Auto-pick the first groomable item in that order. The user may redirect or
stop.

Groom interactively, in this session, with the user. What, why, and acceptance
often exist only in the user's head, so a body drafted purely from repository
evidence is a guess wearing the shape of a work order.

For each pick:

1. Read the full Issue and relevant repository evidence.
2. Draft a self-complete body with What & why, Where, Inputs, Acceptance, and
   Constraints, then propose it and confirm. Assume the user does not remember
   the Issue: re-establish the current problem, its significance, and intended
   outcome before presenting the proposed groomed interpretation. Structure the
   explanation around the content so its relationships and relative importance
   are easy to grasp with low cognitive load; choose the presentation form in
   context rather than exposing the body as an undifferentiated field or
   requirement list. Ask the user for whatever the repository cannot supply,
   and never fill a missing what/why/acceptance with an inference.
3. Decide its true size. Keep one atomic deliverable, promote a small effort to
   parent plus sub-issues, or create a finite Project for a distinct outcome.
4. Inspect `leased`. If another session holds a lease, skip the Issue. Otherwise
   capture `LEASE=$(octa issue lock <number>)` before changing the existing
   Issue.
5. Add `--blocker` relations when completion order matters, passing
   `--lease "$LEASE"` to the protected `issue add` command.
6. Assign exactly one Type label (`impl`, `design`, or `research`). If the Issue
   currently has multiple Type labels, remove the conflicting labels first.
   Pass the same lease to label mutations.
7. Update the Issue body, relations, Project/Milestone, and labels with the
   same lease.
8. Move it to Todo with `octa issue set <number> --as Todo --lease "$LEASE"`
   only after the fresh-agent self-completeness check passes. Otherwise leave
   it Backlog and comment with the missing decision/input.
9. Release the lease normally whether the Issue reached Todo or remained
   Backlog. Never record the lease ID in durable artifacts or use force
   recovery as routine groom cleanup.
10. Re-read the Backlog before choosing the next item because grooming may have
   added, split, moved, or unblocked work.

### 4. Wrap up

Stop when no groomable Backlog remains or the user stops. Summarize Issues that
reached Todo, work that was split, and items left Backlog with their waiting
condition. Point to `octa-start` for ready Todo work.
