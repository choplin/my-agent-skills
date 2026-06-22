---
title: "Loop Engineering vs Spec-Driven Development — Research & dev-workflow Improvement Proposal"
date: 2026-06-11
status: accepted
type: research-note
tags:
  - dev-workflow
  - loop-engineering
  - spec-driven
  - agent-harness
  - research
summary: >
  Review of the dev-workflow plugin, a multi-source investigation of recent
  AI coding-agent practices (especially "loop engineering"), the relationship
  between spec-driven development and loop engineering, and the agreed v1
  improvement roadmap.
---

# Research Notes: dev-workflow Improvement — Loop Engineering vs Spec-Driven

Created: 2026-06-11
Purpose: Record the dev-workflow plugin review and the investigation/discussion of recent AI coding-agent trends (especially loop engineering), to inform future improvement design.

---

## 1. dev-workflow Plugin Review (2026-06-11)

### Strengths

- Documents as the single source of persistent state (spec/plan/review.md).
- Explicit "AI Filling" anti-pattern (the AI filling gaps with plausible assumptions).
- Two consecutive FAILs escalate to NEEDS REVIEW (prevents infinite loops).
- Task→Story promotion defined as a normal flow, not a failure.
- user-review item-level state machine; no implementation before approach agreement.

### Issues (by priority)

1. **Workflow adherence is enforced by prompt only (no hooks).**
   - workflow-concepts.md itself admits the "self-review gets skipped" problem, but the only countermeasure is stronger prompting.
   - Proposal: SessionStart hook (inject in-progress state), Stop hook (detect missing self-review), PostToolUse hook (detect missing Plan Mode Context).
