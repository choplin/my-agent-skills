---
name: dev-workflow-workflow-status
description: Show overview of all active Epics and Stories with their current status. Use this to get a bird's-eye view of development progress before resuming work. Triggers on "/workflow-status", "show status", "what's in progress", "overview of work". Should NOT trigger for resuming a specific task (use resume-work) or starting new work (use kickoff).
allowed-tools: Read, Glob, Grep
user-invocable: true
---

# Status Overview

Display a summary of all active Epics and Stories under `.claude/dev-workflow/`.

## Tool Usage Constraints

- **Read-only**: This skill only reads files. No modifications, no Bash commands.

## Process

### Phase 1: Run the State Evaluator

```
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"
```

This returns all work units (epics, stories, **and tasks**) with their derived `state`, `progress`, `review`, and `level`. `--session` marks the unit this session is bound to as `active` (if any); workflow-status only reports — it does not bind. The state-category and progress rules live in `dev-workflow-base` skill (`references/state-schema.md`) and the script — do not recompute them.

If `work_units` is empty, output:

```
Active な作業はありません。
`/dev-workflow-kickoff` で新しい作業を開始できます。
```

Then stop.

### Phase 2: Map state to a display label

Use each unit's `state` (and `progress` for in_progress) to pick a human label:

| `state` | Display status |
|---------|----------------|
| `review_complete` | Done |
| `in_review` | Review: In Progress |
| `potentially_complete` | Implementation Complete |
| `in_progress` | In Progress ({done}/{total} steps) |
| `planned` | Planned |
| `spec_only` | Spec Created |
| `epic_next_story` | {Done}/{Total} Stories Done (from epic.md Stories table) |
| `blocked` | Blocked |

**Epic-Story association**: For each story/task, read each `epic.md` Stories table; if the unit name appears there, associate it with that epic, else independent (Epic = `-`).

### Phase 3: Display

Output the status overview in this format:

```markdown
## Epics

| Epic | Status |
|------|--------|
| {epic-name} | {done}/{total} Stories Done |

## Stories & Tasks

| Work Unit | Level | Epic | Status |
|-----------|-------|------|--------|
| {unit-name} | Story/Task | {epic-name or -} | {status} |
```

**Display rules**:
- Sort Epics alphabetically by name; sort Stories & Tasks alphabetically by name
- Omit a section entirely if it has no entries
- Names are the directory names from each unit's `path` (e.g. `{yyyy-mm-dd}-{prefix}-{story-name}`, `{yyyy-mm-dd}-{epic-name}`)

## Success Criteria

- [ ] All existing epics, stories, **and tasks** under `.claude/dev-workflow/` are discovered (via the state evaluator)
- [ ] Each item's status comes from the script's derived `state` (no hand-recomputation)
- [ ] Output is displayed as a clear, readable table
- [ ] When no work exists, a helpful empty-state message is shown
