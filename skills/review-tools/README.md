# review-tools

A portable, agent-agnostic review process. A review is a **shared record of items**
(`review.md`); operations either **add** items to it or **drive** items to resolution,
and they run in any order — you move back and forth between adding and resolving.

The record is the single source of truth for review state, so a review survives
`/clear`, a crash, or a new session. review-tools knows nothing about specs, plans, or
any task-management system: run it standalone on a diff, or let a workflow (e.g.
`dev-workflow`) drive it by injecting where the record lives.

## Skills

| Skill | Kind | Description |
|-------|------|-------------|
| `review-tools-ai-review` | ingest | Run an AI code review (delegating to an available code-review skill) + optional tests/lint, and record findings as items |
| `review-tools-import-pr` | ingest | Import GitHub PR review comments as items (PR data kept in `sources/pr.json`) |
| `review-tools-import-ci` | ingest | Import failing CI checks as items (CI data kept in `sources/ci.json`) |
| `review-tools-resolve` | resolve | Work open items to `resolved` / `skipped` / `postponed` — AI proposes, the user approves or discusses |
| `review-tools-reply-pr` | output | Draft and post replies to PR-sourced items |
| `review-tools-report` | output | Produce a completion summary (resolved / postponed / skipped) for downstream |
| `review-tools-base` | — | Shared record model, item state, source-ledger convention, init guide |

Direct feedback typed in the session is a fourth source; it needs no ingestion skill —
`review-tools-resolve` records it as an item and resolves it.

## The model

- **Items** carry only generic state: a `Source` ref (`ai` / `pr:comment/{id}` /
  `ci:job/{id}` / `direct`), a `Status` (`open` → `resolved` / `skipped` / `postponed`),
  a detail, and optional `Approach` / `Resolution`. Statuses are minimal — the
  propose→approve→apply steps happen live, only the outcome is persisted.
- **`postponed`** = a follow-up: acknowledged but needing a larger/design-level change
  beyond this review's scope. `review-tools-report` surfaces these for downstream.
- **Source-specific data** (comment ids, authors, CI runs, replied flags) lives in
  per-source ledgers at `{review_dir}/sources/{source}.json`, never mixed into items.

## Where the record lives (`review_dir`)

- **Standalone** (default): `.agents/review-tools/{yyyy-mm-dd}-{branch}/review.md`
  (agent-agnostic, transient — `.gitignore` it unless you want it committed).
- **Workflow-driven**: the caller injects `review_dir` (e.g. `dev-workflow` passes the
  Story directory).

## When skills activate

- **ai-review**: "AI review", "code review the changes", "AIレビュー", "自動レビューをかけて"
- **import-pr**: "import PR comments", "PRコメントを取り込んで"
- **import-ci**: "import CI results", "CIの失敗を取り込んで"
- **resolve**: "resolve review items", "work through the review", "レビュー対応", "指摘を解決"
- **reply-pr**: "reply to PR comments", "PRコメントに返信"
- **report**: "summarize the review", "review report", "レビュー結果をまとめて"

## Typical flow (standalone)

```
review-tools-ai-review     # seed items from an AI review of the diff
  ↕ (import-pr / import-ci to add PR or CI items at any point)
review-tools-resolve       # propose → approve/discuss → resolved/skipped/postponed
  ↓ LGTM
review-tools-report        # completion summary; postponed items are follow-ups
  (+ review-tools-reply-pr to reply on the PR)
```

## Extensibility

- **New source**: add an ingestion skill plus a `sources/{source}.json` ledger;
  `review-tools-resolve` is unchanged.
- **Different reviewer**: `review-tools-ai-review` calls whatever AI code-review skill
  is available/selected — it does not hard-code one.

## Dependencies

`review-tools-resolve` uses `discuss-toolkit-dig` to clarify ambiguous feedback before
proposing an approach. Install `discuss-toolkit` alongside this group.
