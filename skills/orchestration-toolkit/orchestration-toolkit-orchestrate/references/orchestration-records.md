# Orchestration Records

The Linear `Type/orchestration` Issue is the durable control-plane record for one
Project run. It stays outside the work dependency graph and holds enough state
for a fresh main session to resume without prior conversation.

## Contents

1. Control Issue
2. Initial plan
3. Checkpoint
4. Decision packet
5. Final review packet
6. Resume procedure

## 1. Control Issue

Create:

```yaml
title: "Orchestrate: <Project name>"
project: <selected Project>
labels:
  - Type/orchestration
  - Repo/<same repository as Project>
status: In Progress
```

Description:

```markdown
## Outcome

<Project outcome and observable completion>

## Scope

<Issues and milestones included in this run>

## Knowledge Inputs

<llm-wiki notes, completed blocker outcomes, and repository facts>

## Execution Policy

- Dynamic dependency waves
- Safe maximum parallelism
- Capability-floor model routing
- One routine executor retry
- Risk-based node adversarial review
- Exception-based graph adversarial review
- Mandatory global Lens coverage with two fresh reviewers by default
- Final human approval required

## Completion

This Issue is complete only after the integrated Project result passes mandatory
global adversarial review and a human explicitly approves the final review
packet.
```

The control Issue does not become a parent of all work and does not block or get
blocked by every Issue. Link or mention target Issues in comments using Linear's
internal references.

## 2. Initial plan

Post after discovery:

```markdown
## Orchestration Plan

### Goal and acceptance

...

### Source map

- Linear execution state: ...
- llm-wiki knowledge: ...
- Repository facts: ...
- Conflicts or assumptions: ...

### Execution graph

| Issue | Type | Status | Blocked by | Capability | Expected checks |
|---|---|---|---|---|---|

### Initial waves

1. ...

### Parallelism constraints

- ...

### Assurance plan

- Node lenses: ...
- Graph lenses: ...
- Mandatory global lenses:
  - `global.goal-alignment`
  - `global.integration-consistency`

### Budgets

- Executor concurrency: ...
- Retry limit: 1
- Node adversarial passes: risk-based
- Graph adversarial passes: exception-based
- Default global reviewers: 2
- Minimum fresh global reviewers: 1, covering both mandatory lenses
```

Quick mode records this plan without waiting for approval unless it exposes a
material scope, acceptance, or one-way decision.

## 3. Checkpoint

Post at wave boundaries, before a session ends, or after a material graph
change. Prefer one current snapshot over verbose event narration.

```markdown
## Checkpoint — <timestamp>

### Completed and integrated

- <Issue>: <commit(s)>, <checks>, <completion note status>

### In flight

- <Issue>: <agent/worktree>, <current state>

### Ready next

- ...

### Blocked

- <Issue>: <blocker or decision>

### Decisions and graph changes

- <decision/change>: <evidence and rationale>

### Adversarial findings

- Resolved: ...
- Open: ...
- Coverage gaps: ...

### Budget usage

- Executor attempts: ...
- Node passes: ...
- Graph passes: ...
- Global Lens coverage and reviewer count: ...

### Resume from

<first concrete action for a fresh orchestrator>
```

Do not copy reconstructible diffs or test logs into Linear. Store concise
evidence and point to Git artifacts or commands.

## 4. Decision packet

When a human decision blocks the remaining graph:

```markdown
## Human Decision Required

### Decision

...

### Why it blocks progress

...

### Evidence

...

### Viable options

1. ...
2. ...

### Recommendation

...

### Consequences

...

### Work completed while this was parked

...
```

Move the control Issue to In Review. After the decision, record it, return the
Issue to In Progress, update affected work nodes, and continue.

## 5. Final review packet

Post only after final integration and mandatory global adversarial review:

```markdown
## Final Review Packet

### Project outcome

...

### Acceptance evidence

| Acceptance | Evidence | Result |
|---|---|---|

### Completed work

| Issue | Deliverable | Commit(s) | Verification |
|---|---|---|---|

### Autonomous decisions

- <decision>: <rationale and effect>

### Plan deviations and graph changes

- ...

### Adversarial review

- Lenses and actual reviewer diversity: ...
- Findings resolved: ...
- Findings rejected: <finding, evidence, rationale>
- Coverage gaps: ...

### Residual risks

- ...

### Human decisions or risk acceptance required

- ...

### Scope discipline

- YAGNI check: ...
- Premature-abstraction check: ...
- Out-of-scope changes: ...

### Verification gaps

- ...

### Approval requested

Approve completion of the Orchestration Issue and Project, or identify required
corrections.
```

Move the control Issue to In Review and ask explicitly. Silence is not approval.

## 6. Resume procedure

For a non-terminal control Issue:

1. Read its full description and comments, starting with the latest checkpoint.
2. Reread the Project, all target Issue statuses, and dependency relations.
3. Inspect recorded branches, worktrees, integrated commits, and uncommitted
   changes.
4. Recover prior adversarial findings and human decisions.
5. Recompute the graph from current state; do not trust stale ready lists.
6. Reconcile differences and post a short correction checkpoint.
7. Continue from `Resume from`, unless current evidence invalidates it.

If the Issue is In Review, determine whether it awaits a blocking decision or
final approval. Never resume execution past an unanswered human gate.
