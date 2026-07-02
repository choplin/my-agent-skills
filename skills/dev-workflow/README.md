# dev-workflow

Development workflow management for Claude Code.

## Overview

dev-workflow turns "AI, please remember to follow the process" into a process the mechanism enforces. It guides a task from intent to a reviewed, committed change, and keeps two loops honest:

- **Inner loop (machine-checked):** completion is defined by predicates — commands that return pass/fail. Acceptance criteria carry a `Verify:` command; self-review runs them first, deterministically, before any LLM review. The loop closes on evidence, not on the model's say-so.
- **Outer loop (human-checked):** the things a predicate can't capture — did we build the right thing, is the direction sound — surface as early as possible, when they are cheap to change.

Work state lives in documents and a small `state.json`, so a task survives `/clear`, a crash, or a new session. A bundled script (`scripts/workflow-state.py`) derives "where am I" deterministically, and hooks inject that on session start and remind you to review before stopping.

## Workflow Levels

`dev-workflow-kickoff` interviews you and routes the work to the right level. The core question is **"can you write the completion criteria directly from your need?"** — and, for tasks, **"can every criterion be a command that returns pass/fail?"**

| Level | When | Approach |
|-------|------|----------|
| **Autonomous-Task** | A Task where *every* criterion is machine-verifiable — the answer lives in a test/build/reference, not in your head | *Leaves dev-workflow* → `goal-loop`: write goal + predicates, let the implement→verify loop run to green, review only the finished artifact. |
| **Task** | Criteria writable directly from the need; implementation approach is obvious | *Leaves dev-workflow* → `exec-plan` (self-drivable), or just implement directly (trivial one-off). |
| **Story** | You must decide "what kind" before "done" (requirements need clarifying) | spec + plan documents, then implement. |
| **Epic** | Multiple independent stories | An epic document coordinating stories, each its own Story. |

The split is about **where the "right answer" lives**: in the world (tests, a spec to match, a benchmark) → lean autonomous; in your head (taste, UX, product judgment) → keep the spec as a human contract. See `docs/2026-06-11-loop-engineering-research.md` for the reasoning.

**Task-level work leaves dev-workflow.** Both Task rows above are routed *out* by `dev-workflow-kickoff` — to `goal-loop`, `exec-plan`, or direct implementation, each of which carries its own review/finish. dev-workflow's own document and review flow (below) is for **Story and Epic**. A Task re-enters dev-workflow only via promotion to Story, when requirements turn out to need deciding.

## How It Works

**Predicates (`Verify:`).** Each acceptance criterion gets a `Verify:` line: an executable command that exits 0 on pass, or `human` for criteria only a person can judge. Machine criteria are checked automatically; `human` criteria are routed to human review from the start and never guessed.

**state.json.** Alongside the human-readable spec/plan, each work unit keeps a `state.json` holding machine state (criteria + pass/evidence, steps, review status). Criteria start `passes: false` and only flip to `true` with recorded evidence. Derived values (counters, "what state am I in") are never stored — the script computes them. See `references/state-schema.md`.

**State evaluator.** `scripts/workflow-state.py` scans your work units and reports each one's state, progress, and next action as JSON. It picks the active unit by current branch when there is one, else by most-recent activity — so it works with or without per-unit branches.

