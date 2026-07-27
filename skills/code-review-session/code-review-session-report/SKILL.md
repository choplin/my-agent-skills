---
name: code-review-session-report
description: Output — produce a completion summary of a review from review.md (what was resolved, skipped, and postponed) so it can be handed to a downstream consumer such as a driving workflow's post step, a written report, or an issue tracker. Triggers on "summarize the review", "review report", "レビュー結果をまとめて", "完了サマリ".
allowed-tools: Read, Glob, Grep, Bash
user-invocable: true
---

# Review Report (output)

Summarize a review for downstream use. Reads `review.md`, aggregates the item
outcomes, and emits a structured summary — with the **postponed** items called out as
follow-ups, since those are the work a driving workflow or the user still needs to act
on.

**Trigger phrases**: "summarize the review", "review report", "レビュー結果をまとめて", "完了サマリ"

## Input

- `review_dir` — where the record lives (default: standalone; see `code-review-session-base`).

## Process

1. Find `review.md` at `{review_dir}/review.md` (standalone: search
   `.agents/code-review-session/*/review.md`). Normalize legacy values (see `code-review-session-base`
   skill (`references/review-state.md`)).
2. Aggregate items by `Status` and by `Source`.
3. Emit the summary (below). If the caller is a driving workflow, this is the value it
   consumes to drive its own next step; if standalone, present it to the user.

## Output Format

```markdown
## Review Summary — {title}

**Phase**: {open | done}   **Items**: {total}  (resolved {r} / skipped {s} / postponed {p} / open {o})

### Resolved
| # | Source | Summary | Resolution |
|---|--------|---------|------------|
| {N} | {source} | {summary} | {resolution} |

### Postponed (follow-ups)
| # | Source | Summary | Needs |
|---|--------|---------|-------|
| {N} | {source} | {summary} | {what larger/design-level change it needs} |

### Skipped
| # | Source | Summary | Reason |
|---|--------|---------|--------|
| {N} | {source} | {summary} | {why declined} |

{If any open items remain: "⚠️ {o} items still open — review is not complete."}
```

## Notes

- **Postponed = follow-ups.** They are the primary signal a downstream consumer acts
  on: a driving workflow turns them into scope changes; standalone, the user decides.
- This skill is read-only over the record; it does not change item statuses. If items
  are still `open`, it says so rather than pretending the review is done.

## Success Criteria

- [ ] Summary lists resolved / postponed / skipped items with their context
- [ ] Postponed items surfaced as follow-ups for downstream
- [ ] Remaining `open` items flagged (review not complete)
