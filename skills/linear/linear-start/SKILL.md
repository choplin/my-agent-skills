---
name: linear-start
description: >-
  Starts or resumes work on a Linear issue for the current repository: lists
  the repo's In Progress, Todo, and Backlog issues, presents the chosen one,
  prepares or recovers its workspace, and hands off to an execution skill. A
  resumed issue reconstructs what was already done and continues the execution
  mode in flight. Once the issue reaches Done, reports its Project status and
  suggests related work.
metadata:
  description-role: documentation
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

List **all issues with Repo label = R**, regardless of whether they belong to a Project or which Project they belong to, in two sections. For each issue show: identifier, title, Status, Priority, Type label (`impl`/`design`/`research`/`orchestration`), and Project (`<project name>` or `No Project`).

**Section 1 — In flight (resume candidates):** issues whose `state` is **In Progress**. Show these **first**, as their own section — they are candidates because work already exists on them, not because of their priority, so they are not ranked against the section below. Surfacing them at the top is deliberate: it makes half-finished work visible before new work is picked up.

**Section 2 — Open (start candidates):** issues whose `state` type is in {backlog, unstarted}, i.e. **Todo and Backlog together**. Order by **priority** (Urgent → High → Medium → Low → None), and within a priority keep Todo above Backlog.

**In Review is deliberately excluded** from both sections: the deliverable is
already submitted for review (for example, a PR is open), so it needs review
response rather than selection as new or resumed work.

Present both sections and let the user pick one.

The pick decides the mode for the rest of the flow: an issue from section 2 is a **start**, one from section 1 is a **resume**.

### 3. Read and present the selected issue

Fetch the selected issue's detailed record (needed for later steps). The **first user-facing response after this read** must confirm the pick to the user, before changing its state, setting up or recovering a workspace, analyzing the repository, or handing off to another skill.

Show only:

- identifier and title
- a short summary of what the issue asks for (a few sentences); if it has no description, say so explicitly

Do not dump the full description, metadata fields, or relations into this confirmation. Keep the full record for workspace choice, grooming checks, and hand-off. Only after presenting the title and summary may the flow continue.

