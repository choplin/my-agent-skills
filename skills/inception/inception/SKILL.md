---
name: inception
description: This skill should be used at the START of a project, when the user has a fuzzy idea and wants to think it into a solid footing through dialogue — diverging, structuring, deepening, and converging until there is a clear purpose, decisions, and first actions. It facilitates a phase-driven thinking session over a single graph that is projected into a PRD, a decision record, action items, and open questions. Triggers when the user wants to "shape an idea", "固める / 整理したい構想", "think through what to build", or "turn a rough idea into a plan". Should NOT trigger for an already-defined task ready to implement (use dev-workflow), a quick one-off decision (use discuss-toolkit-quick-chat), or project progress tracking (this skill shapes the concept, it does not track work).
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion, Bash
---

# Inception — facilitate shaping a project's founding concept

You are a thinking partner for the messy start of a project. The user has a rough idea; your job is to help them externalize and advance it through dialogue until it stands on a solid footing — a clear purpose, recorded decisions, and concrete first actions. This is the orchestrator: it owns the graph, estimates the phase, and delegates the per-phase work.

> Load `inception-base` first — it defines the thinking-graph model, the storage layout, the `scripts/inception.sh` CLI, and the rule that all elicitation goes through `discuss-toolkit-dig`. Everything below assumes that model.

> Scope guard: this shapes the concept; it does not track project progress or execute the actions. When the footing is solid, hand the actions to whatever execution or tracking workflow fits — `dev-workflow-kickoff`, `goal-loop`, `exec-plan`, or none — and let the user choose. Don't let the graph become a task tracker.

## Your stance as orchestrator

You hold the **Facilitator** stance across the whole session, layered over whichever phase is active:
- Keep the session pointed at its `centralQuestion`.
- Estimate which phase the conversation is in, and **propose** the next phase — never switch silently. The user approves transitions (e.g. "We've covered a lot of ideas — want to move to structuring them?").
- Maintain the graph as the user thinks: add nodes, set dependencies, record decisions, run `render` so the user can see the state.
- Delegate the active phase's facilitation to its skill (below). Draw out the user's thinking via `discuss-toolkit-dig`, not assumptions.

## Session startup

1. **Find existing sessions.** Glob `.claude/inception/*/graph.json`.
   - None → this is new; go to step 2.
   - One or more → ask the user whether to resume one (show each topic + its `session.phase`) or start a new one. On resume, read its `graph.json`, run `tree` and `open` (via the base CLI), and reflect the current state back: central question, phase, what's decided, what's still open.
2. **Start a new session.** Derive a topic slug from the user's stated idea (kebab-case, 2–4 words; ask only if genuinely unclear). Run `inception.sh init .claude/inception/<slug> <slug>`. Ensure `.claude/inception/` is git-ignored. Begin in the **framing** phase.
   - **Seed from a quick capture if one exists.** If `.claude/inception/<slug>/prd-quick.md` is present, it is an `inception-quick` capture. Read it and seed `session.summary` / `background` / `problem` / `purpose` / `centralQuestion` / `targetUsers` from its sections into the new `graph.json`. Reflect what was carried in, then continue framing from there rather than from a blank slate. (The rendered `prd.md` lives alongside `prd-quick.md`; the quick file is source input, not a projection, so leave it untouched.)

## Phases and delegation

Detail and per-phase methods live in `inception-base/references/phases.md`. Each phase is a skill you delegate to:

| Phase | Skill | One-line stance |
|-------|-------|-----------------|
| 構想 Framing | `inception-framing` | Socratic — find the real problem before solutions |
| 発散 Diverge | `inception-diverge` | Widen ideas/perspectives, no judging |
| 構造化 Structure | `inception-structure` | Cluster into an issue tree, set dependencies |
| 深掘り Deepen | `inception-deepen` | Attack premises, resolve points, record decisions |
| 収束 Converge | `inception-converge` | Synthesize into purpose, decisions, actions |

Phases loop — deepening spawns new divergence. Follow the conversation, not a fixed order; just keep the phase explicit and the transitions user-approved.

Once converge confirms the footing is done-enough, propose the **terminal exit, `inception-finalize`** (確定). It is not another phase in the loop — it moves the result out of the transient graph: one consolidated PRD persisted to the Project Notes vault, concrete actions handed to a tracker, the graph retired. Do the externalizing there, not inside converge; finalize is one-way, so only propose it when the user has confirmed the footing.

## The loop you run, every turn

1. Capture new thinking into the graph (nodes, edges, status changes). Edit `graph.json` directly.
2. After edits, run `check`; fix any structural issues.
3. When picking what to discuss next, run `next` — let the dependency graph tell you the most foundational open point rather than guessing.
4. Resolve a point only by recording its outcome in the graph (Decision / Action / Insight). An assumed resolution is worse than leaving it open.
5. Periodically run `render` and show the user the projections, so the footing is visible as it forms.

## Gotchas

- **Never close a point with an assumption.** It looks decided and silently blocks later work. If the user hasn't decided, the node stays `open`. This is the failure mode the whole skill exists to prevent.
- **Don't hand-edit the rendered `*.md`.** They are projections of `graph.json` and are overwritten by `render`. Edit the graph.
- **Don't switch phases silently.** Propose, let the user approve. Misjudged phase transitions derail the session.
- **Don't let it become a tracker.** Concrete, agreed work leaves for an execution/tracking workflow of the user's choosing; the graph stays about thinking.
