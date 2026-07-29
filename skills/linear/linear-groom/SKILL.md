---
name: linear-groom
description: Groom the Backlog of the current repository's Linear Project — resolve the repo to its active Linear Project, auto-pick Backlog issues one at a time in priority order, and walk each through grooming (Backlog → Todo) interactively until no groomable item remains or the user stops. The counterpart to linear-start (which auto-picks Todo work to execute). Use when the user wants to work through the Backlog without naming issues one by one. Triggers on "groom the backlog", "start grooming", "backlog を整理", "Backlog を groom して", "次の backlog を groom". Should NOT trigger for starting/executing a groomed issue (use linear-start), one-off creation or grooming a single named issue (use linear-base), Jira (jira-cli), or GitHub Issues (github tools).
metadata:
  description-role: documentation
---

# Groom the Backlog of a Linear Project

Work through the **current repository's** Backlog, one issue at a time, turning rough Backlog items into ready **Todo** work orders. This skill covers *selection and looping*; the grooming rules themselves are owned by the `linear-base` skill — read its **Issue authoring standard**, **Grouping & ordering**, and **The grooming step** before starting if unfamiliar.

This is the counterpart to `linear-start`: `linear-start` auto-picks **Todo** work to execute; this auto-picks **Backlog** work to groom.

Use whichever Linear MCP server is wired. Referenced fields (`state`, `project`, `labels`, `priority`) are stable Linear API fields.

## Flow

### 1. Resolve the current repo → active Project

Resolve the repo to its active Project per the `linear-base` skill's **Resolving the current repo's active Project(s)** (derive the Repo label from the git repo, then the active Project(s) tagged `Repo/R`; the label-ambiguity, missing-project-label, and no-active-Project edge cases live there). Like `linear-start`, this skill acts on a **single** Project: auto-select when there's exactly one active Project, ask the user to pick when there are several.

### 2. Survey the Backlog

Within the chosen Project, list the issues with **Repo label = R** and `state` type = **backlog** (Backlog only — Todo items are already groomed). Order by **priority** (Urgent → High → Medium → Low → None).

- **Empty Backlog** → say so and stop. Nothing to groom.
- Otherwise show the queue: identifier, title, Priority, and current Type label if any. Tell the user how many items are queued and that you'll work top-down.

**Groomable vs blocked.** Not every Backlog item can be groomed right now. An item is **not yet groomable** when its content depends on an unresolved upstream — e.g. it is `blocked by` an issue whose outcome isn't settled, or its What/Acceptance can't be written until a prior decision lands. You can't write a self-complete work order on top of an undecided dependency. Skip such items this round and note *what* they're waiting on.

### 3. Loop: auto-pick → groom → Todo

Repeat until **no groomable Backlog item remains** (not merely until the Backlog is empty) or the user stops:

1. **Auto-pick** the top-priority remaining **groomable** Backlog issue (one whose grooming isn't blocked by an unresolved dependency, per above). State which one you picked and why (its priority rank) — don't ask the user to choose. The user may redirect ("skip this / do ISSUE-123 first") or stop the loop at any point.
2. **Groom it interactively**, following `linear-base`'s grooming step. Grooming is **not** automated — do it *with* the user in this session, because What/Why/Acceptance often live only in the user's head. Settle the three things together:
   - **Self-completeness** — bring the description up to `linear-base`'s authoring standard (What & why / Where / Inputs / Acceptance / Constraints). Ask the user for whatever is missing; propose a draft description and confirm.
   - **True size** — decide whether it's really one deliverable or splits. If it splits, apply `linear-base`'s grouping rule and its promote-vs-rebuild asymmetry (small multi-deliverable effort → promote to parent + sub-issues; distinct outcome → build a Project, Cancel+link or reuse the original). Add `blocked by` relations for execution order when needed.
   - **Type label** — set `impl` / `design` / `research` (drives the executor-model choice).
3. **Move Backlog → Todo** once the self-check passes (*could a fresh agent open
   this Issue, follow its explicit inputs to completed blocker outcomes, and
   produce the atomic deliverable without further questions?*). If it can't be
   made self-complete now (missing a decision, unresolved blocker, or external
   input), **leave it in Backlog**, note what it's waiting on, and move to the
   next item.
4. **Re-evaluate the queue** before the next pick — grooming may have split an issue into new Backlog items, promoted one out, or *unblocked* a previously-blocked item (settling this issue can resolve a dependency others were waiting on). Then pick the next top-priority groomable Backlog issue.

### 4. Wrap up

Stop when **no groomable Backlog item remains** (or the user stops) — note that this is not the same as an empty Backlog: items blocked on an unresolved dependency stay put by design. Give a short summary: which issues reached **Todo**, which were split (into sub-issues / a Project), and which stayed in **Backlog** with what each is waiting on (the unresolved dependency or decision). Point out that the freshly-groomed Todo items can now be picked up via `linear-start`.
