---
title: "goal-loop — Design Rationale"
date: 2026-06-24
type: decision
status: accepted
tags:
  - goal-loop
  - loop-engineering
  - agent-harness
  - agent-skills
  - design-rationale
summary: >
  Why the goal-loop skill exists, what it refuses to do, the philosophy behind
  its structural completion contract, and the decision record — including where
  it deliberately diverges from Codex /goal. Concrete file names are confined to
  the final section so the rationale survives renames.
---

# goal-loop — Design Rationale

This is the durable record of *why* the goal-loop skill is shaped the way it is.
It is layered so the upper sections stay true as the code churns: motivation and
problem framing are near-invariant, the philosophy is invariant, the decision
record is semi-invariant, and only the last section names concrete files.

Throughout, components are referred to by **role** — *the scaffolder*, *the
evaluator* (the sole writer of predicate results), *the driver*, *the builder*,
*the guard* — not by file name. The role-to-file mapping lives in the last
section.

Background research: [2026-06-11-loop-engineering-research.md](./2026-06-11-loop-engineering-research.md).

## 1. Motivation

Recent coding-agent practice splits into two complementary halves (research note
§3): **spec-driven development**, where a human contract is fixed before
implementation, and **loop engineering**, where an agent is handed a target and
left to converge on it autonomously. The dev-workflow skill family already covers
the spec-driven half. goal-loop covers the loop-engineering half.

The concrete trigger was a portability gap. Codex ships a built-in `/goal`
command that runs a durable, autonomous objective to completion. That capability
is valuable but host-locked: it does not exist on agents without it. goal-loop is
the portable, self-managed realization of the same idea — a bounded autonomous
loop that any agent with a shell can run — built so the completion guarantee does
**not** depend on the host providing a goal primitive.

## 2. Problem framing — what it solves, what it refuses

goal-loop solves one problem: **turning a clear target with an external
completion oracle into finished work, without a human steering each step**.

It is eligible only when **every** completion criterion can be checked by an
executable predicate or an external reference (a test suite, a build, a benchmark,
a reference implementation, an existing spec). This is the "oracle test."

