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

### Phase 1: Document Discovery

Scan for all existing work documents:

1. **Epics**: Glob for `.claude/dev-workflow/epic/*/epic.md`
2. **Stories**: Glob for `.claude/dev-workflow/story/*/spec.md`

(Task-level work runs outside dev-workflow — hand it off through its own plan file, not here.)

If no documents are found, output:

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

#### Determine Document Path

The path argument for `/dev-workflow-resume-work` should be the most advanced document:
- If `plan.md` exists: use path to `plan.md`
- Else if `spec.md` exists: use path to `spec.md`
- Else if `epic.md` exists: use path to `epic.md`

#### Output Format

Output the following, with the code block clearly marked for copying:

````
以下のプロンプトをコピーして、`/clear` 後に貼り付けてください:
````

Then output the prompt inside a fenced code block:

```
/resume-work {document-path}

## Previous Session Context
- **Type**: {Epic|Story}
- **State**: {state category}
- **Progress**: {done}/{total} steps completed
- **Branch**: {spec branch name} (current: {current git branch})
{if review phase exists:}
- **Review Phase**: {phase value}

## Session Notes
{user's session notes, or omit this section entirely if skipped}
```

**Rules for the generated prompt**:
- Omit the `**Progress**` line if no `plan.md` exists
- Omit the `**Branch**` line if no Branch section in spec
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
