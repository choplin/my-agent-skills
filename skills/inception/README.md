# inception

Skills for the **founding of a project** — develop an unformed concept into a solid footing through phase-driven, dialogic facilitation. The session grows a single thinking graph that is projected into a PRD, a decision record, action items, and open questions.

> Scope: inception shapes the founding concept. It does **not** track project progress or execute the actions — once actions are concrete and the footing is finalized, selected actions become tracker Issues, and execution starts through the selected provider's start skill.

## The model

All thinking lands in **one graph** (`graph.json`). The human-readable documents are projections rendered from it, so closing a point never means cutting-and-pasting text between files and losing its provenance.

```
構想 Framing → 発散 Diverge → 構造化 Structure → 深掘り Deepen → 収束 Converge → 確定 Finalize
 (framing…converge loop — deepening spawns new divergence; finalize is the one-way exit)
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
| `inception-finalize` | 確定 — terminal exit; persist the consolidated PRD through a durable Markdown adapter, hand actions to a tracker, retire the graph |

## Artifacts

Stored under `.agents/inception/<topic-slug>/` (transient, not committed):

- `graph.json` — the single source of truth
- `prd.md` / `decisions.md` / `action-items.md` / `open-questions.md` — projections (regenerated; do not hand-edit)

Everything above is transient. The **durable** artifact is produced only at the end by `inception-finalize`: one consolidated PRD written through `workflow-adapter-markdown` (one note in the repository scope, tagged `prd`), with the decisions' rejected alternatives preserved. After finalize, the durable PRD is authoritative and the `.agents/` graph is spent.

## CLI

`inception-base/scripts/inception.sh` (bash + jq) interprets the graph so the agent doesn't traverse raw JSON:

```
init <dir> [topic]      tree <graph.json>       open <graph.json>
next <graph.json>       check <graph.json>      render <graph.json> <dir>
finalize <graph.json>
```

`next` is the key one — it walks `dependsOn` to surface the most foundational open point to discuss next. `finalize` prints the single consolidated PRD (rejected alternatives included, live queue/actions omitted) that `inception-finalize` persists through `workflow-adapter-markdown`.

## Conventions

- **Decisions are first-class.** Closing a question on a choice creates a `Decision` node with rejected alternatives + rationale — the durable artifact that prevents re-litigation.
- **Elicit via dig.** All drawing-out of the user's thinking goes through `discuss-toolkit-dig`; never fill gaps with the AI's assumptions.
- **A full session starts only when asked.** `inception` is heavy, so the agent never opens one on its own judgment: an explicit user request starts it directly, while an inferred need or a handoff from another skill must first state the cost and get a go-ahead (offering plain conversation instead).
- **Finalize is the one-way exit.** A session ends at `inception-finalize`: the working artifacts stay transient in `.agents/`, and only the consolidated PRD is confirmed through `workflow-adapter-markdown`; inception imposes no provider directory scheme. Concrete actions leave for the selected tracker (or are handed off as-is); the live open-questions queue is a snapshot and is discarded. After finalize the durable PRD is the source of truth — reopen by starting a fresh session or editing the note, not by re-rendering the retired graph.
- **Relationship to neighbors.** Inception owns the persistent, multi-phase development of a project's founding concept; `discuss-toolkit-dig` owns bounded conversational elicitation and creates no lasting artifact. Execution skills begin once the work unit is defined and groomed. The selected Markdown provider owns durable storage; inception supplies the complete `prd`-tagged note through the adapter.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
