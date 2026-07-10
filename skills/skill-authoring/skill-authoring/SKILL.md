---
name: skill-authoring
description: This skill should be used when the user wants to create a skill, improve an existing skill, or ensure a skill produces expected results. Triggers on "create a skill", "improve this skill", "skill isn't working", "fix this skill", "スキルを作りたい", "スキルを改善", "スキルを修正", "スキルがうまく動かない". Works together with plugin-dev:skill-development which handles file structure and formatting. This skill focuses on content quality. Should NOT trigger for plugin structure questions (use plugin-structure), command creation (use command-development), or agent creation (use agent-development).
user-invocable: true
---

# Skill Authoring: Content Quality Guide

This skill is about *what to put in a skill so an agent uses it effectively*. It distills the upstream guidance at [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices) (reproduced in `references/agentskills-best-practices.md`).

## Relationship with plugin-dev:skill-development

> [!IMPORTANT]
> This skill is incomplete without plugin-dev:skill-development.
> Always load both skills together when creating or improving skills.

| Component | Responsibility |
|-----------|----------------|
| **plugin-dev:skill-development** | File structure, YAML frontmatter, writing style, mechanics of progressive disclosure |
| **skill-authoring (this skill)** | Content quality: what the skill should actually say |

## Two independent axes

Skill quality has two axes that are genuinely orthogonal — work them separately:

- **Layer A — Authoring lifecycle**: *how you build* the skill (where the content comes from, how you refine it). A process over time.
- **Layer B — Content quality**: *what goes in* the finished skill (what to say, what to omit, how prescriptive to be). Properties of the artifact.

A skill can be built with a great process but still say the wrong things, or say the right things but never be tested. You need both.

---

## Layer A — Authoring lifecycle

### A1. Ground in real expertise

The most common failure is asking an LLM to generate a skill from its general training knowledge alone. The result is generic ("handle errors appropriately", "follow best practices") instead of the specific API patterns, edge cases, and project conventions that make a skill worth having. Feed real, domain-specific context into the creation process. In order of preference:

1. **Extract from a hands-on task.** Complete the real task with an agent first, then extract the reusable pattern. Capture: the steps that worked, the *corrections you made* mid-task (these become rules and gotchas), the actual input/output formats, and the project-specific facts the agent didn't already know.
2. **Synthesize from existing project artifacts.** Feed real material — runbooks, internal docs, API specs/schemas, code review comments, version-control history (patches/fixes reveal real patterns), past incident reports — and synthesize. Project-specific material beats generic reference articles.
3. **Interview the user (fallback when no artifacts exist).** When there is no hands-on trace or artifact to mine, load `discuss-toolkit-dig` to extract intent. Subject: "skill requirements for [name]". Let dig explore through its axes (Intent & Motivation, Use Cases & Edge Cases, Constraints & Priorities) rather than prescribing fixed questions. Probe specifically for *experiential* rationale: "When did this approach fail before? What did you have to correct?"

> A skill the agent already performs well *without* may not be worth writing. Sanity-check that the skill adds something the agent lacks.

### A2. Draft

Write the first version applying Layer B. Expect it to be wrong in places — drafting is not the end.

### A3. Refine with real execution

The first draft almost always needs refinement. Run the skill against real tasks, then feed *all* the results back — not just the failures:

- **Read execution traces, not just final outputs.** Wasted steps reveal problems: vague instructions (agent tries several approaches before one works), inapplicable instructions (agent follows them anyway), or too many options with no clear default.
- Ask of each run: What triggered false positives? What was missed? What could be cut?
- **When you correct an agent's mistake, add the correction to the skill's Gotchas section.** This is the single most direct way to improve a skill over time.

Even one execute-then-revise pass noticeably improves quality; complex domains need several.

