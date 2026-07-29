---
name: inception-finalize
description: >-
  The terminal exit of an inception session: takes the consolidated PRD from
  the session's graph, writes it to the llm-wiki knowledge base as one keep-
  forever note tagged prd, hands the concrete actions to a tracker, and
  retires the transient thinking graph.
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion
user-invocable: false
metadata:
  description-role: documentation
---

# Inception — Finalize (確定)

The terminal exit of the inception family. The thinking is done; this step **confirms the footing into durable memory** and lets go of the working artifacts. It is one-way: after finalize, the persisted PRD is authoritative and the `.agents/inception/` graph is a spent working note.

> This is not a sixth thinking phase. `framing → diverge → structure → deepen → converge` shape the idea inside the transient graph; **finalize** moves the result out. It is reached from `inception` after converge confirms done-enough, or run directly on an existing session.

The durable output is always the same shape: **one consolidated PRD note** in the llm-wiki knowledge base, actions handed to a tracker, everything transient discarded.

## What it produces

- **One consolidated PRD note** in the llm-wiki knowledge base (durable, keep-forever) — tagged `prd`, written in Japanese for its owner.
- **Concrete actions handed to a tracker** (a Linear Project with its Issues, or another workflow) — not kept in the PRD.
- Nothing else persists. The live open-questions queue is a snapshot and dies with the session.

## Prerequisite — llm-wiki skills installed

Finalize does not write to the knowledge base itself — it delegates to **`llm-wiki-capture`, referenced by skill name** — the skills CLI installs into a flat namespace, so there is no dependency declaration; the llm-wiki skill family being installed is simply assumed. If that skill cannot be loaded, or its write fails, stop and tell the user — then ask where to persist instead (or keep the PRD in `.agents/` and tell them it stays transient). Do not silently drop the durable output.

## Input — where the PRD comes from

Run the base CLI: `inception.sh finalize <dir>/graph.json`. It prints one PRD whose **Direction section carries each decision's rejected alternatives + rationale** (the anti-re-litigation record that `prd.md` alone drops), and omits the live queue and action items.

Locate the session under `.agents/inception/<topic-slug>/` (Glob if the slug is unknown; ask which one if several).

## Workflow

1. **Get the consolidated PRD text** by running the CLI above.
2. **Write the PRD to llm-wiki.** Delegate the write to `llm-wiki-capture` and hand it three things:

   - the **body** — the consolidated PRD, in Japanese (see below);
   - the **title** — `PRD - <タイトル>`, written in the same language as the body;
   - the **tag** — `prd`, a free topical tag marking the note as a PRD.

   Everything else about the note — which scope it lands in, its filename, its frontmatter, how it links and gets indexed — is llm-wiki's domain. Follow that skill and prescribe none of it here; finalize adds no scheme of its own and never reaches into the knowledge base directly.

   - **Never clobber** — if a PRD note on the same topic already exists, show it and ask whether to update it or write a new one alongside.
   - **Write the persisted note in Japanese.** The source PRD (CLI output) is plain English by `inception-base`'s rule — that rule governs the *thinking* artifacts. The wiki note is read only by its owner, so translate the full content (headings and body) into plain, clear Japanese when persisting. Keep the same discipline: short sentences, concrete nouns, no rhetorical flourish; technical terms, proper nouns (product, service, company names), and code identifiers stay in their original form. Translate faithfully — do not add, drop, or reinterpret content while translating.
3. **Hand off the actions.** Present the `Action` nodes and let the user choose how to carry them out — do not decide for them:
   - **Linear (Project + Issues)** — delegate to the `linear-base` skill. A finalized inception footing is a **finite outcome/goal**, which in Linear's model is a **Project** — so **create a Project for this footing first, then register the promoted actions as Issues under that Project** (never as loose issues with no project). Use the PRD's title/purpose for the Project name and description. This writes to an external system, so **show the proposed Project and its issues, and get explicit approval before creating anything**. Issue promotion stays per-action — some actions are still too coarse to be issues; only promote the ones the user picks — but every promoted issue goes under the Project.
   - **Execute one now** — for an action the user wants to start immediately, promote
     it to an Issue as above and pick it up through `linear-start`, which routes a
     groomed Issue to its execution skill. Do not start implementing from inside
     finalize.
   - Or hand the list off as-is. Actions do not stay in the PRD; the PRD records direction, not the to-do list.
4. **Retire the transient layer.** State plainly: the live open-questions queue is a point-in-time snapshot and is **not** persisted; the wiki PRD is now the authoritative footing and the `.agents/inception/` graph is a spent working note. Leave the `.agents/` files in place (they are gitignored and harmless); delete them only if the user asks.

## Self-check before declaring done

- [ ] The PRD was written to llm-wiki as one note tagged `prd`, through `llm-wiki-capture` — not left only in `.agents/`, and not written into the knowledge base by hand.
- [ ] The wiki PRD is written in **Japanese** (translated from the English source PRD), with technical terms, proper nouns, and identifiers left in their original form — under a `PRD - `-prefixed title in the same language.
- [ ] For a full session: the Direction section preserves **rejected alternatives + rationale** (not just the chosen option).
- [ ] **Background is permanent context** — it reads as standing project context that is still true months from now, with no session-process narration ("in this session we questioned/decided…", which duplicates Direction) and no progress snapshot ("implemented X", "collected N months of data", which belongs to the tracker). If it drifts, fix it before persisting; this is a keep-forever anchor. See the "Background: permanent context" contrast table in `inception-base/references/prd-template.md`.
- [ ] No PRD field was fabricated — sections not filled from the user's input still read `_not yet defined_`.
- [ ] Actions were offered to a tracker with the user's choice; no Linear issue was created without explicit approval. If Linear was chosen, a **Project** was created for the footing and every promoted issue was registered under it (not as loose, project-less issues).
- [ ] The user was told the live queue is discarded and the graph is now spent.

## Gotchas

- **One-way boundary.** After finalize, the wiki PRD is the source of truth and the graph is archived. If the user wants to reopen the thinking, start a fresh `inception` session or edit the wiki note directly — do **not** keep re-rendering the old graph, or you recreate the two-source provenance problem inception exists to kill.
- **Don't persist the transient layer.** The live open-questions queue and the action-items list are working artifacts, not durable footing. Only the consolidated PRD (direction, risks, open-by-design) is kept.
- **Never create external issues silently.** Linear issue creation is outward-facing — propose, get approval, then create. Not every action becomes an issue.
- **Finalize confirms; it does not shape.** If the footing still has open foundational questions, it is not ready to finalize — go back to `inception` (deepen/converge), don't lock in a thin PRD.
