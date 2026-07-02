---
name: review-tools-base
description: Shared resources for the review-tools skill family — the review record model (review.md holding generic review items), the item state model, the per-source companion-ledger convention, and the review.md initialization guide. Other review-tools skills delegate to this skill to read a template or resolve where the record lives. Use this skill when another review-tools skill asks to apply the item model, the source convention, or initialize review.md. Not typically invoked on its own.
---

# review-tools base resources

This skill owns the resources shared across the **review-tools** skill family.
review-tools is a general review process built around one idea:

> **A review is a shared record of items. Operations add items to it or drive
> items to resolution. The operations run in any order — you move back and forth
> between adding and resolving.**

The record is `review.md`. Each operation is a separate skill, so at any moment
"what am I doing now" is clear from which skill is running, and "what is left" is
clear from the `open` items in the record.

| Operation | Skill | Kind |
|-----------|-------|------|
| Add items from an AI code review (+ tests/lint) | `review-tools-ai-review` | ingest |
| Add items from GitHub PR review comments | `review-tools-import-pr` | ingest |
| Add items from CI results | `review-tools-import-ci` | ingest |
| Drive open items to resolution | `review-tools-resolve` | resolve |
| Reply to PR-sourced items on the PR | `review-tools-reply-pr` | output |
| Produce a completion summary for downstream | `review-tools-report` | output |

Direct feedback typed in the session is a fourth source; it needs no ingestion
skill — `review-tools-resolve` records it as an item and resolves it.

Delegation form (resolve the path **relative to this skill's installed
directory**): `` `review-tools-base` skill (`references/<file>`) ``.

## References

| Resource | File | Used for |
|----------|------|----------|
| Review template | `references/review-template.md` | Creating `review.md` |
| Review-state model | `references/review-state.md` | Item fields/statuses, review phase, source convention |
| Review init guide | `references/review-init-guide.md` | Resolving `review_dir` and creating `review.md` |

## Where the record lives (`review_dir`)

Every review-tools operation acts on one `review.md` (and any source ledgers)
inside `review_dir`, resolved in this order:

1. **Caller-injected** — a driving workflow passes an explicit `review_dir` (e.g.
   `dev-workflow` passes `.claude/dev-workflow/story/{story-dir}/`). Use it verbatim.
2. **Standalone default** — `.agents/review-tools/{name}/`, where `{name}` =
   `{yyyy-mm-dd}-{branch-with-dashes}` (current git branch, `/` → `-`, date-prefixed).

`.agents/` is agent-agnostic (not `.claude/`). The standalone directory is transient
working state; add it to `.gitignore` unless you want the review record committed.

## Generic items vs. source-specific data

`review.md` holds **generic review items only** — the state that every review shares
(status, a one-line summary, the finding/feedback, an optional approach and
resolution). It is the single source of truth for review state.

**Source-specific data is kept separate**, in a per-source companion ledger under
`{review_dir}/sources/{source}.json` (e.g. `sources/pr.json`, `sources/ci.json`).
A PR comment carries its own comment id, author, inline location, thread, and
replied-flag; a CI result carries its run/job/log — none of that belongs in the
generic item. Each item references its source via a `Source` ref (e.g.
`pr:comment/123`); the ledger, keyed by that ref, holds the source's own data.

This keeps the item model small and lets each source bring arbitrary bookkeeping
without polluting review state. See `references/review-state.md`.

## Extensibility

- **New source**: add an ingestion skill plus a `sources/{source}.json` ledger.
  `review-tools-resolve` is unchanged — it resolves items regardless of source.
- **Different reviewer**: `review-tools-ai-review` calls whatever AI code-review
  skill is available/selected; it does not hard-code one.
