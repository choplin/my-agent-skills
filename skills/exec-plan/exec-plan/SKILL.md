---
name: exec-plan
description: >-
  Invoked by the user (e.g. /exec-plan) or auto-activated when a task clearly fits; also reachable via
  dispatch-work. Agree on a rough goal
  and direction, then run autonomously as far as possible. Write a self-contained, ExecPlan-style
  plan and drive it inline: resolve low-risk, reversible decisions on your own (recorded in a
  Decision Log) and park high-impact or hard-to-reverse decisions in a Parking Lot for a single
  batch review at the end. Use for "run as far as you can without me", "rough goal, drive it
  yourself and ask me the big calls later", "do whatever doesn't need my judgment". Lighter than
  goal-loop (no executable predicates required) and dev-workflow (no up-front spec or approval
  gate). Not for work where most steps need human judgment, where completion should be gated on
  executable predicates (use goal-loop), where requirements must be decided up front (use
  dev-workflow-create-spec), or for shaping a still-fuzzy concept (use inception).
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, AskUserQuestion
---

# Exec Plan

Agree a rough goal, then run as far as you can on your own — and bring the
decisions that were too big to make alone back for one batched discussion at the
end.

This drives the self-contained ExecPlan-style plan file defined in
`exec-plan-base` (read it for the format, location, and the properties that keep a
plan restartable), with **one deliberate change** to the ExecPlan model: it does
*not* resolve every ambiguity autonomously. Reversible, low-impact calls are
decided on the spot and logged; high-stakes calls are parked and reviewed together
at the end. Everything else (single living plan, embedded knowledge, observable
acceptance, frequent commits) is kept, because that is what makes a plan drivable
without a human in the loop.

## Core idea

Maximize how far the agent can self-drive, without making the calls that should be
the user's. The whole skill turns on one split applied to every decision:

- **Two-way door** (low blast radius AND easy to reverse) → decide it yourself,
  write one line in the **Decision Log**, keep moving.
- **One-way door** (high blast radius OR hard to reverse) → do not guess. Add it
  to the **Parking Lot**, skip the parts that depend on it, and keep driving
  everything else.

This is the difference from `goal-loop`: goal-loop *refuses* a task whose
completion needs human judgment, and stops when judgment is needed. exec-plan
*expects* a few such decisions, sets them aside, and runs the rest to the end —
then discusses the parked ones in a single pass.

## The decision split — what to drive through, what to park

When a decision appears, score it on two axes:

- **Blast radius** — how much breaks, and how far it reaches, if the call is wrong.
- **Reversibility** — how costly it is to undo once it's in.

Both low → drive through and log it. Either one high → park it.

Why split this way: a wrong reversible call costs one cheap retry; a wrong
irreversible call can cost the whole run (Goodhart-style — a fast agent confidently
building on a bad one-way decision mass-produces work against the wrong target).
Spend autonomy on the cheap calls; spend the user's attention on the expensive
ones — batched, at the end, when the full picture is visible.

There is no fixed numeric threshold. The two axes are the guide; the agreed
**Boundaries** (below) record whatever concrete lines the user *did* draw.

## Workflow

### 1. Agree the direction and draft the plan

Keep this light — this is the part that stays "rough". Do **not** run a heavy
interview (that's `dev-workflow`) or a thinking session (that's `inception`). A
short `discuss-toolkit-quick-chat`, or `discuss-toolkit-dig` only if the goal is
genuinely unclear, is enough.

Settle just three things and write them into the plan file:

- **Purpose** — what we want and why; the direction, agreed at a "roughly right"
  level, not a complete spec.
- **Boundaries** — what the agent is free to decide, what to park, what not to
  touch. This is where the user pre-draws any lines they care about; the rest is
  judged live by the two-axis split.
- **Acceptance** — observable behavior a human can confirm. This is a self-checked
  target, *not* a machine gate; if you need completion gated on executable
  predicates, use `goal-loop` instead.

Write the plan to the location and format defined in `exec-plan-base` (read it
first). In this skill's terms, **Decision Log** holds the two-way-door calls you
make while driving, and **Parking Lot** holds the one-way-door calls you defer for
the end. Confirm the direction with the user at a "good enough to start" level —
not a sign-off gate.

### 2. Drive autonomously, deferring the big calls

Run the plan **inline** in this session — no subagent and no fresh-context driver
are required (that lightness is the point; reach for them only if the user asks).

- Work the **Progress** list top to bottom. Embed the knowledge each step needs in
  the plan as you learn it, so the plan stays restartable on its own.
- Apply the split to every decision: two-way door → do it and add a Decision Log
  line; one-way door → add a Parking Lot entry and move on.
- When something is blocked only by a parked decision, **skip it** and keep going
  on what isn't blocked.
- Do **not** check in step by step or ask the user "what next" mid-run. The only
  thing that would normally interrupt you — a hard decision — goes to the Parking
  Lot instead of to the user. You surface everything at once in step 3.
- Keep the plan a living document: update Progress (with timestamps), Decision Log,
  Parking Lot, and Surprises as you go. Commit frequently.

"As far as you can" = every Progress item that isn't blocked by a Parking Lot
entry is done, or you genuinely cannot advance further without a parked decision.

### 3. Batch-review the Parking Lot

Stop and bring it all back together:

1. Present the **Parking Lot** as a list — for each: the decision, why it was
   parked (which axis was high), what's blocked on it, the options, and your
   leaning if you have one.
2. Give a short digest of the **Decision Log** (what you already decided and why)
   and the **Acceptance** status, plus anything left unfinished.
3. Decide the parked items **together**. Move each resolution into the Decision
   Log, then implement the parts that were blocked and finish the run.

The user reviews a finished-as-far-as-possible artifact plus a tight list of real
decisions — not an up-front plan, and not a stream of mid-run questions.

## Gotchas

- **Don't fake a one-way decision with a default.** A high-stakes call doesn't
  become safe by picking a "reasonable default" and moving on — that's the exact
  failure this skill avoids. Park it.
- **Don't drip-feed questions mid-run.** Decide the cheap calls yourself; park the
  expensive ones. The user gets one batched discussion, not interruptions.
- **Keep the plan in sync.** If Progress / Decision Log / Parking Lot drift from
  reality, the run stops being restartable and the final review can't be trusted.
- **If the Parking Lot is filling up faster than Progress** — most steps need a
  parked decision — this task isn't a fit. Stop and route to `dev-workflow` (decide
  requirements first) or `inception` (the concept isn't shaped yet).

## Success criteria

- [ ] Purpose, Boundaries, and Acceptance were agreed with the user (roughly) and written to the plan file before driving.
- [ ] The plan is self-contained — a fresh reader could resume from it alone.
- [ ] Every decision was sorted by the two-axis split: reversible/low-impact → Decision Log; high-impact/irreversible → Parking Lot.
- [ ] No high-stakes decision was silently resolved with a default.
- [ ] The run advanced every Progress item not blocked by a parked decision.
- [ ] The Parking Lot was reviewed with the user in one pass, resolutions logged, and the blocked work then finished.

## When NOT to use

- Most steps need human judgment as you go → `dev-workflow` (or just collaborate directly).
- Completion can and should be gated on executable predicates → `goal-loop`.
- Requirements must be decided before "done" can be defined → `dev-workflow-create-spec`.
- The concept itself is still fuzzy and needs shaping → `inception`.
- You only want to write down where the current session has gotten to — goal,
  decisions, progress, what's left — without driving anything → `exec-plan-record`.
- A quick one-off change with nothing to defer → just do it.
