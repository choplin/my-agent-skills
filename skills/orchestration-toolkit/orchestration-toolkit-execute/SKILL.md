---
name: orchestration-toolkit-execute
description: >-
  Executes one groomed tracker Issue inline, with no delegation and no graph:
  recovers the Issue's durable knowledge, uses its prepared worktree, implements
  and commits in this session, handles routine judgment inline, surfaces
  consequential or continuity-relevant choices, keeps resumable checkpoint
  comments, runs risk-based adversarial review, and advances status only as far
  as the integration gate permits.
  Applies when the work unit is a single already-groomed Issue in the tracker.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, AskUserQuestion
metadata:
  description-role: trigger
---

# Execute one Issue

One groomed Issue, one coherent change, driven through implementation and
verification in this session. It reaches Done only when the applicable
integration gate passes; otherwise it remains In Progress or In Review.

The Issue already says **what** to build; this skill decides **how** and does it.
Everything runs inline — no executor subagents, no dependency graph, no wave
scheduling. A single node does not need a project control plane.

Apply `workflow-adapter-tracker-read`, `workflow-adapter-tracker-comment`, and
`workflow-adapter-tracker-transition` for Issue operations;
`workflow-adapter-markdown-find` and `workflow-adapter-markdown-read` for
durable knowledge; and `git-helpers-commit` for every commit. Execution requires
a prepared workspace, an implementation-completion procedure, and any protected
mutation handle. If required execution context is missing, stop before execution
rather than guessing lifecycle state.

## Invariants

- One Issue produces one coherent, independently reviewable change on one branch.
- The tracker owns executable state and the running record; the selected
  Markdown provider owns durable design and decision rationale; the repository
  owns implementation reality.
- The Issue's acceptance is the target. Reject speculative features, future-only
  flexibility, and abstractions without a present second use.
- Never silently resolve a one-way-door decision with a plausible default.
- Keep tracker identifiers and URLs out of branches, commits, repository files,
  and PR text.
- Do not rewrite the Issue's requirements. Re-grooming is a separate operation.

## Decision handling

The Issue fixes the What, but implementation judgment still arises underneath
it. Match the handling and record to the consequence of the call:

- Make routine interpretive choices inline when the Issue and repository provide
  enough context and the result is local and readily reversible. These choices
  do not need individual classification or durable entries.
- Record a resolved choice when its rationale would not be recoverable from the
  code and another session needs it to review or continue the work.
- Do not guess when a choice has material blast radius, is costly to reverse,
  changes acceptance or constraints, or exposes an unresolved requirement.
  Record the question, what it blocks, the viable options, and the current
  evidence.

Blast radius and reversibility are signals, not a form every decision must fill
out. Requirement ambiguity and cross-session continuity matter too. Collect
non-urgent unresolved questions for one review pass at a natural stopping point;
stop immediately when continuing would risk safety or integrity.

## Workflow

### 1. Bind the run to the Issue

Read the Issue in full: description, acceptance, comments, labels, relations, and
status. Then confirm it is actually executable:

- its acceptance is observable — a human could confirm it from outside the code;
- it is self-complete: its description contains the context, inputs,
  acceptance, and constraints a fresh executor needs;
- any `blocked by` relation is Done.

If a blocker is open, stop and say so. If the requested outcome spans several
dependent Issues, this is the wrong skill — stop and report that grooming or
planning must expose an executable next Issue rather than widening this run.

Move the Issue to In Progress if it is not already. Reuse any supplied
coordination handle and prepared workspace rather than reacquiring them.

### 2. Recover the knowledge surface

Use `workflow-adapter-markdown-find` and `workflow-adapter-markdown-read` to
find and read the PRDs, designs, research,
and decision records the Issue depends on. Search from the Issue's own
terminology rather than loading the whole store, and follow only the links
needed to interpret scope, constraints, or acceptance.

Note any contradiction between the Issue, durable knowledge, and the
repository. The tracker is authoritative for current execution state, the
Markdown provider for durable rationale, and the repository for actual
behavior. Treat a material contradiction as an unresolved question, not
something to resolve by preference.

### 3. Use the prepared workspace

Confirm the prepared workspace is the intended repository worktree, then use it
without discovering or creating another one.

### 4. Open the run record

Use `workflow-adapter-tracker-comment` to post one comment on the Issue before driving:

