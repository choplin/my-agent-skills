# Review-state model

All review state lives in `review.md`. Source-specific data lives in per-source
companion ledgers. This file defines both.

## Review item (in review.md)

Each item under `## Items` has these fields:

| Field | Required | Meaning |
|-------|----------|---------|
| summary | ✓ | One-line description (the `### Item {N}:` heading) |
| `Source` | ✓ | Where the item came from — a ref, not the data itself: `ai`, `pr:comment/{id}`, `ci:job/{id}`, `check:{command}`, or `direct` |
| `Status` | ✓ | `open`, `resolved`, `skipped`, or `postponed` |
| `Detail` | ✓ | The finding or feedback text |
| `Approach` | | The proposed response, recorded during resolve (free text) |
| `Resolution` | | What was done, or why it was deferred, when the item leaves `open` |

### Item status

Deliberately minimal — no intermediate "proposed/agreed/implementing" states. The
propose → approve → apply interaction happens live within a `code-review-session-resolve`
turn; only the outcome is persisted. The `Approach` field carries any proposed
response across sessions, so an `open` item with an `Approach` is a resumable
"discussed but not yet applied" item.

| Status | Meaning | Terminal |
|--------|---------|----------|
| `open` | Not yet resolved | no |
| `resolved` | Addressed (with a change or an explanation) | yes |
| `skipped` | Intentionally declined | yes |
| `postponed` | Acknowledged but deferred — needs a larger/design-level change beyond this review's scope | yes |

`postponed` items are the review's **follow-ups**: not done here, surfaced by
`code-review-session-report` for a driving workflow or the user to act on.

## Review-level phase (in review.md `## Status`)

- **Phase**: `open` (review active) or `done` (concluded — no `open` items remain, or
  the user has signed off). "LGTM" / "以上" are user *signals* to conclude; the stored
  value is `open`/`done`.

The `Resolved: X / Y` line is informational; the authoritative count is derived from
item statuses: `resolved` + `skipped` + `postponed` over the total.

## Source companion ledgers

Source-specific data is **not** in `review.md`. Each external source keeps its own
ledger at `{review_dir}/sources/{source}.json`, keyed so an item's `Source` ref
resolves into it. Examples:

- `sources/pr.json` — per PR comment: comment id, author, inline path/line, thread,
  `imported` and `replied` flags.
- `sources/ci.json` — per CI result: run id, job/check name, conclusion, log ref.
- `sources/check.json` — per locally-run check: command, exit code, output excerpt.

An ingestion skill writes both: the generic item in `review.md` and the source record
in its ledger. `code-review-session-resolve` reads only `review.md`; source skills
(`code-review-session-reply-pr`, etc.) read their own ledger.

## Legacy value normalization

When reading an older record, normalize before acting:

| Legacy Phase | Normalized |
|--------------|-----------|
| `REVIEWING`, `COLLECTING FEEDBACK`, `READY FOR IMPLEMENTATION`, `IMPLEMENTING` | `open` |
| `LGTM` | `done` |

| Legacy item status | Normalized |
|--------------------|-----------|
| `OPEN`, `APPROACH PROPOSED`, `APPROACH RECORDED`, `APPROACH AGREED`, `IMPLEMENTING` | `open` |
| `RESOLVED` | `resolved` |
| `SKIPPED` | `skipped` |
| `Design Change` (classification of an unresolved item) | item → `postponed` |
