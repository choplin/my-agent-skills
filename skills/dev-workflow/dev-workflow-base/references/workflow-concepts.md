# dev-workflow Concepts

---

## Overview

dev-workflow provides a "framework" for development work with Claude Code. Following the framework clarifies the approach, enabling AI to autonomously proceed in the intended direction even for complex work spanning multiple sessions.

## Background (Why)

### Characteristics of Development with Claude Code

Claude Code operates on a session basis. When a session is cleared (`/clear`), conversation history is lost, so work spanning sessions requires saving state in another form.

Additionally, AI makes autonomous decisions based on given information. When information is insufficient, user confirmation is needed repeatedly, and when work patterns are not defined, AI decisions diverge from user expectations.

### Challenges in Complex Work

Workflow needs to change according to work scale. Small tasks can be executed directly, but complex work presents these challenges:

1. **Context loss**: Conversation history is lost across sessions, making work continuation impossible
2. **Ambiguous approach**: When it's unclear what to do in each phase, AI cannot make appropriate decisions
3. **Rework**: Proceeding with unresolved issues leads to wasted work

## Goal (What)

Establish a workflow that effectively guides development work with Claude Code.

**Target state**:
- Gated work can be appropriately shaped as a Story or Epic
- Necessary support is available at each phase
- Context is maintained across sessions (through documents)
- AI can determine completion through self-review

---

## Workflow Model

### Core Concepts

#### Session

A Claude Code conversation thread. Refers to one conversation until `/clear`.

When a session is cleared, conversation history is lost, so work spanning sessions requires saving context to documents.

Session clear timing is user-driven. AI may suggest it, but the final decision is made by the user.

#### Terminology

Terms that detail **What** in the traditional What/Why/How framework:

```
Why: Background, motivation
What:
  ├─ User Needs: What the user wants to achieve
  ├─ Requirements: Specifications the system must have
  └─ Criteria: Completion criteria
How: Implementation steps
```

| Concept | Term | Description | Position |
|---------|------|-------------|----------|
| What user wants to achieve | User Needs | Problem, desire | What (abstract) |
| Specifications system must have | Requirements | Functions, constraints | What (concrete) |
| Completion criteria | Criteria | Verification conditions | What (verification) |

**Document correspondence**:

| Document | Content | Corresponding concept |
|----------|---------|----------------------|
| spec | Requirements and acceptance criteria | What (User Needs + Requirements + Criteria) |
| plan | Implementation steps | How |
| epic | Overall requirements + Story management | Why + What (high level) |

#### Story / Epic

`dev-workflow` is the human-gated control model. The user chooses it before
kickoff; kickoff never redirects work to an autonomous mode based on size or
testability.

| Level | Criterion | Documents |
|-------|-----------|-----------|
| Story | One independently specifiable and reviewable outcome, regardless of size | spec + plan |
| Epic | Multiple independent Stories | epic + each Story's spec/plan |

The assessment question is:

> Can this outcome be specified, implemented, and reviewed as one independent
> deliverable?

- **Yes → Story**
- **No → Epic**, then decompose it into independent Stories

Small fixes are valid Stories when the user wants spec/plan/review gates.
Conversely, many files or implementation steps do not make an Epic unless they
produce independently reviewable outcomes.

#### Documents

| Document | Role | Update frequency |
|----------|------|------------------|
| epic | Requirements organization + Story management (including implementation status) | Low |
| spec | Requirements + acceptance criteria (for AI self-review) | Medium |
| plan | Implementation steps + progress | High |
| review | Review state + user feedback tracking (for cross-session review) | High |

#### Branch Management

Each Story maps to a single git branch. Branch lifecycle is managed by skills:

| Timing | Skill | Action |
|--------|-------|--------|
| After spec approval | `dev-workflow-create-spec` | Create branch `{prefix}/{story-name}` and checkout — **conditional**: skip if `linear-start` already set up the workspace (worktree/branch); record the actual branch in `state.json.branch` |
| Session resume | `dev-workflow-resume-work` | Detect `state.json.branch`, confirm checkout with user |

