# inception

Skills for the **start of a project** — think a fuzzy idea into a solid footing through a phase-driven, dialogic facilitation. The session grows a single thinking graph that is projected into a PRD, a decision record, action items, and open questions.

> Scope: inception shapes the founding concept. It does **not** track project progress — once actions are concrete, hand them to `dev-workflow`.

## The model

All thinking lands in **one graph** (`graph.json`). The human-readable documents are projections rendered from it, so closing a point never means cutting-and-pasting text between files and losing its provenance.

```
構想 Framing → 発散 Diverge → 構造化 Structure → 深掘り Deepen → 収束 Converge
 (loops — deepening spawns new divergence)
```

Each phase is a different AI stance over the same graph. The orchestrator estimates the phase and proposes transitions; the user approves.

## Skills

| Skill | Role |
|-------|------|
| `inception` | Orchestrator — owns the graph, estimates the phase, delegates to phase skills (the entry point) |
| `inception-base` | Shared model: graph JSON schema, the shell+jq CLI, the phase model, the dig-elicitation rule |
| `inception-framing` | 構想 — Socratic; find the real problem before solutions |
| `inception-diverge` | 発散 — widen ideas and perspectives, no judging |
| `inception-structure` | 構造化 — cluster into an issue tree, wire dependencies |
| `inception-deepen` | 深掘り — attack premises, resolve points, record decisions |
| `inception-converge` | 収束 — synthesize into purpose, decisions, actions |

## Artifacts

Stored under `.claude/inception/<topic-slug>/` (transient, not committed):

- `graph.json` — the single source of truth
- `prd.md` / `decisions.md` / `action-items.md` / `open-questions.md` — projections (regenerated; do not hand-edit)

## CLI

`inception-base/scripts/inception.sh` (bash + jq) interprets the graph so the agent doesn't traverse raw JSON:

```
init <dir> [topic]      tree <graph.json>       open <graph.json>
next <graph.json>       check <graph.json>      render <graph.json> <dir>
```

`next` is the key one — it walks `dependsOn` to surface the most foundational open point to discuss next.

## Conventions

- **Decisions are first-class.** Closing a question on a choice creates a `Decision` node with rejected alternatives + rationale — the durable artifact that prevents re-litigation.
- **Elicit via dig.** All drawing-out of the user's thinking goes through `discuss-toolkit-dig`; never fill gaps with the AI's assumptions.
- **Relationship to neighbors.** Earlier and lighter than `dev-workflow` (which begins once a task is defined); broader than `discuss-toolkit-dig` (which clarifies one intent without lasting artifacts).
