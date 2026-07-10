# Best practices for skill creators (upstream source)

> Reproduced from <https://agentskills.io/skill-creation/best-practices> (retrieved 2026-06-24).
> This is the source material the content-quality rubric (`content-quality-rubric.md`) distills. Read it for the full original treatment, including examples that the rubric abbreviates. Related upstream pages: `/skill-creation/evaluating-skills`, `/skill-creation/optimizing-descriptions`, `/skill-creation/using-scripts`, `/specification#progressive-disclosure`.

## Start from real expertise

A common pitfall is asking an LLM to generate a skill without providing domain-specific context — relying solely on general training knowledge. The result is vague, generic procedures ("handle errors appropriately," "follow best practices") rather than the specific API patterns, edge cases, and project conventions that make a skill valuable. Effective skills are grounded in real expertise; the key is feeding domain-specific context into the creation process.

### Extract from a hands-on task

Complete a real task in conversation with an agent, providing context, corrections, and preferences along the way. Then extract the reusable pattern. Pay attention to:

- **Steps that worked** — the sequence of actions that led to success
- **Corrections you made** — where you steered the agent (e.g., "use library X instead of Y," "check for edge case Z")
- **Input/output formats** — what the data looked like going in and coming out
- **Context you provided** — project-specific facts, conventions, or constraints the agent didn't already know

### Synthesize from existing project artifacts

When you have a body of existing knowledge, feed it into an LLM and ask it to synthesize a skill. A data-pipeline skill synthesized from your team's actual incident reports and runbooks outperforms one synthesized from a generic article, because it captures *your* schemas, failure modes, and recovery procedures. Good source material:

- Internal documentation, runbooks, and style guides
- API specifications, schemas, and configuration files
- Code review comments and issue trackers (recurring concerns, reviewer expectations)
- Version control history, especially patches and fixes (reveals patterns through what actually changed)
- Real-world failure cases and their resolutions

## Refine with real execution

The first draft usually needs refinement. Run the skill against real tasks, then feed the results — all of them, not just failures — back into the creation process. Ask: what triggered false positives? What was missed? What could be cut? Even a single execute-then-revise pass noticeably improves quality; complex domains benefit from several.

> **Tip:** Read agent execution traces, not just final outputs. If the agent wastes time on unproductive steps, common causes include instructions that are too vague (the agent tries several approaches before finding one that works), instructions that don't apply to the current task (the agent follows them anyway), or too many options presented without a clear default.

## Spending context wisely

Once a skill activates, its full `SKILL.md` body loads into the context window alongside conversation history, system context, and other active skills. Every token competes for attention.

### Add what the agent lacks, omit what it knows

Focus on what the agent *wouldn't* know: project-specific conventions, domain-specific procedures, non-obvious edge cases, the particular tools/APIs to use. You don't need to explain what a PDF is, how HTTP works, or what a database migration does.

```markdown
<!-- Too verbose — the agent already knows what PDFs are -->
PDF (Portable Document Format) files are a common file format... To extract
text you'll need a library. pdfplumber is recommended because it handles
most cases well.

<!-- Better — jumps straight to what the agent wouldn't know -->
Use pdfplumber for text extraction. For scanned documents, fall back to
pdf2image with pytesseract.
```

Ask of each piece of content: "Would the agent get this wrong without this instruction?" If no, cut it. If the agent already handles the entire task well without the skill, the skill may not be adding value.

### Design coherent units

Deciding what a skill covers is like deciding what a function does: encapsulate a coherent unit of work that composes well with others. Too narrow forces multiple skills to load for one task (overhead, conflicting instructions); too broad becomes hard to activate precisely. "Query a database and format the results" may be one coherent unit; adding "database administration" is too much.

### Aim for moderate detail

Overly comprehensive skills can hurt — the agent struggles to extract what's relevant and may pursue unproductive paths triggered by inapplicable instructions. Concise, stepwise guidance with a working example tends to outperform exhaustive documentation. When you're covering every edge case, consider whether the agent's own judgment handles most of them.

### Structure large skills with progressive disclosure

Keep `SKILL.md` under 500 lines and 5,000 tokens — just the core instructions needed every run. Move detailed reference material to `references/` or similar. Tell the agent *when* to load each file: "Read `references/api-errors.md` if the API returns a non-200 status code" is more useful than a generic "see references/ for details." This lets the agent load context on demand.

## Calibrating control

Match the specificity of instructions to the fragility of the task.

### Match specificity to fragility

**Give the agent freedom** when multiple approaches are valid and the task tolerates variation. For flexible instructions, explaining *why* is more effective than rigid directives. A code review skill can describe what to look for without prescribing exact steps.

**Be prescriptive** when operations are fragile, consistency matters, or a specific sequence must be followed:

````markdown
## Database migration
Run exactly this sequence:
```bash
python scripts/migrate.py --verify --backup
```
Do not modify the command or add additional flags.
````

Most skills mix both — calibrate each part independently.

### Provide defaults, not menus

Pick a default and mention alternatives briefly rather than presenting equal options.

```markdown
<!-- Too many options -->
You can use pypdf, pdfplumber, PyMuPDF, or pdf2image...

<!-- Clear default with escape hatch -->
Use pdfplumber for text extraction. For scanned PDFs requiring OCR, use
pdf2image with pytesseract instead.
```

### Favor procedures over declarations

Teach the agent *how to approach* a class of problems, not *what to produce* for a specific instance.

```markdown
<!-- Specific answer — only useful for this exact task -->
Join the `orders` table to `customers` on `customer_id`, filter where
`region = 'EMEA'`, and sum the `amount` column.

<!-- Reusable method — works for any analytical query -->
1. Read the schema from references/schema.yaml to find relevant tables
2. Join tables using the `_id` foreign key convention
3. Apply filters from the user's request as WHERE clauses
4. Aggregate numeric columns and format as a markdown table
```

Specific details (output templates, "never output PII", tool-specific instructions) are still valuable — the point is that the *approach* should generalize.

## Patterns for effective instructions

Reusable techniques; use the ones that fit. (Concrete templates for each are in `instruction-patterns.md`.)

- **Gotchas sections** — environment-specific facts that defy reasonable assumptions; concrete corrections, not general advice. Keep in `SKILL.md` so the agent reads them before encountering the situation.
- **Templates for output format** — provide a concrete template; agents pattern-match against structures better than prose.
- **Checklists for multi-step workflows** — help the agent track progress and avoid skipping steps with dependencies or gates.
- **Validation loops** — do the work, run a validator, fix, repeat until it passes.
- **Plan-validate-execute** — for batch/destructive ops, build a plan, validate against a source of truth, then execute. The key ingredient is a validator that emits actionable errors so the agent self-corrects.
- **Bundling reusable scripts** — if traces show the agent reinventing the same logic each run, write a tested script once and bundle it in `scripts/`.

## Next steps (upstream guides)

- **Evaluating skill output quality** (`/skill-creation/evaluating-skills`) — test cases, grading, systematic iteration.
- **Optimizing skill descriptions** (`/skill-creation/optimizing-descriptions`) — test and improve the `description` field so it triggers on the right prompts.
