---
name: octa-groom
description: Works through one active octa Project's Backlog oldest first, interactively turning rough items into self-complete Todo Issues, splitting oversized work and recording dependencies when needed. Use when preparing octa work for context-free execution.
---

# Groom an octa Backlog

Apply `octa-base`, especially its Todo authoring standard, grouping rules, Type
labels, state mapping, and lease contract.

## Flow

### 1. Select one active Project

Run `octa project list --active --json` in the current repository.

- none: report that no active Project exists and stop;
- one: select it silently;
- several: show their names, state, and open/closed tally, then ask the user
  which Project to groom.

### 2. Survey the queue

Query the selected Project's Backlog Issues by numeric ID:

```graphql
query GroomQueue($projectId: Int!) {
  issues(filter: { state: "Backlog", projectId: $projectId }, limit: 100) {
    number
    title
    leased
    labels { name }
    blockedBy { number state isTerminal }
  }
}
```

Run it with `octa query --variables '{"projectId": <id>}'`, inspect the response
`errors`, and paginate when more than 100 Issues exist. octa records no
priority, so order by Issue number, oldest first, and let the Milestone
placement and blocker graph override that where they say more. Show number,
title, and Type label when present; show untyped Issues explicitly rather than
inferring a Type. If empty, say so and stop.

An Issue is not groomable when its description depends on an unresolved
blocker or undecided external input. Use `blockedBy` for the initial check, then
`octa issue show <n> --json` to read the selected Issue's body, relations, and
comments. Skip blocked items and state what they await.

### 3. Groom one Issue at a time

Auto-pick the first groomable item in that order. The user may redirect or
stop.

For each pick:

1. Read the full Issue and relevant repository evidence.
2. Draft a self-complete body with What & why, Where, Inputs, Acceptance, and
   Constraints. Ask only for decisions that cannot be discovered or safely
   inferred; confirm choices that materially change scope.
3. Decide its true size. Keep one atomic deliverable, promote a small effort to
   parent plus sub-issues, or create a finite Project for a distinct outcome.
4. Inspect `leased`. If another session holds a lease, skip the Issue. Otherwise
   capture `LEASE=$(octa issue lock <number>)` before changing the existing
   Issue. The lease ID is a non-secret coordination handle that may appear in
   tool output and command arguments.
5. Add `--blocker` relations when completion order matters, passing
   `--lease "$LEASE"` to the protected `issue add` command.
6. Assign exactly one Type label (`impl`, `design`, or `research`). Remove a
   conflicting Type label first if the store's configuration predates
   single-selection. Pass the same lease to label mutations.
7. Update the Issue body, relations, Project/Milestone, and labels with the
   same lease.
8. Move it to Todo with the lease only after the fresh-agent
   self-completeness check passes. Otherwise leave it Backlog and
   comment with the missing decision/input; comments need no lease.
9. Release the lease normally whether the Issue reached Todo or remained
   Backlog. Never record the lease ID in durable artifacts or use force
   recovery as routine groom cleanup.
10. Re-read the Backlog before choosing the next item because grooming may have
   added, split, moved, or unblocked work.

### 4. Wrap up

Stop when no groomable Backlog remains or the user stops. Summarize Issues that
reached Todo, work that was split, and items left Backlog with their waiting
condition. Point to `octa-start` for ready Todo work.
