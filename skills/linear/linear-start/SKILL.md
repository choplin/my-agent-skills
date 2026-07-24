---
name: linear-start
description: Start or resume work on a Linear issue for the current repository. List all Repo-label issues in In Progress, Todo, or Backlog, including issues outside a Project; let the user choose; present the selected issue's full contents before taking action; prepare or recover its workspace; and hand off to an execution skill. An In Progress pick resumes its existing worktree, reconstructs completed work, and continues the execution mode already in flight. After the picked issue reaches Done, report its Project status when applicable and suggest related work to continue with. Use when the user wants to pick up new or half-finished Linear work for the repo. Triggers include "start a Linear issue", "pick an issue to work on", and "resume an in-progress issue". Do not use for creating or grooming issues (use linear-base), Jira (jira-cli), or GitHub Issues (github tools).
user-invocable: true
---

# Start or resume work on a Linear issue

Pick one issue for the **current repository** from Linear and work it — either **starting** a Todo/Backlog issue or **resuming** one already In Progress. This skill covers selection, workspace set-up, and hand-off; it builds on the `linear-base` skill for all status/label/project semantics (read that skill's Model mapping and Lifecycle if unfamiliar).

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → Repo label

Resolve the current repo to its issue **Repo label R** using **Step A — repo → Repo label** in `linear-base`'s *Resolving the current repo's active Project(s)* procedure. The label-ambiguity edge case still applies.

Do **not** resolve or require an active Project before listing candidates. Projects represent finite outcomes, while an Issue can validly be a standalone deliverable; making a Project the search root would hide standalone issues. A missing `Repo/R` **project** label or no active Project must therefore not stop this skill.

Retain each candidate's Project, if any, as context for display and the post-completion report. Never ask the user to choose a Project before they choose an Issue.

### 2. List the issues to choose from

List **all issues with Repo label = R**, regardless of whether they belong to a Project or which Project they belong to, in two sections. For each issue show: identifier, title, Status, Priority, Type label (`impl`/`design`/`research`), and Project (`<project name>` or `No Project`).

**Section 1 — In flight (resume candidates):** issues whose `state` is **In Progress**. Show these **first**, as their own section — they are candidates because work already exists on them, not because of their priority, so they are not ranked against the section below. Surfacing them at the top is deliberate: it makes half-finished work visible before new work is picked up.

**Section 2 — Open (start candidates):** issues whose `state` type is in {backlog, unstarted}, i.e. **Todo and Backlog together**. Order by **priority** (Urgent → High → Medium → Low → None), and within a priority keep Todo above Backlog.

**In Review is deliberately excluded** from both sections: a PR is already open on those, and what they need is review response, not resumption of implementation.

Present both sections and let the user pick one.

The pick decides the mode for the rest of the flow: an issue from section 2 is a **start**, one from section 1 is a **resume**.

### 3. Read and present the selected issue

Fetch the selected issue's detailed record. The **first user-facing response after this read** must present the issue itself, before changing its state, setting up or recovering a workspace, analyzing the repository, or handing off to another skill.

Show:

- identifier and title
- Status, Priority, Type, Project, and Milestone (when present)
- the complete description, preserving its headings, lists, checkboxes, acceptance criteria, and constraints; if it has no description, say so explicitly
- parent/sub-issue and blocking/blocked relations when present

Do not replace the description with a summary and do not merely say that the issue was read. Only after presenting it may the flow continue.

Backlog picks are allowed — but after presenting a chosen Backlog issue, check whether it is self-complete (see `linear-base`'s authoring standard). If it is not, flag that it may need grooming first and offer to groom it via `linear-base` before starting.

### 4. Move the issue to In Progress — start only

**Start:** set the selected issue's `state` to **In Progress**. (Todo → In Progress, or Backlog → In Progress if the user started a Backlog item directly.)

**Resume:** the issue is already In Progress. No status change — skip this step.

### 5. Set up (start) or recover (resume) the workspace

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

**Do not create a new worktree — find the existing one.** Because the issue ID never appears in a branch or worktree name, the **worktree note** written at step 5 on start is the only local link back to Linear. Search the notes for the issue identifier:

```bash
wtm list --format json | jq -r '.[].name' | while read -r wt; do
  wtm notes show "$wt" 2>/dev/null | grep -q "ENG-123" && echo "$wt"
done
```

(`wtm list --format json` does not carry notes, hence the per-worktree `notes show`.)

- **Exactly one match** → that is the workspace. Tell the user which worktree/branch, and continue there.
- **Several matches** → list them with their notes and **ask** which to continue in.
- **No match** → the work was done on the current branch, or the worktree was removed. **Ask** the user: continue on the current branch, or create a fresh worktree (as in the start path, `-m` note included) and carry the work forward there. Also check the Linear side — an attached branch/PR link on the issue may name the branch, so offer that branch if one is attached.

### 6. Reconstruct what's already been done — resume only

Before touching anything, establish where the work actually stands, and report it to the user. Read, in the resolved workspace:

- **The issue's comments** — the progress recorded on it. The **most recent handoff note** (see `linear-base`'s *Handoff note*), if one exists, is the canonical pickup record: it states the goal, the decisions made while working, the open questions, and the next step to take. Read it first, then any earlier comments for fuller history. This is the primary account of what was decided and how far it got.
- **The git state** — commits on the branch versus its base, plus uncommitted and staged changes (`git status`, `git log`, `git diff`).
- **In-flight execution artifacts** — the trace left by whichever execution mode was running:
  - `dev-workflow` → its `state.json` (`linear_issue_id` links back to the issue)
  - `exec-plan` → a plan file under `.agents/exec-plans/`
  - host-native `/goal` → active goal state, when the host exposes it to the
    current session (there is no repository artifact to search)
  - none of the above → the work was done in-session with no execution skill

Summarize for the user what is done, what is in progress, and what remains, **before** continuing. A resume that skips this step re-derives the work from scratch and risks contradicting decisions the issue already records.

### 7. Hand off to an execution skill

**Starting:** the issue is now In Progress with a workspace ready. **Delegate the execution-mode choice to `dispatch-work`** (Skill tool): it recommends among its routes — including implementing a small, obvious change directly in-session with no skill — based on how "done" is decided, presents the recommendation, and lets the user make the final call before handing off. The issue context (identifier, title, Type, size) is available via session history to inform its recommendation.

**Resuming:** the execution mode has usually already been chosen — **continue it rather than re-picking one.** `dispatch-work` is a front door for *starting* work and would re-litigate a settled decision, so route by the artifact found at step 6:

| Artifact found at step 6 | Hand off to |
|---|---|
| `dev-workflow` `state.json` | `dev-workflow-resume-work` |
| Plan file under `.agents/exec-plans/` | `exec-plan` (drive the existing plan; do not write a new one) |
| Active host-native `/goal` | Continue the existing goal through the host |
| None | `dispatch-work` — but frame the remaining work (from step 6) as the task, not the whole issue |

Whichever way it goes, remember the later lifecycle transitions owned by `linear-base`: **In Progress → In Review** when a PR opens, **In Review → Done** when it merges. When the issue reaches **Done**, continue with step 8.

### 8. After Done — show context and suggest the next related work

Once the issue this flow put In Progress reaches **Done** (the completion note is left by `linear-base` at that transition), don't stop at "merged". Surface its Project context when it has one, then show what to pick up next so the user can chain into the next piece without re-running the whole selection from scratch. This may land in a later session or turn than the one that started the issue; run it whenever the completion this flow set in motion reaches Done.

**8a. Report Project status when applicable.** If the completed issue belongs to a Project, tally that Project's issues with **Repo label = R** by `state` type and present the compact per-Project block exactly as the `linear` overview skill does (its step 2–3 — `In Progress` / `Todo` / `Backlog`, optional `(Done N)`, `canceled` excluded). Close with a one-line read of the shape (e.g. "one In Progress left, three Todo ready"). If it has **No Project**, state that it was a standalone issue and skip the Project tally; do not invent or require a Project.

**8b. Suggest the next related task(s).** Propose the issue(s) to pick up next, **related to the one just completed** — one or several. Search issues with **Repo label = R** and rank by relatedness first, then fall back to the repo's ready work:

1. **Related to the completed issue, first** — issues that share its **Milestone**, are linked to it by a **Linear relation** (parent, sub-issue, or blocking/blocked — a blocked issue the completed one just unblocked is a strong candidate), or share a **Type/topic label**. Prefer these, ordered by readiness (Todo above Backlog) then priority.
2. **Fallback — the repo's ready work** — if nothing is related, or to round out the list, offer the top open issues by priority exactly as step 2's Section 2 orders them (Todo above Backlog, Urgent → None), including standalone issues.

Show each suggestion as identifier, title, Status, Priority, Type, and Project — plus a short note on *why* it's related (e.g. "same milestone", "was blocked by the one you finished"). Present them and let the user pick, decline, or stop. **If the user picks one, loop back to step 3** so the newly selected issue is read and presented before any action — a Done issue naturally leads into the next start. If no issue is related and none is ready, say so plainly rather than padding the list.
