---
name: linear-start
description: Start work on a Linear issue belonging to the current repository — resolve the repo to its active Linear Project, list that project's open issues (Todo + Backlog), let the user pick one, move it to In Progress, create an isolated worktree, and hand off to an execution skill. Use when the user wants to pick up the next piece of work from Linear for the repo they are in. Triggers on "start a Linear issue", "pick an issue to work on", "着手する issue を選ぶ", "Linear から次の作業を", "このリポジトリの issue に着手". Should NOT trigger for creating/grooming issues (use linear-base), Jira (jira-cli), or GitHub Issues (github tools).
user-invocable: true
---

# Start work on a Linear issue

Pick one open issue for the **current repository** from Linear and begin working it. This skill covers selection and hand-off; it builds on the `linear-base` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → active Project

Resolve the repo to its active Project(s) per the `linear-base` skill's **Resolving the current repo's active Project(s)** (repo → Repo label R → active Projects tagged `Repo/R`; the label-ambiguity, missing-project-label, and no-active-Project edge cases all live there).

This skill acts on a **single** Project:

- **Exactly one active Project → select it and just tell the user** which one; do not ask. (This is the normal case — one repo usually has a single active Project.)
- **Multiple active Projects → list them and ask** the user to pick one.

### 2. List the issues to choose from

Within the chosen Project, list its issues with **Repo label = R** and `state` type in {backlog, unstarted}, i.e. **Todo and Backlog together**. Order by **priority** (Urgent → High → Medium → Low → None), and within a priority keep Todo above Backlog. For each issue show: identifier, title, Status, Priority, and Type label (`impl`/`design`/`research`).

Present the list and let the user pick one. Backlog picks are allowed — but if the chosen issue is Backlog and not yet self-complete (see `linear-base`'s authoring standard), flag that it may need grooming first and offer to groom it via `linear-base` before starting.

### 3. Move the issue to In Progress

Set the selected issue's `state` to **In Progress**. (Todo → In Progress, or Backlog → In Progress if the user started a Backlog item directly.)

### 4. Choose where to work — worktree or current branch

**Ask the user** how to set up the workspace; don't assume:

- **Isolated worktree** (typical) — keeps the work off the main branch.
- **Current branch, no worktree** (e.g. proceed on `main`) — some changes are better done in place. Skip worktree creation entirely and work where you are.

**If worktree** — delegate to the `wtm-worktree` skill (`wtm` CLI):

- **Do not put the Linear issue ID in the branch or worktree name.** Linear references stay internal (see `linear-base`'s "Linear references stay internal") — branch names surface in commits, PRs, and the remote. Name the branch/worktree after the change itself.
- **Record the issue reference in the worktree note instead.** Pass `-m` on creation with the issue identifier, title, and URL, e.g.:

  ```bash
  wtm add <descriptive-name> -m "ENG-123 <issue title> — <issue url>"
  ```

  The note is later readable with `wtm notes show`, so the branch stays clean while the link to Linear is preserved.

**If current branch** — skip `wtm` entirely. There is no worktree note to hold the link, so keep the issue identifier/URL in session context only — per `linear-base`'s "Linear references stay internal", it must **not** end up in the commit message or PR. Preserve the link from the Linear side instead: attach the eventual PR to the issue (Git integration or a `links` attachment).

### 5. Hand off to an execution skill

The issue is now In Progress with a worktree ready. **Delegate the execution-mode choice to `dispatch-work`** (Skill tool): it recommends among its routes — including implementing a small, obvious change directly in-session with no skill — based on how "done" is decided, presents the recommendation, and lets the user make the final call before handing off. The issue context (identifier, title, Type, size) is available via session history to inform its recommendation.

Whichever way it goes, remember the later lifecycle transitions owned by `linear-base`: **In Progress → In Review** when a PR opens, **In Review → Done** when it merges.