**Branch naming convention**: `{prefix}/{story-name}`

| Prefix | When |
|--------|------|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `refactor/` | Refactoring |
| `docs/` | Documentation |
| `test/` | Test |
| `chore/` | Build/CI/tooling |
| `perf/` | Performance |

The Story directory name (e.g., `add-auth`) becomes the branch name (e.g., `feat/add-auth`).

**Note**: Epics do not have associated branches. They are decomposed into Stories,
each with its own branch.

### Workflow Phases

```
[Understand] → Story / Epic assessment
                     │
             create spec / epic
                     │
        create branch (Story) · decompose to Stories (Epic)
                     │
                 create plan
                     │
        [Session clear?] ← optional (documents are self-complete)
                     │
          [Resume Work] ← Re-entry point (branch checkout)
                     │
                [Implement]
                     ↓
              [Test/AI Review] ←┐
                     │          │ Iteration
                     └──────────┘
                     ↓
              [User Review] ← review.md persists state
                     ↓
                 [Commit]
                     ↓
             [Knowledge Capture]
```

**Phase descriptions**:

1. **Understand**: Clarify Why/What and decide whether the gated outcome is one Story or several independent Stories in an Epic
2. **Document creation**: Create spec/plan/epic
3. **Session clear (optional)**: For Story/Epic, clearing before implementation is available but not required — documents are self-complete, so resume works with or without a clear (see Design Principle 2)
4. **Resume Work**: Re-entry point for existing work (evaluates progress, identifies gaps, recommends next action)
5. **Implement**: Proceed with implementation based on documents
6. **Test/AI Review**: Self-review based on acceptance criteria
7. **User Review**: Final confirmation by human
8. **Commit**: Commit changes
9. **Knowledge Capture**: Save learnings to appropriate locations

### Skills for Each Phase

| Phase | Skill | Purpose |
|-------|-------|---------|
| Understand | `dev-workflow-kickoff` | Explore user needs, route to Story or Epic |
| Document (Story) | `dev-workflow-create-spec` → `dev-workflow-create-plan` | Create spec then implementation plan |
| Document (Epic) | `dev-workflow-create-epic` | Decompose into Stories |
| Resume Work | `dev-workflow-resume-work` | Evaluate progress, identify gaps, recommend resumption point |
| Test/AI Review | `dev-workflow-self-review` | Verify against acceptance criteria |
| User Review | `dev-workflow-user-review` | Structured feedback handling |
| Commit + Knowledge Capture | `dev-workflow-post-task` | Commit and capture learnings |

**Note**: Skills are invoked in sequence. Some transitions are automatic (e.g., `dev-workflow-self-review` → `dev-workflow-user-review`), others require explicit invocation or user decision.

---

## Document Storage

Authored content is externalized to **Linear**; only machine-managed execution
state stays local.

- **Epic** → a **Linear Project** (Overview/Background/Goal in its description). No
  local files.
- **Story** → a **Linear Issue** whose description holds the spec (Why/What/Acceptance
  Criteria) and the plan design (Approach/Files/Steps).
- **Local** (`.claude/dev-workflow/story/{story-dir}/`) → `state.json` (criteria +
  steps — the offline execution SoT and the `linear_issue_id` link) and, during
  review, `review.md`.

The split keeps the implementation hot loop and `workflow-state.py` offline: Linear
is read only at session boundaries (bootstrap), and progress is written back to the
Issue best-effort (fire-and-forget). See `references/state-schema.md` § Linear
backing for the full contract.

Permanent artifacts (Design Docs, ADRs) are exported in the post-task phase if needed.

## Knowledge Capture Destinations

Knowledge is stored in different locations by type:

| Knowledge Type | Destination | Purpose |
|----------------|-------------|---------|
| Design decisions | ADR (`docs/adr/`) | Record of why this design was chosen |
| Project-specific knowledge | CLAUDE.md | AI reference for future sessions |
| Generic knowledge | Skill | Reusable across other projects |
| Important specs | Design Doc | Permanent design documentation |

