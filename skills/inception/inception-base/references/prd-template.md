# Foundational PRD Template

The inception PRD is meant to be a **long-term anchor** for a product/project — the document a new contributor reads months later to understand what this is and why. It is not a sprint summary. Do not converge it while it is thin; an unfilled section is a signal to keep working, not to ship.

This template synthesizes common public PRD structures (Marty Cagan / SVPG, Amazon "Working Backwards" PR-FAQ, Lenny's PRD). Each section maps to a `session.*` field rendered by the CLI.

> **Language: all PRD content is plain, clear English.** Short sentences, concrete nouns, no rhetorical flourish. Rhetoric reads as substance in prose but adds no information; plain English exposes thin thinking instead of hiding it. This applies to every node's `content` too.

## Sections (what "good" looks like)

| Section | `session` field | A good answer | Thin / reject |
|---------|-----------------|---------------|---------------|
| **Summary** | `summary` | One–two sentences: what this is and the role it plays. Passes the "elevator" test. | "An app for productivity." |
| **Background** | `background` | The situation and why now — the forces making this worth doing. | "People are busy." |
| **Problem** | `problem` | The core pain, stated from the user's side, falsifiable, not a disguised solution. | "There is no tool for X" (that's a missing solution, not a problem). |
| **Purpose / Vision** | `purpose` | The lasting positioning — where this sits long-term, independent of the first feature. | "Be the best app." |
| **Central question** | `centralQuestion` | The single question the whole effort answers. | (missing) |
| **Target users** | `targetUsers` | Primary and secondary users, specific enough to be wrong about. | "Everyone." |
| **Value proposition** | `valueProposition` | Why this beats the status quo / alternatives — the differentiation. | "It's better and faster." |
| **Goals** | `goal` | The destination / the state reached when this succeeds. | "Launch it." |
| **Non-goals** | `nonGoals` | What is explicitly out of scope — the bounds that keep it focused. | (empty — almost always a smell) |

The remaining PRD sections are rendered from the graph, not session fields:
- **Direction (decided)** ← `Decision` nodes
- **Risks** ← `Counter` nodes (concerns / premise attacks that stand as known risks)
- **Open by design** ← `deferred` nodes (points deliberately left unresolved, with the reason) — the in-scope counterpart to Non-goals

Live, still-being-worked `open` nodes are deliberately **not** in the PRD; they belong to `action-items.md` (work) and `open-questions.md` (the working queue). The PRD records only what is durable: decisions, known risks, and the deliberate choice to leave certain points open.

## How to fill it

- **Framing phase** establishes the top of the funnel: `summary`, `background`, `problem`, `purpose`, `centralQuestion`, and a first cut at `targetUsers`.
- **Deepen / Converge** sharpen `valueProposition`, `goal`, `nonGoals` as decisions land.
- Fill each field via `discuss-toolkit-dig` with the user — do not write the AI's guess into a PRD field. A field you cannot fill from the user's own input stays `_not yet defined_`, which correctly blocks "done-enough".

## Converge gate

Before declaring the footing done, the core PRD sections must be non-placeholder and specific to this project: at minimum `summary`, `problem`, `purpose`, `targetUsers`, `goal`, and `nonGoals`. A PRD where these still read `_not yet defined_` is not done, regardless of how many actions exist.
