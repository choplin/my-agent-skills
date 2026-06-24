# Instruction Patterns

Reusable structures for skill content. Not every skill needs all of them — use the ones that fit the task. (Source: [agentskills.io best practices](https://agentskills.io/skill-creation/best-practices).)

## Gotchas

Environment-specific facts that defy reasonable assumptions. These are concrete corrections to mistakes the agent *will* make otherwise — not general advice. Keep them in `SKILL.md` (not a reference file): the agent must read them before hitting the situation, and may not recognize the trigger to load a separate file.

```markdown
## Gotchas

- The `users` table uses soft deletes. Queries must include
  `WHERE deleted_at IS NULL` or results include deactivated accounts.
- The user ID is `user_id` in the database, `uid` in the auth service,
  and `accountId` in the billing API — all the same value.
- `/health` returns 200 whenever the web server is up, even if the DB is
  down. Use `/ready` to check full service health.
```

> When you correct an agent mid-task, add the correction here. It's the most direct way to improve a skill iteratively.

## Output templates

Agents pattern-match against concrete structures better than prose descriptions. Short templates inline in `SKILL.md`; longer or conditional ones in `assets/`, referenced so they load only when needed.

````markdown
## Report structure

Use this template, adapting sections as needed:

```markdown
# [Analysis Title]

## Executive summary
[One-paragraph overview of key findings]

## Key findings
- Finding 1 with supporting data

## Recommendations
1. Specific actionable recommendation
```
````

## Checklists for multi-step workflows

An explicit checklist helps the agent track progress and avoid skipping steps — especially with dependencies or validation gates.

```markdown
## Form processing workflow

Progress:
- [ ] Step 1: Analyze the form (`scripts/analyze_form.py`)
- [ ] Step 2: Create field mapping (edit `fields.json`)
- [ ] Step 3: Validate mapping (`scripts/validate_fields.py`)
- [ ] Step 4: Fill the form (`scripts/fill_form.py`)
- [ ] Step 5: Verify output (`scripts/verify_output.py`)
```

## Validation loops

Have the agent validate its own work before moving on: do the work → run a validator (script, reference checklist, or self-check) → fix → repeat until it passes.

```markdown
## Editing workflow

1. Make your edits
2. Run validation: `python scripts/validate.py output/`
3. If validation fails: review the error, fix, re-run
4. Only proceed when validation passes
```

A reference document can serve as the validator — instruct the agent to check its work against it before finalizing.

## Plan-validate-execute

For batch or destructive operations, have the agent build an intermediate plan in a structured format, validate it against a source of truth, and only then execute.

```markdown
## PDF form filling

1. Extract fields: `python scripts/analyze_form.py input.pdf` → `form_fields.json`
2. Create `field_values.json` mapping each field name to its value
3. Validate: `python scripts/validate_fields.py form_fields.json field_values.json`
4. If validation fails, revise `field_values.json` and re-validate
5. Fill: `python scripts/fill_form.py input.pdf field_values.json output.pdf`
```

The key ingredient is step 3: a validator that checks the plan against the source of truth and emits actionable errors ("Field 'signature_date' not found — available: customer_name, order_total, signature_date_signed") so the agent can self-correct.

## Bundled scripts

When iterating, compare execution traces across runs. If the agent keeps reinventing the same logic (building charts, parsing a format, validating output), write a tested script once and bundle it in `scripts/`. This removes a recurring source of variance and error.
