---
name: discussion-continuity-continue-discussion
description: Use this skill to save discussion state for continuation in a future session. Triggers on phrases like "save this discussion", "let's continue later", "preserve discussion state", or when a design/planning discussion needs to span sessions. Should NOT trigger for: saving code snippets, bookmarking files, saving implementation progress (use git commit instead), or TODO lists.
allowed-tools: Read, Write, Glob, AskUserQuestion, Task
user-invocable: true
---

# Continue Discussion

Save the current discussion state so it can be continued in a future session.

## Why This Skill Exists

Discussions about design, requirements, and planning often span multiple sessions. Without proper state preservation:
- Decisions made are forgotten
- The same ground gets re-covered
- Context and rationale are lost
- Time is wasted

This has happened multiple times. This skill ensures discussion state is properly captured and can be resumed.

## Storage

- **Location**: `.claude/continuity/`
- **Filename**: `yyyymmdd-{topic}.md`
- **Note**: Temporary document, not committed to repository

## Workflow

```
Clarify → Draft → Review → Approval
```

### Step 1: Clarify

**Why**: Writing things down often reveals misalignment between user's understanding and AI's understanding. Must align before saving.

**How**:
1. Summarize your understanding of:
   - Discussion goal
   - Key decisions made (with rationale)
   - Open questions remaining
   - Current state / what's in progress
2. Use AskUserQuestion: "Is this understanding correct?"
3. If misalignment found, clarify until aligned

**Alignment indicators**:
- Aligned: User says "yes", "correct", "exactly", "その通り" without additions
- Misaligned: User says "not quite", "actually", "well...", corrects facts, adds information, or asks "where did you get that?"

### Step 2: Draft

**Why**: Preserve discussion state in a retrievable format.

**How**:
1. Create file at `.claude/continuity/yyyymmdd-{topic}.md`
2. Follow the format specification below
3. Ensure:
   - All decided points include rationale
   - Context includes insights, not just file paths
   - In-progress discussion details go in Current State section

## Success Criteria

Before presenting the document to the user, verify:

- [ ] **Background**: Describes situation/problem that triggered discussion (not just "we need to decide X")
- [ ] **Goal**: States specific question to answer or outcome to achieve
- [ ] **Decided points**: Each includes BOTH decision AND rationale ("We decided X because Y")
- [ ] **Open points**: Each has sufficient context for someone unfamiliar
- [ ] **References**: Each entry includes why it's referenced
- [ ] **What We've Learned**: If insights emerged, contains concrete learnings (not generic observations)
  - Good: "Realized sync API blocks rendering because main thread handles both UI and network"
  - Bad: "Performance matters" or "We should consider edge cases"
- [ ] **Current State > In Progress**: Contains specific details (options, opinions)
  - Good: "Option A: Use Redis. Option B: Use in-memory cache. User prefers A for persistence."
  - Bad: "Discussing caching options"

### Step 3: Review

**Why**: Verify document is self-complete (can continue discussion with only this document).

**How**:
1. Give the saved document to a subagent (Task tool with Explore agent)
2. Ask subagent: "From this document alone, explain: the discussion goal, what has been decided, what questions are open, and what is the current state"
3. Compare subagent's understanding with your own context

**Pass threshold**: Subagent correctly answers all 4 questions:
1. Discussion goal - matches your understanding of purpose
2. Decided points - lists all decisions with their rationales
3. Open questions - lists all unresolved items
4. Current state - explains what's actively being discussed

**Fail condition** (update document and re-review if any):
- Subagent cannot identify the discussion goal
- Subagent lists a decision but cannot explain WHY
- Subagent misses any decided point
- Subagent says "I don't have enough information"
- Subagent's summary contradicts your understanding

### Step 4: Approval

**Why**: User confirms the document captures enough to continue.

**How**:
1. Present the document to user
2. If rejected:
   - Ask what's missing
   - Return to Clarify step
3. If approved:
   - Confirm file path
   - Provide resume instructions: "In next session, read this file and continue from Current State"

## Document Format

```markdown
---
created-by: continue-discussion skill
---

# Discussion: {Topic}

## Background
{Context that led to this discussion - what situation, problem, or need triggered it}

## Goal
{Purpose of this discussion - what question needs to be answered, what outcome is desired}

## Why This Matters
{Why this discussion is important - consequences of not resolving it, value of resolving it}

## Discussion Points

### {Point A}
**Status**: Decided

{Description/background of the point}

{Decision and rationale in free form}

### {Point B}
**Status**: Open

{Description/background of the point}

### {Point C}
**Status**: In Progress

{Description/background only - details go to Current State}

## References
- `path/to/file.md` - {why referenced}
- https://example.com - {why referenced}

## What We've Learned (optional)
- {Insight gained from this discussion - include only if meaningful insights emerged}

## Current State

### History
{Key events that happened during this discussion - attempts made, problems encountered, pivots taken}

### In Progress: {Point C}
{Current discussion content, key exchanges}
{Options being considered, opinions raised}
```

## How to Resume

Provide user with a copy-paste prompt for the next session:

```
Read .claude/continuity/{filename}.md and continue the discussion.

Steps:
1. Review Goal, Discussion Points, and Current State
2. Resume from "In Progress" in Current State
3. Update the file as discussion progresses
4. When complete, move decisions to spec/plan documents or delete the file
```
