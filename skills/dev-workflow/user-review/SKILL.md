---
name: user-review
description: Structured user review interaction skill. Presents review summary, classifies user feedback (Minor/Complex/Design Change), and responds appropriately.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
user-invocable: true
---

# User Review

Facilitate structured interaction between AI and user during the review phase. This skill ensures AI responds appropriately to user feedback based on its complexity.

## Purpose

Prevent AI from acting unpredictably during user review by establishing clear interaction patterns:

1. **Present review summary**: Show self-review results and NEEDS REVIEW items
2. **Classify and propose approach**: For each feedback item, classify and propose a concrete approach
3. **Obtain approach agreement**: Discuss the approach with the user and get explicit agreement before implementing
4. **Implement after agreement**: Execute changes only after user agrees to the approach
5. **Obtain explicit approval**: Proceed to post-task only after LGTM

## Problem This Skill Solves

Without this skill, AI behavior during user review is ad-hoc:
- AI implements changes without discussing the approach with the user, causing rework when the approach was wrong
- Rigid batch processing forces users to give all feedback before any implementation starts, which doesn't match the natural "comment → discuss → fix → next" rhythm
- User cannot see or influence the AI's planned approach before code changes happen

These issues cause rework and frustration.

## Item-Level State Machine

Instead of managing phases at the review level, each feedback item has its own lifecycle:

```
OPEN → APPROACH PROPOSED → APPROACH AGREED → IMPLEMENTING → RESOLVED
                                                           → SKIPPED
```

| Status | Meaning |
|--------|---------|
| `OPEN` | Feedback received, not yet analyzed |
| `APPROACH PROPOSED` | AI proposed approach, awaiting user agreement |
| `APPROACH AGREED` | User agreed to approach, ready for implementation |
| `IMPLEMENTING` | Currently being implemented |
| `RESOLVED` | Implementation complete |
| `SKIPPED` | User chose to skip this item |

**Review-level state**: `REVIEWING` (active review) or `LGTM` (approved).

**Mode**: `ITERATIVE` (default) or `BATCH` (opt-in).

| Mode | Default | Trigger | Behavior |
|------|---------|---------|----------|
| **ITERATIVE** | ✓ | Default / "1つずつ" | Implement immediately after each approach agreement, then prompt for next feedback |
| **BATCH** | | "まとめて" / "batch" | Record approach agreements only; implement all at once when user says "以上" |

**Transition signals**:
- **"以上" / "done"**: Iterative — no more feedback (check for unresolved items). Batch — trigger batch implementation.
- **"LGTM"**: Approve and proceed to post-task
- **"まとめて" / "batch"**: Switch to Batch mode
- **"1つずつ" / "iterative"**: Switch to Iterative mode (default)

## Input

