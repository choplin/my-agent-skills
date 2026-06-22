# Plan: {plan-name}

**Related spec**: `.claude/dev-workflow/story/{story-dir}/spec.md`
**Branch**: `{prefix}/{story-name}` (from spec)

## Workflow Context

**Current phase**: Implementation
**Work level**: Story

### During Implementation
- Follow Steps sequentially
- Update `## Progress` section as each step completes (`- [ ]` → `- [x]`)
- Refer to Spec's Acceptance Criteria as the source of truth for verification

### After All Steps Complete
1. Invoke `dev-workflow:self-review` skill — verifies against acceptance criteria in spec
2. Invoke `dev-workflow:user-review` skill — presents results and collects user feedback
3. After user LGTM: commit changes
4. Invoke `dev-workflow:post-task` skill — capture knowledge

### If Session Clears
- Use `/resume-work` to evaluate progress and resume from the correct point
- Or read this plan and the spec, then continue from the last completed step

## Approach

{Overview of the implementation approach}

## Files to Change

| File | Change Type |
|------|-------------|
| `path/to/file` | Create/Update/Delete |

## Implementation Steps

### Step 1: {Step name}
- {Detailed tasks}

### Step 2: {Step name}
- {Detailed tasks}

## Progress

- [ ] Step 1: {Step name}
- [ ] Step 2: {Step name}

## Decision Log

- {Date}: {Decision} - {Rationale}

## Discoveries

(Record during implementation)
