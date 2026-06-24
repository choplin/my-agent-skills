---
name: goal-loop
description: >-
  Invoked explicitly by the user (e.g. /goal-loop); this skill does NOT auto-activate. Run a bounded
  autonomous implement->verify loop after the user's What is clear and completion can be checked by
  executable predicates. A portable, predicate-gated counterpart to Codex /goal (completion is gated on
  executable predicates, not asserted by the model): clarify the What with dig,
  write a compact Goal Contract, scaffold default-fail predicates, then run a bounded builder -> verify
  (-> optional evaluator) loop until executable checks pass. Use it for "run this as a goal", "goal loop",
  "while-true loop", "let the agent finish this autonomously", "full-bet on the agent", porting/cloning/
  migration tasks with tests or a reference implementation, or bug fixes whose done state is
  command-verifiable. Not for cases where the right answer depends on unexpressed product judgment, taste,
  UX review, or human-only acceptance; route those to a spec-driven workflow (dev-workflow-kickoff) instead.
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill
---

# Goal Loop

Run a bounded loop-engineering harness once the user's What is clear and the
completion oracle lives outside the user's head.

This skill is a portable, predicate-gated counterpart to Codex `/goal`. It keeps
the same Goal Contract shape, but where `/goal` lets the model declare completion,
this skill gates completion on executable predicates (see
`docs/2026-06-24-goal-loop-design.md` D2). When the host provides a native goal
mechanism, use it — but keep the same Goal Contract and Default-FAIL evidence
discipline so the workflow works on agents without `/goal`.
The bundled scripts are **shell + `jq` only** (no Python, no compiled binary), so
the loop runs anywhere a shell and `jq` exist.

## Core principle

Only run the loop when **every** completion criterion can be checked by an
executable predicate or an external reference.

Why: a loop can converge on a fixed target, but it cannot discover hidden
alignment information. If "done" requires the user to judge direction, taste, UX,
or product fit, that missing information belongs in a spec-driven workflow before
implementation — not in a predicate
(`docs/2026-06-11-loop-engineering-research.md` §3, "where the oracle lives").

## How completion is kept honest (works without hooks)

"Done" is structural, not a matter of the builder asserting it — and this holds
on **any** host, with no hook required:

- `state.json` is scaffolded by `init.sh` and written **only** by `verify.sh`,
  which flips a predicate's `passes` to `true` solely after its command exits 0.
- The builder modifies the codebase, never `state.json`.