Backlog picks are allowed — but after presenting a chosen Backlog issue, check whether it is self-complete (see `linear-base`'s authoring standard). If it is not, flag that it may need grooming first and offer to groom it via `linear-base` before starting.

**Reserved orchestration path:** if the selected Issue has
`Type/orchestration`, hand it directly to
`orchestration-toolkit-orchestrate` after presenting it. Do not create an Issue
worktree or treat it as an atomic deliverable. The orchestration skill
reconstructs its Project graph, integration workspace, checkpoint, and pending
human gate.

### 4. Move the issue to In Progress — start only

**Start:** set the selected issue's `state` to the workspace's working status — the first one whose type is `started` (see `linear-base`'s *Lifecycle & status transitions* for why the type, not the name, decides). In this workspace that is **In Progress**, reached from either Todo or Backlog.

**Resume:** the issue is already In Progress. No status change — skip this step.

### 5. Set up (start) or recover (resume) the workspace

#### If starting

Choose the workspace **autonomously** from the selected issue's expected deliverable. Do not ask the user to choose between these defaults:

- **Isolated worktree** — use when completing the issue entails implementation or other repository changes intended for a commit or PR. This is normally an `impl` issue.
- **Current workspace, no new worktree** — use when the work is analysis, design, research, discussion, or another task whose deliverable does not require repository changes. This is normally a `design` or `research` issue.

Treat the Type label as a strong hint, not a substitute for reading the issue: decide from the actual deliverable and acceptance criteria. If the classification is imperfect but the likely deliverable is clear, use best judgment rather than asking. An explicit user instruction to use or avoid a worktree overrides these defaults. Briefly state the chosen setup and proceed.

**The isolated worktree needs `wtm`, which is an external dependency.** The
`wtm-worktree` skill is not part of this group and may not be installed. When it
is unavailable, **do not improvise a worktree** — fall back to the current
workspace and say so. A bare `git worktree add` would leave nowhere to record
the issue reference (see below), and the current-workspace path already handles
that case correctly.

**If worktree** — delegate to the `wtm-worktree` skill (`wtm` CLI):

- **Do not put the Linear issue ID in the branch or worktree name.** Linear references stay internal (see `linear-base`'s "Linear references stay internal") — branch names surface in commits, PRs, and the remote. Name the branch/worktree after the change itself.
- **Record the issue reference in the worktree note instead.** Pass `-m` on creation with the issue identifier, title, and URL, e.g.:

  ```bash
  wtm add <descriptive-name> -m "ENG-123 <issue title> — <issue url>"
  ```

  The note is later readable with `wtm notes show`, so the branch stays clean while the link to Linear is preserved.

**If current workspace** — whether chosen for the deliverable or fallen back to
because `wtm` is absent — skip `wtm` entirely. There is no worktree note to hold the link, so keep the issue identifier/URL in session context only — per `linear-base`'s "Linear references stay internal", it must **not** end up in the commit message or PR. If a PR is later opened, preserve the link from the Linear side by attaching it to the issue (Git integration or a `links` attachment).

#### If resuming

**Do not create a new worktree before checking for the existing workspace.** Because the issue ID never appears in a branch or worktree name, a **worktree note** written at step 5 on start is the strongest local link back to Linear. Search the notes for the issue identifier — skip this search entirely when `wtm` is not installed, since no note can exist, and go straight to the no-match path below:

```bash
wtm list --format json | jq -r '.[].name' | while read -r wt; do
  wtm notes show "$wt" 2>/dev/null | grep -q "ENG-123" && echo "$wt"
done
```

(`wtm list --format json` does not carry notes, hence the per-worktree `notes show`.)

- **Exactly one match** → that is the workspace. Tell the user which worktree/branch, and continue there.
- **Several matches** → list them with their notes and **ask** which to continue in.
- **No match** → the work was done in the current workspace, or the worktree was removed. Check the Linear side first: if an attached branch/PR identifies the existing workspace, recover and use it. Otherwise inspect the current branch, status, commits, and diffs for evidence of the selected issue; continue there when the work is plausibly present. If no existing work is recoverable, apply the same autonomous deliverable rule as the start path — including its `wtm` dependency: create a fresh worktree (with the `-m` note) for implementation or other repository-changing work when `wtm` is available, and otherwise continue in the current workspace. State the choice and proceed without asking merely because the note was missing.

### 6. Reconstruct what's already been done — resume only

Before touching anything, establish where the work actually stands, and report it to the user. Read, in the resolved workspace:

- **The issue's comments** — the progress recorded on it. The **most recent handoff note** (see `linear-base`'s *Handoff note*), if one exists, is the canonical pickup record: it states the goal, the decisions made while working, the open questions, and the next step to take. Read it first, then any earlier comments for fuller history. This is the primary account of what was decided and how far it got.
- **The git state** — commits on the branch versus its base, plus uncommitted and staged changes (`git status`, `git log`, `git diff`).
- **In-flight execution artifacts** — the trace left by whichever execution mode was running:
  - `orchestration-toolkit-execute` → its run record, kept as checkpoint comments
    on this issue (read with the comments above; there is no local file)
  - `orchestration-toolkit-orchestrate` → the Project's `Type/orchestration`
    control issue and its latest checkpoint
  - `exec-plan` → a plan file under `.agents/exec-plans/`
  - host-native `/goal` → active goal state, when the host exposes it to the
    current session (there is no repository artifact to search)
  - none of the above → the work was done in-session with no execution skill

Summarize for the user what is done, what is in progress, and what remains, **before** continuing. A resume that skips this step re-derives the work from scratch and risks contradicting decisions the issue already records.

### 7. Hand off to an execution skill

**Starting:** the issue is now In Progress with a workspace ready. The issue is
the work unit, so the destination follows from what it asks for — do not run a
mode questionnaire:

| The selected issue | Hand off to |
|---|---|
| Entails repository changes toward a commit (normally `impl`) | `orchestration-toolkit-execute` |
| Produces a non-repository deliverable — analysis, design, research (normally `design` / `research`) | Ordinary in-session work; record the deliverable on the issue |
| Is a trivial, self-evident change | Implement it directly and note it on the issue |

State the choice in one line and proceed. If dependencies on sibling issues
surface while working, that is the signal to stop and hand the Project to
`orchestration-toolkit-orchestrate` instead of widening this run.

**Resuming:** the execution mode has usually already been chosen — **continue it
rather than re-picking one.** Route by the artifact found at step 6:

| Artifact found at step 6 | Hand off to |
|---|---|
| Checkpoint comments from `orchestration-toolkit-execute` | `orchestration-toolkit-execute` (continue the existing run record; do not open a new one) |
| A `Type/orchestration` control issue for the Project | `orchestration-toolkit-orchestrate` |
| Plan file under `.agents/exec-plans/` | `exec-plan` (drive the existing plan; do not write a new one) |
| Active host-native `/goal` | Continue the existing goal through the host |
| None | Apply the Starting table above, but frame the remaining work (from step 6) as the task, not the whole issue |

Whichever way it goes, remember the later lifecycle transitions owned by
`linear-base`: use **In Progress → In Review → Done** when the deliverable goes
through review, or **In Progress → Done** when it completes without a review
step. When the issue reaches **Done**, continue with step 8.

### 8. After Done — suggest follow-up actions and show context

Once the issue this flow put In Progress reaches **Done** (the completion note is
left by `linear-base` at that transition), surface any useful Git follow-up, its
Project context when it has one, and what to pick up next. This may land in a
later session or turn than the one that started the issue; run it whenever the
completion this flow set in motion reaches Done.

**8a. Clean up the worktree when used.** Follow `linear-base`'s **Worktree
cleanup after Done** procedure. Resolve the worktree, verify that it has no
unpreserved changes, show its exact name/path and branch, and ask the user
whether to remove it. Remove only the worktree checkout, and only after explicit
confirmation; keep the branch unless the user separately asks to delete it. If
this Issue ran in the current workspace or its worktree is already gone, skip
this step.

**8b. Suggest a PR when useful.** For a completed `impl` Issue whose branch has
no PR, suggest opening one when review or integration through a PR would be
useful. Present it as an optional next action and let the user accept or decline;
do not open it automatically, and do not treat its absence as incomplete Issue
work. Skip this suggestion when a PR already exists or would add no value.

**8c. Report Project status when applicable.** If the completed issue belongs to a Project, tally that Project's issues with **Repo label = R** by `state` type and present the compact per-Project block exactly as the `linear` overview skill does (its step 2–3 — `In Progress` / `Todo` / `Backlog`, optional `(Done N)`, `canceled` excluded). Close with a one-line read of the shape (e.g. "one In Progress left, three Todo ready"). If it has **No Project**, state that it was a standalone issue and skip the Project tally; do not invent or require a Project.

**8d. Suggest the next related task(s).** Propose the issue(s) to pick up next, **related to the one just completed** — one or several. Search issues with **Repo label = R** and rank by relatedness first, then fall back to the repo's ready work:

1. **Related to the completed issue, first** — issues that share its **Milestone**, are linked to it by a **Linear relation** (parent, sub-issue, or blocking/blocked — a blocked issue the completed one just unblocked is a strong candidate), or share a **Type/topic label**. Prefer these, ordered by readiness (Todo above Backlog) then priority.
2. **Fallback — the repo's ready work** — if nothing is related, or to round out the list, offer the top open issues by priority exactly as step 2's Section 2 orders them (Todo above Backlog, Urgent → None), including standalone issues.

Show each suggestion as identifier, title, Status, Priority, Type, and Project — plus a short note on *why* it's related (e.g. "same milestone", "was blocked by the one you finished"). Present them and let the user pick, decline, or stop. **If the user picks one, loop back to step 3** so the newly selected issue is read and presented before any action — a Done issue naturally leads into the next start. If no issue is related and none is ready, say so plainly rather than padding the list.
