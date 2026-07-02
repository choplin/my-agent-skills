# inception

Skills for the **start of a project** — think a fuzzy idea into a solid footing through a phase-driven, dialogic facilitation. The session grows a single thinking graph that is projected into a PRD, a decision record, action items, and open questions.

> Scope: inception shapes the founding concept. It does **not** track project progress or execute the actions — once actions are concrete, hand them to whatever execution/tracking workflow fits (e.g. `dev-workflow`, `goal-loop`, `exec-plan`), the user's choice.

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
| `inception-quick` | Lightweight route — capture just the background and purpose into a short `prd-quick.md`, no graph, no full session |
| `inception-base` | Shared model: graph JSON schema, the shell+jq CLI, the phase model, the dig-elicitation rule |
| `inception-framing` | 構想 — Socratic; find the real problem before solutions |
| `inception-diverge` | 発散 — widen ideas and perspectives, no judging |
| `inception-structure` | 構造化 — cluster into an issue tree, wire dependencies |
| `inception-deepen` | 深掘り — attack premises, resolve points, record decisions |
| `inception-converge` | 収束 — synthesize into purpose, decisions, actions |
| `inception-finalize` | 確定 — terminal exit; persist the consolidated PRD to the Project Notes vault, hand actions to a tracker, retire the graph |

## Artifacts

Stored under `.claude/inception/<topic-slug>/` (transient, not committed):

- `graph.json` — the single source of truth (full `inception` only)
- `prd.md` / `decisions.md` / `action-items.md` / `open-questions.md` — projections (regenerated; do not hand-edit)
- `prd-quick.md` — the `inception-quick` route's hand-written capture (separate from the rendered `prd.md`, so neither clobbers the other)

Everything above is transient. The **durable** artifact is produced only at the end by `inception-finalize`: one consolidated PRD written to the Project Notes vault (`Notes/PRD - <title>.md`), with the decisions' rejected alternatives preserved. After finalize, the vault PRD is authoritative and the `.claude/` graph is spent.

## CLI

`inception-base/scripts/inception.sh` (bash + jq) interprets the graph so the agent doesn't traverse raw JSON:

```
init <dir> [topic]      tree <graph.json>       open <graph.json>
next <graph.json>       check <graph.json>      render <graph.json> <dir>
finalize <graph.json>
```

`next` is the key one — it walks `dependsOn` to surface the most foundational open point to discuss next. `finalize` prints the single consolidated PRD (rejected alternatives included, live queue/actions omitted) that `inception-finalize` persists to the vault.

## Conventions

- **Decisions are first-class.** Closing a question on a choice creates a `Decision` node with rejected alternatives + rationale — the durable artifact that prevents re-litigation.
- **Elicit via dig.** All drawing-out of the user's thinking goes through `discuss-toolkit-dig`; never fill gaps with the AI's assumptions.
- **Two routes.** Full `inception` shapes an idea through the whole phased session and the thinking graph. `inception-quick` skips all of that to capture just the background and purpose into a short `prd-quick.md` — use it when the idea does not need shaping, only recording. The two use separate files so neither clobbers the other, and the upgrade is lossless: starting full `inception` on a slug that already has a `prd-quick.md` seeds the graph from it before rendering.
- **Finalize is the one-way exit.** Both routes end at `inception-finalize`: the working artifacts stay transient in `.claude/`, and only the consolidated PRD is confirmed into the Project Notes vault (via `project-notes-base`, no new directory). Concrete actions leave for a tracker (Linear, `dev-workflow-kickoff`, …); the live open-questions queue is a snapshot and is discarded. After finalize the vault PRD is the source of truth — reopen by starting a fresh session or editing the note, not by re-rendering the retired graph.
- **Relationship to neighbors.** Earlier and lighter than `dev-workflow` (which begins once a task is defined); broader than `discuss-toolkit-dig` (which clarifies one intent without lasting artifacts). Shares its durable store with `project-notes` (finalize writes a `PRD - ` note into the same vault).