**Decisions in post-task phase**:
- Can this knowledge be used in other projects? → Create Skill
- Will this design decision be referenced in the future? → Create ADR
- Does this spec have permanent value? → Save as Design Doc
- Project-specific learning? → Add to CLAUDE.md

---

## Design Principles

### 1. Self-complete Documents

All spec/plan documents should be autonomously executable without conversation history. Documents become the single source of truth.

**Checklist**:
1. Why/What is documented
   - Background and purpose are written
   - Implementation target is identified
2. Decision rationale is recorded
   - Options considered
   - Selection reasons
3. Completion conditions are clear
   - What constitutes "done"
   - Verification method
4. Next steps are clear
   - Current workflow phase is identified
   - Post-work actions are specified (e.g., "invoke self-review", "update Progress section")
   - Instructions are actionable without session history

### 2. Resumable State (not session-clear)

Keep work in a state that can be interrupted and resumed at any time. Documents (spec + plan + state) are the single source of truth, so a fresh session can pick up from them.

Clearing the session before implementation is **optional**, not required:

- It helps when the planning context is large or noisy, giving implementation a clean context.
- It is unnecessary when the model sustains a long coherent context on its own. The need for a hard reset is model-dependent — newer models reduce it — so treat `/clear` as a tool the user may use, not a mandatory step.

What matters is that the documents stay self-complete (Principle 1), so resumption never depends on conversation history regardless of whether the session was cleared.

### 3. AI-verifiable Acceptance Criteria

Include verifiable acceptance criteria in specs. Format that allows AI to determine pass/fail in self-review.

### 4. Recursive Flow

After Epic → Story decomposition, each Story enters the spec phase as one
human-gated deliverable. The execution-mode decision is not reopened.

### 5. Fail-safe with Knowledge Capture

Update documents including failure knowledge while rolling back. Leave results at each phase.

### 6. Resolve Ambiguities Before Implementation

Start implementation only after all ambiguities are resolved. Proceeding with unresolved issues wastes work.

### 7. Autonomous→Human-gated Escalation

An autonomous run may discover that progress requires decisions only a human
should gate. That run stops and returns to `dispatch-work`; if the user chooses
dev-workflow, kickoff creates a Story or Epic from the context already learned.
This is an escalation between control models, not a classification performed
inside kickoff.

### 8. Plan Mode Context Preservation

When Claude Code autonomously enters Plan Mode during dev-workflow execution, include dev-workflow context (active skill, phase, work level, documents, post-plan action) in the plan file. Without this, the plan creates an isolated context that loses its place in the workflow.

---

## What We've Learned

Lessons learned from designing this workflow:

1. **All ambiguities must be resolved before implementation**. Leaving ambiguities wastes work
2. **SKILLs need "why" and "specific criteria"**. Lists of generalities don't help AI decisions
3. **Discussion phases also span sessions**. A mechanism to save discussion state was needed
4. **Important information tends to be lost during plan-to-implementation transition**. Attention required
5. **spec is an "evolving document", not a "finished product"**. Perfect upfront design is impossible
6. **Autonomous → human-gated escalation is a normal safety transition** when
   the chosen autonomous mode discovers that human approval must gate progress
7. **Criteria must be operationally defined**. Avoid subjective words like "obvious", concretize in checklist format
8. **Using subagents (Claude/Codex) for design review reveals overlooked issues**
9. **Story/Epic assessment is about independent deliverables, not difficulty or
   the number of implementation choices**
10. **Plan documents need workflow context, not just implementation steps**. After session clear, the plan is the only surviving context. Without workflow navigation (which phase, what comes next), AI loses its place in the workflow and skips post-implementation steps like self-review
11. **Plan Mode creates isolated context that loses workflow position**. Claude Code's built-in Plan Mode generates `.claude/plans/` files focused on How. Without explicitly embedding dev-workflow context (active skill, phase, next action), the workflow chain breaks after plan execution
