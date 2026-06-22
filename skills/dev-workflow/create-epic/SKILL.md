---
name: create-epic
description: This skill is invoked ONLY from kickoff when Epic-level work is identified. Should NOT be invoked directly by user or auto-triggered by AI. Creates epic document by decomposing large work into independent Stories.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
user-invocable: false
---

# Create Epic Document

Decompose large work into independent Stories and create an epic document.

## Purpose

The core purpose is **Story decomposition** - breaking down large work into independent Stories that can be implemented in separate sessions.

Epic documents are NOT primarily for:
- Requirements organization (that's what spec does)
- Progress tracking (that's a side effect)

## Input

This skill receives Why/What context from kickoff interview via session history.

## Story Independence Criteria

A Story is independent when:
1. **Can be implemented in a separate session** - After /clear, this Story alone provides enough context
2. **What can be expressed in one sentence** - If you need multiple sentences, consider splitting

**Key question**: "Can I start working on this Story without waiting for another Story to complete?"
- Yes → Independent
- No → Has dependency (document it)

## Process

### 1. Confirm Why/What from kickoff

Review the interview results:
- **Why**: Background, motivation, problem being solved
- **What**: High-level goal to achieve

If unclear, ask for clarification before proceeding.

### 2. Decompose into Stories

For each potential Story, verify:
- [ ] Can be implemented in a separate session
- [ ] What is expressible in one sentence

If a Story fails these checks, split it further.

### 3. Identify Dependencies

For each Story, ask: "Does this require another Story to be completed first?"
- If yes, document the dependency
- If no, mark as independent

### 4. Create Epic Document

**Directory name**: Prepend today's date to the epic name: `{yyyy-mm-dd}-{epic-name}` (e.g., `2026-04-22-auth-overhaul`)

Create `.claude/dev-workflow/epic/{yyyy-mm-dd}-{epic-name}/epic.md`:

```markdown
# Epic: {title}

## Overview
{What this epic achieves}

## Background
{Why this epic is needed}

## Goal
{Desired end state}

## Stories

| # | Story | Status | Dependencies |
|---|-------|--------|--------------|
| 1 | {story-name} | Not Started | - |
| 2 | {story-name} | Not Started | #1 |

## Out of Scope
{What this epic does NOT include}

## References
{Related links}
```

### 5. Suggest Next Action

Identify the first Story with no dependencies and suggest starting create-spec for it.

## Success Criteria

- [ ] Why/What from kickoff is captured in Overview/Background/Goal
- [ ] Each Story can be implemented in a separate session
- [ ] Each Story's What is expressible in one sentence
- [ ] Dependencies between Stories are documented
- [ ] Next Story to start is identified (one with no dependencies)
- [ ] Directory name matches `{yyyy-mm-dd}-{epic-name}` format

## Next Session

After epic is created:

**Reference**: `.claude/dev-workflow/epic/{epic-dir}/epic.md` (where `{epic-dir}` = `{yyyy-mm-dd}-{epic-name}`)
**Next phase**: `create-spec` for first Story (one with no dependencies)

Read the epic file, identify the first Story to implement, and invoke `kickoff` or `create-spec` for that Story.
