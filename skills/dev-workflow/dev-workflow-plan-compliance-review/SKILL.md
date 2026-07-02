---
name: dev-workflow-plan-compliance-review
description: Verify that an implementation completes all planned changes in a dev-workflow plan — every entry in the Files to Change table and every implementation Step. Use during self-review to check plan completeness. This is the portable review procedure; under Claude Code it is also wrapped by the dev-workflow:plan-compliance-reviewer subagent for isolated execution.
---

# Plan Compliance Review

Verify implementation completeness against the plan document. Runs inline on any
agent; under Claude Code it is also dispatched as the
`dev-workflow:plan-compliance-reviewer` subagent (a thin wrapper around this
skill) for an isolated context.

## Input

- `plan`: the plan content (Files to Change table + Steps) as text. self-review
  supplies it from the Story's Linear Issue; this skill stays Linear-agnostic — it
  checks the plan it is given, not a file path.

## Process

### 1. Read the supplied plan

From the supplied `plan` content, extract:
- **Files to Change** table (file paths, actions, descriptions)
- **Steps** (implementation steps)

### 2. Verify Files to Change

For each entry in "Files to Change" table:

| Action | Verification Method |
|--------|---------------------|
| Create | Glob to confirm file exists, Read to verify content matches description |
| Modify | Read file, verify described changes are present |
| Delete | Glob to confirm file does NOT exist |

### 3. Verify Steps

For each step in the plan:
- Check if the step's objective is achieved
- Look for evidence of completion (files, code patterns, test results)

### 4. Determine Result

| Status | Condition |
|--------|-----------|
| COMPLETE | Evidence confirms the change/step is done |
| INCOMPLETE | Change/step is not done or partially done |
| NEEDS REVIEW | Cannot be verified programmatically |

## Output Format

Return results in this exact format:

```markdown
## Plan Compliance Review

### Files to Change

| File | Action | Status | Evidence |
|------|--------|--------|----------|
| {path} | Create | COMPLETE | File exists with expected content |
| {path} | Modify | INCOMPLETE | {what's missing} |

### Steps

| Step | Description | Status | Evidence |
|------|-------------|--------|----------|
| 1 | {step description} | COMPLETE | {evidence of completion} |
| 2 | {step description} | INCOMPLETE | {what remains to be done} |

### Summary

- COMPLETE: X
- INCOMPLETE: X
- NEEDS REVIEW: X
```

## Important Notes

- **File-focused**: Prioritize verifying file changes over abstract steps
- **Evidence-based**: Every COMPLETE must include evidence
- **Actionable INCOMPLETEs**: Describe what remains to be done
- **No modifications**: Only read and report, never fix issues
