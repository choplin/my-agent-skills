---
name: code-review-session-run-checks
description: Ingestion source — run the project's own checks (tests, lint, type check, static analysis, any predicate command) locally and record each failure as an open item in a code-review-session record (review.md), keeping the command, exit code, and output excerpt in a separate sources/check.json ledger. Use before committing or pushing, when the failures should become tracked review items rather than be fixed on the spot. For failures that already ran on the remote, use code-review-session-import-ci.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
user-invocable: true
---

# Run local checks (ingestion)

Add review items from **checks run locally on the working tree**. The generic item
goes into `review.md`; the command, exit code, and output excerpt go into a
separate `sources/check.json` ledger.

This is the **pre-commit / pre-push** counterpart of
`code-review-session-import-ci`. The two are separate on purpose: local checks run
against uncommitted work and the result is reproducible on demand, while CI results
belong to a pushed commit and are fetched, not produced. Running the checks is part
of this skill's job; importing CI results is not.

## Input

- `review_dir` — where the record lives (default: standalone; see
  `code-review-session-base` skill (`references/review-init-guide.md`)).
- `checks` — the commands to run. When the caller provides none, use the project's
  obvious ones (its Makefile targets, package scripts, or the commands named in
  `CLAUDE.md` / `AGENTS.md` / the README). State which commands were chosen.

## Process

### 1. Resolve the record

Resolve `review_dir` and ensure `review.md` exists (create via
`code-review-session-base` skill (`references/review-init-guide.md`) if not).

### 2. Run each check

Run each command (Bash) from the repository root. Record its exit code and keep a
short output excerpt — the failing assertion, the first error, or the summary line
— not the whole log. A non-zero exit is a finding. A command that cannot run at all
(missing tool, missing target) is also a finding: report it as such rather than
silently skipping it.

### 3. Exclude already-recorded

Read `{review_dir}/sources/check.json` (create `{ "checks": {} }` if absent). Skip a
failure already recorded as an `open` item for the same command. A command that now
passes does **not** resolve its existing item — resolution is
`code-review-session-resolve`'s decision, made against the fixed code.

### 4. Write items + ledger

For each failing check:

1. **Item in `review.md`** (see `code-review-session-base` skill
   (`references/review-state.md`)):
   - **Source**: `check:{command}`
   - **Status**: `open`
   - **Detail**: the command, its exit code, and the output excerpt
   - **Summary**: e.g. "Check failing: {command}"
2. **Record in `sources/check.json`**, keyed by the command:
   ```json
   { "checks": { "{command}": {
       "exit": 1, "excerpt": "{short output}", "ran_at": "{iso8601}" } } }
   ```

Update the `Resolved: X / Y` denominator to the new total.

### 5. Report

```markdown
{failed} of {total} checks failing; {count} items added.

Open items: {open count}. Run `code-review-session-resolve` to work through them.
```

This skill does not fix a failing check and does not gate the commit. It records
the failure as an item.

## Success Criteria

- [ ] Every provided (or chosen) check command was run and its outcome reported
- [ ] Each failure recorded as an `open` item with `Source: check:{command}`
- [ ] Command, exit code, and output excerpt kept in `sources/check.json`, not in
      the item
- [ ] A check that cannot run is reported as a finding, not skipped silently
- [ ] Does not fix failures or change the review Phase
