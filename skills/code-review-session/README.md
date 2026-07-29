# code-review-session

A portable, agent-agnostic **record** for one code review. A review is a shared list
of items (`review.md`); operations either **add** items to it or **drive** items to
resolution, and they run in any order — you move back and forth between adding and
resolving.

The record is the single source of truth for review state, so a review survives
`/clear`, a crash, or a new session. It knows nothing about specs, plans, or any
task-management system: run it standalone on a diff, or let a workflow drive it by
injecting where the record lives.

**The session performs no review of its own.** How a review is actually conducted
belongs to the [`artifact-review-toolkit`](../artifact-review-toolkit/README.md)
family; `code-review-session-import-ai` calls into it and records what comes back.

## Skills

| Skill | Kind | Description |
|-------|------|-------------|
| `code-review-session-import-ai` | ingest | Record an AI code review's findings as items (the review itself is delegated to `artifact-review-toolkit`) |
| `code-review-session-import-pr` | ingest | Import GitHub PR review comments as items (PR data kept in `sources/pr.json`) |
| `code-review-session-import-ci` | ingest | Import failing CI checks as items (CI data kept in `sources/ci.json`) |
| `code-review-session-run-checks` | ingest | Run the project's checks locally and record failures as items (`sources/check.json`) |
| `code-review-session-resolve` | resolve | Work open items to `resolved` / `skipped` / `postponed` — AI proposes, the user approves or discusses |
| `code-review-session-reply-pr` | output | Draft and post replies to PR-sourced items |
| `code-review-session-report` | output | Produce a completion summary (resolved / postponed / skipped) for downstream |
| `code-review-session-base` | — | Shared record model, item state, source-ledger convention, init guide |

Direct feedback typed in the session is a fifth source; it needs no ingestion skill —
`code-review-session-resolve` records it as an item and resolves it.

`run-checks` and `import-ci` are separate because they belong to different phases:
local checks run against uncommitted work before a commit or push, CI results belong
to a commit already pushed.

## The model

- **Items** carry only generic state: a `Source` ref (`ai` / `pr:comment/{id}` /
  `ci:job/{id}` / `check:{command}` / `direct`), a `Status` (`open` → `resolved` /
  `skipped` / `postponed`), a detail, and optional `Approach` / `Resolution`.
  Statuses are minimal — the propose→approve→apply steps happen live, only the
  outcome is persisted.
- **`postponed`** = a follow-up: acknowledged but needing a larger/design-level change
  beyond this review's scope. `code-review-session-report` surfaces these for downstream.
- **Source-specific data** (comment ids, authors, CI runs, check commands, replied
  flags) lives in per-source ledgers at `{review_dir}/sources/{source}.json`, never
  mixed into items.

## Where the record lives (`review_dir`)

- **Standalone** (default): `.agents/code-review-session/{yyyy-mm-dd}-{branch}/review.md`
  (agent-agnostic, transient).
- **Workflow-driven**: the caller injects `review_dir`, pointing at its own working
  directory for that unit of work.

## Typical flow (standalone)

```
code-review-session-import-ai      # seed items from an AI review of the diff
  ↕ (import-pr / import-ci / run-checks to add items at any point)
code-review-session-resolve        # propose → approve/discuss → resolved/skipped/postponed
  ↓ LGTM
code-review-session-report         # completion summary; postponed items are follow-ups
  (+ code-review-session-reply-pr to reply on the PR)
```

## Extensibility

- **New source**: add an ingestion skill plus a `sources/{source}.json` ledger;
  `code-review-session-resolve` is unchanged.
- **Different reviewer**: `code-review-session-import-ai` calls a reviewer from
  `artifact-review-toolkit`, or one the caller names — it hard-codes none.

## Dependencies

- `code-review-session-resolve` uses `discuss-toolkit-dig` to clarify ambiguous
  feedback before proposing an approach. Install `discuss-toolkit` alongside this group.
- `code-review-session-import-ai` delegates the review itself to
  `artifact-review-toolkit`.
