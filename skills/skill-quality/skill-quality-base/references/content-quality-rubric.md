# Content-quality rubric (B1–B6)

The rubric for judging *what a skill says* — the content an agent must be able to
act on. It is the shared reference for two consumers in the `skill-quality` family:

- `skill-quality-review` scores a target skill against it (static mode).
- `skill-quality-improve` applies it when writing edits (*how* to write an edit
  well; the improve step decides *which* edits to make).

Authoring a skill from scratch (intent capture, drafting, the create→test→iterate
lifecycle) is out of scope here — use whatever skill-creation path your agent
provides for that, and apply this rubric to the content it produces.

These guidelines distill the [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices)
(reproduced in `agentskills-best-practices.md`). For failure patterns and
detection cues, see `anti-patterns.md`; for concrete instruction templates, see
`instruction-patterns.md`.

---

## B1. Spend context wisely

Once a skill activates, its full body loads into the context window and competes for attention with everything else. Be economical:

- **Add what the agent lacks; omit what it knows.** Don't explain what a PDF is, how HTTP works, or what a migration does. Jump straight to project-specific conventions, non-obvious edge cases, and the particular tools/APIs to use. Test for each line: *"Would the agent get this wrong without this instruction?"* If no, cut it.
- **Design coherent units.** Scope a skill like a function — one coherent unit of work that composes with others. "Query a database and format results" is coherent; adding "database administration" is too much. Too narrow forces many skills to co-load; too broad is hard to trigger precisely.
- **Aim for moderate detail.** Concise stepwise guidance with one working example beats exhaustive documentation. When you find yourself covering every edge case, ask whether the agent's own judgment handles most of them.
- **Use progressive disclosure with explicit load triggers.** Keep `SKILL.md` lean (the spec recommends <500 lines / <5,000 tokens); move detailed material to `references/`. Crucially, tell the agent *when* to load each file: "Read `references/api-errors.md` if the API returns a non-200 status" beats a generic "see references/ for details."

## B2. Capture the "why" and concrete criteria

The highest-value content is what the agent can't infer: experiential judgment and environment-specific facts.

- **Concrete criteria, not adjectives.** "Write clean code" / "follow best practices" add zero information — the agent already knows them. Replace with the specific rule *and the experience behind it*: not "functions should be small" but "split a function when fixing a bug in one part could break another — e.g. `processOrder()` doing validation + pricing → split into `validate()` and `calculatePrice()`."
- **Explain why.** A rule with its rationale lets the agent handle edge cases the rule didn't anticipate. Prefer "because [specific problem that occurred]" over "because best practices say so." A threshold the agent has no basis for (e.g. an arbitrary "20 lines") leaves it unable to judge the 21-line case.
- **Gotchas are gold.** Maintain a Gotchas section of environment-specific facts that defy reasonable assumptions (e.g. "the `users` table uses soft deletes — queries must include `WHERE deleted_at IS NULL`"). Keep gotchas in `SKILL.md`, not a reference file — the agent must read them *before* hitting the situation, and may not recognize the trigger to load a file. See `instruction-patterns.md`.

## B3. Make the skill self-evaluable

Without success criteria for the *deliverable*, an agent completes every step, assumes success, and ships output that misses expectations. Give it what it needs to check its own work and iterate before the user sees it.

- **Define success criteria for the deliverable, not the process.** "Did I run step 1, 2, 3?" can all be Yes while the output is wrong. Criteria must evaluate the final output.
- **Each criterion must be binary, observable, and specific:** answerable Yes/No (not "mostly"), verifiable by reading the output (no external test required), and unambiguous (two people would agree on the answer).
- **Add validation loops** where it helps: do the work → run a validator (script, reference checklist, or self-check) → fix → repeat until it passes. See `instruction-patterns.md`.

## B4. Write a triggering description

The `description` decides whether the skill activates at the right time. Too broad → "always available, never used."

- **Intent-based, not keyword-based.** Describe the problem the user is solving, not bare keywords. "Triggers on 'code review'" misfires on "review this code *tutorial*."
- **Add exclusions when the trigger is ambiguous** ("Should NOT trigger for …"). If the trigger is already specific, exclusions are just noise.
- Set invocation flags from the user's workflow: `user-invocable` (appears in the slash menu), `disable-model-invocation` (suppress auto-activation).

Weak: `description: used when the user mentions "code review"`
Strong: `description: ...when the user wants to review code changes for quality issues — "review my PR", "check this code for bugs". Should NOT trigger for: reviewing docs, reading code to understand it, or security-specific audits (use security-review).`

## B5. Calibrate control

Match the prescriptiveness of each part to the fragility of the task — most skills are a mix, so calibrate part by part.

- **Give freedom** where multiple approaches are valid and variation is fine; here, explaining *why* beats rigid steps. (A code-review checklist can say *what* to look for without prescribing exact steps.)
- **Be prescriptive** where operations are fragile, consistency matters, or a sequence must hold — e.g. "Run exactly this command; do not add flags."
- **Provide defaults, not menus.** Pick one tool and mention alternatives briefly as escape hatches: "Use pdfplumber for text; for scanned PDFs needing OCR, use pdf2image + pytesseract" — not "you can use pypdf, pdfplumber, PyMuPDF, or pdf2image…".
- **Favor procedures over declarations.** Teach *how to approach* a class of problems, not the answer to one instance. "Read the schema, join on the `_id` convention, apply filters as WHERE clauses" generalizes; "join orders to customers on customer_id where region='EMEA'" doesn't. (Specific details — output templates, "never output PII", tool-specific commands — are still fine; it's the *approach* that should generalize.)

## B6. Reusable instruction patterns

When a task calls for one of these structures, read `instruction-patterns.md` for the concrete template:

- **Gotchas** — environment facts that defy assumptions (keep in `SKILL.md`)
- **Output templates** — give a concrete format to pattern-match against, rather than describing it in prose
- **Checklists** — track progress across multi-step workflows with dependencies/gates
- **Validation loops** — do → validate → fix → repeat until pass
- **Plan-validate-execute** — for batch/destructive ops: build a plan, validate against a source of truth, then execute
- **Bundled scripts** — if traces show the agent reinventing the same logic each run, write a tested script once and bundle it in `scripts/`

---

## Quality checklist before you ship

Run this against the skill (or dispatch `skill-quality-review`):

- [ ] **Adds value**: content is what the agent *wouldn't* know on its own (no "write clean code", no explaining what a PDF is)
- [ ] **Concrete + rationale**: every non-obvious rule has a specific criterion and a "because [real problem]"
- [ ] **Gotchas present** (if the domain has them) and kept in `SKILL.md`
- [ ] **Self-evaluable**: deliverable success criteria are binary, observable, specific
- [ ] **Triggering description**: intent-based, with exclusions where ambiguous
- [ ] **Calibrated**: prescriptive where fragile, free where flexible; defaults not menus; procedures not one-off answers
- [ ] **Context-economical**: lean `SKILL.md`; heavy material in `references/` with explicit load triggers
- [ ] **Refined**: run against ≥1 real task and revised from the trace (the empirical loop is `skill-quality-optimize`)
