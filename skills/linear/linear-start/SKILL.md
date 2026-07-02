---
name: linear-start
description: Start work on a Linear issue belonging to the current repository — resolve the repo to its active Linear Project, list that project's open issues (Todo + Backlog), let the user pick one, move it to In Progress, create an isolated worktree, and hand off to an execution skill. Use when the user wants to pick up the next piece of work from Linear for the repo they are in. Triggers on "start a Linear issue", "pick an issue to work on", "着手する issue を選ぶ", "Linear から次の作業を", "このリポジトリの issue に着手". Should NOT trigger for creating/grooming issues (use linear), Jira (jira-cli), or GitHub Issues (github tools).
user-invocable: true
---

# Start work on a Linear issue

Pick one open issue for the **current repository** from Linear and begin working it. This skill covers selection and hand-off; it builds on the `linear` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → Repo label

Derive the repo name from the current git repository (`git remote get-url origin` basename with any `.git` stripped, else the repo-root directory name). Match it to a member of the **Repo** label group (case-insensitive).

- Exactly one match → use it silently.
- No match, or ambiguous → **ask** the user which Repo label applies (don't guess). Offer to add the label via `linear` if the repo has none yet.

### 2. Resolve the active Project (auto-select the common case)

List **active Projects tagged with the Repo project-label = R** — a Project is *active* when its state is not `completed` and not `canceled`. Every Project carries a single Repo tag (required by `linear`), so the repo resolves to its Project directly.

- **The `Repo/R` project-label doesn't exist yet** → the agent **cannot create project labels** (see `linear`). Ask the user to create the `Repo/R` project-label in the Linear UI and tag the relevant Project with it, then continue. (This is a once-per-repo setup step.)
- **Exactly one active Project → select it and just tell the user** which one; do not ask. (This is the normal case — one repo usually has a single active Project.)
- **Multiple active Projects → list them and ask** the user to pick one.
- **No active Project for R** (label exists but no active Project carries it) → say so and stop. Offer to create a Project or groom the backlog via `linear`.

### 3. List the issues to choose from

Within the chosen Project, list its issues with **Repo label = R** and `state` type in {backlog, unstarted}, i.e. **Todo and Backlog together**. Order by **priority** (Urgent → High → Medium → Low → None), and within a priority keep Todo above Backlog. For each issue show: identifier, title, Status, Priority, and Type label (`impl`/`design`/`research`).

Present the list and let the user pick one. Backlog picks are allowed — but if the chosen issue is Backlog and not yet self-complete (see `linear`'s authoring standard), flag that it may need grooming first and offer to groom it via `linear` before starting.

### 4. Move the issue to In Progress

Set the selected issue's `state` to **In Progress**. (Todo → In Progress, or Backlog → In Progress if the user started a Backlog item directly.)

### 5. Choose where to work — worktree or current branch

**Ask the user** how to set up the workspace; don't assume:

- **Isolated worktree** (typical) — keeps the work off the main branch.
- **Current branch, no worktree** (e.g. proceed on `main`) — some changes are better done in place. Skip worktree creation entirely and work where you are.

**If worktree** — delegate to the `wtm-worktree` skill (`wtm` CLI):

- **Do not put the Linear issue ID in the branch or worktree name.** This is a solo workspace; an issue ID in the branch name is sometimes undesirable. Name the branch/worktree after the change itself.
- **Record the issue reference in the worktree note instead.** Pass `-m` on creation with the issue identifier, title, and URL, e.g.:

  ```bash
  wtm add <descriptive-name> -m "ENG-123 <issue title> — <issue url>"
  ```

  The note is later readable with `wtm notes show`, so the branch stays clean while the link to Linear is preserved.

**If current branch** — skip `wtm` entirely. There is no worktree note to hold the link, so keep the issue identifier/URL at hand and reference it in the eventual commit/PR.

### 6. Hand off to an execution skill

The issue is now In Progress with a worktree ready. **Delegate the execution-mode choice to `dispatch-work`** (Skill tool): it recommends among `inception` / `goal-loop` / `exec-plan` / `dev-workflow-kickoff` based on how "done" is decided, presents the recommendation, and lets the user make the final call before handing off. The issue context (identifier, title, Type, size) is available via session history to inform its recommendation.

One escape `dispatch-work` does not cover: for a **small, obvious change**, implementing inline with no skill is also fine — offer that too when the issue is trivial.

Whichever way it goes, remember the later lifecycle transitions owned by `linear`: **In Progress → In Review** when a PR opens, **In Review → Done** when it merges.
