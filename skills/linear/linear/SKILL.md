---
name: linear
description: Read-only bird's-eye view of the current repository's active Linear work — resolve the repo to its active Project(s), then for each Project report issue counts broken down by status (In Progress / Todo / Backlog). Use when the user wants a snapshot of what's in flight for the repo they're in, before deciding what to pick up. Triggers on "Linear overview", "what's in flight", "show active projects and tasks", "Linear の概観", "今動いているプロジェクト", "稼働状況を見せて". Should NOT trigger for starting/executing an issue (use linear-start), grooming the backlog (use linear-groom), creating/updating issues (use linear-base), Jira (jira-cli), or GitHub Issues (github tools).
user-invocable: true
---

# Overview of the current repository's Linear work

Give a **read-only** snapshot of what's currently in flight for the **current repository**: which Projects are active, and for each one how many issues sit in each status. This skill only *reads and reports* — it never creates, grooms, or transitions anything. It builds on the `linear-base` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → active Project(s) — take *all* of them

Resolve the repo to its active Project(s) per the `linear-base` skill's **Resolving the current repo's active Project(s)** (repo → Repo label R → active Projects tagged `Repo/R`; the label-ambiguity, missing-project-label, and no-active-Project edge cases live there).

Unlike `linear-start` / `linear-groom`, this skill is a survey: **when there are multiple active Projects, report on all of them** rather than asking the user to pick one.

### 2. Tally each Project's issues by status

For each active Project, count its issues with **Repo label = R**, grouped by `state` type:

- **In Progress** (`started`) — what's actively being worked.
- **Todo** (`unstarted`) — groomed and ready to pick up.
- **Backlog** (`backlog`) — not yet groomed.

These three are the "what's in flight" axis and are always shown. Optionally append **Done** (`completed`) as a single total in parentheses to convey progress; **exclude `canceled`** from the counts. Do not enumerate individual issues here — the point is the shape, not the list.

If a Project organizes work under **Milestones**, you may add a one-line "current milestone" note per Project when it's obvious which one is in progress — but keep the status counts as the primary output. Don't expand into per-milestone breakdowns unless asked.

### 3. Report the snapshot

Present one compact block per active Project, most-active first (a Project with In Progress work outranks one sitting entirely in Backlog). For example:

```
<Project name>  ·  <current milestone, if any>
  In Progress  3
  Todo         5
  Backlog     12   (Done 47)
```

Close with a one-line read of the situation (e.g. "Project A is mid-flight; Project B is all Backlog and unstarted"). Then point the way forward without doing it:

- Want to **pick up** a Todo/Backlog item → `linear-start`.
- Want to **groom** the Backlog into ready work → `linear-groom`.
- Want to **drill into** a specific Project's issues → offer to list them (identifier, title, Status, Priority) as a follow-up; individual-issue detail is out of scope for the snapshot itself but a natural next question.
