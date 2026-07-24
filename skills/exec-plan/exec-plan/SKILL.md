---
name: exec-plan
description: >-
  Invoked explicitly or via dispatch-work for a clear, near-horizon goal whose
  route is visible enough to plan and drive inline. Pin the direction, resolve
  reversible calls autonomously, and park the few high-impact decisions for one
  batch review at the end. Lighter than native /goal, which fits distant outcomes
  whose route must be discovered or reorganized while working; unlike
  dev-workflow, exec-plan has no spec or phase-approval gates. Not for work where
  most steps need human judgment, requirements must be decided up front, or the
  concept itself is still fuzzy.
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
the user's. Two things are treated very differently:

- **Direction** — the overall approach and how the goal is interpreted. This is
  *not* a decision to defer. Pin it up front with the user; it is cheap because it
  is one high-altitude thing, not a spec. A silently-resolved direction is exactly
  where "that's not what I expected" comes from — and it is never a detail.
- **Detail decisions** — everything that arises *under* an agreed direction. These
  are what get deferred, and deferring them is the source of the fast start. Each
  one is sorted by a single split:

  - **Two-way door** (low blast radius AND easy to reverse) → decide it yourself,
    write one line in the **Decision Log**, keep moving.
  - **One-way door** (high blast radius OR hard to reverse) → do not guess. Add it
    to the **Parking Lot**, skip the parts that depend on it, and keep driving
    everything else.

This is the difference from native `/goal`: `/goal` keeps a persistent, possibly
distant outcome attached while Codex discovers and revises the route across
multiple stages. exec-plan starts closer to the work: the direction and most of
the route are already visible enough to write a self-contained plan. It sets
aside the few decisions that should not be guessed, runs the unblocked plan to
the end, then discusses the parked decisions in a single pass.

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

### 1. Draft the direction and plan

Keep this light. Do **not** run a heavy interview (that's `dev-workflow`) or a
thinking session (that's `inception`). A short back-and-forth, or
`discuss-toolkit-dig` only if the goal is genuinely unclear, is enough.

Settle just three things and write them into the plan file:

- **Purpose** — the direction: the approach and how the goal is interpreted, pinned
  to a definite line, but without a full spec. "Rough" refers to the *absence of a
  spec*, not to an unsettled direction — the direction itself is not left open.
- **Boundaries** — what the agent is free to decide, what to park, what not to
  touch. This is where the user pre-draws any lines they care about; the rest is
  judged live by the two-axis split.
- **Acceptance** — observable behavior a human can confirm. This is a self-checked
  target, *not* a persistent long-horizon goal; if reaching the outcome requires
  discovering or repeatedly restructuring the route, use native `/goal` instead.

Write the plan to the location and format defined in `exec-plan-base` (read it
first). In this skill's terms, **Decision Log** holds the two-way-door calls you
make while driving, and **Parking Lot** holds the one-way-door calls you defer for
the end.

### 2. Preview the direction, then start

Before driving, play the direction back to the user — the mirror image of the
end-of-run review — so a wrong direction is caught now, when correcting it is
cheap. Three parts, kept tight:

1. **Direction I'm committing to** — the approach, stated as a definite line.
2. **What I'll decide as I go** — the ambiguities that remain *at direction level*
   and are reversible, which I'll resolve myself and log. List only the ones
   visible now; do **not** enumerate every small call (that's a spec — the thing
   this skill exists to avoid).
3. **What I'll bring back to you** — anything already visible as a one-way door,
   previewed as a Parking Lot entry.

Then take one light beat: give the user a chance to correct the direction, and
**proceed by default if there's nothing to change**. This is a course-correction
window, *not* a sign-off gate — silence means go. Fold any correction into the
plan before driving.

### 3. Drive autonomously, deferring the big calls

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
  Lot instead of to the user. You surface everything at once in step 4.
- Keep the plan a living document: update Progress (with timestamps), Decision Log,
  Parking Lot, and Surprises as you go. Commit frequently.

"As far as you can" = every Progress item that isn't blocked by a Parking Lot
entry is done, or you genuinely cannot advance further without a parked decision.

### 4. Batch-review the Parking Lot

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

- **Don't defer the direction.** The two-axis split is only for decisions that
  arise *under* an agreed direction. The direction itself is pinned and previewed
  up front — never silently resolved as if it were a detail. That silent
  resolution is the "not what I expected" failure this skill exists to prevent.
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
- [ ] The direction was pinned, not deferred — and previewed to the user before driving (direction + what stays open + what's parked) with a light beat to correct.
- [ ] The plan is self-contained — a fresh reader could resume from it alone.
- [ ] Every decision was sorted by the two-axis split: reversible/low-impact → Decision Log; high-impact/irreversible → Parking Lot.
- [ ] No high-stakes decision was silently resolved with a default.
- [ ] The run advanced every Progress item not blocked by a parked decision.
- [ ] The Parking Lot was reviewed with the user in one pass, resolutions logged, and the blocked work then finished.

## When NOT to use

- Most steps need human judgment as you go → `dev-workflow` (or just collaborate directly).
- The outcome is distant and the route must be discovered or reorganized while
  working → native `/goal`.
- Requirements must be decided before "done" can be defined → `dev-workflow-create-spec`.
- The concept itself is still fuzzy and needs shaping → `inception`.
- A quick one-off change with nothing to defer → just do it.
