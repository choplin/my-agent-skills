---
name: dev-workflow-create-plan
description: This skill is invoked ONLY after create-spec completes. Should NOT be invoked directly by user or auto-triggered by AI. Authors the implementation plan design into the Story's Linear Issue and populates steps in state.json.
user-invocable: false
---

# Create Plan

Design the implementation plan for a Story. The plan **design** (Approach,
decisions, Files to Change, Steps) is appended to the Story's **Linear Issue**
(alongside the spec authored by create-spec); the **steps** are mirrored into the
local `state.json` as the machine-managed progress state. There is no local
`plan.md`.

## Tool Usage Constraints

- **Linear**: use whichever Linear MCP server is wired, per the `linear-base` skill.

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

This skill is invoked after create-spec completes. The input is the Story's
**Linear Issue** (`state.json.linear_issue_id`, at
`.claude/dev-workflow/story/{story-dir}/state.json`, where `{story-dir}` =
`{yyyy-mm-dd}-{prefix}-{story-name}`), whose description holds the spec.

## Process

### 1. Read the spec from the Story Issue

Read the Story's Linear Issue description and understand:
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

### 4. Author the plan into the Story Issue

Append a `## Plan` section to the Story's Linear Issue description (below the spec
authored by create-spec):

```markdown
## Plan

### Approach
{High-level implementation approach}

### Approach Decisions
{The implementation-direction choices the user should be able to review at plan
approval — not just files and steps. For each significant decision: the options
considered and why this one was chosen. Wrong direction is expensive once it is
code; expose it here while it is still cheap to change. Omit only if the approach
is genuinely obvious.}

| Decision | Options considered | Chosen + why |
|----------|--------------------|--------------|
| {e.g. state storage} | {A vs B} | {choice and rationale} |

### Files to Change

| File | Change |
|------|--------|
| `path/to/file` | {brief description} |

### Steps

- [ ] Step 1: {name} — {what to do}
- [ ] Step 2: {name} — {what to do}
```

The Steps checklist in the Issue is the **human-visible mirror**; the source of
truth for progress is `state.json` (next step). It is best-effort updated as steps
complete. Acceptance Criteria in the spec (same Issue) remain the source of truth
for verification.

**Slice checkpoint**: after Step 1 (the walking skeleton) is done, briefly show the
user the running artifact and ask if the direction looks right before building the
rest — a quick "here's the slice, on track?", not a full review. This surfaces spec
omissions and wrong-direction early, when they are cheap to fix.

### 4b. Populate steps in state.json

Update `.claude/dev-workflow/story/{story-dir}/state.json` (created by create-spec). Populate `steps` with one entry per plan Step: `{id, name, done: false}`, in the same order/count as the Issue's Steps checklist. This is the machine-managed progress truth; `workflow-state.py` reads it, and the Issue checklist mirrors it. See `dev-workflow-base` skill (`references/state-schema.md`). Do not add derived fields.

### 4c. Bind this session to the Story

Bind so dev-workflow hooks track only this work during implementation (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

```bash
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/story/{story-dir}"
```

### 5. User Review

Present plan to user for approval before proceeding.

## Success Criteria

- [ ] Plan design (Approach/Decisions/Files/Steps) is appended to the Story Issue description
- [ ] Files to change are listed
- [ ] Steps are in dependency order (walking skeleton first)
- [ ] `state.json.steps` is populated, one per Step, matching the Issue's Steps checklist
- [ ] Implementation can start by reading the Story Issue alone (/clear and go)
- [ ] User has approved the plan

## Next Session

After the plan is approved:

**Reference**: the Story's Linear Issue (spec + plan) and `.claude/dev-workflow/story/{story-dir}/state.json` (progress)

**Next phase**: Implementation

Read the Issue, then implement. Mark `state.json.steps[].done` as each step completes (and best-effort tick the Issue's Steps checklist). Navigation/resumption is driven by `state.json` via `dev-workflow-resume-work`.
