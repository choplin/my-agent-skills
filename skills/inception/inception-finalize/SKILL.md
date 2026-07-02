---
name: inception-finalize
description: The terminal exit of the inception family (確定 / Finalize) — confirm a shaped footing into durable external memory. Takes the consolidated PRD (from a full session's graph or a quick capture's prd-quick.md) and writes it to the Project Notes vault as a keep-forever PRD note, hands concrete actions to a tracker (e.g. Linear), and retires the transient thinking graph. Invoked from inception (after converge) and from inception-quick; also usable directly to finalize an existing session. Triggers on "finalize this footing", "save this to project notes", "confirm the PRD and hand off the actions", "この構想を確定して保存", "PRDをプロジェクトノートに残して". Should NOT trigger while the idea still needs shaping (use inception), for quick capture only (use inception-quick), or to track/execute the actions themselves (that is the tracker's job).
user-invocable: true
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
---

# Inception — Finalize (確定)

The terminal exit of the inception family. The thinking is done; this step **confirms the footing into durable memory** and lets go of the working artifacts. It is one-way: after finalize, the persisted PRD is authoritative and the `.claude/inception/` graph is a spent working note.

> This is not a sixth thinking phase. `framing → diverge → structure → deepen → converge` shape the idea inside the transient graph; **finalize** moves the result out. It is reached from `inception` (after converge confirms done-enough) and from `inception-quick` (to keep its `prd-quick.md`), or run directly on an existing session.

Both routes converge here, so the durable output is the same shape regardless of how the footing was reached: **one consolidated PRD** in the vault, actions handed to a tracker, everything transient discarded.

## What it produces

- **One consolidated PRD note** in the Project Notes vault (durable, keep-forever).
- **Concrete actions handed to a tracker** (Linear issues, or another workflow) — not kept in the PRD.
- Nothing else persists. The live open-questions queue is a snapshot and dies with the session.

## Inputs — where the PRD comes from

| Source route | How to get the consolidated PRD |
|--------------|---------------------------------|
| Full `inception` | Run the base CLI: `inception.sh finalize <dir>/graph.json`. It prints one PRD whose **Direction section carries each decision's rejected alternatives + rationale** (the anti-re-litigation record that `prd.md` alone drops), and omits the live queue and action items. |
| `inception-quick` | Use the existing `<dir>/prd-quick.md` as-is — it is already a self-contained PRD. Its deepen/converge sections read `_not yet defined_`; that is expected and fine, finalize persists the footing that exists. |

Locate the session under `.claude/inception/<topic-slug>/` (Glob if the slug is unknown; ask which one if several).

## Workflow

1. **Get the consolidated PRD text** from the source above (CLI for full, the file for quick).
2. **Resolve the vault anchor.** Read `project-notes-base` and run its "Resolving the Anchor" step (mandatory) — it gives `<anchor>` (`.git/project-notes`, symlinked into the vault). This reuses the vault location, per-repo layout, and symlink machinery; finalize adds no new directory of its own.
   - If the user has no Project Notes vault at all, `project-notes-base` says to ask for a path. If they decline a vault, ask where to persist instead (or keep it in `.claude/` and tell them it stays transient). Do not silently drop the durable output.
3. **Write the PRD note** to `<anchor>/Notes/PRD - <concise title>.md` with the light frontmatter below. Use a human-readable title (not the kebab slug). **Never clobber** — if a same-title PRD note already exists, show it and ask whether to update or write under a new title.
4. **Hand off the actions (full route only).** Present the `Action` nodes and let the user choose how to carry them out — do not decide for them:
   - **Linear issues** — delegate to the `linear` skill. This writes to an external system, so **show the proposed issues and get explicit approval before creating any**. Optional and per-action: some actions are still too coarse to be issues; only promote the ones the user picks.
   - **`dev-workflow-kickoff`** — for a spec/plan/review-driven task.
   - Or hand the list off as-is. Actions do not stay in the PRD; the PRD records direction, not the to-do list.
5. **Retire the transient layer.** State plainly: the live open-questions queue is a point-in-time snapshot and is **not** persisted; the vault PRD is now the authoritative footing and the `.claude/inception/` graph is a spent working note. Leave the `.claude/` files in place (they are gitignored and harmless); delete them only if the user asks.

## Frontmatter (matches project-notes)

```markdown
---
repo: <repo-name>
type: prd
created: YYYY-MM-DD
---
```

Get `created` and `repo-name` the same way `project-notes-base` does (`date +%F` for the date; do not guess it).

## Self-check before declaring done

- [ ] The vault PRD is written under `<anchor>/Notes/` with the `PRD - ` prefix, not left only in `.claude/`.
- [ ] For a full session: the Direction section preserves **rejected alternatives + rationale** (not just the chosen option).
- [ ] No PRD field was fabricated — sections not filled from the user's input still read `_not yet defined_`.
- [ ] Actions were offered to a tracker with the user's choice; no Linear issue was created without explicit approval.
- [ ] The user was told the live queue is discarded and the graph is now spent.

## Gotchas

- **One-way boundary.** After finalize, the vault PRD is the source of truth and the graph is archived. If the user wants to reopen the thinking, start a fresh `inception` session or edit the vault note directly — do **not** keep re-rendering the old graph, or you recreate the two-source provenance problem inception exists to kill.
- **Don't persist the transient layer.** The live open-questions queue and the action-items list are working artifacts, not durable footing. Only the consolidated PRD (direction, risks, open-by-design) is kept.
- **Never create external issues silently.** Linear issue creation is outward-facing — propose, get approval, then create. Not every action becomes an issue.
- **Finalize confirms; it does not shape.** If the footing still has open foundational questions, it is not ready to finalize — go back to `inception` (deepen/converge), don't lock in a thin PRD.