It **refuses** work whose "done" lives in a human's head — taste, UX, product
fit, "looks right." A loop can converge on a fixed target but cannot discover
hidden alignment information; if the oracle is missing, no amount of looping finds
it, and a strong loop on a weak predicate mass-produces polished output that meets
the letter of the predicate and misses the intent (Goodhart's law). Such work
belongs in a spec-driven workflow *before* implementation. When a criterion is
mixed, it is split: the machine-verifiable part runs in the loop, the human-judged
part routes to the spec flow.

This refusal is the point, not a limitation. goal-loop is deliberately narrow so
that *inside* its scope the completion signal is trustworthy.

## 3. Core philosophy

**Completion is structural, not asserted.** "Done" is not the builder declaring
it done. A single component — the evaluator — is the only thing that can record a
criterion as satisfied, and it does so only after that criterion's command has
actually exited successfully, with the run kept as evidence. Asking a model to
report honestly is unreliable; making "done" a structural property of the harness
is not (research note §2).

**Probabilistic orchestration, deterministic guarantees.** The parts that benefit
from intelligence — deciding what to change, writing the change — are left to a
probabilistic agent. The parts that must not be faked — what counts as done, when
to stop — are deterministic scripts. The guarantee never rides on the model's good
behavior; the model's creativity is never constrained by the guarantee.

**Default-FAIL.** Every criterion starts unsatisfied and is moved to satisfied
only by evidence. There is no path by which a criterion is assumed true. The state
is scaffolded by a script rather than hand-written, so the contract holds from the
first byte.

**Bounded by construction.** The loop cannot run forever. It stops when all
criteria pass, when a criterion is genuinely stuck (the same failure twice with no
observable change), or when a hard iteration ceiling is reached. Stopping short is
reported as *blocked*, which is not a failure — it is the loop refusing to fake
completion and handing control back.

**Fresh context per round.** Each implementation pass runs as a fresh process, so
it never reviews — and never flatters — its own prior work. Continuity is carried
by the durable contract and the recorded findings, not by an accumulating
conversation.

**Honest by portability.** The guarantee holds with no host integration at all.
Where a host offers more (hooks, native goal state), those are additive
optimizations layered on top of an already-safe core, never preconditions.

## 4. Decision record

Each decision is framed as a question, the options weighed, the choice, and why
the alternatives were rejected.

### D1 — When is a loop the right tool at all?
**Options:** (a) always loop; (b) never loop, always write a spec first; (c) route
by where the completion oracle lives.
**Choice:** (c). Run the loop only when the oracle is external and every criterion
is predicate-able; otherwise route to the spec flow.
**Why not the others:** (a) mass-produces work against an absent target; (b)
throws away loop engineering's real wins on porting, migration, and
command-verifiable bug fixes.

### D2 — Who decides "done"?
**Options:** (a) the builder asserts completion (this is how Codex `/goal` works —
the model calls an `update_goal` tool whose only power is to mark the goal
complete, and the loop auto-continues until it does or a budget is hit); (b) a
human confirms each completion; (c) a separate evaluator gates completion on
executable predicates and is the only writer of predicate results.
**Choice:** (c).
**Why not the others:** (a) makes the completion signal a model assertion — the
exact false-"done" failure mode the harness exists to prevent; (b) defeats the
purpose of an autonomous loop. This is goal-loop's deliberate divergence from
`/goal`: same goal-contract shape, but completion is *predicate-gated* rather than
*model-asserted*. On this axis goal-loop is intentionally stricter than the tool
that inspired it.

### D3 — Where does the guarantee live?
**Options:** (a) in prompt discipline ("please don't fake it"); (b) in a host hook
that blocks tampering; (c) in a sole-writer component that is the only thing able
to record completion.
**Choice:** (c), with (b) as an additive layer where the host supports it.
**Why not the others:** (a) is the unreliable channel by definition; (b) alone
would make correctness depend on a specific host. The sole-writer design keeps the
contract intact on any host; the hook, where present, makes it structural rather
than merely conventional.

### D4 — One long context or a fresh context each round?
**Options:** (a) one continued thread that accumulates context (the `/goal`
model); (b) a fresh builder process each round.
**Choice:** (b).
**Why not (a):** an agent that sees its own prior reasoning tends to ratify it and
to drift as context rots. A fresh pass each round, re-grounded on the durable
contract and the latest recorded findings, is the loop-engineering ("Ralph")
discipline. The cost — no accumulated working memory — is paid by writing the
failing-criterion evidence forward between rounds.

### D5 — How is the loop bounded?
**Options:** (a) a token budget with a soft stop (the `/goal` model); (b)
wall-clock time; (c) an iteration ceiling plus stall detection.
**Choice:** (c).
**Why not the others:** token accounting is not portably available across hosts,
and wall-clock is noisy. An iteration ceiling is a hard backstop; stall detection
is the nuanced bound — see D6.

### D6 — How is a stall detected without killing a converging loop?
**Options:** (a) block after N consecutive failures; (b) block only on *no
observable progress*.
**Choice:** (b). On each failure the evaluator computes a signature from the exit
code and output; an identical signature twice in a row means the builder changed
nothing observable and the criterion is stuck, while a changing signature resets
the count (the builder is moving — give it another round). A criterion that emits
no output carries no progress signal and so is bounded by the iteration ceiling
rather than fast-failed.
**Why not (a):** a naive counter kills any criterion that legitimately takes more
than N rounds to satisfy.

### D7 — Are already-satisfied criteria re-checked?
**Options:** (a) latch a criterion once it passes (cheaper — never re-run it); (b)
re-evaluate every criterion every round.
**Choice:** (b).
**Why not (a):** latching admits a false *complete* — a later round can regress an
earlier criterion, and a latched harness would never notice. Completion must mean
"all criteria pass against the final state simultaneously," so a regression flips
a criterion back to unsatisfied. The cost is re-running passing checks; correctness
outranks it.

### D8 — What is the single runtime dependency?
**Options:** (a) a language runtime (e.g. Python); (b) a compiled binary; (c)
shell plus `jq`.
**Choice:** (c).
**Why not the others:** a portable harness should not assume a language runtime or
ship a platform-specific binary. `jq` is a single, ubiquitous dependency; each
script checks for it and fails with a clear message if it is absent.

### D9 — Does the entry point auto-activate?
**Options:** (a) let the agent invoke it heuristically; (b) explicit user
invocation only.
**Choice:** (b), via the standard Agent Skills fields for user-invocable,
non-model-invocable skills.
**Why not (a):** committing to a long autonomous run is a decision the user should
make deliberately, not one an agent should infer.

## 5. Current implementation

This section is the volatile layer: names and layout only, kept thin. The code is
the source of truth.

- **The skills** live in `skills/goal-loop/`:
  - `goal-loop/` — the entry skill (the role driving D1–D9 end to end); explicit
    invocation only.
  - `goal-loop-base/` — shared resources delegated to by name:
    - `references/goal-contract-template.md` — the goal contract structure
      (Why / Target / Boundaries / Predicates / Stop Conditions).
    - `references/state-schema.md` — the completion-state schema, the Default-FAIL
      contract, stall detection, loop pseudocode, and stop conditions.
    - `scripts/init.sh` — *the scaffolder*: writes a Default-FAIL state file.
    - `scripts/verify.sh` — *the evaluator / sole writer of predicate results*:
      runs every predicate, records evidence, recomputes status (D2, D3, D6, D7).
    - `scripts/loop.sh` — *the driver*: fresh builder pass then evaluation, each
      round (D4, D5). On its own round cap it records a terminal `blocked` status,
      but never writes predicate results.
- **Durable artifacts** for a run live in `.agents/goals/{yyyy-mm-dd}-{slug}/`:
  the human-readable goal contract (`goal.md`) and the machine state
  (`state.json`).
- **The builder** is host-supplied (any command that reads the contract and edits
  the codebase as a fresh process) — `claude -p`, `codex exec`, a make target, a
  shell function.
- **The optional second-pass evaluator** (`--evaluator-cmd`) can reopen the loop
  after predicates pass; it is advisory and cannot itself mark completion.
- **Claude Code add-on** (opt-in, never required) lives in
  `opts/claude/skills/goal-loop/`: a driver wrapper that defaults the builder to a
  fresh `claude -p`, a PreToolUse *guard* that denies direct edits to the state
  file (making D3 structural), and SessionStart/Stop hooks that surface and nudge
  an active run. Installed via `scripts/install-opts.sh claude`. With the add-on
  absent, nothing breaks — the evaluator is still the sole writer of predicate
  results and the scaffolder still creates the state.

### Mapping to Codex /goal (reference)

| Concern | Codex `/goal` | goal-loop |
|---|---|---|
| Goal contract | objective / out-of-scope / validation / stop | Why / Target / Boundaries / Predicates / Stop |
| Completion (D2) | model marks complete via `update_goal` | predicate-gated by the evaluator |
| Progression (D4) | continued thread | fresh process per round |
| Bound (D5) | token budget + soft stop | iteration ceiling + stall signature |
| State store | SQLite app-server, `goal_id` versioned | files under a goal directory |
| Anti-tamper | asymmetric tool space (model can only mark complete) | sole-writer evaluator + optional guard |

Sources for the `/goal` mechanics: OpenAI Codex docs —
[Follow a goal](https://developers.openai.com/codex/use-cases/follow-goals),
[Slash commands](https://developers.openai.com/codex/cli/slash-commands); and a
community implementation analysis
([gist](https://gist.github.com/patleeman/b1b5768393f9bf2f60865b1defeeb819),
[openai/codex#20536](https://github.com/openai/codex/issues/20536)).