2. **State management relies on LLM Markdown parsing + the state-evaluation logic is triplicated.**
   - The state-evaluation priority table is duplicated across resume-work / handoff / workflow-status (workflow-status' copy already differs subtly).
   - Legacy Phase-value backward-compat mappings are duplicated in 4 places.
   - The `Resolved: X / Y` counter is hand-maintained even though it is derivable from item statuses.
   - Proposal: move state evaluation into a plugin-bundled script that emits JSON; at minimum consolidate into a single reference.
3. **self-review level-detection bug** (`self-review/SKILL.md:32`).
   - The `story/*/spec.md` glob misroutes to Story flow whenever a completed Story directory remains.
   - Proposal: detect via the current git branch / directory correspondence.
4. **Smaller inconsistencies.**
   - workflow-status does not list Tasks (only scans epic/story).
   - The required dependency on `discuss-toolkit:dig` is undeclared (kickoff, user-review); same for the `continue-discussion` reference.
   - Only create-task is missing `user-invocable: false`.
   - self-review's self-correction loop has no false-positive (noise finding) safeguard.
5. **Reconsider the /clear-mandatory principle and handoff ritual** (a design decision).
   - Better auto-compact and subagent delegation reduce the cases where the cost is worth it (model-generation dependent; see §3).

---

## 2. Deep-Research Findings (conducted 2026-06-11)

106 agents, 24 sources, 119 claims extracted → 25 put through 3-vote adversarial verification → 24 confirmed, 1 refuted.

### Verified key findings (Anthropic primary sources, passed 3-0)

| Finding | Content | Source |
|---------|---------|--------|
| Two-part harness | An initializer (set up environment + progress file + initial commit) → a coding agent advances each session. Fresh context recovers state from the progress file + git history. | effective-harnesses-for-long-running-agents |
| State in JSON | "The model is less likely to inappropriately change or overwrite JSON than Markdown." Restrict edits to the `passes` field; forbid test deletion in strong wording. | ibid. |
| Generator/evaluator separation | A single agent praises its own work even when quality is poor. Tuning the skepticism of an independent evaluator is easier. | harness-design-long-running-apps |
| Planner first | Without a planner the generator under-scopes and starts implementing without specifying. | ibid. |
| The verification watershed | "Can the agent itself run a pass/fail check?" is the watershed of autonomy. Without it, the human becomes the verification loop. | code.claude.com/docs best-practices |
| Don't chase every review finding | "A reviewer prompted to find gaps will report some even when the work is sound. Chasing every finding leads to over-engineering" (official warning). | ibid. |
| Stop-hook gate | A Stop hook can block turn-end until a verification script passes — but Claude Code overrides after 8 consecutive blocks (infinite forcing is impossible). | ibid. |
| **The pruning principle** | "Every harness component encodes an assumption about what the model can't do on its own; stress-test and prune them each model generation." Opus 4.6 ran 2h+ coherently without sprint decomposition. | harness-design-long-running-apps |
| compaction vs reset | Reset-with-structured-handoff superiority was motivated by Sonnet 4.5's "context anxiety." Opus 4.5 removed the need for resets (**the only claim that split 2-1; model-dependent**). | ibid. |

### State of loop engineering (the Ralph family)

- **Official example**: [anthropics/cwc-long-running-agents](https://github.com/anthropics/cwc-long-running-agents) (Code with Claude 2026 teaching material). A while-true fresh-context loop: while `test-results.json` still has `"passes": false`, relaunch the builder with `claude -p`; if the evaluator fails it, write findings to `NEXT_FINDINGS.md` for the next iteration.
- **Three primitives**: (1) a Default-FAIL contract (start with all criteria false; cannot flip to pass without opening the evidence file, enforced by a PreToolUse hook); (2) a fresh-context evaluator with no Write/Edit; (3) self-handoff via PROGRESS.md + git commits.
- "Asking politely in a prompt does not reliably prevent false 'done' reports. **The harness makes 'done' structural.**" (stated in the README).
- The built-in Claude Code `/goal` command is the built-in version of the same primitives.
- **Caveat**: the repo self-describes as an "unmaintained event demo." In production OSS, **bounded (capped) loops dominate**, not infinite ones.

### Comparable OSS

- **claude-code-workflows (shinpr)**: the most active OSS closest to dev-workflow (440 stars). Deliberate separation of durable artifacts (committed to docs/) from transient execution state (cleaned up on exit). investigator→verifier→solver self-verification loop with a **2-iteration cap** + escalation.
- **claude-code-spec-workflow (Pimzino)**: 4-stage spec-driven + steering files (3,765 stars). **Migrated to an MCP-server version; the Claude Code-only version is in reduced maintenance** (migration motive unknown, needs further investigation).
- **pro-workflow**: persists user correction instructions as rules in SQLite (FTS5), injected each session via a SessionStart hook. (Its PreCompact/PostCompact-hook claim was **refuted 0-3**.)

### Limits of the investigation

The Ralph original (Geoffrey Huntley), Gas Town, beads, GitHub Spec Kit, OpenSpec, Kiro, claude-task-master, BMAD-METHOD, superclaude, agent-os left no claims that passed verification and are unevaluated. All official findings are the vendor's own qualitative case studies, with no controlled benchmarks or independent reproduction.

---

## 3. Concept: The Relationship Between Spec-Driven and Loop Engineering (discussion conclusions)

### Two halves of the same problem

- **Spec-driven** = "how to define the right target." It locates error in ambiguity of intent and builds quality in via an up-front agreed document (feedforward control).
- **Loop engineering** = "how to converge on a fixed target." It locates error in false completion reports and drift, and converges by iterating against a machine-checkable predicate (feedback control).
- **dev-workflow already has all the loop parts** (document state / fresh context / self-review / promotion rule). The differences are only two: (1) who turns the crank — a human + prompt adherence vs an external mechanism; (2) what defines completion — LLM self-report + LGTM vs an evidence-required machine predicate.
- Integrated form: the spec is the specification for the loop's completion predicate. Only the implement→self-review segment can be looped. kickoff/spec (negotiating intent) and user-review (value judgment) are inherently human-paced.

### Three error classes and where the loop helps

- **(a) Spec omissions** (unknown unknowns) — impossible to write into any predicate; found only once you see something running.
- **(b) Implementation-approach flaws not expressed in the spec** — partially caught by an LLM evaluator, but noisy.
- **(c) Mechanical correctness** (tests/build/lint) — predicate-able. **This is the only class the loop fully covers.**

Most real-world rework is (a)/(b) (consistent with the user's experience); (c) is already mostly handled by CI + existing enforcement.

### Nested loop structure

```
Outer loop (human as evaluator): spec → implement → human review → omission found → revise spec → …
Inner loop (machine as evaluator):        implement ⇄ predicate (tests/build/criteria)
```

- Loop engineering can only automate the inner loop. **A spec omission surfacing in human review is not a failure — it is the outer loop working correctly** (dev-workflow's "evolving spec", "Design Change", and "promotion flow" already account for this).
- The inner-loop agent evaluates *against the spec*, so it cannot declare "the spec itself is wrong." A strong loop + weak predicate risks mass-producing "polished garbage" (Goodhart's law).
- Loop engineering's honest premise is not "a perfect spec" but "**a verifiable floor + cheap retries**." It does not eliminate rework; it makes rework cheap.

### Conditions for a goal-driven loop (the radical form that puts spec generation inside the loop)

In the form where the human gives only a goal and the loop also produces the spec (the Ralph original, Gas Town), the spec's function shifts from "a contract with the human" to "the loop's working memory," and the human approval gate disappears. But there is a **conservation law of alignment information** — the information the human used to inject during spec review must go somewhere, and there are only three destinations:

1. Compressed into the goal statement and the evaluator (only when the goal can be written completely in a few lines).
2. **An external oracle exists** (cloning, porting, implementing an existing spec, a benchmark) — nearly all success demos are this class.
3. The human reviews the whole artifact at the end (= deferring the alignment conversation to the most expensive point).

→ **The real axis is "where the oracle lives."** For work whose answer lives in the world, a goal-driven loop is correct; for work whose answer lives only in the human's head (ordinary product development), the spec must remain outside as a contract.
→ **kickoff's Task/Story test ("can you write Criteria directly from Needs?") doubles as an oracle detector.** Rather than choosing spec-driven vs loop for the whole plugin, route per work item by that test — that is the correct integration.

---

## 4. Article Assessment

### sairahul1's loop-engineering article (2026-06-09, 3.3M views)

- Content: "Don't prompt, design the loop" (Steinberger/OpenAI); "My job is to write the loop" (Cherny/Anthropic). Six components (Automations/Worktrees/Skills/Plugins/Subagents/Memory), single-agent vs fleet loops, economics enabled by cheap models.
- Assessment: **a repackaging of the verified harness-design literature.** The parts are validated, but it never mentions the oracle problem (who verifies the spec's validity) and generalizes while hiding its applicability conditions.
- Only the economics point is new: "cheap retries" now hold. But polished garbage also becomes cheap, so the bottleneck shifts to human review bandwidth, and the value of good predicates and specs actually rises.
- Practical use: useful as a gap-analysis checklist. dev-workflow has Memory/Subagents/Skills; **Automations (the crank) and Worktrees (parallelism) are missing.**

### 0x_rody's self-improving-loop article (2026-06-10)

- Content: implements an inner loop with 3 files (PostToolUse/Stop hooks + CLAUDE.md + fixer agent). Max 5 retries, stop after the same error twice, no editing tests. "The model didn't get smarter. It just stopped being allowed to quit early."
- Assessment: **an honest, small implementation of the verified consensus pattern.** Each constraint maps 1:1 to a primary-source finding (bounded loop, Goodhart safeguard, Stop-hook gate, fresh-context fixer). It does not overclaim.
- But it only solves (c) and is unrelated to (a)/(b). It is corroboration that dev-workflow's "escalate after 2 FAILs" independently converged on the same design — and a reference implementation for turning the self-review loop into a hook-enforced one.

### The discourse map

Loop-engineering discourse circulates in two layers: the "reliable but unglamorous **inner loop**" (rody type) and the "flashy but oracle-problem-hiding **outer loop**" (sairahul type). The real bottleneck — (a)/(b) — has no solution in either; the countermeasure is "**shorten the distance until the human first sees something real.**"

---

## 5. Applicability Summary for dev-workflow

### High value to adopt (backed by official primary sources)

1. JSON for machine-managed state (human-readable spec/plan stay Markdown; phase/progress/review items split into `state.json`).
2. Default-FAIL contract (acceptance criteria start all-false; flip to pass only with evidence).
3. Scripted verification (each spec Criterion gets an executable verify command; the more pass/fail is mechanical, the more the loop closes).
4. Review-finding filter criteria (add a "does it affect correctness / requirements?" filter to the verdict mapping).
5. State injection via a SessionStart hook (replaces the handoff copy-paste ritual).

### Be cautious (model-dependent, thin evidence)

- Infinite while-true loops (production favors bounded loops; keep the current 2-FAIL rule + structure the completion check).
- Forced continuation via Stop hook (depends on the 8-block implementation detail; good as a gate, risky as a loop engine).
- Keeping the /clear-mandatory principle (reset superiority was motivated by a Sonnet 4.5 flaw; relaxing to "keep a resumable state" is reasonable).

### The countermeasure for rework (a)/(b) is shortening the outer loop, not the loop

- Show the human the first reviewable real artifact (a thin vertical slice) as fast as possible.
- Strengthen plan review from "file list + steps" to "explicitly ask the implementation-approach decision."
- Feed omission patterns found in user-review back into the spec template / kickoff questions via post-task.

### Overarching warning (the pruning principle)

Build heavy structure (fine-grained phases, the handoff ritual, forced checkpoints) on the assumption it will become obsolete across model generations, so it is easy to delete. Prioritize "model-independent quality assurance like verification gates."

---

## 6. Improvement Proposal v1 (agreed with the user 2026-06-12)

Design principles: (1) make completion structural; (2) move the crank to mechanism; (3) shorten the outer loop; (4) build it to be prunable.

### A. Make completion structural (predicate-ize the inner loop)

- **A-1. Introduce state.json**: split machine-managed state (criteria/steps/review items) out of Markdown. Do not store derived data (Resolved counter, state category) — derive it in the script. Initialize all criteria with `"passes": false` (Default-FAIL contract; no flipping to true without evidence).
- **A-2. Script the state evaluation** `scripts/workflow-state.py`: return all work units' state as JSON. resume-work/handoff/workflow-status/self-review just consume the script result. Resolves the triplication, the legacy-mapping duplication, the self-review level-detection bug, and the workflow-status Task omission in one move.
- **A-3. Predicate-ize Criteria** (create-spec change): for each Criterion, always ask "is it machine-verifiable?" — if yes, a `Verify:` command; if no, fix it as NEEDS REVIEW (human) from the start.
- **A-4. Restructure self-review**: machine-verification pass (run verify commands; cheap, deterministic) → then, after all pass, the LLM review pass (expensive, probabilistic). Require all reviewers to classify findings: `correctness/requirements` (gates) vs `improvement` (recorded only). Update the Codex verdict mapping likewise.

### B. Move the crank to mechanism (hooks + routing)

- **B-1. SessionStart hook**: run workflow-state.py and inject in-progress state + next action. Replaces the handoff copy-paste ritual (handoff shrinks to session-notes use).
- **B-2. Stop hook**: only when "all plan steps done but no review record," block up to 2 times with a notification. Not a loop engine (does not depend on the 8-block implementation detail).
- **B-3. Oracle-test routing** (kickoff extension): if "Criteria directly writable" + "all Criteria predicate-able," classify as **autonomous-task**. Skip the spec approval gate, write only goal + predicates, run via an autonomous loop (e.g. `/goal`), human reviews only the artifact. Non-predicate-able work keeps the spec as a human contract as before.
- **B-4. (optional, deferred)** Worktree parallelism for Epic Stories (wtm integration).

### C. Shorten the outer loop (countermeasure for (a)/(b) rework — potentially the best ROI)

- **C-1. Force a first reviewable slice** (create-plan): Step 1 = walking skeleton, with a lightweight user-review checkpoint on completion.
- **C-2. Add `## Approach Decisions` to the plan**: state the options considered and why others were rejected, so the approach can be reviewed at plan approval.
- **C-3. post-task feedback**: from Design Change / omission items, propose additions to the spec template / kickoff questions.

### D. Pruning

- /clear-mandatory principle → relax to "keep a state that can be interrupted/resumed at any time."
- Plan Mode Context inline duplication in 5 places → a single reference line.
- Declare the discuss-toolkit dependency; add `user-invocable: false` to create-task.

### E. Out of scope

- Infinite while-true loops; turning the Stop hook into a loop engine.
- Full adoption of in-loop spec generation (goal-driven) — because the work is dominated by cases where the oracle lives in the human's head.

### Sequencing

| Phase | Content |
|-------|---------|
| 0 | Bug fixes + small cleanup (self-review branch detection, dependency declaration, group D) |
| 1 | A-2 state script + A-1 state.json |
| 2 | B-1/B-2 hooks |
| 3 | A-3 predicate-ization + A-4 self-review restructure |
| 4 | C-1–C-3 outer-loop shortening |
| 5 | B-3 oracle routing |
| 6 | B-4 worktree parallelism (optional) |

After Phases 1-2, handoff/resume-work simplify and the plugin's prose shrinks (parsing/judgment logic moves down into the script).

> Implementation note (2026-06-12): Phase 0+1 shipped as Story #1 (`state-foundation`). The state evaluator was implemented in Python (`scripts/workflow-state.py`). Active-unit identification does not assume one branch per unit: a unique current-branch match wins, otherwise the most recently modified unit is used — so it works with or without per-unit branches. See `references/state-schema.md`.

## 7. Open Questions

1. Does production data exist for the Ralph original / the official ralph-loop plugin (success rate, cost, runaway cases)?
2. How do the designs of GitHub Spec Kit / OpenSpec / Kiro / BMAD-METHOD / claude-task-master differ from dev-workflow (no claims survived verification, unevaluated)?
3. Pimzino's motive for migrating from a plugin to an MCP server (is there a structural limit to plugin-form state management?).
4. Integration/division of labor between the `/goal` command and the plugin's own state machine (the trade-offs of replacing the self-review gate with /goal or a Stop hook).

---

## 8. Sources

### Primary (Anthropic official)

- https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents (2025-11-26)
- https://www.anthropic.com/engineering/harness-design-long-running-apps (2026-03-24)
- https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents
- https://code.claude.com/docs/en/best-practices
- https://code.claude.com/docs/en/goal
- https://github.com/anthropics/cwc-long-running-agents (event demo, unmaintained)

### OSS (primary)

- https://github.com/shinpr/claude-code-workflows
- https://github.com/Pimzino/claude-code-spec-workflow (reduced maintenance)
- https://github.com/rohitg00/pro-workflow (some claims refuted)

### Blogs / secondary (fetched during the investigation; claim verification partial)

- https://ghuntley.com/ralph/ , https://ghuntley.com/loop/ (Ralph original; no claims passed verification)
- https://www.seangoedecke.com/gas-and-ralph/
- https://www.codecentric.de/en/knowledge-hub/blog/the-ralph-wiggum-loop-autonomous-code-generation-with-a-fresh-context
- https://github.com/cameronsjo/spec-compare , https://arceapps.com/blog/sdd-frameworks-analysis-spec-kit-openspec-bmad/ , https://dabase.com/blog/2026/sdd-framework-comparison/ , https://somniosoftware.com/blog/spec-driven-development-in-practice-github-spec-kit-openspec-and-gsd-compared (SDD tool comparisons)
- https://www.theregister.com/special-features/2026/01/27/ralph-wiggum-loop-prompts-claude-to-vibe-clone-software/4211889
- https://alexop.dev/posts/spec-driven-development-claude-code-in-action/ , https://codebycorey.com/blog/building-a-claude-code-plugin-for-spec-driven-development/ , https://heeki.medium.com/using-spec-driven-development-with-claude-code-4a1ebe5d9f29

### X articles (2026-06, summaries fetched via mirror API)

- https://x.com/sairahul1/status/2064277888216555684 (loop engineering, 6 components, fleet loop)
- https://x.com/0x_rody/status/2064728139314389073 (self-improving loop, 3-file implementation)
