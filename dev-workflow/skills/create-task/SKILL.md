---
name: create-task
description: Internal skill called by kickoff after Task assessment. Creates a task-level plan with full Why/What context for potential Story promotion. Should NOT be invoked directly by users.
allowed-tools: Read, Write, Glob, Grep
user-invocable: false
---

# Create Task Plan

Create a task-level implementation plan with full Why/What context, enabling Story promotion without information loss.

## Purpose

Structure the Why/What information from kickoff interview into Claude Code plan file format. This ensures that if the Task is later promoted to Story, all context is preserved in the plan file.

**Key insight**: The plan file is the ONLY surviving context after session clear. If Why/What is omitted (as Plan mode defaults to How-focused plans), Story promotion loses critical information.

## Prerequisites

- kickoff has completed interview and determined Task level
- Why/What information is available in session history

## Process

### Step 1: Receive Context

The kickoff skill has already confirmed:
- **Why**: Background, motivation, problem to solve
- **What**: Implementation target + completion criteria

This information is available in the session history. Do NOT re-interview.

### Step 2: Investigate Implementation Approach

Gather information for the How section:
- Use Glob/Grep to find relevant files
- Use Read to understand existing code structure
- Identify files that need changes
- Determine implementation pattern

### Step 3: Write Plan to Claude Code Plan File

Write to the plan file with this structure:

```markdown
# Plan: [Task Name]

## Related Files

- **Workflow concepts**: `dev-workflow/docs/workflow-concepts.md`
- **Spec**: `.claude/dev-workflow/story/{story-dir}/spec.md` (if promoted from Task)
- **Epic**: `.claude/dev-workflow/epic/{epic-dir}/epic.md` (if part of an Epic)

## Workflow Context

**Current phase**: Implementation
**Work level**: Task

### After All Steps Complete
1. Run tests to confirm no regressions
2. Invoke `dev-workflow:self-review` (it will verify Completion Criteria and code quality)
3. After review completes, commit changes

### If Complexity Grows
If implementation reveals unexpected complexity, promote to Story:
- Invoke `dev-workflow:create-spec` with Why/What from this plan
- See `dev-workflow/docs/workflow-concepts.md` for promotion flow

### If Session Clears
- Re-read this plan and continue implementation
- Or use `/resume-work`

## Why (Background & Purpose)

[User-confirmed background and motivation from kickoff interview]

**Problem being solved**: [Specific problem statement]
**Why now**: [Urgency or trigger for this task]

## What (Implementation Target)

[User-confirmed implementation target from kickoff interview]

### Completion Criteria

- [ ] [Criterion 1 - specific, measurable]
- [ ] [Criterion 2 - specific, measurable]

## How (Implementation Steps)

### Files to Change

| File | Change |
|------|--------|
| `path/to/file` | [Description of change] |

### Steps

1. [Step with concrete action]
2. [Step with concrete action]

## Verification

[How to verify completion criteria are met]
- [ ] [Verification step 1]
- [ ] [Verification step 2]
```

### Step 4: Request Approval

Call ExitPlanMode to request user approval of the plan.

## Machine State (state.json)

A Task does not get a `.claude/dev-workflow/task/{task-dir}/` directory until review time. During implementation the Claude Code plan file is the source of truth; the script falls back to it. The Task's `state.json` is created together with `review.md` when self-review runs (see `dev-workflow:self-review` and `references/state-schema.md`). No `state.json` is written by this skill.

## Critical: No AI Filling

**Every piece of information in Why/What sections must come from the kickoff interview.**

**OK (information consolidation):**
- Summarizing multiple user statements into one sentence
- Unifying technical terms ("slow" → "high response time")
- Making vague criteria verifiable ("works" → "existing tests pass")

**NG (inference/addition):**
- Adding reasons user didn't mention ("probably because...")
- Adding completion criteria user didn't specify ("should also need...")
- Example: User says "change button color" → Adding "for accessibility improvement"
  as reason is NG (actual reason might be design consistency)

The How section can be derived from code investigation, but Why/What must be user-confirmed.

## Success Criteria

- [ ] Why section contains specific problem/motivation from kickoff interview
- [ ] What section contains measurable completion criteria from kickoff interview
- [ ] How section is based on actual code investigation (not generic steps)
- [ ] Plan file is self-contained (can be understood without session history)
- [ ] All Why/What information is preserved for potential Story promotion
- [ ] Workflow Context section includes post-implementation instructions and promotion guidance

## Trigger

This skill is invoked ONLY by kickoff after Task assessment.

**Do NOT invoke directly** - if user calls this skill directly, redirect to kickoff first.

## Next Session

After plan is approved via ExitPlanMode:

**Reference**: Plan file (Claude Code's plan feature)
**Next phase**: Implementation

User can resume by loading the plan and continuing implementation.

### Plan Mode During Task Implementation

If EnterPlanMode is used during task implementation, add a `## dev-workflow Context` block to the plan file. Use the template in `references/plan-mode-context.md` with these values:

- **Active skill**: create-task (Implementation)
- **Work level**: Task
- **Documents**: Plan (Claude Code plan file)
- **After This Plan Completes**: Run tests to confirm no regressions; invoke `dev-workflow:self-review` (verifies Completion Criteria and code quality); after review completes, commit changes.
