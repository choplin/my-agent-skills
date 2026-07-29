---
name: inception-framing
description: >-
  The framing phase of an inception session: finds the real problem before any
  solution, establishing the purpose, the background, and the central
  question.
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
user-invocable: false
metadata:
  description-role: documentation
---

# Inception — Framing (構想)

> Assumes `inception-base` is loaded (graph model, CLI, dig rule). Phase map: `inception-base/references/phases.md`.

**Stance: Socratic. Find the real problem before any solution.** At the start, the highest-leverage move is reframing the problem, not answering it. The first framing a user offers is rarely the sharpest one.

## What this phase produces

- The top of the foundational PRD set in the graph: `session.summary`, `session.background`, `session.problem`, `session.purpose`, `session.centralQuestion`, and a first cut at `session.targetUsers`. See `inception-base/references/prd-template.md` for what a good answer to each looks like.
- Root-level `Question` nodes for the genuinely open problems.

Fill each field from the user's own words via dig — never the AI's guess. A field you cannot fill stays empty and renders `_not yet defined_`, which correctly keeps the PRD from looking done. Write the content in plain, clear English.

## How to run it

- Elicit the user's actual intent and the problem behind it via `discuss-toolkit-dig` (subject: "the real problem behind this idea"). Don't supply the framing yourself.
- Pressure-test the framing: restate the problem two or three different ways and ask which is truest. Ask "what would not be solved even if we did the obvious thing?"
- **Guard against solutioning-too-early.** If the user jumps to *how* before *why/what*, capture the how as an `Idea` node and pull back to the problem. Solutions are welcome later; here they are clues to the real question, not the answer.
- **Guard `session.background` against session-viewpoint and progress.** Background is *permanent* project context — the standing problem, still true months from now. When the user's answer drifts into how the thinking is going ("originally I assumed…, now I'm questioning…") or into current status ("I've already implemented / collected…"), don't write that into `background`: route the first to a `Decision`/`Question` node (the reasoning is what Direction records) and the second to an `Action`/tracker. Ask instead: "setting aside what we've done or decided so far, what standing situation makes this worth doing?" See the "Background: permanent context" contrast table in `inception-base/references/prd-template.md`.
- Use So-What / Why-So to move between the symptom and the underlying need.

## Exit

When the user recognizes the central question as the right one to be asking, set it in the graph and propose moving to **Diverge** (`inception-diverge`). The user approves the transition.
