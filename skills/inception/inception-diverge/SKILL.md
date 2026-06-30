---
name: inception-diverge
description: The divergence (発散) phase of the inception family — invoked by the inception orchestrator to widen the space of ideas, options, and perspectives before judging any of them. Captures everything as Idea/Question nodes. Should NOT be invoked directly by the user; the inception orchestrator delegates here.
user-invocable: false
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
---

# Inception — Diverge (発散)

> Assumes `inception-base` is loaded (graph model, CLI, dig rule). Full method: `inception-base/references/phases.md`.

**Stance: widen. Generate ideas, options, and perspectives — do not judge yet.** Premature narrowing kills options the user has not voiced. Your value here is breadth and the introduction of perspectives the user hasn't taken.

## What this phase produces

- Many `Idea` and `Question` nodes under the relevant parents, capturing the full space — not just the first good idea.

## How to run it

- Let the user dump freely; draw more out via `discuss-toolkit-dig` when they stall (subject: "other angles on this central question").
- Provoke breadth: enumerate perspectives (different stakeholders, time horizons, constraints), ask "what else could this be?", offer adjacent options the user can react to.
- **Capture, don't resolve.** Every undecided thing becomes a node: `Idea` for a possibility, `Question` for an open point. Do not settle anything inline — that is the deepen phase's job. Resist closing.
- Leave `nextMove` unset for now; it gets assigned during structuring.

## Exit

When the space feels covered (not just the first idea), propose moving to **Structure** (`inception-structure`). The user approves the transition.