> When the skill's deliverable can be judged **mechanically** (a test/oracle, a verification anchor, or binary self-criteria) and you have real tasks to run against, this refinement can be driven as a bounded autonomous loop — `skill-optimize` runs evaluate → improve → held-out gate and keeps only edits that verifiably help. Beware: fold in a correction only once it recurs across *multiple* runs (a single-trace fix is likely overfitting), and remember an imprecise evaluator makes iteration degrade quality, not improve it — so a trustworthy signal is the precondition, not the loop itself.

---

## Layer B — Content quality

### B1. Spend context wisely

Once a skill activates, its full body loads into the context window and competes for attention with everything else. Be economical:

- **Add what the agent lacks; omit what it knows.** Don't explain what a PDF is, how HTTP works, or what a migration does. Jump straight to project-specific conventions, non-obvious edge cases, and the particular tools/APIs to use. Test for each line: *"Would the agent get this wrong without this instruction?"* If no, cut it.
- **Design coherent units.** Scope a skill like a function — one coherent unit of work that composes with others. "Query a database and format results" is coherent; adding "database administration" is too much. Too narrow forces many skills to co-load; too broad is hard to trigger precisely.
- **Aim for moderate detail.** Concise stepwise guidance with one working example beats exhaustive documentation. When you find yourself covering every edge case, ask whether the agent's own judgment handles most of them.
- **Use progressive disclosure with explicit load triggers.** Keep `SKILL.md` lean (the spec recommends <500 lines / <5,000 tokens); move detailed material to `references/`. Crucially, tell the agent *when* to load each file: "Read `references/api-errors.md` if the API returns a non-200 status" beats a generic "see references/ for details."

### B2. Capture the "why" and concrete criteria

The highest-value content is what the agent can't infer: experiential judgment and environment-specific facts.

- **Concrete criteria, not adjectives.** "Write clean code" / "follow best practices" add zero information — the agent already knows them. Replace with the specific rule *and the experience behind it*: not "functions should be small" but "split a function when fixing a bug in one part could break another — e.g. `processOrder()` doing validation + pricing → split into `validate()` and `calculatePrice()`."
- **Explain why.** A rule with its rationale lets the agent handle edge cases the rule didn't anticipate. Prefer "because [specific problem that occurred]" over "because best practices say so." A threshold the agent has no basis for (e.g. an arbitrary "20 lines") leaves it unable to judge the 21-line case.
- **Gotchas are gold.** Maintain a Gotchas section of environment-specific facts that defy reasonable assumptions (e.g. "the `users` table uses soft deletes — queries must include `WHERE deleted_at IS NULL`"). Keep gotchas in `SKILL.md`, not a reference file — the agent must read them *before* hitting the situation, and may not recognize the trigger to load a file. See `references/instruction-patterns.md`.

### B3. Make the skill self-evaluable

Without success criteria for the *deliverable*, an agent completes every step, assumes success, and ships output that misses expectations. Give it what it needs to check its own work and iterate before the user sees it.

- **Define success criteria for the deliverable, not the process.** "Did I run step 1, 2, 3?" can all be Yes while the output is wrong. Criteria must evaluate the final output.
- **Each criterion must be binary, observable, and specific:** answerable Yes/No (not "mostly"), verifiable by reading the output (no external test required), and unambiguous (two people would agree on the answer).
- **Add validation loops** where it helps: do the work → run a validator (script, reference checklist, or self-check) → fix → repeat until it passes. See `references/instruction-patterns.md`.

### B4. Write a triggering description

The `description` decides whether the skill activates at the right time. Too broad → "always available, never used."

- **Intent-based, not keyword-based.** Describe the problem the user is solving, not bare keywords. "Triggers on 'code review'" misfires on "review this code *tutorial*."
- **Add exclusions when the trigger is ambiguous** ("Should NOT trigger for …"). If the trigger is already specific, exclusions are just noise.
- Set invocation flags from the user's workflow: `user-invocable` (appears in the slash menu), `disable-model-invocation` (suppress auto-activation).

Weak: `description: used when the user mentions "code review"`
Strong: `description: ...when the user wants to review code changes for quality issues — "review my PR", "check this code for bugs". Should NOT trigger for: reviewing docs, reading code to understand it, or security-specific audits (use security-review).`

