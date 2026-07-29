---
name: code-review-session-base
description: >-
  The record model shared across a code-review session: review.md holding
  generic review items, the item state model, the per-source companion-ledger
  convention, and how a record is initialized. Applies whenever a code-review
  session is created, read, or added to, so every source and every step writes
  the same record.
user-invocable: false
metadata:
  description-role: trigger
---

# code-review-session base resources

This skill owns the resources shared across the **code-review-session** skill family.
A code-review session is built around one idea:

> **A review is a shared record of items. Operations add items to it or drive
> items to resolution. The operations run in any order — you move back and forth
> between adding and resolving.**

The record is `review.md`. Each operation is a separate skill, so at any moment
"what am I doing now" is clear from which skill is running, and "what is left" is
clear from the `open` items in the record.

| Operation | Skill | Kind |
|-----------|-------|------|
| Add items from an AI code review | `code-review-session-import-ai` | ingest |
| Add items from GitHub PR review comments | `code-review-session-import-pr` | ingest |
| Add items from CI results | `code-review-session-import-ci` | ingest |
| Add items from locally-run project checks | `code-review-session-run-checks` | ingest |
| Drive open items to resolution | `code-review-session-resolve` | resolve |
| Reply to PR-sourced items on the PR | `code-review-session-reply-pr` | output |
| Produce a completion summary for downstream | `code-review-session-report` | output |

Direct feedback typed in the session is a fifth source; it needs no ingestion
skill — `code-review-session-resolve` records it as an item and resolves it.

The session performs no review of its own. `code-review-session-import-ai`
delegates that to the **`artifact-review-toolkit`** family
(`artifact-review-toolkit-quick` or `artifact-review-toolkit-adversarial`).

Delegation form (resolve the path **relative to this skill's installed
directory**): `` `code-review-session-base` skill (`references/<file>`) ``.

## References

| Resource | File | Used for |
|----------|------|----------|
| Review template | `references/review-template.md` | Creating `review.md` |
| Review-state model | `references/review-state.md` | Item fields/statuses, review phase, source convention |
| Review init guide | `references/review-init-guide.md` | Resolving `review_dir` and creating `review.md` |

## Where the record lives (`review_dir`)

Every code-review-session operation acts on one `review.md` (and any source ledgers)
inside `review_dir`, resolved in this order:

1. **Caller-injected** — a driving workflow passes an explicit `review_dir` so the
   record lands beside that workflow's own artifacts. Use it verbatim.
2. **Standalone default** — `.agents/code-review-session/{name}/`, where `{name}` =
   `{yyyy-mm-dd}-{branch-with-dashes}` (current git branch, `/` → `-`, date-prefixed).

`.agents/` is agent-agnostic (not `.claude/`). The standalone directory is transient
working state.

## Generic items vs. source-specific data

`review.md` holds **generic review items only** — the state that every review shares
(status, a one-line summary, the finding/feedback, an optional approach and
resolution). It is the single source of truth for review state.

**Source-specific data is kept separate**, in a per-source companion ledger under
`{review_dir}/sources/{source}.json` (e.g. `sources/pr.json`, `sources/ci.json`,
`sources/check.json`). A PR comment carries its own comment id, author, inline
location, thread, and replied-flag; a CI result carries its run/job/log; a locally-run
check carries its command and exit code — none of that belongs in the
generic item. Each item references its source via a `Source` ref (e.g.
`pr:comment/123`); the ledger, keyed by that ref, holds the source's own data.

This keeps the item model small and lets each source bring arbitrary bookkeeping
without polluting review state. See `references/review-state.md`.

## Extensibility

- **New source**: add an ingestion skill plus a `sources/{source}.json` ledger.
  `code-review-session-resolve` is unchanged — it resolves items regardless of source.
- **Different reviewer**: `code-review-session-import-ai` calls a reviewer from
  `artifact-review-toolkit` (or one the caller names); it does not hard-code one and
  contains no review procedure of its own.
