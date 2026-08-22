---
name: design-note
description: >-
  Captures an established problem and chosen approach as one durable Design
  Note after a conversation or investigation has settled what should be built.
  Elicits only material gaps, then records the background, target users, goals,
  boundaries, approach, alternatives, and reasoning in a durable Markdown
  store, at a level shallower than implementation design.
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion, Bash
metadata:
  description-role: trigger
---

# Design Note

Capture **the problem and the approach to it** as one durable note. This is the layer between a PRD (why build anything at all — background, problem, users) and a design doc (how it is built — structure, interfaces, implementation): it states the problem, names the approach taken to it and the reasoning behind that approach, and stops before the mechanics.

Most conversations that arrive here have already done the thinking — a discussion, a `/dig`, a code investigation. This skill's job is to get that thinking out of the session and into memory before it evaporates, filling only the gaps that are genuinely missing.

## What it produces

**One note in the selected durable Markdown store.** Nothing else — no file under `.agents/`, no working copy, no second step to make it durable.

- **Location** — the current repository's durable Markdown scope, resolved by `workflow-adapter-markdown`.
- **Title** — `Design Note - <concise title>`, written **in the same language as the body** (below), so the note does not read as two documents stitched together. What that title becomes as a filename, and how links resolve to it, belongs to the selected provider — not this skill.
- **Tag** — `design-note`.
- **Body language** — **the language the session is being conducted in.** The note is read by the person who wrote it, so match the conversation rather than translating out of it. Whatever the language, keep the discipline: short sentences, concrete nouns, no rhetorical flourish. Technical terms, proper nouns, and code identifiers stay in their original form.

## Sections

The section names below are the canonical (English) ones. When the session runs in another language, write the headings in that language too — the note should read as one document, not a translated shell around native prose.

```markdown
## Summary

## Background

## Problem

## Target users

## Goals

## Non-goals

## Approach

## Open questions
```

| Section | What it holds | The bar |
|---|---|---|
| **Summary** | One or two sentences: what this is and the role it plays. | Someone who has never seen this can tell what it is from these sentences alone. |
| **Background** | The situation and why now — the forces that make this worth doing. | **Permanent context.** Still true months from now. No session narration ("at first I assumed…, now questioning…"), no progress snapshot ("already implemented X"). |
| **Problem** | The concrete pain, from the affected side. | Falsifiable, and not a missing feature in disguise. If it reads as "there is no X", restate it as what breaks because X is absent. |
| **Target users** | Who this is for. | Specific enough to be wrong about. |
| **Goals** | What must become true for this to have worked. | Stated as a changed state, not as work to do ("X is no longer needed", not "remove X"). Each one is checkable later. Not the same as the Problem restated in the positive — if it is, the goal is not saying anything. |
| **Non-goals** | What this deliberately does not try to achieve, plus what the note itself does not cover. | Paired with Goals: each entry is something a reader would otherwise reasonably assume is in. A non-goal nobody would have expected is noise. |
| **Approach** | The line of attack — how this is solved in principle — together with **why this one**: the alternatives considered and why they were dropped, and the constraints that bind the choice. | The reasoning is present, not just the conclusion. A reader who disagrees can tell exactly which premise to attack. |
| **Open questions** | Questions still open. | Actual questions, not work items. A fabricated question to avoid an empty section is worse than the empty section. |

A section that cannot be filled from what the user actually said reads `TODO` — the literal string, whatever language the note is in, so unfinished notes stay greppable. Never write a guess into a note that is kept forever.

`TODO` and empty are different answers: `TODO` means "not established yet, come back to it"; empty means "there is nothing here". Open questions with nothing open is legitimately empty, not `TODO`.

**Why the reasoning lives inside Approach, not in its own section.** Constraints and rejected alternatives only mean anything as the justification for the choice. Split into separate sections they become a checklist to fill in, which is exactly the PRD-shaped ceremony this note exists to avoid.

## Prerequisite — Markdown adapter installed

This skill does not write to the knowledge base itself. Delegate the completed
note to `workflow-adapter-markdown`. If the adapter cannot be loaded or its
write fails, stop and tell the user; do not silently choose another location.

## How to run it

1. **Take stock of what the conversation already established.** Read back over the discussion and list which sections you can already fill from the user's own words. Only what is genuinely missing goes into elicitation — do not re-ask what was already settled.
2. **Draw out the gaps.** Delegate elicitation to `discuss-toolkit-dig` (subject: the problem and the approach to it). Keep it to the gaps. Two guardrails while eliciting:
   - **The approach needs its reasoning.** If the user names an approach without saying why it beats the alternatives, ask. The conclusion alone is what makes a note un-reusable six months later.
   - **The problem must survive the approach.** If the stated problem is only "the approach isn't in place yet", it is a solution in disguise — pull back and ask what actually breaks today.
3. **Write the durable note.** Delegate a `create` operation to `workflow-adapter-markdown` with three things:

   - the **body** — the sections above, in the session's language;
   - the **title** — `Design Note - <concise title>`, in the same language as the body;
   - the **tag** — `design-note`.

   Everything else about the note — which scope it lands in, its filename, its frontmatter, how it links to related notes and gets indexed — belongs to the adapter and selected provider. Prescribe none of it here; this skill adds no storage scheme of its own.

   - **Never clobber.** If a `design-note`-tagged note already covers the same
     ground, show it and ask whether to request an update or create a new note
     alongside. Do not let the adapter silently extend or replace it.
4. **Self-check, then close.** Validate against the section bars above before showing anything — in particular that **Background** is permanent context, **Problem** is falsifiable, **Goals** read as states rather than tasks, and **Approach** carries its reasoning. Then show the user the note and name the path onward: when the approach should become schedulable work, `planning-toolkit-plan` reads durable design notes through the adapter and cuts them into an outcome, milestones, and issues.

## Where this stops

A design note states the problem, the goals, and the approach. It does **not** state the finite **Outcome** — the completable end state that scope is cut against.

Goals and Outcome are not the same thing. Goals say what must become true for this to have worked; Outcome says how much of that a single delivery commits to reaching. One note's goals can outlive several deliveries.

That boundary is deliberate. Fixing the Outcome is `planning-toolkit`'s core judgment, made against a declared scope policy (an MVP policy cuts very differently from the default one). Deciding it here would pre-empt that judgment from upstream, using no policy at all — and Goals are precisely what planning needs in order to make the cut.

What the note does carry — Problem, Target users, the constraints and rejected alternatives inside Approach, and Non-goals — covers four of the five Outcome Contract fields that `planning-toolkit-base` requires. They are here because a note about an approach is incomplete without them, not because planning wants them. The fifth, Outcome, is planning's to cut.

## Gotchas

- **Don't drift into a design doc.** Interfaces, schemas, file layouts, and call flows belong to implementation design. If the note starts specifying mechanics, the material has outgrown this note — say so rather than growing the note.
- **Don't turn Open questions into a task list.** Open questions are things nobody knows the answer to yet. Work items belong in the tracker, and only after planning has shaped them.
- **Never fill a section with an assumption.** A `TODO` is an honest signal that something is still missing. A fabricated section is worse than an empty one, because a note kept forever is read later as settled fact.
- **One note, written once.** There is no transient working file and no separate step to make it durable. If the discussion is still moving, keep discussing — write the note when the approach has actually settled.
