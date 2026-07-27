# Review record initialization guide

Shared procedure for creating `review.md` when it does not yet exist. The first
ingestion op (or `code-review-session-resolve` invoked directly) creates it; later ops
append to it.

## 1. Resolve `review_dir`

1. **Caller-injected** — if a driving workflow passed an explicit `review_dir`, use
   it verbatim (e.g. `dev-workflow` passes `.claude/dev-workflow/story/{story-dir}/`).
2. **Standalone default** — otherwise `.agents/code-review-session/{name}/`, where `{name}` =
   `{yyyy-mm-dd}-{branch-with-dashes}` (current git branch, `/` → `-`, date-prefixed).

## 2. Resolve metadata

| Field | Value |
|-------|-------|
| Title | The thing under review — a spec/plan `# {title}` if the caller supplied one, else the branch name |
| Under Review | Any diff/branch/spec/plan/PR reference the caller supplied; omit if none |

## 3. Create review.md

1. Check for an existing `review.md` at `{review_dir}/review.md` — if it exists,
   append to it rather than overwriting.
2. Read `code-review-session-base` skill (`references/review-template.md`).
3. Fill in Title and Under Review; leave `## Items` empty; set Phase `open`,
   Resolved `0 / 0`.
4. Create `{review_dir}` (and `{review_dir}/sources/` when a source ledger is needed)
   and write `{review_dir}/review.md`.

There is no separate machine-state file for review state — `review.md` is the source
of truth (see `code-review-session-base` skill (`references/review-state.md`)). Source ledgers
under `sources/` hold only source-specific bookkeeping, not review state.
