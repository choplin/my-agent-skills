---
name: self-review
description: Orchestrates comprehensive self-review of implementation through specialized reviewers. Can be invoked directly or automatically after implementation completes.
allowed-tools: Read, Write, Glob, Grep, Bash, Task, Skill
user-invocable: true
---

# Self Review

Orchestrate comprehensive review of implementation through parallel execution of specialized reviewers.

**Trigger phrases**: "self-review", "セルフレビュー", "自動レビュー"

## Purpose

Comprehensive review of implementation through specialized reviewers. The review scope depends on the work level:

- **Story**: Three parallel reviews (Acceptance Criteria, Plan Compliance, Code Quality)
- **Task (with plan)**: Completion Criteria check (inline) + Code Quality review only
- **Task (no plan)**: Code Quality review only (no Completion Criteria)

## Input

- **Story**: Spec at `.claude/dev-workflow/story/{story-dir}/spec.md` + Plan at `.claude/dev-workflow/story/{story-dir}/plan.md`
- **Task (with plan)**: Active Claude Code plan file (from `.claude/plans/`)
- **Task (no plan)**: Git diff of current branch changes (no plan file required)

## Process

### 0. Determine Work Level

Determine the level from the **active work unit**, not a glob over all stories (a leftover completed Story directory must never hijack the current work).

1. Run `python3 dev-workflow/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"` and read `active_path` (the unit bound to this session). If `active_path` is `null` (this session was never bound — e.g. you implemented after a `/clear`), identify the unit from `work_units[]` by `matches_current_branch`; if still ambiguous, ask the user. See `references/state-schema.md`.
   - If the active unit is a **Story** → **Story flow** (proceed to Step 1). Use its `path` as `{story-dir}`.
2. If the active unit is a **Task** (or there is no active Story) → **Task flow**:
   - Identify the active plan file: Glob `.claude/plans/*.md` and find the plan with `**Work level**: Task` in its `## Workflow Context` section
   - If active Task plan found → **Task (with plan)** flow (proceed to Step 1T)
   - If no active Task plan found → **Task (no plan)** flow (proceed to Step 1T, skip 1T-a)

### 0M. Machine-Verification Pass (run first — cheap & deterministic)

Before spending any LLM reviewers, run the criteria predicates. This closes the cheap, certain cases first and surfaces hard FAILs without paying for review.

1. Read the active unit's `state.json` `criteria[]` (Story/Task with plan). For each criterion with a non-null `verify` command:
   - Run the command (Bash). Exit 0 → PASS; non-zero → FAIL.
   - Write the result back to `state.json`: set `passes` and fill `evidence` (a one-line summary of the command + outcome). **Default-FAIL**: never set `passes: true` without having run the command and captured evidence.
2. Criteria with `verify: null` (i.e. `Verify: human`) are **not** guessed here — they go to the acceptance-reviewer / human as NEEDS REVIEW.
3. If any predicate FAILs → this is a hard FAIL. Go straight to Self-Correct (Step 4) and fix, then re-run from 0M. Do not launch the LLM reviewers until predicates pass (no point reviewing code that fails its own tests).

Once all machine predicates PASS (or there are none), proceed to the LLM review pass.

### 1. Invoke Reviewers — Story Flow (Parallel)

Launch reviewers in parallel using Task tool. Every reviewer must **classify each finding** (see "Finding Classification" below) so non-gating noise doesn't force rework.

```
Task 1: acceptance-reviewer (internal agent)
- subagent_type: dev-workflow:acceptance-reviewer
- prompt: "Review implementation against acceptance criteria. spec_path: {spec_path}. Only judge criteria whose Verify is `human` (machine-verifiable criteria were already checked). Classify each as PASS / NEEDS REVIEW."

Task 2: plan-compliance-reviewer (internal agent)
- subagent_type: dev-workflow:plan-compliance-reviewer
- prompt: "Review implementation against plan. plan_path: {plan_path}"

Task 3: feature-dev:code-reviewer (external agent)
- subagent_type: feature-dev:code-reviewer
- prompt: "Review code quality for the changes. For EACH finding, label it `correctness` (a real bug or a violated requirement) or `improvement` (style/refactor/nice-to-have). Only correctness findings gate; report improvements separately."
- Note: Skip if agent not available
```

#### Finding Classification

Reviewers prompted to find gaps will report some even when the work is sound; chasing every finding causes over-engineering (Anthropic best-practices, see `docs/2026-06-11-loop-engineering-research.md` §2). So each finding is one of:

