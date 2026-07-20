---
name: dev-workflow-self-review
description: Verify a dev-workflow Story is actually complete, then prepare its review record. Runs the completion gate (machine-verification against state.json criteria, plan-compliance) — fixing or returning to implementation if anything is incomplete — then seeds an AI code review into review.md via the review-tools family. Can be invoked directly or after implementation completes.
allowed-tools: Read, Write, Glob, Grep, Bash, Task, Skill
user-invocable: true
---

# Self Review (dev-workflow Story wrapper)

Confirm a **Story**'s implementation is complete, then open its review. This skill runs
dev-workflow's **completion gate** and seeds the review record (`review.md`, owned by the
`review-tools` family) with an AI code review. The recorded items are then worked to
resolution by `dev-workflow-user-review`.

**Trigger phrases**: "self-review", "セルフレビュー", "自動レビュー"

## Principle: completion gate vs. review

A gap in the machine predicates or the plan means the **implementation is not
complete** — it is not a review finding. Those are fixed (or sent back to
implementation) here, never turned into review items. The review itself is only over a
*completed* implementation: an AI code review (here) and the human's judgment
(`dev-workflow-user-review`, which also applies the human acceptance criteria).

## Scope

Story-level work only. Task-level work leaves dev-workflow and is reviewed by its own
route (an ad-hoc `review-tools-ai-review` + `review-tools-resolve` on the diff,
`goal-loop`, `exec-plan`). If the active unit is a Task, see Step 0.

## Input

- **Story**: `state.json` at `.claude/dev-workflow/story/{story-dir}/` (criteria +
  steps — the local execution state). The authored **spec + plan** live in the
  Story's **Linear Issue** (`state.json.linear_issue_id`); self-review reads them
  once at this boundary and supplies their text to the review sub-skills (which stay
  Linear-agnostic — they take content, not paths). Its `review_dir` is
  `.claude/dev-workflow/story/{story-dir}/`.

## Process

### 0. Determine Work Level

1. Run `python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"` and read `active_path`. If `null`, identify the unit from `work_units[]` by `matches_current_branch`; if ambiguous, ask. See `dev-workflow-base` skill (`references/state-schema.md`).
2. **Story** → proceed. Use its `path` as `{story-dir}`.
3. **No active Story** (Task-level or no dev-workflow unit) → self-review does not apply.
   Point the user at the Task route (or an ad-hoc `review-tools-ai-review` +
   `review-tools-resolve` on the diff). Stop.

### 1. Completion Gate (not review — fix, don't itemize)

Confirm the implementation is actually done. Nothing here becomes a review item.

**1a. Machine verification.** Read the Story's `state.json` `criteria[]`. For each with
a non-null `verify` command: run it (Bash). Exit 0 → PASS; non-zero → FAIL. Write
`passes` + `evidence` back. **Default-FAIL**: never set `passes: true` without running
the command. Any FAIL → fix the implementation and re-run until green.

**1b. Plan compliance.** Read the plan (Files to Change + Steps) from the Story Issue
and verify every planned change is present — via the
`dev-workflow:plan-compliance-reviewer` subagent (a wrapper around the
`dev-workflow-plan-compliance-review` skill; apply the skill inline if the subagent is
unavailable), passing the plan **content**. A gap means implementation is unfinished:
complete it now (set the matching `state.json.steps[].done` and best-effort tick the
Issue's Steps checklist). If a gap needs substantial further work, say so and return to
implementation — **do not open the review** until the plan is fully implemented.

Criteria with `verify: null` (`Verify: human`) are not judged here — they are the human
acceptance step in `dev-workflow-user-review`.

### 2. Seed the review — AI code review → items

The implementation is complete. Open the review by seeding it with an AI code review:

```
Skill(skill: "review-tools-ai-review")
- review_dir: .claude/dev-workflow/story/{story-dir}/
- scope: current branch changes
```

It runs an available AI code reviewer (+ Codex), creates `review.md` (Phase `open`), and
appends findings as `open` items (`Source: ai`). It does not fix or gate. (If it finds
nothing, `review.md` is still created — the human review below is the point.)

### 3. Bind and hand off

1. **Bind this session** to the Story (idempotent):
   ```bash
   python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/story/{story-dir}"
   ```
   The state evaluator reads review phase/items from `review.md`; only the
   machine-verification `criteria` results are written to `state.json`.
2. **Leave the unit at `in_review`** (review.md Phase `open`). No prompt to copy: the
   SessionStart hook injects the active-unit summary into the next session, so resuming is
   just `dev-workflow-resume-work` — it detects `in_review` and dispatches to
   `dev-workflow-user-review`, which applies the human acceptance criteria and resolves the
   items.

## Output Format

```markdown
## Self Review — {story title}

**Story Issue**: `{linear_issue_id}`

### Completion Gate
- Machine verification: {PASS per criterion with evidence — all green}
- Plan compliance: {complete, or gaps completed / returned to implementation}

### Review seeded (review.md)
| # | Source | Summary |
|---|--------|---------|
| 1 | ai | {code finding} |

{count} items open. Left at in_review — /clear, then `dev-workflow-resume-work` runs user review.
```

## Success Criteria

- [ ] Active unit confirmed to be a Story (Task-level redirected)
- [ ] Machine predicates run and fixed to green; `state.json` criteria updated (Default-FAIL honored)
- [ ] Plan fully implemented (gaps completed or returned to implementation) — not itemized
- [ ] AI code review seeded via `review-tools-ai-review` (`ai` items); `review.md` at Phase `open`
- [ ] Session bound; unit left at `in_review` for the next session to resume
- [ ] No dev-workflow items written to `review.md`; only `criteria` results written to `state.json`
