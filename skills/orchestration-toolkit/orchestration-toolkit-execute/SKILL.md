---
name: orchestration-toolkit-execute
description: >-
  Carry one groomed Linear Issue to Done inline — no delegation, no graph. Recover
  the Issue's knowledge from llm-wiki, prepare its worktree, implement and commit
  in this session, decide reversible calls autonomously while parking one-way
  doors, keep the running state on the Issue as checkpoint comments, run
  risk-based adversarial review, and close with a completion note. Use when the
  work unit is a single already-groomed Issue in the tracker. Not for a
  multi-Issue Project with dependencies (use orchestration-toolkit-orchestrate),
  not for ad-hoc work with no Issue behind it (use exec-plan), and not for
  deciding what the Issue should say (use linear-groom or inception).
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, AskUserQuestion
metadata:
  description-role: trigger
---

# Execute one Issue

One groomed Issue, one coherent change, driven to Done in this session.

The Issue already says **what** to build; this skill decides **how** and does it.
Everything runs inline — no executor subagents, no dependency graph, no wave
scheduling. That lightness is the point: `orchestration-toolkit-orchestrate`
exists for work that genuinely needs delegation, and paying its control-plane cost
for a single node buys nothing.

Apply `linear-base` for Linear mechanics, installed llm-wiki skills for durable
knowledge, `wtm-worktree` for worktree operations, and `git-helpers-commit` for
every commit.

## Invariants

- One Issue produces one coherent, independently reviewable change on one branch.
- Linear owns executable state and the running record; llm-wiki owns durable
  design and decision rationale; the repository owns implementation reality.
- The Issue's acceptance is the target. Reject speculative features, future-only
  flexibility, and abstractions without a present second use.
- Never silently resolve a one-way-door decision with a plausible default.
- Keep Linear identifiers and URLs out of branches, commits, repository files, and
  PR text, as required by `linear-base`.
- Do not rewrite the Issue's requirements. Re-grooming is a separate operation.

## The decision split

The Issue fixes the What, but decisions still arise underneath it. Sort each one
on two axes — **blast radius** (how much breaks if the call is wrong) and
**reversibility** (how costly it is to undo).

- **Two-way door** (low blast radius AND easy to reverse) → decide it, record one
  line in the Decision Log, keep moving.
- **One-way door** (high blast radius OR hard to reverse) → do not guess. Add it
  to the Parking Lot, skip the parts that depend on it, and keep driving the rest.

Do not drip-feed questions while driving. A hard decision goes to the Parking Lot,
not to the user; the Parking Lot is reviewed in one pass at the end. A wrong
reversible call costs one cheap retry, so spend autonomy there; a wrong
irreversible call can cost the whole run, so spend the user's attention there.

## Workflow

### 1. Bind the run to the Issue

Read the Issue in full: description, acceptance, comments, labels, relations, and
status. Then confirm it is actually executable:

- its acceptance is observable — a human could confirm it from outside the code;
- it is self-complete under `linear-base` (no unstated dependency on another
  Issue's outcome);
- any `blocked by` relation is Done.

If a blocker is open, stop and say so. If the Issue belongs to a Project with
other ready Issues that depend on each other, this is the wrong skill — hand off
to `orchestration-toolkit-orchestrate`.

Move the Issue to In Progress if it is not already. When entered from
`linear-start`, the status and workspace are already prepared; do not redo them.

### 2. Recover the knowledge surface

Use `llm-wiki-overview` or `llm-wiki-retrieve` to find the PRDs, designs,
research, and decision records the Issue depends on. Search from the Issue's own
terminology rather than loading the whole wiki, and follow only the links needed
to interpret scope, constraints, or acceptance.

Note any contradiction between the Issue, the wiki, and the repository. Linear is
authoritative for current execution state, llm-wiki for durable rationale, and the
repository for actual behavior. A material contradiction is a Parking Lot entry,
not something to resolve by preference.

### 3. Prepare the workspace

Recover or create the Issue's worktree through `wtm-worktree`, based on the
repository's normal target branch. Name the branch after the deliverable, never
after the Linear identifier, and record the Issue in the worktree note.

### 4. Open the run record

Post one comment on the Issue before driving:

```markdown
## Run — <timestamp>

### Approach

<how this will be built, in a few lines — the How, not a restated What>

### Knowledge inputs

<llm-wiki notes and repository facts this run depends on>

### Progress

- [ ] <step>

### Decision Log

### Parking Lot
```

This is the running record. Do not also keep a local plan file: the Issue is the
durable state, and a second copy on disk only goes stale.

### 5. Drive inline

Work the Progress list top to bottom.

- Implement in this session. Commit frequently through `git-helpers-commit`.
- Apply the decision split to every call that arises.
- When a step is blocked only by a parked decision, skip it and continue.
- Update the record at meaningful boundaries and before the session ends by
  posting a fresh checkpoint comment — one current snapshot of Progress, Decision
  Log, and Parking Lot, not an event log. Do not copy diffs or test output into
  Linear; git holds those. The record carries the judgment git cannot.

If the Parking Lot fills faster than Progress — most steps need a parked decision
— the Issue was not groomed enough to execute. Stop, post what you found, and
route to `linear-groom` (the requirements need settling) or `inception` (the
concept itself is unformed).

If the run must pause mid-Issue, use `linear-handoff` so a different session can
resume from the Issue alone.

### 6. Verify

Check the result yourself first: every acceptance item satisfied with observable
evidence, scope not exceeded, unrelated user changes preserved, no unjustified
abstraction, required tests and repository checks run with their raw outcomes.

Then decide whether an independent pass is warranted. Call
`artifact-review-toolkit-adversarial` with `scope: node` when the change has any
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

Bring the Parking Lot back in one pass: for each entry, the decision, why it was
parked, what it blocks, the options, and your leaning. Decide them with the user,
move each resolution into the Decision Log, then finish the work that was blocked.

When nothing remains open, post the completion note required by `linear-base`
with:

- the acceptance table — each criterion mapped to observable evidence;
- the commits produced;
- autonomous decisions and their rationale;
- adversarial findings, or the recorded reason none were sought;
- residual risks and verification gaps.

Move the Issue to In Review, or to Done when the repository's convention allows
closing without a separate review step. A PR is optional; open one only when
separately authorized.

## When NOT to use

- Several Issues with dependencies between them → `orchestration-toolkit-orchestrate`.
- No Issue behind the work — an ad-hoc task to run autonomously → `exec-plan`.
- The Issue's requirements are not settled → `linear-groom`.
- The concept itself is unformed → `inception`.
- A trivial change with self-evident completion → just do it and note it on the Issue.

## Success criteria

- [ ] The Issue's acceptance was checked as executable before driving, and its blockers were Done.
- [ ] The run record lives on the Issue and reconstructs Progress, Decision Log, and Parking Lot without conversation history.
- [ ] Every decision was sorted by the two-axis split; no one-way door was resolved with a default.
- [ ] The run advanced every Progress item not blocked by a parked decision, and the Parking Lot was reviewed in one pass.
- [ ] Independent adversarial review was run, or its absence was recorded with the risk assessment that justified it.
- [ ] The completion note maps every acceptance criterion to observable evidence or an explicit gap.
