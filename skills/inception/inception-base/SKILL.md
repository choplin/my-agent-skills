---
name: inception-base
description: Shared resources for the inception skill family — the thinking-graph JSON schema, the shell+jq CLI that interprets the graph, the node/graph data model, the phase model, and the convention for eliciting the user's thinking via dig. Other inception skills delegate to this skill to read the model, run the CLI, or render the document projections. Use this skill when an inception skill asks to follow the graph schema, run the inception CLI, or apply the phase/node model. Not typically invoked on its own.
user-invocable: false
allowed-tools: Read, Write, Edit, Glob, AskUserQuestion, Bash
---

# Inception Base

Shared substrate for the `inception` skill family: a phase-driven, dialogic facilitation that helps the user shape a fuzzy idea into a solid footing at the *start* of a project. This skill holds the parts every phase shares — the data model, the CLI, and the cross-cutting conventions.

> Scope guard: inception solidifies the founding concept. It does **not** track project progress or execute the actions — once actions are concrete, hand them to whatever execution/tracking workflow the user prefers (e.g. `dev-workflow-kickoff`, `goal-loop`, `exec-plan`). Keep the graph about thinking, not task management.

## The one idea: a graph, projected

Everything the user thinks lands in **one thinking graph** (`graph.json`). The PRD, the decision record, the action items, and the open questions are **not separate authoritative files — they are projections rendered from the graph.** This kills the cut-and-paste/provenance problem of moving text between documents.

- Edit thinking → edit `graph.json`.
- Re-render the human-readable views with the CLI's `render`.
- Never hand-edit the rendered `*.md`; they are regenerated and your edits will be lost.

**The graph is internal; the kept documents are self-contained.** `graph.json` is scaffolding — node ids, `status`/`nextMove` enums, and `dependsOn` edges are mechanics for *you*, never for the reader. The rendered `*.md` must read clearly on their own, with no trace of graph internals. Likewise, when you talk to the user, speak in the content, not in node ids ("the persistence decision", not "n2"). If you ever surface graph mechanics in a kept document or a summary, that is a leak to fix.

## Storage

```
.claude/inception/<topic-slug>/
├── graph.json        # the single source of truth (schema: schema/graph.schema.json)
├── prd.md            # projection: foundational PRD (see references/prd-template.md)
├── decisions.md      # projection: Decision nodes with rejected alternatives
├── action-items.md   # projection: Action nodes
└── open-questions.md  # projection: open discussion nodes by nextMove + deferred
```

`.claude/` keeps these transient working notes out of the committed tree. If `.claude/inception/` is not already git-ignored, add it to `.gitignore` when running `init`.

