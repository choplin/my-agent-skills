---
name: skill-quality-standard
description: >-
  Defines the qualitative standard for a good agent skill: loadability,
  context economy, concrete guidance, judgeable outcomes, precise
  descriptions, calibrated control, direct present-tense contracts, and
  reusable instruction patterns. Applies when authoring, reviewing, or
  improving skill content.
metadata:
  description-role: trigger
---

# Skill quality standard

Use this as the canonical qualitative definition of what a good skill is.
Authoring produces content that conforms to it; `skill-quality-review` applies it
with model judgment and reports departures from it; `skill-quality-improve` keeps
candidate edits within it. A mechanical evaluation, when one is possible,
provides separate quantitative evidence and does not redefine this standard.

The standard has one mechanical precondition (B0), six content requirements
(B1–B6), and a library of reusable structures (B7). Read
`references/anti-patterns.md` when detecting violations. Read
`references/instruction-patterns.md` when selecting an instruction structure.
Read `references/writing-descriptions.md` when writing or judging frontmatter
descriptions. Read `references/agentskills-best-practices.md` only when the
condensed rules here leave an authoring question unresolved.

These guidelines distill the [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices)
reproduced in `references/agentskills-best-practices.md`.

---

## B0. Be loadable

A skill must load before any content requirement can matter. Run the mechanical
preflight first:

```sh
skill-quality-standard/scripts/lint-frontmatter.sh <skill-path>
```

The script checks that frontmatter starts and closes with `---`, top-level entries
use `key: value`, unquoted scalar values avoid YAML's `: ` parsing trap, and both
`name` and `description` exist. Exit 0 means the checked skills satisfy this
loadability precondition; exit 1 identifies malformed files to fix before applying
B1–B7.

Use a real YAML parser as the fallback when the script is unavailable. Confirm
that parsing succeeds and returns non-empty string values for `name` and
`description`.

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
- **Gotchas are gold.** Maintain a Gotchas section of environment-specific facts that defy reasonable assumptions (e.g. "the `users` table uses soft deletes — queries must include `WHERE deleted_at IS NULL`"). Keep gotchas in `SKILL.md`, not a reference file — the agent must read them *before* hitting the situation, and may not recognize the trigger to load a file. See `references/instruction-patterns.md`.

## B3. Make the outcome judgeable

Without a concrete account of a successful *deliverable*, an agent can complete
every step and still miss the point. Give the acting agent and a reviewer enough
evidence to judge the result in context.

- **Describe success in terms of the deliverable, not completed steps.** Explain
  what the result should accomplish, preserve, reveal, or enable.
- **Ground judgment in observable evidence.** Use concrete criteria, examples,
  trade-offs, and domain-specific failure modes. Qualitative criteria may require
  interpretation; give the reviewer the evidence and rationale needed to exercise
  that judgment well.
- **Match the evaluation form to the work.** Use deterministic validation when a
  reproducible checker genuinely exists. Use a model review for qualities such as
  clarity, coherence, usefulness, or appropriate judgment. Do not manufacture a
  binary proxy merely to make qualitative work look measurable.
- **Add validation loops** where they help: do the work → inspect it against the
  relevant criteria → revise. A validator may be a script, a reference checklist,
  or a reasoned model self-check. See `references/instruction-patterns.md`.

## B4. Write the description to its role

A `description` does one of two jobs, and which one is a recorded fact rather
than a judgement made while writing. Judge it against the job it has.

- **When the description is a trigger**, it decides whether the skill activates at the right time. Too broad → "always available, never used."
  - **Intent-based, not keyword-based.** Describe the problem the user is solving, not bare keywords. "Triggers on 'code review'" misfires on "review this code *tutorial*."
  - **Written in the positive.** The model matches on what is present, not on what has been ruled out. Resolve observed mistriggers by making the intended situation more precise, without adding a negative catalogue of adjacent work.
- **When the description is documentation**, something else supplies the decision to run the skill: a caller names it, a standing instruction names it, or the user types its name. Trigger phrasings and exclusions buy nothing there and cost listing budget.
- **Never redirect.** No "use `other-skill` instead", no sibling names. Skills are distributed one at a time, so the neighbour may not be installed. State the work this skill covers precisely enough that its boundary is visible from the positive description.

Weak: `description: used when the user mentions "code review"`
Strong: `description: Reviews code changes for quality issues and returns the findings. Applies when someone asks to review a diff, check code for bugs, or get a read on what was just written.`

Read `references/writing-descriptions.md` before judging this requirement or rewriting a
description: it holds the full guidance behind these bullets, including how to
settle which job a description has.

