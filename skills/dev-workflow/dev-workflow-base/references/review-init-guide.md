# Review.md Initialization Guide

Shared procedure for creating `review.md` when it does not yet exist. Referenced by `dev-workflow-self-review`, `dev-workflow-user-review`, and `dev-workflow-import-pr-comments` skills.

review.md is created for **Story-level work only** — Task-level work leaves dev-workflow and carries its own review (see `references/workflow-concepts.md`).

## 1. Resolve the Story

Identify the active Story from the state evaluator (or the unit passed in). Its directory `{story-dir}` = `{yyyy-mm-dd}-{prefix}-{story-name}` under `.claude/dev-workflow/story/`.

If there is no active Story (the work is Task-level, or has no dev-workflow unit), review.md does not apply — the calling skill should stop and let Task-level review run through its own route (`goal-loop` / `exec-plan` / an ad-hoc `/code-review`).

## 2. Resolve Metadata

| Field | Value |
|-------|-------|
| Title | spec.md title (`# {title}`) |
| Spec path | `story/{story-dir}/spec.md` |
| Plan path | `story/{story-dir}/plan.md` |
| review.md path | `story/{story-dir}/review.md` |

## 3. Self-Review Results Section

The content of the Self-Review Results table depends on which skill creates `review.md`:

| Creator | Self-Review Results content |
|---------|---------------------------|
| **self-review** | Actual review results from the self-review process |
| **user-review** | `| - | Self-review | SKIPPED | Self-review was not performed |` |
| **import-pr-comments** | `| - | Self-review | SKIPPED | Self-review was not performed |` |

## 4. Create review.md

1. Check for existing `review.md` at the resolved path — if it exists, ask user before overwriting
2. Read `references/review-template.md`
3. Fill in the template:
   - **Title**: Resolved title from step 2
   - **Related Files**: Spec and Plan paths
   - **Self-Review Results**: Based on creator (see step 3)
   - **Review Items**: Empty (no feedback yet)
   - **Phase**: `REVIEWING`
   - **Mode**: `ITERATIVE`
   - **Resolved**: `0 / 0` (informational only — derived by the state evaluator)
4. Write to the resolved `review.md` path
5. Ensure a `state.json` exists in the same directory (see `references/state-schema.md`). If missing, create it with `review` = `{ "phase": "REVIEWING", "mode": "ITERATIVE", "items": [] }`; otherwise set its `review` block to the same.