- Self-review results (from self-review skill, if available)
- **Story**: Spec document at `.claude/dev-workflow/story/{story-dir}/spec.md`
- **Task (with plan)**: Plan file (path from review.md's `## Related Files`)
- **Task (no plan)**: Git diff of current branch changes

## Process

### 0. Check Review State

Before starting, check for existing review state:

1. Look for `review.md` at:
   - `.claude/dev-workflow/story/{story-dir}/review.md` (Story)
   - `.claude/dev-workflow/task/{task-dir}/review.md` (Task — includes both "with plan" and "no plan")
2. If **review.md exists**, read it and resume based on the normalized Phase (legacy phase and item-status values are normalized per `dev-workflow-base` skill (`references/state-schema.md`); e.g. `COLLECTING FEEDBACK`→`REVIEWING`, `APPROACH RECORDED`→`APPROACH PROPOSED`):
   - `REVIEWING`: Show summary of items and their states — including any items that are `OPEN` or `APPROACH PROPOSED` (re-present their approach for agreement) — then wait for next feedback
   - `LGTM`: Proceed to post-task
3. If **review.md does not exist**, continue to step 1 (normal flow)

Once the work-unit directory is known, **bind this session** to it so dev-workflow hooks track only this work (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

```bash
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set "<work-unit-dir>"
```

### 1. Present Review Summary (Independent Entry Point)

> **Note**: In the normal workflow, self-review creates review.md before invoking handoff. Step 0 detects the existing review.md and resumes from `REVIEWING`, skipping this step entirely. Step 1 serves as an independent entry point for when user-review is invoked directly without prior self-review (e.g., manual invocation, skipping self-review).

If review.md does not exist (Step 0 found nothing):

1. **Create review.md** using `dev-workflow-base` skill (`references/review-init-guide.md`):
   - Follow the guide to determine work level (Story / Task with plan / Task no plan)
   - Resolve metadata (title, paths) according to the work level
   - Use `dev-workflow-base` skill (`references/review-template.md`) to create review.md at the resolved path
   - Self-Review Results: Use SKIPPED row (`| - | Self-review | SKIPPED | Self-review was not performed |`)
   - Set Phase to `REVIEWING`
   - Set Mode to `ITERATIVE`
   - Set Resolved to `0 / 0`
2. **Present** the review summary to the user:

```markdown
## Review Summary

<!-- Story: show Spec path -->
<!-- Task (with plan): show Plan path -->
<!-- Task (no plan): show Branch name -->
**{Spec/Plan/Branch}**: `{path or branch name}`

### Self-Review Results

| # | Criterion | Result |
|---|-----------|--------|
| - | Self-review | SKIPPED |
<!-- Or actual results if self-review was performed -->

### Items Requiring User Review

{List NEEDS REVIEW items with context, or "No self-review results available" if SKIPPED}

### Request

Please review the implementation and provide feedback.
- **LGTM**: Approve and proceed to post-task
- **Feedback**: Point out issues to address
```

### 2. Wait for User Feedback

After presenting the summary, **wait for user input**. Do not proceed autonomously.

### 3. Classify Feedback

When user provides feedback, classify it using the ambiguity test.

**Problem this classification solves**: Without clear classification, AI makes two recurring mistakes:
1. Implements changes prematurely when user intent is unclear (causes rework)
2. Over-asks for clarification on trivial fixes (causes frustration)

This test emerged from analyzing past failures: AI misidentified modification location (WHERE error) or misunderstood modification content (WHAT error). Both must be unambiguous to avoid rework.

**Ambiguity Test** (both must be met for "Minor"):

1. **Where**: Can the modification location be uniquely identified?
   - Pass: "line 42", "function processOrder", "before calling save()"
   - Fail: "error handling code" (multiple locations), "the service" (which part?)

2. **What**: Can the modification content be uniquely determined?
   - Pass: "rename to `result`", "add null check", "change timeout to 5000"
   - Fail: "improve", "fix", "make better", "optimize" (how specifically?)

**Why both conditions are required**: Past experience shows:
- WHERE clear + WHAT vague = wrong fix implemented in right place
- WHERE vague + WHAT clear = right fix implemented in wrong place

Either results in rework. Both must pass for immediate approach recording.

| Classification | Test Result | Action | Rationale |
|----------------|-------------|--------|-----------|
| **LGTM** | N/A | Proceed to post-task (or confirm pending items first) | User explicitly approved |
| **"以上" / "done"** | N/A | Iterative: check for unresolved items. Batch: trigger batch implementation | User finished giving feedback |
| **Mode switch** | N/A | "まとめて" → Batch mode. "1つずつ" → Iterative mode | User changed processing mode |
| **Minor** | Both pass | Propose approach to user | No ambiguity = safe to propose |
| **Complex** | Either fails | dig → propose approach to user | Ambiguity = clarify first |
| **Design Change** | Requires new/changed spec criteria | Propose approach (with spec changes) to user | Cannot implement within current spec |

**Note on PR-imported items**: Items with a `Source` field (imported via `import-pr-comments`) are pre-classified at import time. They follow the same approach-proposal-and-agreement flow as user-provided feedback — no special handling required.

### 4. Handle Each Classification

**Core rule: Do NOT implement any code changes until the user agrees to the proposed approach.**

#### LGTM (Approval)

User signals approval with phrases like "LGTM", "OK", "Looks good", "Approved".

**Action**:
1. If items with Status `APPROACH PROPOSED` or `APPROACH AGREED` exist: Ask user "There are {N} items with pending approaches. Implement them first, or skip and approve as-is?"
   - If implement: Process each pending item (propose/agree/implement as needed)
   - If skip: Continue to step 2
2. Update review.md: Set Phase to `LGTM`
3. Proceed to post-task skill

#### Completion Signal ("以上" / "done" / "完了")

User signals they have finished giving all feedback.

**Action (Iterative mode)**:
1. Check for unresolved items:
   - Items with `APPROACH PROPOSED`: Re-present each approach for agreement
   - Items with `OPEN`: Propose approaches for each
2. If no unresolved items: Present completion summary and wait for LGTM or additional feedback

**Action (Batch mode)**:
1. Check for items needing attention:
   - Items with `APPROACH PROPOSED`: Ask user to agree or skip before proceeding
   - Items with `OPEN`: Propose approaches for each and get agreement
2. Once all actionable items are `APPROACH AGREED`: Proceed to Batch Implementation (Step 5)

#### Minor Feedback

Feedback where both location and content are unambiguous.

**Examples of Minor**:
- "Fix the typo in line 42" (where: line 42, what: fix typo)
- "Change the variable name from `tmp` to `result`" (where: specific variable, what: rename)
- "Add a null check before calling process()" (where: before process(), what: null check)

**Action**:
1. Add Review Item to review.md (Status: OPEN, Classification: Minor)
2. Formulate approach (WHERE + WHAT)
3. Present approach to user:
   ```markdown
   **Item {N}** (Minor): {feedback summary}
   **Approach**: WHERE: {file:location} / WHAT: {specific change}

   Agree? (or suggest changes / "skip")
   ```
4. Update Review Item in review.md: Status → `APPROACH PROPOSED`, fill Approach
5. Wait for user response:
   - **Agreement** ("OK", "やって", "それで", "go ahead"): Update to `APPROACH AGREED`. In Iterative mode → implement immediately (Step 4a). In Batch mode → report "Recorded. Will implement with other items."
   - **Modification**: Revise approach based on feedback, re-present, stay at `APPROACH PROPOSED`
   - **Rejection** ("skip", "やめて"): Update to `SKIPPED`
6. After response handled: Wait for next feedback

##### 4a. Iterative Implementation (within Step 4)

Triggered immediately after approach agreement in Iterative mode:

1. Update Review Item: Status → `IMPLEMENTING`
2. Implement the change according to the agreed Approach
3. Update Review Item: Status → `RESOLVED`, fill Resolution
4. Update review.md Resolved counter
5. Report:
   ```markdown
   Item {N} resolved: {resolution}.

   Any more feedback? Say "以上" when done, or "LGTM" to approve.
   ```
6. Wait for next input

#### Complex Feedback

Feedback where location OR content is ambiguous.

**Examples of Complex**:
- "The error handling seems off" (where unclear, what unclear)
- "This function is too long" (what: split? extract? unclear)
- "The naming could be better" (what: which names? to what?)
- "Performance might be an issue here" (where: which part? what: optimization approach?)

**Action**:
1. Add Review Item to review.md (Status: OPEN, Classification: Complex)
2. Acknowledge: "I'd like to clarify the intent before proposing an approach."
3. Use dig skill to explore:
   - **Why**: What is the underlying concern?
   - **Where**: Which specific location(s)?
   - **What**: What specific change is expected?
4. After clarification, formulate approach (WHERE + WHAT)
5. Present approach to user (same as Minor step 3-6)

#### Design Change

Feedback that requires changes beyond the current spec's scope.

**How to identify Design Change**:

For **Story** (check spec file):
1. Read current spec at `.claude/dev-workflow/story/{story-dir}/spec.md`
2. Compare feedback against spec's "Success Criteria" and "Requirements"
3. If feedback requires NEW success criteria or changes EXISTING criteria → Design Change

For **Task** (check plan file):
1. Read the plan file (path from review.md's `## Related Files`)
2. Compare feedback against plan's "Completion Criteria"
3. If feedback requires NEW or CHANGED Completion Criteria → Design Change
4. When a Design Change is identified in a Task, suggest **promoting to Story** (invoke `dev-workflow:create-spec` with Why/What from the plan)

**Concrete examples**:

| Feedback | Classification | Reason |
|----------|----------------|--------|
| "Add async support to the processor" | Design Change | Current spec defines sync processing; async requires new error handling, retry logic, timeouts (new success criteria) |
| "Change error message from X to Y" | Minor/Complex | Within current spec's error handling approach; no new criteria needed |
| "Add a new endpoint for bulk operations" | Design Change | Current spec defines single-item operations; bulk requires new transaction handling (new success criteria) |
| "Improve validation error messages" | Minor/Complex | Within current spec's validation approach; same criteria apply |

**When in doubt**: If implementing the feedback would require changing the spec's Success Criteria section, it's a Design Change.

**Action**:
1. Add Review Item to review.md (Status: OPEN, Classification: Design Change)
2. Acknowledge: "This feedback suggests changes beyond the current spec."
3. Formulate approach with spec change details
4. Present approach to user:
   ```markdown
   **Item {N}** (Design Change): {feedback summary}
   **Approach**: SPEC CHANGE: {which success criteria to add/modify} / WHAT: {implementation changes after spec update}

   Agree? (or suggest changes / "skip")
   ```
5. Update Review Item: Status → `APPROACH PROPOSED`, fill Approach
6. Wait for user response (same agreement/modification/rejection flow as Minor)

### 5. Batch Implementation

**Entry**: Batch mode only. All actionable items are `APPROACH AGREED`. Triggered by "以上" signal in Batch mode.

**Processing order**: Design Change items first (they may affect spec and other items), then remaining items in order.

#### 5a. Design Change Items

For each Design Change item with Status = `APPROACH AGREED`:

1. Update Review Item: Status → `IMPLEMENTING`
2. Invoke create-spec skill to edit the existing spec
3. After spec update, re-implement and re-run self-review for affected changes
4. Update Review Item: Status → `RESOLVED`, fill Resolution
5. Update review.md Resolved counter

#### 5b. Minor and Complex Items

For each remaining item with Status = `APPROACH AGREED`:

1. Update Review Item: Status → `IMPLEMENTING`
2. Implement the change according to the agreed Approach
3. Update Review Item: Status → `RESOLVED`, fill Resolution
4. Update review.md Resolved counter

#### Plan Mode Context Preservation

If you use EnterPlanMode during implementation of review items, add a `## dev-workflow Context` block to the plan file. Use the template in `dev-workflow-base` skill (`references/plan-mode-context.md`) with these values:

- **Active skill**: user-review (Implementation)
- **Work level**: Story / Task / Task (no plan) — match the current flow
- **Documents**: the relevant docs for the work level, always including `review.md` — Story: Spec + Plan + Review; Task (with plan): the plan file + Review; Task (no plan): Review only
- **After This Plan Completes**: Continue resolving remaining review items in review.md; after all items resolved, present implementation summary to user.

#### 5c. Completion

After all items are resolved (both Iterative and Batch modes reach this point):

1. Present implementation summary:
   ```markdown
   ## Implementation Complete

   | # | Item | Resolution |
   |---|------|------------|
   | 1 | {summary} | {what was done} |
   | 2 | {summary} | {what was done} |

   All {N} items resolved. LGTM to proceed, or provide additional feedback.
   ```
2. Wait for user response:
   - **LGTM**: Update Phase to `LGTM`, proceed to post-task
   - **Additional feedback**: Return to feedback handling (Step 4)

## Output Format

### After Presenting Summary

```markdown
## Review Summary

[Summary content as specified above]

Awaiting your feedback.
```

### After Proposing Approach

```markdown
**Item {N}** ({classification}): {feedback summary}
**Approach**: WHERE: {file:location} / WHAT: {specific change}

Agree? (or suggest changes / "skip")
```

### After Iterative Implementation

```markdown
Item {N} resolved: {resolution}.

Any more feedback? Say "以上" when done, or "LGTM" to approve.
```

### After Recording Approach (Batch Mode)

```markdown
Recorded: {description of approach}. Will implement with other items when you say "以上".

Any other feedback?
```

### After Batch Implementation Complete

```markdown
## Implementation Complete

| # | Item | Resolution |
|---|------|------------|
| 1 | {summary} | {what was done} |

All {N} items resolved. LGTM to proceed, or provide additional feedback.
```

## Session Persistence

Review state is persisted in two files that must be kept in sync:

- **`review.md`** — human-readable record of each item (feedback, approach, resolution).
- **`state.json`** — machine state (see `dev-workflow-base` skill (`references/state-schema.md`)). Whenever you change an item's Status or the review Phase in review.md, mirror it into `state.json` (`review.phase`, `review.items[].status/classification/source`). This is the source the state evaluator reads.

Do **not** hand-maintain a "Resolved X / Y" counter as authoritative — the count is derived by `dev-workflow-base/scripts/workflow-state.py` from item statuses. A counter line in review.md, if present, is only an informational hint.

After completing each review item:

1. Inform the user that review state is saved (review.md + state.json)
2. Mention that they can clear the session and resume later with `resume-work`
3. Do not force session clear — leave the decision to the user

This enables handling each feedback item in a separate session when the context becomes large.

## Success Criteria

### Process Criteria

- [ ] Review summary presented: Response contains "## Review Summary" section with spec path, self-review results, and NEEDS REVIEW items
- [ ] No autonomous action after summary: Response ends without implementation and without "Should I proceed?" question
- [ ] Approach always proposed before implementation: For every feedback item, AI presents a concrete approach (WHERE + WHAT) and waits for user agreement
- [ ] No implementation without agreement: Code changes only occur after user explicitly agrees to the proposed approach (Status reaches `APPROACH AGREED`)
- [ ] Minor feedback identified correctly: When both WHERE and WHAT are unambiguous, approach is proposed without excessive questioning
- [ ] Complex feedback identified correctly: When either WHERE or WHAT is ambiguous, dig skill is invoked before proposing approach
- [ ] Design change identified correctly: When feedback requires new/changed spec success criteria, recorded as Design Change
- [ ] Iterative mode works: In default mode, each item is implemented immediately after approach agreement
- [ ] Batch mode works: When user says "まとめて", approaches are recorded and implemented together on "以上"
- [ ] Explicit LGTM obtained: User explicitly signals approval ("LGTM", "OK", "Looks good") before invoking post-task skill

### Outcome Criteria

- [ ] User doesn't need to re-explain: Each response directly addresses the feedback without requiring user to clarify what they already said
- [ ] No premature implementation: Code changes only occur after user agrees to the proposed approach
- [ ] No excessive questioning: For Minor feedback, approach is proposed directly without asking "Should I investigate?"
- [ ] Approach discussion happens naturally: User can modify, reject, or approve approaches through normal conversation

## Integration with Workflow

```
self-review (all PASS or NEEDS REVIEW)
    ↓ review.md created (by self-review)
    ↓ handoff invoked (by self-review)
    ↓ user copies prompt → /clear → pastes
    ↓ resume-work detects in_review → dispatches user-review
    ↓
user-review (this skill)
    ↓ Step 0: existing review.md found → resume REVIEWING
    ↓ feedback → classify → propose approach → agree → implement (iterative)
    ↓ (repeat for each item)
    ↓ "以上" → completion check
    ↓ (LGTM obtained)
post-task
```

## Anti-patterns to Avoid

| Anti-pattern | Why It's Wrong | Correct Behavior |
|--------------|----------------|------------------|
| Implementing without approach agreement | Wrong approach causes rework | Always propose approach and wait for explicit agreement |
| Forcing batch mode on all users | Doesn't match natural review rhythm | Default to iterative; batch is opt-in via "まとめて" |
| Auto-implementing after proposing approach | User hasn't agreed yet | Wait for explicit agreement signal |
| Silently recording approach without showing user | User can't influence the approach | Always present approach for discussion |
| Assuming LGTM without explicit signal | User may have more feedback | Wait for explicit approval |
| Asking "Should I proceed?" after summary | User review is for feedback, not approval of summary | Wait silently for feedback |
| Proposing multiple interpretations | Adds cognitive load to user | Use dig to narrow down |

## Next Session

**Reference** (Story):
- `.claude/dev-workflow/story/{story-dir}/spec.md`
- `.claude/dev-workflow/story/{story-dir}/plan.md`
- `.claude/dev-workflow/story/{story-dir}/review.md`

**Reference** (Task):
- Plan file (path from review.md's `## Related Files`)
- `.claude/dev-workflow/task/{task-dir}/review.md`

**Next phase** (depends on review.md Phase):

| review.md Phase | Next phase |
|-----------------|------------|
| `REVIEWING` | Continue `user-review` (resume from review.md item states) |
| `LGTM` | `post-task` |

Read spec, plan, and review.md, then invoke the appropriate skill.
