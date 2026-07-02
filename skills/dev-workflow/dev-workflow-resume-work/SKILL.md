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
| `spec_only` | Create implementation plan | `Skill(skill: "create-plan")` |
| `planned` | Begin implementation from step 1 | _(No skill — see Phase 8: Implementation Handoff)_ |
| `in_progress` | Continue from last completed step | _(No skill — see Phase 8: Implementation Handoff)_ |
| `potentially_complete` | Run self-review | `Skill(skill: "self-review")` |
| `in_review` | Resume user review | `Skill(skill: "user-review")` |
| `review_complete` | Run post-task | `Skill(skill: "post-task")` |
| `epic_next_story` | Start next Story | `Skill(skill: "create-spec")` |
| `blocked` | Report blockers, suggest resolution | _(depends on blocker)_ |
| Major divergence | Suggest plan update first | `Skill(skill: "create-plan")` |
| Update spec requested | Update spec | `Skill(skill: "create-spec")` |
| Update plan requested | Update plan | `Skill(skill: "create-plan")` |

## Tool Usage Constraints

- **Bash**: ONLY for git branch operations (`git branch --show-current`, `git checkout`, `git status --porcelain`, `git stash`). No other use.

## Process

### Phase 1: Document Discovery

If path is provided as argument:
- Read the specified document directly

If no path provided:
- Scan `.claude/dev-workflow/` for existing documents
- List found documents with basic metadata
- Present options to user for selection

**Scan pattern**:
```
.claude/dev-workflow/
  ├── story/{yyyy-mm-dd}-{prefix}-{story-name}/
  │     ├── spec.md
  │     ├── plan.md
  │     └── review.md
  └── epic/{yyyy-mm-dd}-{epic-name}/
        └── epic.md
```

**Directory naming**: Directories are prefixed with creation date (`yyyy-mm-dd`) and Story directories match the branch name (with `/` replaced by `-`).

### Phase 2: Document Loading

Read the selected document(s) and extract:
- **Type**: Epic / Story
- **Spec path**: If exists (Story/Epic only)
- **Plan path**: If exists (Story: `plan.md` in dev-workflow dir)
- **Review path**: If exists
- **Review Phase**: Phase value from review.md (REVIEWING / LGTM)
- **Review Items**: Count of OPEN, APPROACH PROPOSED, APPROACH AGREED, IMPLEMENTING, RESOLVED, and SKIPPED items
- **Branch**: Name and Base from spec.md `## Branch` section (if exists)
- **Why**: Background and motivation
- **What**: Implementation target and success criteria
- **Progress**: Current implementation status
- **Workflow Context**: Current phase, work level, post-work instructions (if exists in plan)

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

**Workflow Context integration**: If the plan document contains a `## Workflow Context` section, use it to:
- Include post-work instructions in the recommendation (e.g., "After completing remaining steps, invoke self-review")
- Confirm the recommended action aligns with the workflow sequence

### Phase 6: Report and Propose

Output structured report:

```markdown
## Resume Work Report

### Document Summary
- **Type**: [Epic/Story]
- **Spec**: [path or N/A]
- **Plan**: [path or N/A]
- **Branch**: [spec branch name] (current: [current git branch])

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

If spec.md contains a `## Branch` section:

1. **Check current branch**: Run `git branch --show-current`
2. **Already on correct branch**: If current branch matches spec branch name, report "Already on branch {name}" and skip
3. **Different branch**: If on a different branch:
   - Check for uncommitted changes with `git status --porcelain`
   - If uncommitted changes exist, present options:
     - Stash changes and switch (`git stash && git checkout {branch}`)
     - Stay on current branch
     - Commit first before switching
   - If clean, ask user: "Switch to {branch-name}?"
4. **Execute only after user approval**: Run `git checkout {branch-name}`

If no Branch section in spec, skip this phase.

### Phase 8: Dispatch

After user confirms the recommended action, **dispatch according to the Core Rule table at the top of this document**.

For states with a Skill dispatch: invoke it via the `Skill` tool immediately. Do NOT replicate the skill's behavior manually.

#### Implementation Handoff (`planned` / `in_progress`)

When the state is `planned` or `in_progress`, there is no dedicated implementation skill. Instead:

1. **Read documents**: Load both spec.md and plan.md fully into context
2. **Locate Workflow Context**: Find the `## Workflow Context` section in plan.md
3. **Identify resumption point**: From `## Progress`, find the first unchecked `- [ ]` step
4. **Begin/continue implementation**: Follow the plan steps sequentially
5. **Track progress**: Update `## Progress` as each step completes (`- [ ]` → `- [x]`)
6. **After all steps complete**: Invoke `Skill(skill: "self-review")` — this is specified in plan's Workflow Context and MUST NOT be skipped

##### Plan Mode Context Preservation

If you use EnterPlanMode during implementation, add a `## dev-workflow Context` block to the plan file. Use the template in `dev-workflow-base` skill (`references/plan-mode-context.md`) with these values:

- **Active skill**: resume-work (Implementation Handoff)
- **Work level**: Story
- **Documents**: Spec + Plan (`.claude/dev-workflow/story/{story-dir}/`)
- **After This Plan Completes**: Continue remaining plan.md steps, updating Progress; after all steps complete, invoke `dev-workflow-self-review` skill.

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
