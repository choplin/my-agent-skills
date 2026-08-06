---
name: linear
description: >-
  Read-only snapshot of the current repository's active Linear work: resolves
  the repo to its Repo label and reports issue counts by status across active
  Projects and Project-unassigned work, with representative issue details.
metadata:
  description-role: documentation
---

# Overview of the current repository's Linear work

Give a **read-only** snapshot of what's currently in flight for the **current repository**: which Projects are active, which work is not assigned to a Project, how many issues sit in each status, and what the current and upcoming work is about. This skill only *reads and reports* — it never creates, grooms, or transitions anything. It builds on the `linear-base` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → Repo label, then active Project(s)

Resolve the current repo to its issue **Repo label R** using **Step A — repo → Repo label** in `linear-base`'s *Resolving the current repo's active Project(s)* procedure. This issue label is the search root for the snapshot.

Then use **Step B — Repo label → active Project(s)** to obtain Project context. Unlike `linear-groom`, this skill is a survey: **when there are multiple active Projects, report on all of them** rather than asking the user to pick one. A missing `Repo/R` project label or no active Project must not hide or prevent reporting Project-unassigned Issues; report those Issues and mention the Project-resolution gap.

### 2. Retrieve all open Repo Issues and group them by Project

Retrieve **all issues with Repo label = R** whose `state` type is `started`, `unstarted`, or `backlog`, regardless of whether they belong to a Project. Partition them into one block per active Project plus a **No Project** block for Issues whose `project` is unset. Never discard an Issue merely because its Project is unset. If an open Repo Issue belongs to a completed, canceled, or differently tagged Project, show it under that Project too and flag the inconsistent Project context instead of silently dropping it.

Within each block, group the Issues by status and count every Issue in each
group. The first `started` status is the working state and the later one is
review, per `linear-base`:

- **In Progress** (first `started`) — what's actively being worked.
- **In Review** (later `started`) — what's awaiting review or integration.
- **Todo** (`unstarted`) — groomed and ready to pick up.
- **Backlog** (`backlog`) — not yet groomed.

These four are the "what's in flight" axis and are always shown. Optionally append **Done** (`completed`) as a single total in parentheses to convey progress for Project blocks; **exclude `canceled`** from the counts. Do not query or show completed Issues merely to decorate the No Project block.

Under each non-empty status, show enough issues to make the work legible without turning the snapshot into a full dump:

- **In Progress**: show up to 5 issues, higher priority first.
- **In Review**: show up to 5 issues, higher priority first.
- **Todo**: show up to 5 issues, highest priority first.
- **Backlog**: show up to 3 representative issues, highest priority first.
- If a status exceeds its display limit, say how many additional issues are omitted.
- For each shown issue, include `identifier`, `title`, and Priority when set. Add one short purpose/outcome clause from the description only when the title alone does not explain the substance.
- Mention a blocking relation when it materially changes whether a Todo issue is actually pickable.
- Do not enumerate Done issues.

Apply the same display limits and ordering to the No Project block. If a Project organizes work under **Milestones**, you may add a one-line "current milestone" note per Project when it's obvious which one is in progress — but keep the status counts as the primary output. Don't expand into per-milestone breakdowns unless asked.

### 3. Report the snapshot

Present one compact block per active Project and, when non-empty, one **No Project** block. Order all blocks most-active first (a block with In Progress work outranks one sitting entirely in Backlog). For example:

```
<Project name>  ·  <current milestone, if any>
  In Progress  2
    ENG-123  Replace the legacy cache path  · High
    ENG-127  Verify migration telemetry
  In Review    1
    ENG-129  Add cache migration metrics
  Todo         5
    ENG-130  Remove the compatibility layer  · High
    ENG-131  Document the new cache contract
    …3 more
  Backlog     12   (Done 47)
    ENG-142  Add per-key invalidation  · Medium
    ENG-145  Investigate cross-region replication
    ENG-149  Expose cache diagnostics
    …9 more

No Project
  In Progress  0
  In Review    0
  Todo         2
    ENG-160  Refresh the contributor guide
  Backlog      1
    ENG-166  Investigate flaky release uploads  · Medium
```

If there are no active Projects but the No Project block is non-empty, report that block normally instead of stopping. If neither active Projects nor Project-unassigned open Issues exist, say that no current work was found for the Repo label.

Close with a brief content-aware read of the situation: explain what is actively changing, what is ready next, and any visible bottleneck or concentration of risk. Call out substantial unassigned work because it has no finite outcome context. Ground this interpretation in the shown issues rather than merely restating the counts. Then point the way forward without doing it:

- Want to **pick up** a Todo/Backlog item, or **resume** an In Progress one → `linear-start`.
- Want to **groom a Project's** Backlog into ready work → `linear-groom`; for a No Project Backlog Issue, pick it through `linear-start`, which applies the single-Issue grooming gate before execution.
- Working an In Progress issue and **pausing before it finishes** → `linear-handoff` records a handoff note so a later session can resume it.
- Want to **drill into** a specific Project or omitted issues → offer to list the full set (identifier, title, Status, Priority) as a follow-up.