Everything under `.claude/inception/` is transient. The **durable** output is written only at the end, by `inception-finalize`: one consolidated PRD persisted to the Project Notes vault. After that, the vault PRD is authoritative and the graph here is a spent working note (see the phase model's terminal exit below).

## Language: plain, clear English

All artifacts — every node's `content` and every PRD field — are written in **plain, clear English**, regardless of the conversation language. Short sentences, concrete nouns, no rhetorical flourish. Rationale: in prose, rhetoric reads as substance and lets thin thinking pass unnoticed; plain English exposes a gap instead of papering over it. The dialogue with the user can be in any language; the recorded thinking is English.

## The PRD is foundational, not a summary

`prd.md` is meant to be a long-term anchor — what a new contributor reads months later to understand what this is and why. It renders a full template (`references/prd-template.md`): Summary, Background, Problem, Purpose/Vision, Central question, Target users, Value proposition, Goals, Non-goals, plus Direction (decisions) / Risks / Open-by-design drawn from the graph. Live open questions stay in `open-questions.md`, not the PRD. **Unfilled sections render as `_not yet defined_`** — that is a signal to keep working, not to converge. Fill each PRD field from the user's own input via dig; never write the AI's guess into a PRD field. The session fields backing these sections are in the schema (`session.summary`, `session.problem`, …).

## Node / graph model

A node is one unit of thinking. Full schema: `schema/graph.schema.json`.

| Field | Meaning |
|-------|---------|
| `type` | `Question` (open point), `Idea`, `Insight` (something learned), `Counter` (objection / premise attack), `Decision` (a settled choice), `Action` (concrete work) |
| `parentId` | issue-tree parent (structure) |
| `dependsOn[]` | nodes this is blocked by (graph edges) — drives "what to discuss next" |
| `status` | `open` / `resolved` / `deferred` / `dropped` |
| `nextMove` | for OPEN discussion nodes only — the planned next move, **not** an intrinsic type |
| `decision` | for `Decision` only — `chosen`, `rejected[]` (option+reason), `rationale` |

### nextMove — the planned move, not a category

`nextMove` answers "what do we do next with this open point", and it changes as the point matures:

| nextMove | The AI's move |
|----------|---------------|
| `decide` | surface enumerable, mutually-exclusive options and get a choice |
| `investigate` | name what to find out and who/how |
| `validate` | find the cheapest way to test the assumption |
| `deepen` | the point is not yet resolvable — discuss further |

Only `Question`/`Idea`/`Counter` nodes carry a nextMove and appear in the open-questions queue. `Action` nodes are work, not discussion — they go to action-items regardless of status.

### Decisions are first-class

When a question closes on a choice, do not just delete it. Add a `Decision` node recording `chosen`, the `rejected` alternatives with reasons, and the `rationale`. **This is the single most valuable durable artifact** — it is what prevents the same choice from being re-litigated weeks later. Mark the originating question `resolved` and link the Decision under it (`parentId`).

## The CLI: `scripts/inception.sh`

Run the script located at `scripts/inception.sh` inside this skill's directory. It is **read-only except `init` and `render`** — to change thinking, edit `graph.json` directly, then re-render.

| Command | Use |
|---------|-----|
| `init <dir> [topic]` | create `<dir>/graph.json` skeleton |
| `tree <graph.json>` | issue tree, indented (`[type/status]` prefix) |
| `open <graph.json>` | open discussion nodes grouped by nextMove |
| `next <graph.json>` | **the foundational open nodes to discuss next** — unblocked nodes ranked by how many others depend on them |
| `check <graph.json>` | structural lint (dup ids, dangling refs, Decision without record, etc.) |
| `render <graph.json> <dir>` | regenerate the four `*.md` projections |
| `finalize <graph.json>` | print **one consolidated PRD** to stdout — Direction carries each decision's rejected alternatives + rationale, and the live queue / action items are omitted. Used by `inception-finalize` to persist the durable footing (it is read-only, like the query commands). |

Two habits: run `check` after editing the graph, and `render` whenever you want the user to read the current state. Use `next` instead of guessing which open point is most foundational — the dependency graph answers it.

## Eliciting the user's thinking — always via dig

This family's job is to grow the *user's* thinking, never to fill gaps with the AI's assumptions. Whenever a phase needs to draw out what the user actually thinks (their intent, criteria, the real problem, which option they prefer), **delegate the elicitation to `discuss-toolkit-dig`** rather than interviewing ad hoc. Provide dig the subject and context (e.g. "clarify the real problem behind this central question"); let dig drive the questions. Capture what surfaces as nodes in the graph.

This is a hard rule, not a suggestion: a resolution built on an assumed answer looks decided and silently blocks later work. If the user has not actually decided, the node stays `open`.

## Phase model

The session moves through phases; in each, the AI takes a different stance. The orchestrator estimates the phase and **proposes** transitions for the user to approve (it never switches silently). Full detail and per-phase methods: `references/phases.md`.

| Phase | session.phase | AI stance |
|-------|---------------|-----------|
| 構想 Framing | `framing` | Socratic — find the real problem before any solution |
| 発散 Diverge | `diverge` | widen ideas and perspectives, no judging |
| 構造化 Structure | `structure` | cluster into an issue tree, set dependencies |
| 深掘り Deepen | `deepen` | attack premises, devil's advocate, resolve points |
| 収束 Converge | `converge` | synthesize: decisions, tradeoffs, next actions |

Phases are not strictly linear — deepening often spawns new divergence. Loop as needed.

### Terminal exit: 確定 Finalize — `inception-finalize`

After converge confirms the footing is done-enough, the session leaves the graph. **Finalize is not a sixth phase** — the five phases shape thinking inside the transient graph; finalize moves the result out to durable memory (one consolidated PRD in the vault), hands concrete actions to a tracker, and retires the graph. It is one-way: reopening means a fresh session or editing the vault note, not re-rendering the old graph. `inception-quick` also ends here, to keep its `prd-quick.md`.
