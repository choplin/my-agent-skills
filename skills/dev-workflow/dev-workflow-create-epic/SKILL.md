---
name: dev-workflow-create-epic
description: This skill is invoked ONLY from kickoff when Epic-level work is identified. Should NOT be invoked directly by user or auto-triggered by AI. Decomposes large work into independent Stories and creates a Linear Project holding them.
user-invocable: false
---

# Create Epic

Decompose large work into independent Stories and set them up in Linear.

An **Epic maps to a Linear Project**; its **Stories are the Project's Issues**
(a Story maps to an Issue — see `dev-workflow-create-spec`). There is no local
epic document. All Linear mechanics — the required Repo project-label, the
goal/target framing of a Project, Issue labels, `blocked by` relations — are owned
by the **`linear-base` skill**; follow its conventions rather than restating them.

## Tool Usage Constraints

- **Linear**: use whichever Linear MCP server is wired, per the `linear-base` skill.

## Purpose

The core purpose is **Story decomposition** — breaking large work into independent
Stories that can each be implemented in a separate session. The Linear Project is
where those Stories live and where the Epic's rollup (which Story next, how many
done) is read at session boundaries. It is NOT for:
- Requirements organization (that's what each Story's spec does)
- Progress tracking as a stored artifact (it is derived from the Issues' statuses)

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

### 4. Create the Linear Project

Create a Project for the Epic, per the `linear-base` skill (it must carry the repo's
**Repo** project-label; frame it as a finite outcome with a target, not a bucket).
Resolve the repo's Project namespace the same way `linear-start` does. Put the
Epic's framing in the Project **description**:

```markdown
## Overview
{What this epic achieves}

## Background
{Why this epic is needed}

## Goal
{Desired end state}

## Out of Scope
{What this epic does NOT include}
```

### 5. Create the Story Issues in the Project

For each Story, create an Issue **in the Project** (Repo + Type labels per `linear-base`):

- **Title** = the Story name; **description** = the one-sentence What (kept
  lightweight — full spec structuring happens later, at `create-spec` adopt time).
- **Status** = Backlog (the first dependency-free Story may be set Todo to signal it
  is next).
- **Dependencies** = express as Linear **`blocked by`** relations between the
  Issues, not as prose.

These Issues are what the Epic rollup reads: `workflow-status` / `resume-work`
list the Project's Issues and their statuses to compute progress and the
next Story. Do not create local directories or a `state.json` for the Epic.

### 6. Suggest Next Action

Identify the first Story Issue with no open `blocked by` and suggest starting it
(`dev-workflow-kickoff` or `dev-workflow-create-spec` in **adopt** mode on that
Issue).

## Success Criteria

- [ ] Why/What from kickoff is captured in the Project description (Overview/Background/Goal)
- [ ] A Linear Project is created with the repo's Repo project-label
- [ ] Each Story is a Project Issue whose What is expressible in one sentence and implementable in a separate session
- [ ] Dependencies are expressed as `blocked by` relations between Issues
- [ ] The first Story to start (no open blockers) is identified

## Next Session

After the Project and its Story Issues are created:

**Reference**: the Linear **Project** (the Epic) and its Story **Issues**
**Next phase**: `dev-workflow-create-spec` (adopt mode) for the first Story (one with no open blockers)

Identify the first Story Issue to implement and invoke `dev-workflow-kickoff` or `dev-workflow-create-spec` for it.
