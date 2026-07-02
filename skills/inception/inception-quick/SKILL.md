---
name: inception-quick
description: The lightweight route of the inception family — when the user wants to capture just the background and purpose of an idea into a short PRD, without the full diverge/structure/deepen/converge session or the thinking-graph machinery. Runs a brief dig on the framing (why, what, for whom) and writes it straight to prd-quick.md. Triggers when the user wants to "sketch the background and purpose of an idea", "quickly note down the background and purpose", "サクッと背景と目的をまとめる", "軽く構想を書き留める", or "write a quick PRD/brief". Should NOT trigger when the user wants to actually shape/pressure-test the idea (use inception); when they want to start a development task and have the AI drive intake/routing (use dev-workflow-kickoff) — this skill only writes the background/purpose capture, not task routing; an already-defined task ready to implement (use dev-workflow); or a one-off decision (use discuss-toolkit-quick-chat).
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion, Bash
---

# Inception — Quick (軽量ルート)

The lightweight sibling of `inception`. Use it when the idea does not need a full thinking session — the user just wants the **background and purpose** written down on a solid footing, quickly. This is the framing phase's output, captured directly, without diverging, deciding, tracking, or spinning up the thinking graph.

> This skill deliberately does **not** load `inception-base` (graph model, CLI, phases) — that machinery is the weight this route exists to avoid. It reuses only two things from the family: the PRD section definitions in `inception-base/references/prd-template.md`, and the rule that elicitation goes through `discuss-toolkit-dig`.

## What it produces

A single self-contained `prd-quick.md` at `.claude/inception/<topic-slug>/prd-quick.md`, holding the sections the framing phase establishes:

- **Summary** — one–two sentences: what this is and the role it plays.
- **Background** — the situation and why now: the forces making this worth doing.
- **Problem** — the core pain from the user's side, falsifiable, not a disguised solution.
- **Purpose / Vision** — where this sits long-term, independent of the first feature.
- **Central question** — the single question the whole effort answers.
- **Target users** — a first cut; primary/secondary, specific enough to be wrong about.

See `inception-base/references/prd-template.md` for what "good" vs "thin" looks like per section. The sections that only deepening/convergence can fill (Value proposition, Goals, Non-goals, and the graph-derived Direction/Risks) render as `_not yet defined_` — an honest signal that this is a foundation, and the upgrade hook to full `inception`.

No `graph.json`, no CLI, no `decisions.md` / `action-items.md` / `open-questions.md`. One file.

## How to run it

1. **Slug + location.** Derive a topic slug from the user's idea (kebab-case, 2–4 words; ask only if genuinely unclear). Target `.claude/inception/<slug>/prd-quick.md` (deliberately **not** `prd.md`, which full `inception` renders from its graph — separate names so neither route can clobber the other).
   - If `.claude/inception/<slug>/graph.json` already exists, this topic is a full `inception` session — do not start a quick capture over it; tell the user and defer to `inception`.
   - If `.claude/inception/<slug>/prd-quick.md` already exists (from a prior quick run), offer to update it rather than clobber.
   - Ensure `.claude/inception/` is git-ignored (it holds transient working notes). At most repos `.claude` is already ignored; add it if not.
2. **Brief framing dig.** Delegate elicitation to `discuss-toolkit-dig` (subject: "the background and purpose behind this idea"). Draw out *why now*, *what problem*, and *for whom* — enough to write each section from the user's own words. Keep it brief: this is a capture, not the full Socratic reframing loop, so stop once the framing sections can be filled honestly rather than sweeping for more.
   - Still apply the one framing guardrail: if the user jumps to *how* (a solution) before *why/what*, note it and pull back to the problem. A quick brief with a sharp problem beats a fast one built on a solution-in-disguise.
3. **Write `prd-quick.md`.** Fill each section from what surfaced, in **plain, clear English** (short sentences, concrete nouns — regardless of the conversation language). A section you cannot fill from the user's own input stays `_not yet defined_`; never write the AI's guess into a PRD field. Leave the deepen/converge sections as `_not yet defined_`.
4. **Self-check, then close.** Before showing the file, validate it against the section bars (never present without this gate):
   - Each filled section is in the user's own words — no AI guess written into any field.
   - **Problem** is stated as a pain, falsifiable, not a missing feature in disguise.
   - **Central question** is a single question, not a list.
   - Any section not filled from the user's input reads `_not yet defined_` (not fabricated).
   Then show the user the `prd-quick.md` and name the two paths out:
   - **Keep it.** To persist this footing into durable memory, offer **`inception-finalize`** (確定) — it writes `prd-quick.md` to the Project Notes vault as a keep-forever PRD note. `prd-quick.md` under `.claude/` is transient; finalize is what makes it last.
   - **Upgrade it.** If they later want to pressure-test the idea, generate options, or record decisions and first actions, run full `inception` on the **same topic** — it detects this hand-written `prd-quick.md`, seeds its graph's `session.*` fields from it, and continues from there (the capture is carried forward, not lost). If a concrete next action is already obvious instead, offer to hand it to `dev-workflow-kickoff`.

## Scope guard

This route captures the footing; it does not shape it. No divergence, no options, no decisions, no action tracking — those are exactly what full `inception` (then `dev-workflow`) are for. If the conversation starts genuinely wrestling with the idea (weighing alternatives, needing to decide), that is the signal to propose switching to full `inception`, not to grow this file.

## Gotchas

- **Don't reinvent the graph here.** If you find yourself wanting nodes, dependencies, or `render`, the task has outgrown quick — switch to `inception`.
- **Never fill a PRD field with an assumption.** An unfilled section renders `_not yet defined_` on purpose; that is a signal to keep working, not a blank to paper over.
- **`prd-quick.md`, never `prd.md`.** Full `inception` renders `prd.md` from its graph and overwrites it on every `render`; the quick capture lives in a separate `prd-quick.md` precisely so it is never clobbered. Upgrading to a full session is lossless — `inception` reads `prd-quick.md` to seed its graph, then renders its own `prd.md` alongside it (step 4).
