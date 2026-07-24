---
name: inception-finalize
description: The terminal exit of the inception family (確定 / Finalize) — confirm a shaped footing into durable external memory. Takes the consolidated PRD (from a full session's graph or a quick capture's prd-quick.md), writes it to the llm-wiki knowledge base as a keep-forever PRD note (one note in the repo scope, tagged `prd`), hands concrete actions to a tracker (e.g. Linear), and retires the transient thinking graph. Invoked from inception (after converge) and from inception-quick; also usable directly. Triggers on "finalize this footing", "save this to the wiki", "confirm the PRD and hand off the actions", "この構想を確定して保存", "PRDをllm-wikiに残して". Should NOT trigger while the idea still needs shaping (use inception), for quick capture only (use inception-quick), or to track/execute the actions themselves (that is the tracker's job).
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Bash, AskUserQuestion
---

# Inception — Finalize (確定)

The terminal exit of the inception family. The thinking is done; this step **confirms the footing into durable memory** and lets go of the working artifacts. It is one-way: after finalize, the persisted PRD is authoritative and the `.agents/inception/` graph is a spent working note.

> This is not a sixth thinking phase. `framing → diverge → structure → deepen → converge` shape the idea inside the transient graph; **finalize** moves the result out. It is reached from `inception` (after converge confirms done-enough) and from `inception-quick` (to keep its `prd-quick.md`), or run directly on an existing session.

Both routes converge here, so the durable output is the same shape regardless of how the footing was reached: **one consolidated PRD note** in the llm-wiki knowledge base, actions handed to a tracker, everything transient discarded.

## What it produces

- **One consolidated PRD note** in the llm-wiki knowledge base (durable, keep-forever) — one note in the current repo's scope, tagged `prd`, written in Japanese for its owner.
- **Concrete actions handed to a tracker** (a Linear Project with its Issues, or another workflow) — not kept in the PRD.
- Nothing else persists. The live open-questions queue is a snapshot and dies with the session.

## Prerequisite — llm-wiki skills installed

Finalize delegates the write to **`llm-wiki-base`, referenced by skill name** — the skills CLI installs into a flat namespace, so there is no dependency declaration; the llm-wiki skill family being installed is simply assumed. If `llm-wiki-base` cannot be loaded, or `zk` is not on PATH, stop and tell the user — then ask where to persist instead (or keep the PRD in `.agents/` and tell them it stays transient). Do not silently drop the durable output.

## Inputs — where the PRD comes from

| Source route | How to get the consolidated PRD |
|--------------|---------------------------------|
| Full `inception` | Run the base CLI: `inception.sh finalize <dir>/graph.json`. It prints one PRD whose **Direction section carries each decision's rejected alternatives + rationale** (the anti-re-litigation record that `prd.md` alone drops), and omits the live queue and action items. |
| `inception-quick` | Use the existing `<dir>/prd-quick.md` as-is — it is already a self-contained PRD. Its deepen/converge sections read `_not yet defined_`; that is expected and fine, finalize persists the footing that exists. |

Locate the session under `.agents/inception/<topic-slug>/` (Glob if the slug is unknown; ask which one if several).

## Workflow

1. **Get the consolidated PRD text** from the source above (CLI for full, the file for quick).
2. **Resolve the notebook and scope.** Read `llm-wiki-base` and run its Setup (mandatory, idempotent) and scope resolution — they give `$wiki` (the zk notebook) and `$scope` (the current repo's scope directory, `<repo-name>/`, resolved via git). **Repo scope is the default home for a PRD**; outside a repo, propose a concern name and confirm it with the user, per the base. Finalize adds no directory scheme of its own.
3. **Write the PRD note** into the scope via the base's **`new` verb** — not capture (a PRD is not a fleeting drop) and not distill (nothing is being promoted):

   ```sh
   printf '%s' "<PRD body>" | zk -W "$wiki" new "$scope" --title "PRD - <concise title>"
   ```

   - The verb prints the created path; the template seeds the frontmatter (`created`/`updated`/`distilled`/`distill_count`, `tags: []`). Then edit that file's frontmatter to `tags: [prd]` — `prd` is a **free topical tag**, not a reserved kind — and run `zk -W "$wiki" reindex`.
   - **Title is human-readable and slug-friendly.** The filename is the title's slug; keep the `PRD - ` prefix and prefer a concise **English** title — zk transliterates CJK titles into pinyin-style slugs (`構想` becomes `gou-xiang`), which makes inbound `[[slug]]` links unreadable. The body stays Japanese.
   - **Never clobber** — before writing, run `zk -W "$wiki" scan "$scope" --tag prd` and check for a PRD note on the same topic; if one exists, show it and ask whether to update it or write under a new title.
   - **Write the persisted note in Japanese.** The source PRD (CLI output or `prd-quick.md`) is plain English by `inception-base`'s rule — that rule governs the *thinking* artifacts. The wiki note is read only by its owner, so translate the full content (headings and body) into plain, clear Japanese when persisting. Keep the same discipline: short sentences, concrete nouns, no rhetorical flourish; technical terms, proper nouns (product, service, company names), and code identifiers stay in their original form. Translate faithfully — do not add, drop, or reinterpret content while translating.
   - Any link from the PRD to other wiki notes uses the **slug form** (`[[slug]]` same-scope, `[[scope/slug]]` cross-scope) — never the natural title, which zk treats as a broken link.
4. **Hand off the actions (full route only).** Present the `Action` nodes and let the user choose how to carry them out — do not decide for them:
   - **Linear (Project + Issues)** — delegate to the `linear-base` skill. A finalized inception footing is a **finite outcome/goal**, which in Linear's model is a **Project** — so **create a Project for this footing first, then register the promoted actions as Issues under that Project** (never as loose issues with no project). Use the PRD's title/purpose for the Project name and description. This writes to an external system, so **show the proposed Project and its issues, and get explicit approval before creating anything**. Issue promotion stays per-action — some actions are still too coarse to be issues; only promote the ones the user picks — but every promoted issue goes under the Project.
   - **`dispatch-work`** — for an action the user wants to execute now. Return the
     selected action to the single mode selector; it will ask human-gated versus
     autonomous and route accordingly.
   - Or hand the list off as-is. Actions do not stay in the PRD; the PRD records direction, not the to-do list.
5. **Retire the transient layer.** State plainly: the live open-questions queue is a point-in-time snapshot and is **not** persisted; the wiki PRD is now the authoritative footing and the `.agents/inception/` graph is a spent working note. Leave the `.agents/` files in place (they are gitignored and harmless); delete them only if the user asks.

## Frontmatter (llm-wiki template + `prd` tag)

The note's frontmatter is seeded by llm-wiki-base's template via `new` — do not hand-author it. After the single `tags` edit it reads:

```markdown
---
title: PRD - <concise title>
created: YYYY-MM-DD
updated: YYYY-MM-DD
distilled:
distill_count: 0
tags: [prd]
---
```

Only `tags` is edited after creation (`[]` → `[prd]`); every other field is written by the template.

## Self-check before declaring done

- [ ] The PRD is one note in the llm-wiki notebook under the repo scope (`<repo-name>/`), tagged `prd` — not left only in `.agents/`.
- [ ] The wiki PRD is written in **Japanese** (translated from the English source PRD), with technical terms, proper nouns, and identifiers left in their original form — under a slug-friendly English title.
- [ ] For a full session: the Direction section preserves **rejected alternatives + rationale** (not just the chosen option).
- [ ] **Background is permanent context** — it reads as standing project context that is still true months from now, with no session-process narration ("in this session we questioned/decided…", which duplicates Direction) and no progress snapshot ("implemented X", "collected N months of data", which belongs to the tracker). If it drifts, fix it before persisting; this is a keep-forever anchor. See the "Background: permanent context" contrast table in `inception-base/references/prd-template.md`.
- [ ] No PRD field was fabricated — sections not filled from the user's input still read `_not yet defined_`.
- [ ] Every wikilink the note makes is in slug form (`[[slug]]` / `[[scope/slug]]`), and `reindex` was run after the write.
- [ ] Actions were offered to a tracker with the user's choice; no Linear issue was created without explicit approval. If Linear was chosen, a **Project** was created for the footing and every promoted issue was registered under it (not as loose, project-less issues).
- [ ] The user was told the live queue is discarded and the graph is now spent.

## Gotchas

- **One-way boundary.** After finalize, the wiki PRD is the source of truth and the graph is archived. If the user wants to reopen the thinking, start a fresh `inception` session or edit the wiki note directly — do **not** keep re-rendering the old graph, or you recreate the two-source provenance problem inception exists to kill.
- **Don't persist the transient layer.** The live open-questions queue and the action-items list are working artifacts, not durable footing. Only the consolidated PRD (direction, risks, open-by-design) is kept.
- **Never create external issues silently.** Linear issue creation is outward-facing — propose, get approval, then create. Not every action becomes an issue.
- **Finalize confirms; it does not shape.** If the footing still has open foundational questions, it is not ready to finalize — go back to `inception` (deepen/converge), don't lock in a thin PRD.