## B5. Calibrate control

Match the prescriptiveness of each part to the fragility of the task — most skills are a mix, so calibrate part by part.

- **Give freedom** where multiple approaches are valid and variation is fine; here, explaining *why* beats rigid steps. (A code-review checklist can say *what* to look for without prescribing exact steps.)
- **Be prescriptive** where operations are fragile, consistency matters, or a sequence must hold — e.g. "Run exactly this command; do not add flags."
- **Provide defaults, not menus.** Pick one tool and mention alternatives briefly as escape hatches: "Use pdfplumber for text; for scanned PDFs needing OCR, use pdf2image + pytesseract" — not "you can use pypdf, pdfplumber, PyMuPDF, or pdf2image…".
- **Favor procedures over declarations.** Teach *how to approach* a class of problems, not the answer to one instance. "Read the schema, join on the `_id` convention, apply filters as WHERE clauses" generalizes; "join orders to customers on customer_id where region='EMEA'" doesn't. (Specific details — output templates, "never output PII", tool-specific commands — are still fine; it's the *approach* that should generalize.)

## B6. State the current contract directly

A skill is an executable description of how the agent should behave now. Write
that contract directly, without making the agent reconstruct it from discarded
alternatives or the path that produced it.

- **Use the desired behavior as the subject.** State the action, output, boundary,
  or decision rule that applies now. Prefer "Return a Markdown report with..." to
  "Do not return the old JSON format." The first sentence gives the agent a
  target; the second spends context activating an irrelevant target.
- **Remove historical residue.** Origin stories, superseded names, former
  workflows, and comparisons with previous implementations belong outside the
  skill. Judge the current artifact on its own. Consult version history only when
  an explicit migration, deprecation, interoperability, or versioned external
  contract is itself part of the current deliverable and needs verification.
- **Rewrite contrast-defined behavior.** Inspect `not X`, `instead of X`,
  `rather than X`, and negative imperatives. If `X` is merely an old or rejected
  design, delete the comparison and state the selected behavior. Preserve a
  negative constraint when it directly expresses a present invariant or safety
  boundary, such as "Never expose credentials."
- **Require an explicit reason for compatibility content.** Compatibility belongs
  in a skill only when interoperability, migration, deprecation, or a versioned
  schema/protocol is part of the task's current deliverable. Name the external
  contract and the consequence the agent must preserve. Treat compatibility as
  absent when no such requirement is evidenced.

Detection sweep: first flag historical markers such as `legacy`, `formerly`,
`previously`, `backward-compatible`, `no longer`, `replaced`, and `deprecated`.
Then inspect contrast and negative forms semantically: ask whether the sentence
defines an intrinsic current constraint or makes a discarded alternative part of
the instructions. Report the latter even when it contains no historical keyword.

## B7. Reusable instruction patterns

When a task calls for one of these structures, read `references/instruction-patterns.md` for the concrete template:

- **Gotchas** — environment facts that defy assumptions (keep in `SKILL.md`)
- **Output templates** — give a concrete format to pattern-match against, rather than describing it in prose
- **Checklists** — track progress across multi-step workflows with dependencies/gates
- **Validation loops** — do → validate → fix → repeat until pass
- **Plan-validate-execute** — for batch/destructive ops: build a plan, validate against a source of truth, then execute
- **Bundled scripts** — if traces show the agent reinventing the same logic each run, write a tested script once and bundle it in `scripts/`

---

## Conformance checklist

Run this against the skill (or dispatch `skill-quality-review`):

- [ ] **Adds value**: content is what the agent *wouldn't* know on its own (no "write clean code", no explaining what a PDF is)
- [ ] **Concrete + rationale**: every non-obvious rule has a specific criterion and a "because [real problem]"
- [ ] **Gotchas present** (if the domain has them) and kept in `SKILL.md`
- [ ] **Judgeable outcome**: the desired deliverable and relevant evidence are concrete enough for reasoned review; qualitative work has not been forced into an artificial binary proxy
- [ ] **Description matches its role**: a trigger is intent-based and positive; documentation carries no trigger phrasings; neither names a sibling skill
- [ ] **Calibrated**: prescriptive where fragile, free where flexible; defaults not menus; procedures not one-off answers
- [ ] **Present-tense contract**: desired behavior is stated directly; history and discarded alternatives are absent; any compatibility content names the external contract that requires it
- [ ] **Context-economical**: lean `SKILL.md`; heavy material in `references/` with explicit load triggers
- [ ] **Refined**: run against ≥1 real task and revised from the trace (the empirical loop is `skill-quality-optimize`)
