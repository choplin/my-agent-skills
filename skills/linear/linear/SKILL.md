---
name: linear
description: >-
  Read-only snapshot of the current repository's active Linear work: resolves
  the repo to its active Projects and reports issue counts by status, with
  representative issue details explaining what the work is about.
metadata:
  description-role: documentation
---

# Overview of the current repository's Linear work

Give a **read-only** snapshot of what's currently in flight for the **current repository**: which Projects are active, how many issues sit in each status, and what the current and upcoming work is about. This skill only *reads and reports* — it never creates, grooms, or transitions anything. It builds on the `linear-base` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → active Project(s) — take *all* of them

Resolve the repo to its active Project(s) per the `linear-base` skill's **Resolving the current repo's active Project(s)** (repo → Repo label R → active Projects tagged `Repo/R`; the label-ambiguity, missing-project-label, and no-active-Project edge cases live there).

Unlike `linear-start` / `linear-groom`, this skill is a survey: **when there are multiple active Projects, report on all of them** rather than asking the user to pick one.

### 2. Tally and inspect each Project's issues by status

For each active Project, retrieve its issues with **Repo label = R**, group them by `state` type, and count every issue in each group:

- **In Progress** (`started`) — what's actively being worked.
- **Todo** (`unstarted`) — groomed and ready to pick up.
- **Backlog** (`backlog`) — not yet groomed.

These three are the "what's in flight" axis and are always shown. Optionally append **Done** (`completed`) as a single total in parentheses to convey progress; **exclude `canceled`** from the counts.

Under each non-empty status, show enough issues to make the work legible without turning the snapshot into a full dump:

- **In Progress**: show up to 5 issues. Prefer active execution over items in review, then higher priority.
- **Todo**: show up to 5 issues, highest priority first.
- **Backlog**: show up to 3 representative issues, highest priority first.
- If a status exceeds its display limit, say how many additional issues are omitted.
- For each shown issue, include `identifier`, `title`, and Priority when set. Add one short purpose/outcome clause from the description only when the title alone does not explain the substance.
- Mention a blocking relation when it materially changes whether a Todo issue is actually pickable.
- Do not enumerate Done issues.

If a Project organizes work under **Milestones**, you may add a one-line "current milestone" note per Project when it's obvious which one is in progress — but keep the status counts as the primary output. Don't expand into per-milestone breakdowns unless asked.

### 3. Report the snapshot

Present one compact block per active Project, most-active first (a Project with In Progress work outranks one sitting entirely in Backlog). For example:

```
<Project name>  ·  <current milestone, if any>
  In Progress  2
    ENG-123  Replace the legacy cache path  · High
    ENG-127  Verify migration telemetry
  Todo         5
    ENG-130  Remove the compatibility layer  · High
    ENG-131  Document the new cache contract
    …3 more
  Backlog     12   (Done 47)
    ENG-142  Add per-key invalidation  · Medium
    ENG-145  Investigate cross-region replication
    ENG-149  Expose cache diagnostics
    …9 more
```

Close with a brief content-aware read of the situation: explain what is actively changing, what is ready next, and any visible bottleneck or concentration of risk. Ground this interpretation in the shown issues rather than merely restating the counts. Then point the way forward without doing it:

- Want to **pick up** a Todo/Backlog item, or **resume** an In Progress one → `linear-start`.
- Want to **groom** the Backlog into ready work → `linear-groom`.
- Working an In Progress issue and **pausing before it finishes** → `linear-handoff` records a handoff note so a later session can resume it.
- Want to **drill into** a specific Project or omitted issues → offer to list the full set (identifier, title, Status, Priority) as a follow-up.
