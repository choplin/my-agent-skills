# Inception Phase Model

Five phases, each a different AI stance over the same thinking graph. The orchestrator (`inception`) estimates the current phase and proposes transitions; the user approves. Phases loop — deepening spawns new divergence, structuring exposes unframed problems. Each phase is also a standalone skill (`inception-<phase>`) the orchestrator delegates to.

The shape mirrors the Double Diamond (diverge / converge twice): framing and divergence open up; structure, deepen, and converge close down — then may reopen.

In every phase, draw out the *user's* thinking via `discuss-toolkit-dig`; never substitute the AI's assumptions. Record what surfaces as graph nodes, in plain, clear English (see `prd-template.md` for why).

---

## 構想 / Framing — `inception-framing`

**Stance: Socratic. Find the real problem before any solution.** The highest-leverage early move is reframing, not answering. Resist the pull toward solutions.

- Establish the top of the foundational PRD: `session.summary`, `session.background`, `session.problem`, `session.purpose`, `session.centralQuestion`, and a first cut at `session.targetUsers` (see `prd-template.md`). The central question is the single problem the whole session organizes around.
- Methods: Socratic questioning, So-What / Why-So (空・雨・傘), "what problem are we actually solving?", restating the problem three different ways to test the framing.
- Watch for solutioning-too-early: if the user describes *how* before *why/what*, park the how as an `Idea` node and pull back to the problem.
- Graph ops: set the session fields; create root `Question` nodes for the genuinely open problems.
- Exit signal: the user recognizes the central question as the right one to be asking. Propose moving to Diverge.

## 発散 / Diverge — `inception-diverge`

**Stance: widen. Generate ideas, options, and perspectives. Do not judge yet.** Premature narrowing kills options the user has not voiced. The failure mode is stopping after one or two questions — divergence is brainstorming, so run its reproducible shape rather than eyeballing "covered."

- Run under **Osborn's four rules**: defer judgment, go for quantity, welcome wild ideas, build/combine.
- Sweep a fixed set of breadth lenses, capturing nodes from each: stakeholders, time horizons, dropped-then-added constraints, analogies & prior art, **SCAMPER** on the leading idea, inversion ("what would guarantee failure?"). Offer adjacent options for the user to react to.
- Capture every undecided thing as a node — `Idea` for possibilities, `Question` for open points. Do not resolve inline; breadth first. Set `nextMove` later (in structure), not here.
- Exit signal: every lens has been walked AND the last lens or two add little that is genuinely new (real diminishing returns) — not "feels covered." Propose moving to Structure.

## 構造化 / Structure — `inception-structure`

**Stance: organize. Cluster the divergent material into an issue tree and wire dependencies.** This is where the flat dump becomes a navigable graph.

- Methods: Issue Tree / Logic Tree (MECE — are these the right branches, are they overlapping?), clustering related nodes, naming the real underlying questions.
- Set `parentId` to build the tree; set `dependsOn` where one point blocks another; assign each open discussion node a `nextMove` (decide / investigate / validate / deepen).
- Run `check` to catch dangling refs, then `next` to see what the structure says is most foundational.
- Exit signal: the open questions have a clear shape and a defensible "discuss this first." Propose moving to Deepen.

## 深掘り / Deepen — `inception-deepen`

**Stance: adversarial. Attack premises; be the devil's advocate.** Drain the queue one foundational point at a time, but pressure-test before closing.

- Use `next` to pick the most foundational unblocked node; discuss it to resolution.
- Methods: 5 Whys, premise attack ("what must be true for this to hold?"), dialectic (thesis → antithesis → synthesis), multi-perspective, red-teaming. Record strong objections as `Counter` nodes.
- For each open node, act on its `nextMove`: `decide` → surface enumerable options (use AskUserQuestion when mutually exclusive) and get a choice; `investigate` → name what to find out; `validate` → cheapest test of the assumption; `deepen` → keep discussing.
- When a point closes: mark it `resolved` and **record the outcome** — a `Decision` node (with rejected alternatives + rationale) for a choice, an `Action` node for work, an `Insight` node for a learning. A point is not closed until its outcome is in the graph. Never close with an assumption.
- Deepening legitimately spawns new `Question`/`Idea` nodes — add them; the queue growing mid-discussion is healthy.
- Exit signal: remaining open nodes are non-foundational or deferred. Propose moving to Converge.

## 収束 / Converge — `inception-converge`

**Stance: synthesize. Pull the resolved graph into a coherent footing.**

- Methods: summarize the through-line, surface tradeoffs across decisions, sequence the actions, name what is deliberately deferred and why.
- Complete the foundational PRD: sharpen `session.valueProposition`, `session.goal`, `session.nonGoals` as decisions land (`prd-template.md`). Ensure the `Decision` nodes collectively tell a consistent story. Fill any `Action` node that a decision implies but no one captured.
- Run `render` and walk the user through `prd.md`, `decisions.md`, `action-items.md`, `open-questions.md`.
- Done-enough (all must hold, checkable by the AI):
  - the core PRD sections are non-placeholder and specific: `summary`, `problem`, `purpose`, `targetUsers`, `goal`, `nonGoals`
  - every `Action` node is a single discrete action (not "figure out X" — that stays an open `Question`)
  - every still-open node is either non-foundational or `deferred` with a `deferReason`
  - no open node depends only on other still-open nodes with no path to resolution
  Summarize this state and ask the user to confirm before declaring the footing done. Then offer to hand the actions to `dev-workflow-kickoff`.
