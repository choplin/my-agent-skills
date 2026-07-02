---
name: inception-diverge
description: The divergence (発散) phase of the inception family — invoked by the inception orchestrator to widen the space of ideas, options, and perspectives before judging any of them. Captures everything as Idea/Question nodes. Should NOT be invoked directly by the user; the inception orchestrator delegates here.
user-invocable: false
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
---

# Inception — Diverge (発散)

> Assumes `inception-base` is loaded (graph model, CLI, dig rule). Full method: `inception-base/references/phases.md`.

**Stance: widen. Generate ideas, options, and perspectives — do not judge yet.** Premature narrowing kills options the user has not voiced. Your value here is breadth and the introduction of perspectives the user hasn't taken.

The failure mode this phase exists to prevent: asking one or two questions, deciding "the space feels covered," and sliding into convergence. Divergence is **brainstorming**, and brainstorming has a reproducible shape — run it, don't eyeball it.

## What this phase produces

- Many `Idea` and `Question` nodes under the relevant parents, capturing the full space — not just the first good idea.

## Hold Osborn's four brainstorming rules for the whole phase

State them to the user if they start narrowing:
- **Defer judgment** — no "but that won't work" yet; critique is the deepen phase's job.
- **Go for quantity** — more options make a better final choice. Do not stop at the first good one; push each branch for several.
- **Welcome wild ideas** — the unreasonable option often relocates where the reasonable one sits.
- **Build and combine** — take an idea the user voiced and spin variants off it.

## The breadth sweep — a fixed set of lenses

Do not free-associate and hope. Walk each lens below in turn, capturing what surfaces as nodes. A lens counts as done only when it has produced something *or* the user has genuinely considered and dismissed it — not when you skipped it. This checklist is the reproducibility mechanism; it is also the reason you cannot be "done" after two questions.

- **Stakeholders** — enumerate who is affected or cares (user, buyer, operator, competitor, regulator, future maintainer). What does each want that changes the idea?
- **Time horizons** — what does this look like shipped this month vs. in a year vs. in five? What is right for one horizon and wrong for another?
- **Constraints, dropped then added** — "if budget / time / tech / headcount were no limit, what would you do?" then "if you had a tenth of the resources?" Each extreme surfaces options the comfortable middle hides.
- **Analogies / prior art** — how do other products, other industries, or nature solve this shape of problem? Name concrete examples for the user to react to.
- **SCAMPER on the leading idea** — apply each verb to the current best idea to spawn variants: Substitute, Combine, Adapt, Modify, Put-to-other-use, Eliminate, Reverse.
- **Inversion** — "what would guarantee this fails?" Invert each failure mode into something to do or avoid.

Offer adjacent options for the user to react to — reacting is easier than generating from a blank page. When the user stalls, draw out *their* thinking via `discuss-toolkit-dig` (subject: "other angles on this central question"), not the AI's assumptions.

Do not decide the depth or which lenses to skip on your own. When a lens feels heavy for the topic, or the user seems to want to move faster, ask them — "worth pushing this angle, or skip it?" — rather than silently narrowing. The user sets the pace; you keep the checklist honest.

## Capture, don't resolve

Every undecided thing becomes a node: `Idea` for a possibility, `Question` for an open point. Do not settle anything inline — that is the deepen phase's job. Resist closing. Leave `nextMove` unset; it gets assigned during structuring.

## Exit

Not "the space feels covered." Exit only when **both** hold:
- every lens above has been walked (each produced nodes or was genuinely considered), and
- the last lens or two added little that was genuinely new — real diminishing returns, not first-idea satisfaction.

Then propose moving to **Structure** (`inception-structure`). The user approves the transition.
