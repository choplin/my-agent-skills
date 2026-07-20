---
name: linear-start
description: Start or resume work on a Linear issue belonging to the current repository — resolve the repo to its active Linear Project, list that project's in-flight and open issues (In Progress + Todo + Backlog), let the user pick one, set up or recover its workspace, and hand off to an execution skill. Picking an In Progress issue resumes it: the existing worktree is located, the work already done is reconstructed, and the execution mode already in flight is continued. Use when the user wants to pick up the next piece of work — new or half-finished — from Linear for the repo they are in. Triggers on "start a Linear issue", "pick an issue to work on", "resume an in-progress issue", "着手する issue を選ぶ", "Linear から次の作業を", "途中の issue を再開", "続きから作業する". Should NOT trigger for creating/grooming issues (use linear-base), Jira (jira-cli), or GitHub Issues (github tools).
user-invocable: true
---

# Start or resume work on a Linear issue

Pick one issue for the **current repository** from Linear and work it — either **starting** a Todo/Backlog issue or **resuming** one already In Progress. This skill covers selection, workspace set-up, and hand-off; it builds on the `linear-base` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → active Project

Resolve the repo to its active Project(s) per the `linear-base` skill's **Resolving the current repo's active Project(s)** (repo → Repo label R → active Projects tagged `Repo/R`; the label-ambiguity, missing-project-label, and no-active-Project edge cases all live there).

This skill acts on a **single** Project:

- **Exactly one active Project → select it and just tell the user** which one; do not ask. (This is the normal case — one repo usually has a single active Project.)
- **Multiple active Projects → list them and ask** the user to pick one.

### 2. List the issues to choose from

Within the chosen Project, list its issues with **Repo label = R** in two sections. For each issue show: identifier, title, Status, Priority, and Type label (`impl`/`design`/`research`).

**Section 1 — In flight (resume candidates):** issues whose `state` is **In Progress**. Show these **first**, as their own section — they are candidates because work already exists on them, not because of their priority, so they are not ranked against the section below. Surfacing them at the top is deliberate: it makes half-finished work visible before new work is picked up.

**Section 2 — Open (start candidates):** issues whose `state` type is in {backlog, unstarted}, i.e. **Todo and Backlog together**. Order by **priority** (Urgent → High → Medium → Low → None), and within a priority keep Todo above Backlog.

**In Review is deliberately excluded** from both sections: a PR is already open on those, and what they need is review response, not resumption of implementation.

Present both sections and let the user pick one. Backlog picks are allowed — but if the chosen issue is Backlog and not yet self-complete (see `linear-base`'s authoring standard), flag that it may need grooming first and offer to groom it via `linear-base` before starting.

The pick decides the mode for the rest of the flow: an issue from section 2 is a **start**, one from section 1 is a **resume**.

### 3. Move the issue to In Progress — start only

**Start:** set the selected issue's `state` to **In Progress**. (Todo → In Progress, or Backlog → In Progress if the user started a Backlog item directly.)

**Resume:** the issue is already In Progress. No status change — skip this step.

### 4. Set up (start) or recover (resume) the workspace

#### If starting

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

#### If resuming

**Do not create a new worktree — find the existing one.** Because the issue ID never appears in a branch or worktree name, the **worktree note** written at step 4 on start is the only local link back to Linear. Search the notes for the issue identifier:

```bash
wtm list --format json | jq -r '.[].name' | while read -r wt; do
  wtm notes show "$wt" 2>/dev/null | grep -q "ENG-123" && echo "$wt"
done
```

(`wtm list --format json` does not carry notes, hence the per-worktree `notes show`.)

- **Exactly one match** → that is the workspace. Tell the user which worktree/branch, and continue there.
- **Several matches** → list them with their notes and **ask** which to continue in.
- **No match** → the work was done on the current branch, or the worktree was removed. **Ask** the user: continue on the current branch, or create a fresh worktree (as in the start path, `-m` note included) and carry the work forward there. Also check the Linear side — an attached branch/PR link on the issue may name the branch, so offer that branch if one is attached.

### 5. Reconstruct what's already been done — resume only

Before touching anything, establish where the work actually stands, and report it to the user. Read, in the resolved workspace:

- **The issue's comments** — the progress recorded on it. The **most recent handoff note** (see `linear-base`'s *Handoff note*), if one exists, is the canonical pickup record: it states the goal, the decisions made while working, the open questions, and the next step to take. Read it first, then any earlier comments for fuller history. This is the primary account of what was decided and how far it got.
- **The git state** — commits on the branch versus its base, plus uncommitted and staged changes (`git status`, `git log`, `git diff`).
- **In-flight execution artifacts** — the trace left by whichever execution mode was running:
  - `dev-workflow` → its `state.json` (`linear_issue_id` links back to the issue)
  - `exec-plan` → a plan file under `.agents/exec-plans/`
  - `goal-loop` → its loop/goal artifacts
  - none of the above → the work was done in-session with no execution skill

Summarize for the user what is done, what is in progress, and what remains, **before** continuing. A resume that skips this step re-derives the work from scratch and risks contradicting decisions the issue already records.

### 6. Hand off to an execution skill

**Starting:** the issue is now In Progress with a workspace ready. **Delegate the execution-mode choice to `dispatch-work`** (Skill tool): it recommends among its routes — including implementing a small, obvious change directly in-session with no skill — based on how "done" is decided, presents the recommendation, and lets the user make the final call before handing off. The issue context (identifier, title, Type, size) is available via session history to inform its recommendation.

**Resuming:** the execution mode has usually already been chosen — **continue it rather than re-picking one.** `dispatch-work` is a front door for *starting* work and would re-litigate a settled decision, so route by the artifact found at step 5:

| Artifact found at step 5 | Hand off to |
|---|---|
| `dev-workflow` `state.json` | `dev-workflow-resume-work` |
| Plan file under `.agents/exec-plans/` | `exec-plan` (drive the existing plan; do not write a new one) |
| `goal-loop` artifacts | `goal-loop` (continue against the existing predicates) |
| None | `dispatch-work` — but frame the remaining work (from step 5) as the task, not the whole issue |

Whichever way it goes, remember the later lifecycle transitions owned by `linear-base`: **In Progress → In Review** when a PR opens, **In Review → Done** when it merges.
