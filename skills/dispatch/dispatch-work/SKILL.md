---
name: dispatch-work
description: >-
  Single front door for STARTING a piece of work when you are unsure which execution mode fits.
  Invoked explicitly by the user (e.g. /dispatch-work); does not auto-activate. Assesses one thing —
  how "done" is decided and how much you stay in the loop — then RECOMMENDS an execution mode and lets
  the user make the final call: a fuzzy concept to shape (inception), a task whose completion is fully
  checkable by executable predicates (goal-loop), a rough goal to self-drive with the big calls batched
  for you at the end (exec-plan), or work that needs an up-front spec and approval/review gates,
  possibly across sessions (dev-workflow-kickoff). Use for "start this / which mode should I use /
  route this work / I don't know whether to spec it or just let you run". Not itself an executor, and
  it does not decide for you — it recommends, the user chooses, then it hands off.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Skill
user-invocable: true
disable-model-invocation: true
---

# Dispatch Work

One entry point for starting work. Decide **how "done" is decided and how much the
user stays in the loop**, then hand off to the engine that matches. This skill does
not implement, plan, or write documents itself — it routes.

## Why this exists

There are several task-driving skills, split along a single axis: **where the
completion oracle lives, and how much human judgment gates the work.** Picking the
wrong one is the common failure — spec-gating a task a loop could close on its own,
or turning an autonomous loop loose on work whose "done" only the user can judge.
This skill makes that one choice explicit — but **recommends, it does not decide.**
The final call of which mode to run is always the user's. Surface the best-fit
route with your reasoning, then let the user confirm or override.

## The one question

> **How is "done" decided, and how much do you want to stay in the loop?**

Everything hinges on this. Read the conversation, form a recommendation from the
routing table below — then **present it to the user and let them choose.** Do not
silently route, even when the answer looks obvious from context: the whole point of
this front door is to make the mode a deliberate, user-owned choice. Do not run a
full interview either (the chosen engine runs its own intake) — this is one question,
not a requirements dialogue.

## Routing table

Evaluate top to bottom; take the first row that fits.

| The work looks like… | Route to | Why |
|---|---|---|
| Still fuzzy — you don't yet know *what* to build; needs shaping before any execution | `inception` | No defined What means no oracle yet; shape the concept first |
| A clear task whose **every** completion criterion is an executable pass/fail (tests, build, a reference impl, a benchmark), and you want to hand it off | `goal-loop` | The oracle lives outside the user's head; a bounded implement→verify loop can close it |
| A rough goal you want driven **as far as possible autonomously**, with the few high-impact / hard-to-reverse decisions parked and batch-reviewed at the end — no up-front spec wanted | `exec-plan` | Most calls are reversible and cheap to self-drive; only the one-way doors need the user, once |
| Work that needs requirements **decided up front**, or benefits from a durable spec/plan, approval gates, self-review, or spans multiple sessions / a PR-review flow | `dev-workflow-kickoff` | The oracle is a human-authored contract; keep the human in the loop with tracked artifacts |

Tie-breakers:
- **goal-loop vs dev-workflow**: if *any* completion criterion needs human taste,
  UX, or product judgment, it is **not** goal-loop → route to dev-workflow-kickoff.
- **exec-plan vs dev-workflow**: does the work need a durable spec/plan and approval
  gates (dev-workflow), or just a rough goal and autonomy with a single batched
  review at the end (exec-plan)? When decisions must survive across sessions or be
  reviewed as they are made, choose dev-workflow.
- **exec-plan vs goal-loop**: exec-plan *expects* a few decisions that need the user
  and parks them; goal-loop *refuses* work whose completion needs judgment. If
  completion is fully predicate-checkable, prefer goal-loop.

The routing table is how *you* reason about fit — not a verdict you impose. Turn
your best-fit row into a recommendation, then hand the decision to the user.

## Present the recommendation and let the user choose

Always ask, using a single `AskUserQuestion`. Put your recommended mode first and
mark it as the recommendation with a one-line reason; list the other three as
selectable alternatives so the user can override. Adapt the wording to the task:

- **実行可能なチェックで完了判定できる／任せきりにしたい** → goal-loop
- **だいたい任せて、重い決定だけ最後にまとめて相談したい** → exec-plan
- **先に仕様を固め、承認・レビューしながら進めたい（複数セッションを跨ぐ）** → dev-workflow-kickoff
- **まだ何を作るか曖昧で、まず構想を固めたい** → inception

State *why* you recommend one, but do not argue the user out of a different pick —
the decision is theirs.

## Handoff (only after the user has chosen)

Once the **user** has picked a mode, hand off — never start the work yourself, and
never dispatch before the user has decided. All four targets (`inception`,
`goal-loop`, `exec-plan`, `dev-workflow-kickoff`) are model-invocable: use the
**Skill tool** to invoke the chosen one directly. It receives the task context via
session history.

## Anti-patterns

- **NEVER decide for the user.** Recommend a mode, but the choice — and any
  override — is theirs. Do not dispatch before they have picked.
- **NEVER** implement, plan, or write documents yourself. The whole value of this
  skill is the recommendation + handoff; doing the work here defeats it.
- **Do not run a full requirements interview.** This skill makes one recommendation.
  The destination engine (dig, spec, Goal Contract, ExecPlan) runs its own intake.
- **Do not skip the ask because the answer "looks obvious."** Even a clear-cut fit
  is presented for confirmation — a wrong mode is expensive to unwind mid-run.
