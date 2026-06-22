# dev-workflow

Development workflow management for Claude Code.

## Overview

A plugin that systematizes development workflows with Claude Code. Supports workflow branching based on task scale and work continuation across sessions.

## Workflow Levels

| Level | Characteristics | Recommended Approach |
|-------|-----------------|---------------------|
| **Task** | 1-2 hours, few files | Direct implementation with Claude Code Plan |
| **Story** | Multiple steps, hours to days | Create spec/plan documents then implement |
| **Epic** | Multiple stories, weeks to months | Manage stories with epic document |

## Skills

| Skill | Description |
|-------|-------------|
| `kickoff` | Explore user needs through dialogue and route to appropriate workflow |
| `create-task` | Create task-level plan with full Why/What context |
| `create-epic` | Create epic document (manage multiple stories) |
| `create-spec` | Create spec document (AI self-reviewable acceptance criteria) |
| `create-plan` | Create implementation plan document (self-contained) |
| `resume-work` | Resume existing work by evaluating progress and identifying resumption point |
| `handoff` | Generate handoff prompt for seamless session continuation |
| `self-review` | Self-review based on acceptance criteria |
| `user-review` | Facilitate structured user review with appropriate response patterns |
| `post-task` | Capture knowledge after task completion |

## Hooks

Two command hooks (in `hooks/`) move workflow adherence from prompt instructions to mechanism. Both delegate state to `scripts/workflow-state.py` and are best-effort — any failure leaves the session untouched, and they stay silent when there is no active dev-workflow work.

| Hook | Event | Behavior |
|------|-------|----------|
| `session-start.py` | SessionStart | Injects a short summary of the active work unit (state, progress, next action) so a fresh session resumes with context — replacing the handoff copy-paste ritual for the common case. |
| `stop-gate.py` | Stop | When the active unit is `potentially_complete` (all plan steps done, no review started), reminds you to run `/dev-workflow:self-review`. Blocks at most twice in a row, then yields — a reminder, not a loop engine. |

> Hooks load at session start; after installing or changing them, restart Claude Code. See `docs/2026-06-22-hooks-design.md` for the design.

## Dependencies

This plugin depends on the **`discuss-toolkit`** plugin:

- `kickoff` and `user-review` use `discuss-toolkit:dig` as a base skill to clarify ambiguous intent before proceeding.

Install `discuss-toolkit` alongside this plugin. If it is not available, `kickoff` (the entry point) and the Complex-feedback path of `user-review` cannot run their interview step.

## Templates

| File | Description |
|------|-------------|
| `references/epic-template.md` | Epic document template |
| `references/spec-template.md` | Spec document template |
| `references/plan-template.md` | Plan document template |

## Typical Workflow (Story Level)

1. Explore user needs with `kickoff`
2. Create spec document with `create-spec`
3. Create implementation plan with `create-plan`
4. (Session can be cleared)
5. Load plan document and implement
6. Verify acceptance criteria with `self-review`
7. Obtain user approval with `user-review`
8. Commit and complete with `post-task`

## Installation

Add to your `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/dev-workflow"
  ]
}
```
