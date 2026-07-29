---
name: code-review-session-import-ci
description: Ingestion source — import failing CI results (checks/jobs) as items in review.md, keeping CI-specific data (run id, job/check name, conclusion, log ref) in a separate sources/ci.json ledger. Triggers on "import CI results", "CIの失敗を取り込んで", "pull CI failures".
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh *), Bash(git branch *), Bash(git remote *)
metadata:
  description-role: documentation
---

# Import CI Results (ingestion)

Add review items from CI results on the current change — typically the failing checks.
The generic item goes into `review.md`; CI-specific data goes into a separate
`sources/ci.json` ledger.

**Trigger phrases**: "import CI results", "CIの失敗を取り込んで", "pull CI failures"

## Input

- `review_dir` — where the record lives (default: standalone; see `code-review-session-base`
  skill (`references/review-init-guide.md`)).
- CI checks for the current branch / PR (default source: GitHub checks via `gh`).

## Process

### 1. Resolve the record and CI run

1. Resolve `review_dir`; ensure `review.md` exists (create if not).
2. **Fetch checks** for the current branch's head commit or PR:
   - `gh pr checks --json name,state,link,bucket` (or
     `gh api repos/{owner}/{repo}/commits/{sha}/check-runs`).
   - Derive owner/repo via `gh repo view --json nameWithOwner --jq '.nameWithOwner'`.
3. Keep the **failing / action-required** checks (skip passing and skipped ones,
   unless the caller asks to import all).

### 2. Exclude already-imported

Read `{review_dir}/sources/ci.json` (create `{ "checks": {} }` if absent). Skip any
check already recorded with `imported: true` for the same run. If none remain: report
"No new CI failures to import." and stop.

### 3. Preview and confirm

```markdown
## CI Import Preview

**Commit/PR**: {sha or #number}
**Failing checks**: {count}

| # | Check | Conclusion | Link |
|---|-------|-----------|------|
| 1 | {name} | failure | {link} |

Proceed with import?
```

Wait for confirmation.

### 4. Write items + ledger

For each failing check:

1. **Item in `review.md`**:
   - **Source**: `ci:job/{checkId or name}`
   - **Status**: `open`
   - **Detail**: check name + conclusion + a short excerpt/link to the failing log
   - **Summary**: e.g. "CI failing: {check name}"
2. **Record in `sources/ci.json`**, keyed by check id/name:
   ```json
   { "checks": { "{checkId}": {
       "name": "{name}", "conclusion": "failure",
       "run": "{runId}", "link": "{link}", "imported": true } } }
   ```

Update the `Resolved: X / Y` denominator to the new total.

### 5. Report

```markdown
{count} items imported from CI ({sha or #number}).

Run `code-review-session-resolve` to work through them.
```

## Success Criteria

- [ ] Failing checks imported (deduped via `sources/ci.json`)
- [ ] Preview shown and confirmed before writing
- [ ] Each check → an `open` item (`Source: ci:job/{id}`) + a `sources/ci.json` record
- [ ] CI-specific data kept out of `review.md`
