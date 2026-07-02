---
name: dev-workflow-resume-work
description: Use this skill to resume work on an existing Epic or Story. Triggers on phrases like "resume work", "continue previous work", "pick up where I left off", "what was I working on", or when user wants to continue existing development work. Should NOT trigger for starting new tasks (use kickoff), Task-level work that left dev-workflow (resume it via goal-loop/exec-plan or its own plan file), or for discussion continuity without implementation artifacts.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Skill, Bash
user-invocable: true
---

# Resume Work

Resume work on an existing Epic or Story by evaluating current state and identifying the appropriate resumption point. (Task-level work runs outside dev-workflow — resume it through `goal-loop` / `exec-plan` or its own plan file.)

## Core Rule: Skill Dispatch

**After analysis and user confirmation, you MUST invoke the appropriate skill via the `Skill` tool.** Do NOT replicate skill behavior manually.

| State | Action | Dispatch |
|-------|--------|----------|
| `spec_only` | Create implementation plan | `Skill(skill: "dev-workflow-create-plan")` |
| `planned` | Begin implementation from step 1 | _(No skill — see Phase 8: Implementation Handoff)_ |
| `in_progress` | Continue from last completed step | _(No skill — see Phase 8: Implementation Handoff)_ |
| `potentially_complete` | Run self-review | `Skill(skill: "dev-workflow-self-review")` |
| `in_review` | Resume user review | `Skill(skill: "dev-workflow-user-review")` |
| `review_complete` | Run post-task | `Skill(skill: "dev-workflow-post-task")` |
| `epic_next_story` | Start next Story (Epic) | `Skill(skill: "dev-workflow-create-spec")` (adopt mode on the next Project Issue) |
| `blocked` | Report blockers, suggest resolution | _(depends on blocker)_ |

`epic_next_story` is not emitted by the offline script (it only evaluates Stories); when resuming an **Epic**, compute the next Story by reading the Linear Project's Issues (see Phase 2).
| Major divergence | Suggest plan update first | `Skill(skill: "dev-workflow-create-plan")` |
| Update spec requested | Update spec | `Skill(skill: "dev-workflow-create-spec")` |
| Update plan requested | Update plan | `Skill(skill: "dev-workflow-create-plan")` |

## Tool Usage Constraints

- **Bash**: ONLY for git branch operations (`git branch --show-current`, `git checkout`, `git status --porcelain`, `git stash`). No other use.

## Process

### Phase 1: Document Discovery

If path is provided as argument:
- Read the specified document directly

If no path provided:
- Discover **Stories** via the state evaluator (each is a `story/` dir with `state.json`)
- Optionally read the repo's **Epics** (Linear Projects, per `linear-start`) when resuming Epic-level work
- Present options to user for selection

**Layout**:
```
.claude/dev-workflow/
  └── story/{yyyy-mm-dd}-{prefix}-{story-name}/
        ├── state.json     ← local execution state (the work unit)
        └── review.md      ← review state (when in review)
```
The Story's authored spec + plan live in its **Linear Issue** (`state.json.linear_issue_id`); an Epic is a **Linear Project**. There are no local `spec.md`/`plan.md`/`epic.md`.

**Directory naming**: Directories are prefixed with creation date (`yyyy-mm-dd`) and Story directories match the branch name (with `/` replaced by `-`).

### Phase 2: Load state + authored context (boundary read)

For the selected Story, load:
- **`state.json`** (local): `title`, `branch`, `linear_issue_id`, `criteria`, `steps` (progress).
- **Review**: `review.md` phase/items (when it exists).
- **Authored context from the Linear Issue** (`linear_issue_id`) — this is the once-per-session boundary read that recovers the "why": Why/What, Requirements, Acceptance Criteria, the plan's Approach/Decisions/Files/Steps. Do **not** rebuild `state.json` from it (that would overwrite live progress — see `dev-workflow-base` skill (`references/state-schema.md`) § Linear backing).

For an Epic, read its Linear Project's Issues to find the next Story.

If Linear is unavailable, proceed with `state.json` alone (progress is intact); note that authored context could not be loaded.

### Phase 3: State Evaluation

Run the state evaluator and use its output — do not re-derive state by hand:

```
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"
```

This returns every work unit's derived `state`, `progress`, `review`, and `next_action` in `work_units[]`. The state-category priority order, legacy-value mappings, and progress-counting rules are defined once in `dev-workflow-base` skill (`references/state-schema.md`) and implemented by the script.

resume-work is the skill that **establishes** the session binding, so do not rely on `active`/`active_path` to pre-exist (a fresh session is unbound). Select the unit to resume from: the path passed as argument if given; otherwise the unit the user selected in Phase 1. `matches_current_branch` is a useful hint when presenting candidates, but the user's choice governs.

Then cross-check against reality (the script reads documents, not the working tree):
1. Confirm referenced files actually exist / changed
2. Run verification commands if criteria define them

