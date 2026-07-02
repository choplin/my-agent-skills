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

Assessment produces two kinds of routes. **Task-level work leaves dev-workflow** — it needs no spec and no approval gate, so it is handed to an autonomous execution skill (or just implemented directly). **Story- and Epic-level work stays in dev-workflow**, because it needs a spec before "done" can be defined.

### Routes that leave dev-workflow (Task-level — no spec, no approval gate)

| Level | Criterion | Route |
|-------|-----------|-------|
| **Autonomous-Task** | Task **and** every criterion is machine-verifiable (an executable pass/fail) — the "answer" lives in a runnable check, not in the user's head | Use Skill tool: `goal-loop` (predicate-gated implement→verify loop) |
| **Task** | Criteria writable directly from User Needs (no Requirements clarification needed) | Use Skill tool: `exec-plan` — or, for a trivial one-off with nothing to defer, just implement it directly (no skill needed) |

### Routes that stay in dev-workflow (spec required)

| Level | Criterion | Route |
|-------|-----------|-------|
| **Story** | Requirements clarification needed before Criteria (need to decide "what kind" before "done") | Use Skill tool: `dev-workflow-create-spec` |
| **Epic** | Multiple independent Stories (What has multiple parts) | Use Skill tool: `dev-workflow-create-epic` |

**Examples**:
- Autonomous-Task: "Make the failing tests in `auth/` pass" / "Port module X to match reference Y" → done = a command exits 0; the oracle is external → `goal-loop`
- Task: "Fix this bug" → Criteria "Bug fixed, tests pass" - directly writable → `exec-plan`, or just do it if it's a two-line change
- Story: "Add authentication" → Need to decide "what kind of auth?" before defining "done" → `dev-workflow-create-spec`

### The oracle test (Task → Autonomous-Task)

Once something is a Task, ask one more question: **can every completion criterion be a command that returns pass/fail?** This is the oracle test — does the "right answer" live in the world (a test suite, a build, a reference implementation, a benchmark) or only in the user's head (taste, product judgment, UX)?

- **Answer in the world → Autonomous-Task.** The loop can close on its own; an up-front approval gate is pure overhead. Route to `goal-loop`: state goal + predicates and let the implement→verify loop run to green; the human reviews only the finished artifact.
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

The work is a Task whose every criterion is an executable predicate. It **leaves dev-workflow**: there is no spec and no up-front approval gate — the loop closes on the predicates.

**You MUST use the Skill tool** to call `goal-loop`. It will clarify the What, write a compact Goal Contract with executable predicates, and run a bounded implement→verify loop until every predicate passes, then present the finished artifact for human review.

If during implementation a criterion turns out to need human judgment after all, `goal-loop` stops as `blocked` and hands back to a spec-driven route (`dev-workflow-create-spec`).

### If Task

The work **leaves dev-workflow**: Criteria follow directly from Needs, so no spec and no approval gate are needed.

- **Self-drivable Task** (some decisions may need deferring) → use the Skill tool to call `exec-plan`. It agrees a rough Purpose/Boundaries/Acceptance, drives autonomously, parks the big calls, and batch-reviews them at the end. For a small Task, the plan can be a few lines.
- **Trivial one-off** with nothing to defer → just implement it directly. No skill needed.

If complexity turns out to need requirements decided up front, promote to Story (`dev-workflow-create-spec`).

### If Story

**You MUST use the Skill tool** to call `dev-workflow-create-spec`. Do NOT proceed with spec creation yourself.

The create-spec skill will receive the interview context via session history. **If an existing Linear Issue is already in play** (entered via `linear-start` → `dispatch-work`, so an Issue is already picked and In Progress), create-spec runs in **adopt** mode on that Issue rather than creating a new one.

### If Epic

**You MUST use the Skill tool** to call `dev-workflow-create-epic`. Do NOT proceed with epic decomposition yourself.

The create-epic skill will receive the interview context via session history.

### Anti-pattern: Doing Story/Epic work inline

For **Story and Epic**, you MUST use the Skill tool to dispatch to `dev-workflow-create-spec` / `dev-workflow-create-epic`. NEVER write a spec or decompose an epic inline yourself — that skips the requirements step these levels exist for.

For **Task-level** work the opposite holds: routing to `goal-loop` / `exec-plan`, or implementing a trivial change directly, is correct — do not force it through a spec.

The one error to avoid on the Task side: silently treating Story- or Epic-level work as a Task to skip the spec. When requirements need deciding, route up, don't drive through.

## Promotion Flow

Task → Story promotion is a **normal flow**, not a failure. It is how a Task-level route (`goal-loop` / `exec-plan`) re-enters dev-workflow when requirements turn out to need deciding.

**Promotion triggers**:
- Design decision emerged during implementation that wasn't anticipated
- Discovered complexity requires documentation for future reference
- Need to preserve decisions across session boundaries

**When promoting**:
- Carry the Why/What over to the spec: from the `goal-loop` Goal Contract, or the `exec-plan` Purpose/Boundaries/Acceptance already written for the Task
- Document the How decisions made so far (the `exec-plan` Decision Log / Parking Lot, if present)
- Use the Skill tool to call `dev-workflow-create-spec` with that context

## Success Criteria

- [ ] All information in output is user-confirmed (no AI filling)
- [ ] Why is concrete with specific problem/motivation
- [ ] What is specific with measurable completion criteria
- [ ] Assessment rationale is clear and traceable (based on "Criteria directly from Needs?" question)
- [ ] Correct route taken based on assessment (Task-level → `goal-loop` / `exec-plan` / direct implementation, which leave dev-workflow; Story → `create-spec`; Epic → `create-epic`)

## Next Session

If session is cleared before completing this skill:

**Reference**: None (interview context is lost)
**Next phase**: Restart with `dev-workflow-kickoff` (invoke `/dev-workflow-kickoff`)
