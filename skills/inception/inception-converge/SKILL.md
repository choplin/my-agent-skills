---
name: inception-converge
description: The convergence (収束) phase of the inception family — invoked by the inception orchestrator to synthesize the resolved graph into a coherent footing (purpose, decisions, sequenced actions) and check it is done-enough before handing off. Should NOT be invoked directly by the user; the inception orchestrator delegates here.
user-invocable: false
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
---

# Inception — Converge (収束)

> Assumes `inception-base` is loaded (graph model, CLI, dig rule). Full method: `inception-base/references/phases.md`.

**Stance: synthesize.** Pull the resolved graph into a footing the user can act on.

## How to run it

- Summarize the through-line from central question to decisions. Surface **tradeoffs** across decisions and sequence the `Action` nodes.
- **Complete the foundational PRD.** Sharpen `session.valueProposition`, `session.goal`, and `session.nonGoals` as decisions land. The PRD is a long-term anchor, not a summary — don't converge it while sections are thin (`inception-base/references/prd-template.md`).
- Ensure the `Decision` nodes collectively tell a consistent story. If a decision implies an action no one captured, add the `Action` node.
- Name what is deliberately deferred and why (`deferred` status + `deferReason`), so it reads as a choice, not an omission.
- Run `render` and walk the user through `prd.md`, `decisions.md`, `action-items.md`, `open-questions.md`.

## Done-enough check (all must hold; you can verify these yourself)

- [ ] the core PRD sections are non-placeholder and specific to this project: `summary`, `problem`, `purpose`, `targetUsers`, `goal`, `nonGoals` (none still `_not yet defined_`)
- [ ] every `Action` node is a single discrete action (not "figure out X" — that stays an open `Question`)
- [ ] every still-open node is either non-foundational or `deferred` with a `deferReason`
- [ ] no open node depends only on other still-open nodes with no path to resolution

Run `check`, confirm the four above, then **summarize the state and ask the user to confirm** before declaring the footing done — don't declare it unilaterally.

## Handoff

Once the user confirms the footing is done-enough, the concept is shaped and the session leaves the graph. If new uncertainty surfaced instead, propose looping back to **Deepen** or **Diverge** rather than converging on a thin footing.

When it is confirmed, propose moving to the terminal exit, **`inception-finalize`** (確定) — do not persist or hand off actions from here. Finalize confirms the footing into the llm-wiki knowledge base as one consolidated PRD note (with the decisions' rejected alternatives preserved), hands the concrete actions to whatever tracker fits (`dev-workflow-kickoff`, `goal-loop`, `exec-plan`, Linear, or as-is — the user's choice), and retires the transient graph. Keep converge about synthesizing; let finalize do the externalizing.
