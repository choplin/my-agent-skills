---
name: inception-structure
description: The structuring (構造化) phase of the inception family — invoked by the inception orchestrator to cluster divergent material into an issue tree, wire dependencies, and assign each open point a next move. Turns a flat dump into a navigable graph. Should NOT be invoked directly by the user; the inception orchestrator delegates here.
allowed-tools: Read, Write, Edit, AskUserQuestion, Bash
user-invocable: false
metadata:
  description-role: documentation
---

# Inception — Structure (構造化)

> Assumes `inception-base` is loaded (graph model, CLI, dig rule). Phase map: `inception-base/references/phases.md`.

**Stance: organize.** Turn the divergent dump into an issue tree with dependencies, so the conversation knows what to discuss first.

## What this phase produces

- A graph with `parentId` (tree), `dependsOn` (edges), and a `nextMove` on every open discussion node.

## How to run it

- Build the **issue tree**: set `parentId` to group nodes under the real underlying questions. Apply MECE as a check — are these the right branches? Do they overlap? Is something missing?
- Wire **dependencies**: set `dependsOn` where one point cannot be settled until another is. This is what lets `next` compute the most foundational point — don't skip it.
- Assign each open `Question`/`Idea`/`Counter` node a `nextMove`: `decide` / `investigate` / `validate` / `deepen`. This is the planned move, not a fixed category; it will change as points mature.
- Run `check` (catch dangling refs / missing nextMove), then `tree` and `next` to confirm the structure reads sensibly and yields a defensible "discuss this first".

## Exit

When the open questions have a clear shape and the graph yields a sensible most-foundational point, propose moving to **Deepen** (`inception-deepen`). The user approves the transition.