### B5. Calibrate control

Match the prescriptiveness of each part to the fragility of the task — most skills are a mix, so calibrate part by part.

- **Give freedom** where multiple approaches are valid and variation is fine; here, explaining *why* beats rigid steps. (A code-review checklist can say *what* to look for without prescribing exact steps.)
- **Be prescriptive** where operations are fragile, consistency matters, or a sequence must hold — e.g. "Run exactly this command; do not add flags."
- **Provide defaults, not menus.** Pick one tool and mention alternatives briefly as escape hatches: "Use pdfplumber for text; for scanned PDFs needing OCR, use pdf2image + pytesseract" — not "you can use pypdf, pdfplumber, PyMuPDF, or pdf2image…".
- **Favor procedures over declarations.** Teach *how to approach* a class of problems, not the answer to one instance. "Read the schema, join on the `_id` convention, apply filters as WHERE clauses" generalizes; "join orders to customers on customer_id where region='EMEA'" doesn't. (Specific details — output templates, "never output PII", tool-specific commands — are still fine; it's the *approach* that should generalize.)

### B6. Reusable instruction patterns

When a task calls for one of these structures, read `references/instruction-patterns.md` for the concrete template:

- **Gotchas** — environment facts that defy assumptions (keep in `SKILL.md`)
- **Output templates** — give a concrete format to pattern-match against, rather than describing it in prose
- **Checklists** — track progress across multi-step workflows with dependencies/gates
- **Validation loops** — do → validate → fix → repeat until pass
- **Plan-validate-execute** — for batch/destructive ops: build a plan, validate against a source of truth, then execute
- **Bundled scripts** — if traces show the agent reinventing the same logic each run, write a tested script once and bundle it in `scripts/`

---

## Quality checklist before you ship

Run this against the skill you authored (or dispatch the review — see below):

- [ ] **Adds value**: content is what the agent *wouldn't* know on its own (no "write clean code", no explaining what a PDF is)
- [ ] **Concrete + rationale**: every non-obvious rule has a specific criterion and a "because [real problem]"
- [ ] **Gotchas present** (if the domain has them) and kept in `SKILL.md`
- [ ] **Self-evaluable**: deliverable success criteria are binary, observable, specific
- [ ] **Triggering description**: intent-based, with exclusions where ambiguous
- [ ] **Calibrated**: prescriptive where fragile, free where flexible; defaults not menus; procedures not one-off answers
- [ ] **Context-economical**: lean `SKILL.md`; heavy material in `references/` with explicit load triggers
- [ ] **Refined**: run against ≥1 real task and revised from the trace (Layer A3)

For a structured review, use the `skill-authoring-quality-review` skill. Under Claude Code, dispatch the `skill-authoring-quality-reviewer` subagent to run it in an isolated context; otherwise apply the skill inline. Also check against `references/anti-patterns.md`.

## How this maps onto the skill-development process

- **Step 1 (Understand)** → Layer A1: ground in real expertise (prefer task/artifact extraction; dig as fallback).
- **Step 4 (Edit)** → Layer B: write content economically, concretely, calibrated, self-evaluable.
- **Step 5 (Validate)** → the Quality checklist + `skill-authoring-quality-review` + `references/anti-patterns.md`.
- **After validation, before use** → present a short summary (Purpose / core rules with rationale / success criteria / trigger + exclusions) and get user approval; iterate if rejected.
- **Step 6 (Iterate)** → Layer A3: refine from real execution traces; fold every correction into Gotchas.

## References

- `references/instruction-patterns.md` — concrete templates for gotchas, output templates, checklists, validation loops, plan-validate-execute, and bundled scripts. *Read when implementing one of these patterns.*
- `references/anti-patterns.md` — common content failure modes with detection cues. *Read when reviewing a skill's content.*
- `references/agentskills-best-practices.md` — the upstream source these guidelines distill. *Read for the full original treatment.*