**self-review.** Runs the machine predicates first (cheap, certain); only then launches LLM reviewers. Every reviewer finding is classified `correctness` (a real bug or violated requirement — blocks) or `improvement` (style/refactor — recorded, doesn't block), so review noise doesn't force needless rework.

**Outer-loop shortening.** Plans start with a walking skeleton (the first reviewable real artifact) and a quick "is this the right direction?" checkpoint, and record their `Approach Decisions` so you can review the *direction*, not just the file list. Omissions found in review are fed back into the spec template / kickoff questions by `dev-workflow-post-task`.

## Hooks

Two command hooks (in `hooks/`) move workflow adherence from prompt to mechanism. Both delegate state to `scripts/workflow-state.py`, are best-effort (any failure leaves the session untouched), and stay silent when there's no active dev-workflow work.

| Hook | Event | Behavior |
|------|-------|----------|
| `session-start.py` | SessionStart | Injects a short summary of the active work unit (state, progress, next action) so a fresh session resumes with context — replacing the handoff copy-paste ritual for the common case. |
| `stop-gate.py` | Stop | When the active unit is `potentially_complete` (all steps done, no review started), reminds you to run `/dev-workflow-self-review`. Blocks at most twice in a row, then yields — a reminder, not a loop engine. |

> Hooks load at session start; after installing or changing them, restart Claude Code. See `docs/2026-06-22-hooks-design.md`.

## Skills

| Skill | Description |
|-------|-------------|
| `dev-workflow-kickoff` | Explore the need through dialogue and route to the right level (incl. the oracle test → Autonomous-Task); Task-level work is routed out to `goal-loop` / `exec-plan` / direct implementation |
| `dev-workflow-create-epic` | Create an epic document coordinating multiple stories |
| `dev-workflow-create-spec` | Create a spec with predicate-ized (`Verify:`) acceptance criteria |
| `dev-workflow-create-plan` | Create a self-contained implementation plan (walking skeleton first, approach decisions) |
| `dev-workflow-resume-work` | Resume existing work from the evaluator's view of progress |
| `dev-workflow-handoff` | Generate a handoff prompt (mostly superseded by the SessionStart hook; use for session notes) |
| `dev-workflow-self-review` | Machine-verification pass, then classified LLM review |
| `dev-workflow-user-review` | Structured handling of user feedback during review |
| `dev-workflow-post-task` | Capture knowledge and feed omissions back into the workflow |
| `dev-workflow-workflow-status` | Overview of all active epics and stories |

## Dependencies

This plugin depends on the **`discuss-toolkit`** plugin:

- `dev-workflow-kickoff` and `dev-workflow-user-review` use `discuss-toolkit-dig` as a base skill to clarify ambiguous intent before proceeding.

Install `discuss-toolkit` alongside this plugin. If it is not available, `dev-workflow-kickoff` (the entry point) and the Complex-feedback path of `dev-workflow-user-review` cannot run their interview step.

## Templates

| File | Description |
|------|-------------|
| `references/epic-template.md` | Epic document template |
| `references/spec-template.md` | Spec document template (with the `Verify:` line) |
| `references/plan-template.md` | Plan document template |
| `references/state-schema.md` | `state.json` schema and the state contract |

## Typical Workflow (Story Level)

1. `dev-workflow-kickoff` — explore the need, assess the level.
2. `dev-workflow-create-spec` — write requirements and predicate-ized acceptance criteria (`Verify:` commands, or `human`).
3. `dev-workflow-create-plan` — sequence the steps; Step 1 is a walking skeleton; record approach decisions.
4. Implement, updating progress. Show the walking-skeleton slice early for a quick direction check. (Clearing the session is optional — documents + `state.json` are the source of truth.)
5. `dev-workflow-self-review` — runs the `Verify:` predicates first, then classified LLM review. Fix `correctness` findings; `improvement` findings are noted, not forced.
6. `dev-workflow-user-review` — present results; handle feedback.
7. After LGTM, commit.
8. `dev-workflow-post-task` — capture knowledge; feed any late-surfacing omissions back into the spec template / kickoff.

For **Task-level** work this whole flow is skipped — the work leaves dev-workflow: an **Autonomous-Task** goes to `goal-loop` (write goal + predicates, run the implement→verify loop to green, review the finished artifact); an ordinary **Task** goes to `exec-plan` or is implemented directly.

## Installation

Add to your `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/dev-workflow"
  ]
}
```

After installing (or changing hooks), restart Claude Code so the hooks load.
