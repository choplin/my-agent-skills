---
name: code-review-session-import-ai
description: >-
  Runs an AI code review of a change and records each finding as an open item
  in a code-review session record. Normalizes findings into generic items; it
  does not fix anything and gates nothing.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, Task
metadata:
  description-role: documentation
---

# Import AI review findings (ingestion)

Add review items from an **AI code review**. This is one of the ways items enter
the record (alongside `code-review-session-import-pr`,
`code-review-session-import-ci`, `code-review-session-run-checks`, and direct
feedback). It **ingests** findings — it does not resolve or fix them; that is
`code-review-session-resolve`'s job.

Select this skill when the requested deliverable is a **persistent review record**.
A one-off "review this diff and tell me what's wrong" wants findings in the
conversation and no record: that is `quick-code-review` on its own.

## Who performs the review

This skill contains no review procedure. It calls one:

| Reviewer | Use when |
|----------|----------|
| `quick-code-review` (default) | One-pass functional, security, performance, and maintainability review of the change |
| `artifact-review` | The change needs independent multi-Lens coverage — broad blast radius, low reversibility, weak evidence, or cross-artifact risk |
| A reviewer named by the caller | The caller specifies one; honor it |

The caller may also pass findings it already has, in which case this skill only
records them.

## Input

- `review_dir` — where the record lives (default: standalone; see
  `code-review-session-base` skill (`references/review-init-guide.md`)).
- `scope` — the change to review (default: current branch diff).
- `reviewer` — optional; which reviewer to invoke (default
  `quick-code-review`).
- `findings` — optional; findings already produced, to record without reviewing.

## Process

### 1. Resolve the record

Resolve `review_dir` and ensure `review.md` exists (create via
`code-review-session-base` skill (`references/review-init-guide.md`) if not).

### 2. Obtain findings

Unless `findings` was supplied, invoke the selected reviewer over `scope`. Require
each finding to carry a one-line summary, the location, and the detail; a severity
if the reviewer offers one. Severity is optional metadata — this skill does not
gate on it.

### 3. Record findings as items

For each finding, append an item to `review.md` under `## Items` (see
`code-review-session-base` skill (`references/review-state.md`)):

- **Source**: `ai`
- **Status**: `open`
- **Detail**: the finding text, including its location
- **Summary**: the one-line heading

Determine the next item number from the highest existing item. **Dedupe**: skip a
finding that matches an existing item (same location + gist) so re-running the
ingestion does not double-add.

Update the `Resolved: X / Y` denominator to the new total.

### 4. Report

```markdown
{count} items added from AI review ({reviewer used}).

Open items: {open count}. Run `code-review-session-resolve` to work through them.
```

This skill does not fix anything or change the review Phase. It leaves the items
`open` for `code-review-session-resolve`.

## Success Criteria

- [ ] The review itself is delegated to a reviewer; no review procedure is
      re-implemented here
- [ ] Each finding recorded as an `open` item with `Source: ai`
- [ ] Duplicates against existing items are skipped
- [ ] Does not run project checks (that is `code-review-session-run-checks`)
- [ ] Does not fix, gate, or change the review Phase
