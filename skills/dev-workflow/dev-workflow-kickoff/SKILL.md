---
name: dev-workflow-kickoff
description: Use this skill when the user wants to START work on a new development task. This skill explores user needs through dialogue to understand What they want to achieve and Why. Triggers on phrases like "I want to start this task", "let's work on this", "I have an idea", "how should I approach this work", or when user presents a new work item (concrete or vague). Should NOT trigger for ongoing tasks (use continue-discussion), discussing features without intent to start work, or questions about existing code.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Skill
user-invocable: true
---

# Task Assessment

Assess task complexity through thorough interview, then route to the appropriate workflow.

## Purpose

Determine whether a task is Task, Story, or Epic based on thorough understanding of user intent. The core question: **"Can you write Criteria directly from User Needs?"**

- **If Yes → Task**: Requirements are implicit, Criteria follows naturally from Needs
- **If No → Story**: Need to clarify Requirements before Criteria can be defined

Why this matters: When Criteria cannot be derived directly from User Needs, it means there are unresolved decisions. These decisions should be documented in a spec before implementation begins.

## Critical Anti-Pattern: AI Filling

**Problem**: AI tends to fill documents with general best practices and common patterns, creating documents that look complete but don't reflect user intent. When sessions span, only these documents survive, leading to implementations that miss the actual goal.

**Solution**: Use ONLY information confirmed by the user. Never infer or assume.

Rules:
- Every piece of information in output must be traceable to user confirmation
- If information is unknown, mark as "TBD" or ask for clarification
- Never fill gaps with "reasonable assumptions" or "best practices"
- When user says "I don't know": probe deeper if critical to spec, otherwise mark TBD or propose with explicit "[AI suggestion]" label

## Interview Process

### Use dig for Intent Clarification

Use the Skill tool to call `discuss-toolkit-dig` as a base skill to clarify user intent.

**Context to provide to dig**:
- Subject: User's development task requirements
- Purpose: Need to understand Why (motivation/problem) and What (implementation target/completion criteria) to assess task complexity
- The goal is to determine whether Criteria can be written directly from User Needs

**When dig completes**: Proceed to Assessment Criteria with the clarified understanding.

## Assessment Criteria

| Level | Criterion | Output |
|-------|-----------|--------|
| **Autonomous-Task** | Task **and** every criterion is machine-verifiable (an executable pass/fail) — the "answer" lives in a runnable check, not in the user's head | Use Skill tool: `dev-workflow-create-task` (autonomous variant — see "If Autonomous-Task") |
| **Task** | Criteria writable directly from User Needs (no Requirements clarification needed) | Use Skill tool: `dev-workflow-create-task` |
| **Story** | Requirements clarification needed before Criteria (need to decide "what kind" before "done") | Use Skill tool: `dev-workflow-create-spec` |
| **Epic** | Multiple independent Stories (What has multiple parts) | Use Skill tool: `dev-workflow-create-epic` |

**Examples**:
- Autonomous-Task: "Make the failing tests in `auth/` pass" / "Port module X to match reference Y" → done = a command exits 0; the oracle is external
- Task: "Fix this bug" → Criteria "Bug fixed, tests pass" - directly writable
- Story: "Add authentication" → Need to decide "what kind of auth?" before defining "done"

### The oracle test (Task → Autonomous-Task)

Once something is a Task, ask one more question: **can every completion criterion be a command that returns pass/fail?** This is the oracle test — does the "right answer" live in the world (a test suite, a build, a reference implementation, a benchmark) or only in the user's head (taste, product judgment, UX)?

- **Answer in the world → Autonomous-Task.** The loop can close on its own; an up-front approval gate is pure overhead. Write goal + predicates and let the implement→verify loop run to green; the human reviews only the finished artifact.
- **Answer in the user's head → ordinary Task/Story.** Keep the spec/approval as a human contract; predicates alone cannot capture intent — the oracle lives in the user's head.

When in doubt (some criteria predicate-able, some not), it is **not** Autonomous-Task — fall back to Task/Story.

### Detailed Criteria

**Task**: All of these are true:
- Criteria can be written directly from User Needs
- No specification decisions needed (Requirements are implicit)
- Implementation approach is obvious once What is clear

**Story**: Any of these are true:
- Cannot write Criteria without first clarifying Requirements
- Multiple implementation approaches with trade-offs to document
- Decisions will need to be referenced in future sessions

**Epic**:
- What consists of multiple independent parts
- Each part could be its own Story with separate spec
- Requires coordination document across Stories

## Output by Assessment Result

### If Autonomous-Task

The work is a Task whose every criterion is an executable predicate. The point is to **skip the up-front approval gate** and let the loop close on the predicates.

**You MUST use the Skill tool** to call `dev-workflow-create-task`, telling it this is the **autonomous variant**:
1. Write the completion criteria as executable `Verify:` commands (no `human` criteria — if any criterion would be `human`, this is not Autonomous-Task).
2. State the goal + predicates; do **not** request plan approval via ExitPlanMode (the gate is what we are skipping).
3. Run the implement → verify loop until every predicate exits 0. Prefer the built-in `/goal` command if available (a generator/evaluator loop on the completion condition); otherwise iterate implement → `dev-workflow-self-review` (its Step 0M machine pass runs the predicates) until green.
4. Present the **finished artifact** for human review (the human reviews output, not the plan).

If during implementation a criterion turns out to need human judgment after all, stop the autonomous loop and fall back to ordinary Task (request approval, involve the user).

### If Task

**You MUST use the Skill tool** to call `dev-workflow-create-task`. Do NOT proceed with implementation yourself.

The create-task skill will:
1. Receive Why/What context from this interview (via session history)
2. Structure the information into Claude Code plan file format
3. Request user approval via ExitPlanMode

### If Story

**You MUST use the Skill tool** to call `dev-workflow-create-spec`. Do NOT proceed with spec creation yourself.

The create-spec skill will receive the interview context via session history.

### If Epic

**You MUST use the Skill tool** to call `dev-workflow-create-epic`. Do NOT proceed with epic decomposition yourself.

The create-epic skill will receive the interview context via session history.

### Anti-pattern: Skipping Skill dispatch

**NEVER** start implementation, planning, or document creation directly after assessment. You MUST always use the Skill tool to dispatch to the appropriate skill. Using Plan tool, Write tool, or any other tool to do the work yourself instead of dispatching is a critical error.

## Promotion Flow

Task → Story promotion is a **normal flow**, not a failure.

**Promotion triggers**:
- Design decision emerged during implementation that wasn't anticipated
- Discovered complexity requires documentation for future reference
- Need to preserve decisions across session boundaries

**When promoting**:
- Why/What from Plan carry over to spec (this is why create-task includes full Why/What)
- Document the How decisions made so far
- Use the Skill tool to call `dev-workflow-create-spec` with existing Plan context

## Success Criteria

- [ ] All information in output is user-confirmed (no AI filling)
- [ ] Why is concrete with specific problem/motivation
- [ ] What is specific with measurable completion criteria
- [ ] Assessment rationale is clear and traceable (based on "Criteria directly from Needs?" question)
- [ ] Correct skill invoked based on assessment (create-task / create-spec / create-epic)

## Next Session

If session is cleared before completing this skill:

**Reference**: None (interview context is lost)
**Next phase**: Restart with `dev-workflow-kickoff` (invoke `/dev-workflow-kickoff`)