```markdown
## Run — <timestamp>

### Approach

<how this will be built, in a few lines — the How, not a restated What>

### Knowledge inputs

<durable notes and repository facts this run depends on>

### Progress

- [ ] <step>

### Next

<the next concrete step>
```

This is the running record. Do not also keep a local plan file: the Issue is the
durable state, and a second copy on disk only goes stale.

Add `### Decisions` or `### Unresolved questions` only when they contain
information another session needs. Do not preserve empty headings as ceremony.

### 5. Drive inline

Work the Progress list top to bottom.

- Implement and verify without committing; the supplied completion procedure
  owns the reviewed commit.
- Make routine choices inline. Apply the decision-handling threshold when a
  choice becomes consequential, requirement-sensitive, or important to
  reconstructing the run.
- When a step is blocked only by an unresolved question, skip it and continue
  where that is safe.
- Update the record at meaningful boundaries and before the session ends by
  posting a fresh checkpoint comment — one current snapshot of completed and
  current work, consequential decisions and rationale, unresolved questions,
  and the next concrete step. Omit sections with no durable information. Do not
  copy diffs or test output into the tracker; git holds those. The record carries
  only the judgment and continuity context git cannot.

If unresolved questions block most progress, the Issue was not groomed enough to
execute. Stop, post what you found, and report whether the requirements need
grooming or the concept itself is unformed.

If the run must pause mid-Issue, post a checkpoint and return a pause outcome so
the surrounding workflow can perform any provider-specific handoff.

### 6. Verify

Check the result yourself first: every acceptance item satisfied with observable
evidence, scope not exceeded, unrelated user changes preserved, no unjustified
abstraction, required tests and repository checks run with their raw outcomes.

Then decide whether an independent pass is warranted. Call `artifact-review`
with `scope: node` when the change has any
of:

- broad blast radius across modules or callers;
- low reversibility (migration, data shape, published interface);
- weakly observable acceptance;
- deviation from a recorded design decision;
- security, data-handling, or API impact;
- repeated failure or retry during the run.

None of these → the self-check stands; record that no independent pass was run and
why. Because this skill is inline, the author and the checker are the same
context, so say plainly which of the two happened rather than implying more
assurance than the run produced.

Apply supported findings, record rejected ones with the evidence that rejects
them, and treat `inconclusive` as a coverage gap rather than a pass.

### 7. Close

Bring unresolved questions back in one pass at a natural stopping point. For
each, present what it blocks, the viable options, the evidence, and your leaning.
Resolve them with the user, record rationale only when it remains important for
review or continuation, then finish the work that was blocked.

When nothing remains open, assemble these Issue-specific inputs for the
supplied implementation-completion procedure:

- the acceptance table — each criterion mapped to observable evidence;
- the prospective commit scope;
- consequential or continuity-relevant decisions and their rationale;
- adversarial findings, or the recorded reason none were sought;
- residual risks and verification gaps.

Apply that procedure from pre-commit review through its terminal outcome. It
owns commit continuation, integration, tracker status, and cleanup; do not
reproduce those branches here. Route each requested Issue operation through the
matching `workflow-adapter-tracker-<operation>` skill, preserving any supplied
mutation handle. Return the outcome after the procedure finishes or reaches an
explicit stop.

## When NOT to use

- Several Issues with dependencies between them → groom or plan the next
  executable Issue first.
- No Issue behind the work — an ad-hoc task to run autonomously → `exec-plan`.
- The Issue's requirements are not settled → groom the Issue first.
- The concept itself is unformed → `inception`.
- A trivial change with self-evident completion → just do it and note it on the Issue.

## Success criteria

- [ ] The Issue's acceptance was checked as executable before driving, and its blockers were Done.
- [ ] Routine implementation judgment proceeded without unnecessary recording,
      while consequential or requirement-sensitive decisions were not guessed.
- [ ] The Issue record is sufficient to reconstruct completed and current work,
      relevant rationale, unresolved questions, and the next step without
      conversation history.
- [ ] Independent adversarial review was run, or its absence was recorded with the risk assessment that justified it.
- [ ] The completion note maps every acceptance criterion to observable evidence or an explicit gap.
- [ ] A Done implementation is verified on its target branch, or its completion
      note records the user's explicit decision to accept an unintegrated
      exception.
