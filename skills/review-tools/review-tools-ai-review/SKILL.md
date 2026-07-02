---
name: review-tools-ai-review
description: Ingestion source — run an AI code review over the change (delegating to whatever code-review skill is available) plus optional formal checks (tests, lint, static analysis), and record each finding as an item in review.md. Does not fix or gate; it only adds items for review-tools-resolve to work through. Triggers on "AI review", "code review the changes", "AIレビュー", "自動レビューをかけて".
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, Task
user-invocable: true
---

# AI Review (ingestion)

Add review items from an **AI automated review** of the current change. This is one
of the ways items enter the record (alongside `review-tools-import-pr`,
`review-tools-import-ci`, and direct feedback). It **ingests** findings — it does not
resolve or fix them; that is `review-tools-resolve`'s job.

**Trigger phrases**: "AI review", "code review the changes", "AIレビュー", "自動レビューをかけて"

## What it runs

Two kinds of automated review, both optional and pluggable:

1. **AI code review** — delegate to an available code-review skill rather than
   re-implementing one. Pick the first that applies:
   - `/code-review` (the harness code-review command), if available;
   - the `feature-dev:code-reviewer` agent (via Task), if available;
   - `codex:review` (Codex), if available;
   - otherwise, an inline review of the diff.
   The caller may name a specific reviewer to use; honor it. This choice is meant to
   be swappable — new reviewers can be plugged in without changing this skill's shape.
2. **Formal checks** — any test / lint / static-analysis / predicate commands the
   caller provides (or the obvious project ones). Run them; a failure becomes an item.

## Input

- `review_dir` — where the record lives (default: standalone; see `review-tools-base`
  skill (`references/review-init-guide.md`)).
- `scope` — the change to review (default: current branch diff).
- `reviewer` — optional; which code-review skill/agent to delegate to.
- `checks` — optional; test/lint/etc. commands to run.

## Process

### 1. Resolve the record

Resolve `review_dir` and ensure `review.md` exists (create via `review-tools-base`
skill (`references/review-init-guide.md`) if not).

### 2. Run the AI code review

Delegate to the selected reviewer over `scope`. Ask it to report discrete findings
with, for each: a one-line summary, the location, the detail, and (if it offers one)
a severity. Severity is optional metadata — this skill does not gate on it.

### 3. Run formal checks (if any)

For each provided `checks` command: run it (Bash). A non-zero exit (failing test,
lint error) is a finding — capture the command and a short output summary.

### 4. Record findings as items

For each finding (from the reviewer or a failing check), append an item to `review.md`
under `## Items` (see `review-tools-base` skill (`references/review-state.md`)):

- **Source**: `ai`
- **Status**: `open`
- **Detail**: the finding text (include location and, for a failing check, the command
  + output summary)
- **Summary**: the one-line heading

Determine the next item number from the highest existing item. **Dedupe**: skip a
finding that matches an existing item (same location + gist) so re-running ai-review
does not double-add.

Update the `Resolved: X / Y` denominator to the new total.

### 5. Report

```markdown
{count} items added from AI review ({reviewer used}{, +N failing checks}).

Open items: {open count}. Run `review-tools-resolve` to work through them.
```

`ai-review` does not fix anything or change the review Phase. It leaves the items
`open` for `review-tools-resolve`.

## Success Criteria

- [ ] Delegates to an available code-review skill/agent (no re-implemented reviewer)
- [ ] Runs any provided formal-check commands; failures become items
- [ ] Each finding recorded as an `open` item with `Source: ai`
- [ ] Duplicates against existing items are skipped
- [ ] Does not fix, gate, or change the review Phase
