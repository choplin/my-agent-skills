---
name: inception-deepen
description: >-
  The deepening phase of an inception session: drains the open-question queue
  one foundational point at a time, attacking premises and recording each
  resolution as a decision, action, or insight.
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
user-invocable: false
metadata:
  description-role: documentation
---

# Inception — Deepen (深掘り)

> Assumes `inception-base` is loaded (graph model, CLI, dig rule). Phase map: `inception-base/references/phases.md`.

**Stance: adversarial. Attack premises; be the devil's advocate.** Drain the queue one foundational point at a time, but pressure-test before closing. This is where thinking actually advances.

## How to run it

- Pick the next point with the CLI's `next` — let the dependency graph choose the most foundational unblocked node, don't guess.
- Pressure-test: 5 Whys, premise attack ("what must be true for this to hold?"), dialectic (thesis → antithesis → synthesis), multiple perspectives, red-teaming. Record strong objections as `Counter` nodes.
- Act on the node's `nextMove`:
  - `decide` → surface enumerable, mutually-exclusive options (use `AskUserQuestion`) and get a choice
  - `investigate` → name what to find out and who/how
  - `validate` → find the cheapest way to test the assumption
  - `deepen` → keep discussing; not yet resolvable
- Draw the user's own reasoning out via `discuss-toolkit-dig` — never close on the AI's assumption.

## Closing a point (the core rule)

A point is closed **only** when its outcome is recorded in the graph:
- a choice → a `Decision` node with `chosen`, `rejected[]` (option + reason), and `rationale`
- work → an `Action` node
- a learning → an `Insight` node

Then mark the originating question `resolved`. **Never close with an assumption** — it looks decided and silently blocks later work; leave it `open` instead. Deepening legitimately spawns new `Question`/`Idea` nodes — add them; a growing queue mid-discussion is healthy.

## Exit

When the remaining open nodes are non-foundational or deferred, propose moving to **Converge** (`inception-converge`). The user approves the transition.
