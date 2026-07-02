# Plan Mode Context Preservation

## Problem

When Claude Code autonomously enters Plan Mode (EnterPlanMode) during dev-workflow skill execution, the generated plan file (`.claude/plans/`) contains only implementation steps (How). The dev-workflow context — which skill is active, what phase we're in, what to do after the plan completes — is lost.

This causes Claude Code to lose its place in the workflow after executing the plan, skipping post-implementation steps like self-review.

**Note**: This concerns Claude Code's built-in `.claude/plans/` files. The dev-workflow plan itself lives in the Story's Linear Issue and its progress in `state.json`; this block re-anchors an ad-hoc Plan-Mode file back into that workflow.

## Rule

When using EnterPlanMode during any dev-workflow skill execution, include a `## dev-workflow Context` block in the plan file. This block tells the next session (or post-plan execution) where it is in the workflow and what to do next.

## Template

```markdown
## dev-workflow Context

**Active skill**: {skill-name} ({phase-description})
**Phase**: {Implementation | Self-Review | User-Review}
**Work level**: Story
**Documents**:
- Story Issue: {linear_issue_id or N/A} (spec + plan)
- State: `.claude/dev-workflow/story/{story-dir}/state.json`
- Review: {review path or N/A}

### After This Plan Completes
{Specific next action — e.g., continue remaining steps, re-run self-review, resolve next review item}
```

## Field Descriptions

| Field | Description |
|-------|-------------|
| **Active skill** | The dev-workflow skill currently executing (e.g., `resume-work (Implementation Handoff)`, `self-review (Self-Correct)`) |
| **Phase** | The workflow phase: Implementation, Self-Review, or User-Review |
| **Work level** | Story — dev-workflow's in-flow level (Task-level work runs outside dev-workflow) |
| **Documents** | Paths to relevant dev-workflow documents for re-loading context |
| **After This Plan Completes** | The specific action to take when the plan's steps are done. Must be concrete and actionable without session history |