**Bind this session** to the selected unit so dev-workflow hooks track only this work (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

```bash
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set "<selected-unit-dir>"
```

### Phase 4: Gap Analysis

Compare plan with actual state:

| Check | Detection Method |
|-------|------------------|
| Unimplemented items | Plan steps marked as pending vs actual code |
| Divergence from plan | Implemented but not in plan |
| Incomplete implementations | Partial code, TODO comments |
| Failed tests | Run tests if test commands defined |

Output gap summary:
- What's done vs what's planned
- Unexpected changes
- Potential issues

### Phase 5: Resumption Point Decision

Based on state and gaps, determine the recommended action from the **Core Rule** dispatch table above.

**Workflow navigation**: post-work sequencing is driven by `state.json` via the state evaluator's `next_action` (not by a plan document section). Use it to:
- Include post-work instructions in the recommendation (e.g., "After completing remaining steps, invoke self-review")
- Confirm the recommended action aligns with the workflow sequence

### Phase 6: Report and Propose

Output structured report:

```markdown
## Resume Work Report

### Document Summary
- **Type**: [Epic/Story]
- **Linear**: [Story Issue id, or Epic Project ref]
- **State dir**: [`.claude/dev-workflow/story/{story-dir}` or N/A]
- **Branch**: [state.json.branch] (current: [current git branch])

### Context
**Why**: [Brief summary of motivation]
**What**: [Brief summary of target]

### Progress Assessment

| Step | Status | Notes |
|------|--------|-------|
| 1. [description] | ✅ Done | |
| 2. [description] | 🔄 In Progress | [partial details] |
| 3. [description] | ⬜ Pending | |

### Review Status (if review.md exists)
- **Phase**: [REVIEWING / LGTM]
- **Items**: [N OPEN, N APPROACH PROPOSED, N APPROACH AGREED, N IMPLEMENTING, N RESOLVED, N SKIPPED]

### Gap Analysis
[Summary of differences between plan and current state]

- **On track**: [items proceeding as planned]
- **Divergence**: [items that differ from plan]
- **Issues**: [problems detected]

### Recommended Action
**State**: `[evaluated state from Phase 3]`
**Action**: [description of recommended action]
**Invoke**: `Skill(skill: "dev-workflow:[skill-name]")` or "Begin/continue implementation (no skill — see Phase 8)"
**Post-work**: [instructions from Workflow Context, e.g., "After all steps complete, invoke self-review → user-review → commit → post-task"]

Options:
1. [Primary recommendation] (Recommended)
2. [Alternative action]
3. [Update plan first, then continue]
```

### Phase 7: Branch Checkout

If `state.json.branch` is set:

1. **Check current branch**: Run `git branch --show-current`
2. **Already on correct branch**: If current branch matches `state.json.branch`, report "Already on branch {name}" and skip
3. **Different branch**: If on a different branch:
   - Check for uncommitted changes with `git status --porcelain`
   - If uncommitted changes exist, present options:
     - Stash changes and switch (`git stash && git checkout {branch}`)
     - Stay on current branch
     - Commit first before switching
   - If clean, ask user: "Switch to {branch-name}?"
4. **Execute only after user approval**: Run `git checkout {branch-name}`

If `state.json.branch` is null, skip this phase.

### Phase 8: Dispatch

After user confirms the recommended action, **dispatch according to the Core Rule table at the top of this document**.

For states with a Skill dispatch: invoke it via the `Skill` tool immediately. Do NOT replicate the skill's behavior manually.

#### Implementation Handoff (`planned` / `in_progress`)

When the state is `planned` or `in_progress`, there is no dedicated implementation skill. Instead:

1. **Read the Story Issue**: load the authored spec + plan (Approach/Files/Steps) from the Linear Issue (`state.json.linear_issue_id`); load progress from `state.json`
2. **Identify resumption point**: from `state.json.steps`, find the first step with `done: false`
3. **Begin/continue implementation**: follow the plan steps sequentially
4. **Track progress**: set each `state.json.steps[].done` to `true` as it completes, and best-effort tick the matching item in the Issue's Steps checklist (fire-and-forget; a failed Linear write never blocks)
5. **After all steps complete**: Invoke `Skill(skill: "dev-workflow-self-review")` — this MUST NOT be skipped

##### Plan Mode Context Preservation

If you use EnterPlanMode during implementation, add a `## dev-workflow Context` block to the Claude Code plan file. Use the template in `dev-workflow-base` skill (`references/plan-mode-context.md`) with these values:

- **Active skill**: resume-work (Implementation Handoff)
- **Work level**: Story
- **Documents**: the Story's Linear Issue (spec + plan) + `.claude/dev-workflow/story/{story-dir}/state.json`
- **After This Plan Completes**: continue remaining steps, updating `state.json.steps`; after all steps complete, invoke `dev-workflow-self-review` skill.

## Anti-Patterns

### Avoid Starting Fresh

If documents exist, DO NOT:
- Ask user to re-explain their requirements
- Create new documents without acknowledging existing ones
- Ignore progress already made

### Avoid Skipping Skill Dispatch

After state evaluation, DO NOT:
- Start implementing without invoking the target skill (e.g., jumping to code review without invoking `dev-workflow-self-review`)
- Manually replicate a skill's behavior instead of invoking it via `Skill` tool
- Skip `dev-workflow-self-review` after implementation completes — this breaks the workflow chain

### Avoid Assumptions

When gap analysis shows ambiguity:
- Report findings clearly
- Ask user for clarification
- Do not assume which divergence is "correct"

## Success Criteria

- [ ] Existing documents are discovered or specified path is validated
- [ ] Document content is correctly parsed (Type, Spec, Plan, Progress)
- [ ] Actual state is evaluated against plan
- [ ] Gap analysis clearly identifies differences
- [ ] Recommended action is appropriate for the state
- [ ] User approves action before execution
- [ ] Correct skill is invoked based on user selection
