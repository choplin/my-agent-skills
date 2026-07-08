---
name: dev-workflow-workflow-status
description: Show overview of all active Epics and Stories with their current status. Use this to get a bird's-eye view of development progress before resuming work. Triggers on "/workflow-status", "show status", "what's in progress", "overview of work". Should NOT trigger for resuming a specific task (use resume-work) or starting new work (use kickoff).
allowed-tools: Read, Glob, Grep, Bash
user-invocable: true
---

# Status Overview

Display a summary of the repo's Stories (local `state.json`) and Epics (Linear
Projects). Stories come from the offline evaluator; Epics are read from Linear at
this boundary. If Linear is unavailable, the Epic overview degrades gracefully —
Stories still display.

## Tool Usage Constraints

- **Read-only**: reads local state and Linear. No modifications.
- **Linear**: use whichever Linear MCP server is wired, per the `linear-base` skill.

## Process

### Phase 1: Run the State Evaluator (Stories)

```
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"
```

This returns every **Story** work unit (a directory with `state.json`) with its
derived `state`, `progress`, `review`, `linear_issue_id`, and `active` flag.
`--session` marks the bound unit as `active`; workflow-status only reports — it
does not bind. The state-category and progress rules live in `dev-workflow-base`
skill (`references/state-schema.md`) and the script — do not recompute them.

### Phase 1b: Read the repo's Epics from Linear

Resolve the repo's active Linear Project(s) the way `linear-start` does (Repo
project-label → active Projects). Each Project is an **Epic**; read its Issues and
their statuses to compute the rollup (`{Done}/{Total} Stories`). Associate each
local Story with its Epic by matching `linear_issue_id` to a Project Issue.

- **Linear unavailable / unauthenticated** → skip the Epic section, note
  "Linear 未接続のため Epic 俯瞰は省略" and continue with Stories only.

If there are no Stories **and** no Epics, output:

```
Active な作業はありません。
`/dev-workflow-kickoff` で新しい作業を開始できます。
```

Then stop.

### Phase 2: Map state to a display label

Use each Story's `state` (and `progress` for in_progress) to pick a human label:

| `state` | Display status |
|---------|----------------|
| `review_complete` | Done |
| `in_review` | Review: In Progress |
| `potentially_complete` | Implementation Complete |
| `in_progress` | In Progress ({done}/{total} steps) |
| `planned` | Planned |
| `spec_only` | Spec Created |
| `blocked` | Blocked |

Epic rollup (`{Done}/{Total} Stories`) comes from the Linear read in Phase 1b, not
from the script.

### Phase 3: Display

Output the status overview in this format:

```markdown
## Epics

| Epic | Status |
|------|--------|
| {epic-name} | {done}/{total} Stories Done |

## Stories

| Work Unit | Level | Epic | Status |
|-----------|-------|------|--------|
| {unit-name} | Story | {epic-name or -} | {status} |
```

**Display rules**:
- Sort Epics alphabetically by name; sort Stories alphabetically by name
- Omit a section entirely if it has no entries (e.g. omit Epics when Linear is unavailable)
- Story names are the directory names from each unit's `path` (e.g. `{yyyy-mm-dd}-{prefix}-{story-name}`); Epic names are the Linear Project names

## Success Criteria

- [ ] All local Stories (via the state evaluator) are discovered
- [ ] Epics are read from the repo's Linear Project(s), or the Epic section is gracefully omitted when Linear is unavailable
- [ ] Each Story's status comes from the script's derived `state` (no hand-recomputation)
- [ ] Output is displayed as a clear, readable table
- [ ] When no work exists, a helpful empty-state message is shown