| Class | Meaning | Effect |
|-------|---------|--------|
| `correctness` | A real bug, broken behavior, or a violated spec requirement | **Gates** — counts as FAIL until fixed |
| `improvement` | Style, refactor, naming, optional hardening | **Does not gate** — recorded in review.md as an improvement note for the user to consider |

When a finding's class is genuinely unclear, treat it as `correctness` (fail safe), but state the uncertainty.

### 1C. Codex Code Review (All Flows)

After the parallel reviewers complete (Story) or after code quality review (Task), invoke Codex review:

```
Skill(skill: "codex:review", args: "--wait")
```

- `--wait`: Run in foreground to get results inline
- **IMPORTANT**: `codex:review` is a command and must be invoked via the Skill tool. Do NOT use the `codex:codex-rescue` agent (Agent tool) — rescue runs `task`, not `review`, and will modify files.
- **Skip if Codex CLI is not available** (e.g., command not found error). Treat as PASS and note "Skipped (Codex CLI not available)" in output.

#### Verdict Mapping

Apply Finding Classification to Codex findings too: a finding only gates if it is a `correctness` issue (real bug / violated requirement). Severity is a hint, not the gate.

| Codex Verdict | Findings after classification | Self-Review Status |
|---|---|---|
| `approve` | (none) | PASS |
| `needs-attention` | any `correctness` finding | FAIL |
| `needs-attention` | only `improvement` findings | NEEDS REVIEW (record, don't gate) |
| Skipped/Error | N/A | PASS (not counted) |

### 1T. Invoke Reviewers — Task Flow

For Task-level work, run two review steps:

#### 1T-a. Completion Criteria Check (Inline)

> **Skip this step if Task (no plan)** — proceed directly to 1T-b.

The machine-verification pass (Step 0M) already ran any criteria with a `verify` command and wrote results to `state.json`. Here, handle only the remainder:

1. For criteria with `verify: human` (or plan `### Completion Criteria` items without a command), examine the implementation and mark PASS / NEEDS REVIEW.
2. Any machine-predicate FAIL from 0M is already a hard FAIL → Self-Correct.

This check is performed inline (no agent needed).

#### 1T-b. Code Quality Review

Launch code-reviewer agent:

```
Task: feature-dev:code-reviewer (external agent)
- subagent_type: feature-dev:code-reviewer
- prompt: "Review code quality for the changes in this implementation"
- Note: Skip if agent not available
```

### 2. Aggregate Results

Combine outputs from all reviewers into a unified report. Keep `correctness` findings and `improvement` findings in separate lists.

### 3. Determine Overall Status

A reviewer gates (can produce FAIL) only on machine-predicate failures, missing requirements, or `correctness` findings. `improvement` findings never gate.

| Source | PASS Condition |
|--------|----------------|
| Machine Verification (0M) | All criteria predicates exited 0 |
| Acceptance (human criteria) | All `Verify: human` criteria PASS or NEEDS REVIEW |
| Plan Compliance | All items COMPLETE or NEEDS REVIEW |
| Code Review | No `correctness` findings (improvements are recorded, not gated) |
| Codex Review | Verdict "approve", or skipped, or only `improvement` findings |

Overall PASS requires every gating source to pass. `improvement` findings are listed for the user but do not block reaching user-review.

### 4. Self-Correct (if FAIL)

This is a feedback loop. If any FAIL exists:

1. **Machine-predicate FAIL**: Fix the implementation until the criterion's `verify` command exits 0. This is the cheapest, most certain signal — fix these first.
2. **Acceptance FAIL** (human criteria): Fix implementation to meet the criterion.
3. **Plan FAIL**: Complete missing steps/file changes.
4. **Code/Codex `correctness` finding**: Fix it. `improvement` findings are recorded but not fixed here unless the user asks.

After fixing, re-run self-review from Step 0M.

**Escalation rule**: If the same FAIL occurs twice consecutively, promote it to NEEDS REVIEW.

**Rationale**: If AI cannot fix an issue after one attempt, the issue likely requires user judgment.

#### Plan Mode Context Preservation

If you use EnterPlanMode to fix issues, add a `## dev-workflow Context` block to the plan file. Use the template in `references/plan-mode-context.md` with these values:

- **Active skill**: self-review (Self-Correct)
- **Work level**: Story / Task / Task (no plan) — match the current flow
- **Documents**: the relevant docs for the work level — Story: Spec + Plan; Task (with plan): the active plan file; Task (no plan): `.claude/dev-workflow/task/{task-dir}/review.md`
- **After This Plan Completes**: Re-run self-review to verify fixes are effective.

### 5. Create review.md (if no FAIL remains)

When all results are PASS or NEEDS REVIEW (no FAIL), create review.md for the upcoming user-review phase.

**Also create/update `state.json`** in the same work-unit directory (see `references/state-schema.md`):

- **Story**: `state.json` already exists (from create-spec/create-plan). Set `criteria[].passes`/`evidence` from the verification results, and initialize `review` = `{ "phase": "REVIEWING", "mode": "ITERATIVE", "items": [] }`.
- **Task (with plan / no plan)**: the Task has no `state.json` yet — create it now alongside review.md. Set `level: "task"`, `title`, `branch` (current branch, or `null` for no-plan without a dedicated branch), `criteria` (from the plan's Completion Criteria if present, else `[]`), `steps` (from the plan if present, else `[]`), and `review` = `{ "phase": "REVIEWING", "mode": "ITERATIVE", "items": [] }`. Use the same `{task-dir}` as review.md.

Do not store a resolved counter — it is derived by the script.

**Bind this session** to the work unit now that its directory exists (idempotent; this is the first binding point for a Task, see `references/state-schema.md` § Session binding):

```bash
python3 dev-workflow/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set "<work-unit-dir>"
```

#### Story Flow

1. Check for existing `.claude/dev-workflow/story/{story-dir}/review.md` — if it exists, ask user before overwriting
2. Read `references/review-template.md`
3. Fill in the template:
   - **Title**: From spec.md title
   - **Related Files**: Actual spec and plan paths
   - **Self-Review Results**: Aggregated review result table from Step 2
   - **Review Items**: Empty (no user feedback yet)
   - **Phase**: `REVIEWING`
   - **Mode**: `ITERATIVE`
   - **Resolved**: `0 / 0`
4. Write to `.claude/dev-workflow/story/{story-dir}/review.md`

#### Task Flow (with plan)

1. Derive task name from plan file's `# Plan: {name}` title (convert to kebab-case)
2. Prepend today's date: `{yyyy-mm-dd}-{task-name}`
3. Check for existing `.claude/dev-workflow/task/{yyyy-mm-dd}-{task-name}/review.md` — if it exists, ask user before overwriting
3. Read `references/review-template.md`
4. Fill in the template:
   - **Title**: From plan file title
   - **Related Files**: Plan path only (no Spec)
   - **Self-Review Results**: Completion Criteria + Code Quality results only (no Acceptance Criteria / Plan Compliance rows)
   - **Review Items**: Empty (no user feedback yet)
   - **Phase**: `REVIEWING`
   - **Mode**: `ITERATIVE`
   - **Resolved**: `0 / 0`
6. Write to `.claude/dev-workflow/task/{yyyy-mm-dd}-{task-name}/review.md`

#### Task Flow (no plan)

Follow `references/review-init-guide.md` to resolve metadata:

1. Derive directory name from git branch: replace `/` with `-`, prepend today's date as `{yyyy-mm-dd}-{branch-with-dashes}`
2. Check for existing `.claude/dev-workflow/task/{task-dir}/review.md` — if it exists, ask user before overwriting
3. Read `references/review-template.md`
4. Fill in the template:
   - **Title**: From branch name (prefix removed)
   - **Related Files**: No Spec or Plan lines (add comment `<!-- No plan file associated -->`)
   - **Self-Review Results**: Code Quality results only (no Completion Criteria rows)
   - **Review Items**: Empty (no user feedback yet)
   - **Phase**: `REVIEWING`
   - **Mode**: `ITERATIVE`
   - **Resolved**: `0 / 0`
5. Write to `.claude/dev-workflow/task/{task-dir}/review.md`

### 6. Invoke Handoff

After review.md is created:

1. Notify user: "review.md を作成しました。handoff プロンプトを生成します。"
2. Invoke `Skill(skill: "dev-workflow:handoff")`
3. Handoff detects `in_review` state and generates a resume-work prompt for the next session

The user can then copy the prompt, `/clear`, and paste to start user-review in a clean session.

## Output Format

### Story Flow

```markdown
## Self Review Results

**Spec**: `.claude/dev-workflow/story/{story-dir}/spec.md`
**Plan**: `.claude/dev-workflow/story/{story-dir}/plan.md`

### 1. Acceptance Criteria Review

{Output from acceptance-reviewer agent}

### 2. Plan Compliance Review

{Output from plan-compliance-reviewer agent}

### 3. Code Quality Review

{Output from feature-dev:code-reviewer agent, or "Skipped (agent not available)" if unavailable}

### 4. Codex Code Review

{Output from codex:review, or "Skipped (Codex CLI not available)" if unavailable}

### Overall Summary

| Review | PASS | FAIL | NEEDS REVIEW |
|--------|------|------|--------------|
| Acceptance Criteria | X | X | X |
| Plan Compliance | X | X | X |
| Code: Bugs | X | X | X |
| Code: Logic Errors | X | X | X |
| Code: Security | X | X | X |
| Code: Code Quality | X | X | X |
| Code: Conventions | X | X | X |
| Codex Review | X | X | X |
| **Total** | X | X | X |

### Next Action

{If any FAIL: specific fixes to apply, then re-run self-review}
{If all PASS or only NEEDS REVIEW: review.md created, handoff invoked — copy prompt, /clear, paste to start user-review}
```

### Task Flow (with plan)

```markdown
## Self Review Results

**Plan**: `{path to plan file}`

### 1. Completion Criteria Check

| # | Criterion | Result | Details |
|---|-----------|--------|---------|
| 1 | {criterion from plan} | PASS/FAIL/NEEDS REVIEW | {details} |

### 2. Code Quality Review

{Output from feature-dev:code-reviewer agent, or "Skipped (agent not available)" if unavailable}

### 3. Codex Code Review

{Output from codex:review, or "Skipped (Codex CLI not available)" if unavailable}

### Overall Summary

| Review | PASS | FAIL | NEEDS REVIEW |
|--------|------|------|--------------|
| Completion Criteria | X | X | X |
| Code: Bugs | X | X | X |
| Code: Logic Errors | X | X | X |
| Code: Security | X | X | X |
| Code: Code Quality | X | X | X |
| Code: Conventions | X | X | X |
| Codex Review | X | X | X |
| **Total** | X | X | X |

### Next Action

{If any FAIL: specific fixes to apply, then re-run self-review}
{If all PASS or only NEEDS REVIEW: review.md created, handoff invoked — copy prompt, /clear, paste to start user-review}
```

### Task Flow (no plan)

```markdown
## Self Review Results

**Branch**: `{branch name}`

### 1. Code Quality Review

{Output from feature-dev:code-reviewer agent, or "Skipped (agent not available)" if unavailable}

### 2. Codex Code Review

{Output from codex:review, or "Skipped (Codex CLI not available)" if unavailable}

### Overall Summary

| Review | PASS | FAIL | NEEDS REVIEW |
|--------|------|------|--------------|
| Code: Bugs | X | X | X |
| Code: Logic Errors | X | X | X |
| Code: Security | X | X | X |
| Code: Code Quality | X | X | X |
| Code: Conventions | X | X | X |
| Codex Review | X | X | X |
| **Total** | X | X | X |

### Next Action

{If any FAIL: specific fixes to apply, then re-run self-review}
{If all PASS or only NEEDS REVIEW: review.md created, handoff invoked — copy prompt, /clear, paste to start user-review}
```

## Success Criteria

- [ ] Work level is correctly determined (Story or Task)
- [ ] Story: All three reviewers are invoked in parallel
- [ ] Task: Completion Criteria checked inline + code-reviewer invoked
- [ ] Results are aggregated into unified report
- [ ] Each FAIL includes actionable fix instruction
- [ ] Feedback loop continues until no FAIL remains
- [ ] Ready to proceed to user review (all PASS or only NEEDS REVIEW)
- [ ] review.md is created at `.claude/dev-workflow/story/{story-dir}/review.md` (Story) or `.claude/dev-workflow/task/{task-dir}/review.md` (Task)
- [ ] Codex review is invoked via Skill tool (when available)
- [ ] Codex unavailability does not block self-review
- [ ] Handoff skill is invoked to generate resume prompt

## Next Session

After self-review completes (all PASS or NEEDS REVIEW only), review.md is created automatically and handoff is invoked. The user copies the generated prompt, clears the session, and pastes it. resume-work detects `in_review` state and dispatches to user-review, which finds existing review.md at Step 0 and begins from `REVIEWING` phase.
