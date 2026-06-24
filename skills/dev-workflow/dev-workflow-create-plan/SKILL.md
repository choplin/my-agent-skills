---
name: dev-workflow-create-plan
description: This skill is invoked ONLY after create-spec completes. Should NOT be invoked directly by user or auto-triggered by AI. Creates implementation plan document based on spec.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
user-invocable: false
---

# Create Plan Document

Create an implementation plan document based on a spec.

## Purpose

Three core functions:
1. **Implementation steps**: Organize How into sequential steps
2. **Change locations**: Identify which files to modify
3. **Progress tracking**: Track completion of steps during implementation

## Detail Level

Plan should contain **steps and files only**:
- What to do (step description)
- Which files to change

**Why this level?**
- **Focus on direction**: AI is capable enough that if it knows what to do, it can handle implementation. Plan should focus on direction and goal.
- **Flexibility**: Too much detail makes the plan brittle/fragile - implementation often evolves differently
- **Review cost**: More detail means more to review (same problem as create-spec)

**Exception**: For repetitive tasks, few-shot examples can be included to guide implementation style.

Plan should NOT contain:
- Specific code changes
- Function/class level details
- Implementation code snippets

## Input

This skill is invoked after create-spec completes. The spec document at `.claude/dev-workflow/story/{story-dir}/spec.md` is the input (`{story-dir}` = `{yyyy-mm-dd}-{prefix}-{story-name}`).

## Process

### 1. Read Spec

Load the spec document and understand:
- Why: Background and motivation
- What: Requirements and acceptance criteria
- Out of Scope: What NOT to do

### 2. Investigate Codebase

Gather information needed for implementation:
- Existing code structure
- Files that need changes
- Existing patterns to follow

### 3. Design Implementation Steps

Create steps following these principles:
- **Dependency-aware**: Start with prerequisites
- **One deliverable per step**: Each step produces a clear result
- **Verifiable**: Completion can be confirmed
- **Walking skeleton first**: Make **Step 1** a thin vertical slice that produces the first *reviewable real artifact* — the smallest end-to-end thing the user can actually look at and react to. Most rework comes from spec omissions and wrong direction, which are only visible once something runs; the earlier the user sees a real artifact, the cheaper that correction. Do not back-load all visible behavior into the final step.

### 4. Create Plan Document

Create `.claude/dev-workflow/story/{story-dir}/plan.md`:

```markdown
# Plan: {title}

## Related Files

- **Workflow concepts**: `dev-workflow-base/references/workflow-concepts.md`
- **Spec**: `.claude/dev-workflow/story/{story-dir}/spec.md`
- **Branch**: `{prefix}/{story-name}` (from spec)
- **Epic**: `.claude/dev-workflow/epic/{epic-dir}/epic.md` (if part of an Epic)

## Workflow Context

**Current phase**: Implementation
**Work level**: Story

### During Implementation
- Follow Steps sequentially
- Update `## Progress` section as each step completes (`- [ ]` → `- [x]`)
- Refer to Spec's Acceptance Criteria as the source of truth for verification
- **Slice checkpoint**: after Step 1 (the walking skeleton) is done, briefly show the user the running artifact and ask if the direction looks right, before building the rest. This surfaces spec omissions and wrong-direction early, when they are cheap to fix. Keep it lightweight — a quick "here's the slice, on track?", not a full review.

### After All Steps Complete
1. Invoke `dev-workflow-self-review` skill — verifies against acceptance criteria in spec
2. Invoke `dev-workflow-user-review` skill — presents results and collects user feedback
3. After user LGTM: commit changes
4. Invoke `dev-workflow-post-task` skill — capture knowledge

### If Session Clears
- Use `/dev-workflow-resume-work` to evaluate progress and resume from the correct point
- Or read this plan and the spec, then continue from the last completed step

## Approach
{High-level implementation approach}

## Approach Decisions
{The implementation-direction choices the user should be able to review at plan
approval — not just files and steps. For each significant decision: the options
considered and why this one was chosen. Wrong direction (the "(b)" rework class
in the research note) is expensive once it is code; expose it here while it is
still cheap to change. Omit only if the approach is genuinely obvious.}

| Decision | Options considered | Chosen + why |
|----------|--------------------|--------------|
| {e.g. state storage} | {A vs B} | {choice and rationale} |

## Files to Change

| File | Change |
|------|--------|
| `path/to/file` | {brief description} |

## Steps

### Step 1: {name}
{What to do}

### Step 2: {name}
{What to do}

## Progress

- [ ] Step 1
- [ ] Step 2

## Notes
{Decisions made during planning, if any}
```

### 4b. Update state.json

Update `.claude/dev-workflow/story/{story-dir}/state.json` (created by create-spec). Populate `steps` with one entry per plan Step: `{id, name, done: false}`. Keep it in sync with the plan's `## Progress` checklist (same order/count). See `dev-workflow-base` skill (`references/state-schema.md`). Do not add derived fields.

### 4c. Bind this session to the Story

Bind so dev-workflow hooks track only this work during implementation (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

```bash
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/story/{story-dir}"
```

### 5. User Review

Present plan to user for approval before proceeding.

## Success Criteria

- [ ] Plan document is created at `.claude/dev-workflow/story/{story-dir}/plan.md`
- [ ] Spec is referenced
- [ ] Files to change are listed
- [ ] Steps are in dependency order
- [ ] Progress checklist exists
- [ ] Implementation can start by reading plan alone (/clear and go)
- [ ] Workflow Context section includes current phase, post-implementation workflow sequence, and session recovery instructions
- [ ] User has approved the plan

## Next Session

After plan is approved:

**Reference**:
- `.claude/dev-workflow/story/{story-dir}/spec.md`
- `.claude/dev-workflow/story/{story-dir}/plan.md`

**Next phase**: Implementation

Read both spec and plan, then proceed with implementation. Update Progress section as steps complete.
