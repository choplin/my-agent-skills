---
name: dev-workflow-handoff
description: Generate handoff prompt for seamless session continuation. Use before /clear to preserve context across sessions.
allowed-tools: Read, Glob, Grep, Bash, AskUserQuestion
user-invocable: true
---

# Handoff

Generate a copy-pasteable prompt that enables seamless work continuation in a new session.

**Flow**: `/dev-workflow-handoff` → copy prompt → `/clear` → paste prompt → `/dev-workflow-resume-work` launches with context

## Tool Usage Constraints

- **Bash**: ONLY for `git branch --show-current`. No other use.
- **Read-only**: This skill does not modify any files.

## Process

### Phase 1: Work Unit Discovery

Discover the repo's **Story** work units by running the state evaluator (Phase 2/3
use it too) — each is a `story/` directory with a `state.json`. An Epic is a Linear
Project; hand off an Epic by referencing its Project (a handoff is normally of the
active Story).

(Task-level work runs outside dev-workflow — hand it off through its own plan file, not here.)

If no work units are found, output:

```
Active な作業はありません。引き継ぎプロンプトを生成するには、作業中のwork unitが必要です。
```

Then stop.

### Phase 2: Work Unit Selection

Run `python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"` (also used in Phase 3).

**If exactly one work unit found**: Use it directly, no user interaction needed.

**If multiple work units found**: Present all discovered work units to the user with `AskUserQuestion` and let them select which one to hand off. Default the selection to the `active` unit (`active_path`) when this session is bound to one; otherwise leave the default unset. handoff does not bind — the receiving session rebinds via `dev-workflow-resume-work`.

Display format for each option:
- Label: directory name (e.g., `add-auth`)
- Description: Type (Epic/Story) + brief status indicator

### Phase 3: State Snapshot

Run the state evaluator and read the entry for the selected work unit:

```
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"
```

Each entry provides everything needed for the handoff prompt: `level` (Epic/Story), `state` (derived category), `progress` (`{done, total}`), `review.phase`, `branch`, and `next_action`. The current git branch is in the top-level `current_branch`.

The state-category priority order, legacy-value mappings, and progress-counting rules live in `dev-workflow-base` skill (`references/state-schema.md`) and the script — do not restate or recompute them here.

### Phase 4: Session Notes

Ask the user with `AskUserQuestion`:

> "Session notes to include in the handoff prompt? (e.g., discoveries, gotchas, tips for next session)"

Options:
1. **Skip** - No additional notes needed
2. **Add notes** - I have context to pass along

If the user selects "Add notes", they will provide free-text input. Include it in the generated prompt.

### Phase 5: Prompt Generation

Generate the handoff prompt and output it in a fenced code block that the user can copy.

#### Determine the resume target

The argument for `/dev-workflow-resume-work` is the **Story directory** (the one
holding `state.json`), e.g. `.claude/dev-workflow/story/{story-dir}`. resume-work
binds to it, loads `state.json`, and reads the backing Linear Issue
(`linear_issue_id`) for authored context. For an Epic handoff, pass the Linear
Project reference instead.

#### Output Format

Output the following, with the code block clearly marked for copying:

````
以下のプロンプトをコピーして、`/clear` 後に貼り付けてください:
````

Then output the prompt inside a fenced code block:

```
/resume-work {story-dir path (or Linear Project ref for an Epic)}

## Previous Session Context
- **Type**: {Epic|Story}
- **State**: {state category}
- **Progress**: {done}/{total} steps completed
- **Branch**: {branch name} (current: {current git branch})
- **Linear**: {linear_issue_id}
{if review phase exists:}
- **Review Phase**: {phase value}

## Session Notes
{user's session notes, or omit this section entirely if skipped}
```

**Rules for the generated prompt**:
- Omit the `**Progress**` line if `state.json` has no steps
- Omit the `**Branch**` line if `state.json.branch` is null
- Omit the `**Review Phase**` line if no `review.md` exists
- Omit the `## Session Notes` section entirely if user skipped notes
- Keep the prompt minimal — `dev-workflow-resume-work` handles detailed state analysis

## Success Criteria

- [ ] All work units under `.claude/dev-workflow/` are discovered
- [ ] State category is correctly determined using the priority table
- [ ] Generated prompt contains the correct document path
- [ ] Generated prompt is inside a code block ready for copy-paste
- [ ] Session notes are included only when provided by the user
- [ ] The generated prompt, when pasted, correctly triggers `/dev-workflow-resume-work` with context