Where a host offers hooks (e.g. Claude Code's opt-in add-on), a PreToolUse guard
*additionally* denies direct edits to `state.json` and SessionStart/Stop hooks
surface and resume an active loop. Those are **optimizations layered on top** of
the already-safe core — never a prerequisite. See "Host add-ons" below.

## Workflow

### 1. Clarify What with dig

Apply the `discuss-toolkit-dig` skill before writing the Goal Contract.

Give dig this context (purpose and subject only — do not prescribe exact
questions; let dig run its own interview):

- **Subject**: the autonomous goal-loop contract for the user's task.
- **Purpose**: identify the exact goal, why it matters, the external oracle, the
  boundaries, and the stop conditions before starting an autonomous loop.
- **Quality bar**: every completion criterion must become an executable
  predicate, or the task is not eligible for this skill.

If `discuss-toolkit-dig` is unavailable, run the same interview inline using the
host's user-input mechanism. Never fill gaps with assumptions.

### 2. Run the oracle test

Classify the task before implementing:

| Question | If yes | If no |
|----------|--------|-------|
| Can the outcome be stated as a compact goal without a separate requirements document? | Continue | Route to a spec-driven workflow |
| Can every completion criterion be verified by a command, benchmark, snapshot comparison, reference implementation, or existing spec? | Continue | Route to a spec-driven workflow |
| Would a human-only criterion (`looks right`, `feels good`, `UX is acceptable`, `user approves`) be needed? | Route to a spec-driven workflow | Continue |

If a criterion is mixed, split it: run the loop only for the machine-verifiable
part and route the human-judged part to the spec flow. If `dev-workflow-kickoff`
is available, it is a suitable spec-driven fallback.

### 3. Write the Goal Contract

Before editing any implementation file, write a compact contract. For work that
may span a context reset, persist it under
`.agents/goals/{yyyy-mm-dd}-{slug}/goal.md`, with `state.json` beside it.

Apply the `goal-loop-base` skill (`references/goal-contract-template.md`) for the
exact structure (Why / Target / Boundaries / Predicates / Stop Conditions). Then
scaffold `state.json` with the base skill's `scripts/init.sh` — do **not**
hand-write it:

```bash
init.sh --goal-dir .agents/goals/{yyyy-mm-dd}-{slug} \
  --predicate 'tests::{test command}' \
  --predicate 'lint::{lint command}' \
  --max-iterations 20
```

Every predicate starts `passes: false` (Default-FAIL). See the `goal-loop-base`
skill (`references/state-schema.md`) for the full schema and the stall-detection
rule. If `goal-loop-base` is unavailable, inline the same structure from memory:
a Goal Contract with executable predicates and a `state.json` whose predicates all
start `false`.

### 4. Run the loop

Read `references/state-schema.md` (loop pseudocode) before running. The loop
alternates a fresh-context **builder pass** (implement the smallest change set
that can make a failing predicate pass) with a **verify pass** (the only writer
of predicate results in `state.json`).

**If a loop driver is available**, use it. The `goal-loop-base` skill bundles
`scripts/loop.sh`:

```bash
loop.sh --goal-dir .agents/goals/{yyyy-mm-dd}-{slug} \
  --builder-cmd '{fresh-context agent command}' \
  --max-rounds 20
```

Add `--evaluator-cmd '{command}'` only when an independent second pass adds value
after predicates pass (snapshot review, API-compat check, a separate agent
review). The builder is host-supplied: on Claude Code use `claude -p '<builder
prompt>'`; on Codex use `codex exec`; on any host, any command that reads
`GOAL_FILE`/`GOAL_STATE`/`NEXT_FINDINGS` and edits the codebase. Each round runs
the builder as a fresh process, so it never reviews its own prior work.

**If no driver is available**, run the loop inline in this session (bounded):

1. Read `goal.md`, `state.json`, and `NEXT_FINDINGS.md` if present. Pick a
   predicate that is still `false`.
2. Implement the smallest change set that could make it pass. Do **not** edit
   `passes` directly; do **not** delete or weaken predicates or tests.
3. Run `verify.sh <goal-dir>` (the only sanctioned state writer).
4. Fix only failures that affect the Goal Contract. Do not chase optional
   refactors or reviewer suggestions outside the contract
   (`docs/...research.md` warns that chasing every finding over-engineers).
5. Repeat until `status` is `complete` or `blocked`. Respect the bounds:
   `max_iterations` and the stall rule (same error twice in a row → `blocked`).

### 5. Stop on drift

Stop the loop and route to a spec-driven workflow when implementation reveals:

- a predicate cannot be written without adding product judgment;
- the desired behavior conflicts with existing tests or documented contracts;
- the task has split into multiple independent deliverables;
- the agent would need permission to change scope, delete tests, rewrite public
  APIs, or accept a trade-off the user did not confirm.

Why: continuing after the oracle disappears turns cheap retries into repeated
work against the wrong target (Goodhart's law — a strong loop on a weak predicate
mass-produces polished garbage).

### 6. Finish

When `status` is `complete`:

1. Run any repository-standard formatting, lint, and test commands that are part
   of normal verification.
2. Summarize the implemented change and list each predicate's evidence.
3. Present the **finished artifact** for human review. The user reviews the
   result, not an up-front plan.

When `status` is `blocked`, hand back with `blocked_reason` and the failing
predicate (or the missing oracle) named. Blocked is not failure — it is the loop
refusing to fake completion.

## Host add-ons (opt-in, never required)

The core above runs on any host. Where a host can do more, an opt-in add-on
layers structural enforcement and convenience on top:

- **Claude Code**: the `goal-loop` opt-in plugin under `opts/claude/skills/goal-loop/`
  adds a PreToolUse hook that denies direct edits to `state.json` (structural
  Default-FAIL), SessionStart/Stop hooks that surface and nudge an active loop,
  and a `loop.sh` wrapper that defaults `--builder-cmd` to `claude -p`. Install
  with `scripts/install-opts.sh claude`.

If the add-on is absent, nothing breaks: the contract still holds because
`verify.sh` is the only writer of predicate results and `init.sh` is the only
scaffolder.

## Success criteria

- [ ] The Goal Contract has a user-confirmed Why, Target, Boundaries, Predicates, and Stop Conditions.
- [ ] Every predicate is executable or tied to a concrete external reference; none require human judgment.
- [ ] `state.json` was scaffolded by `init.sh` in default-fail state, and is written only by `verify.sh`.
- [ ] Every passing predicate has evidence from an actual command run.
- [ ] The loop stops as `complete` only when all predicates pass, and as `blocked` only when a stop condition is met (named).
- [ ] No implementation-scope decision was added unless it is in the Goal Contract or confirmed by the user during the loop.

## When NOT to use

- The right answer depends on taste, UX, or product judgment → a spec-driven workflow (`dev-workflow-kickoff`).
- Requirements must be decided before "done" can be defined → `dev-workflow-create-spec`.
- A quick one-off change with no need for a verification loop → just do it.
