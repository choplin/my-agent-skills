---
name: code-review-session-import-pr
description: Ingestion source — import GitHub PR review comments as items in review.md, keeping PR-specific data (comment id, author, inline location, thread, replied flag) in a separate sources/pr.json ledger. Triggers on "import PR comments", "PRコメントを取り込んで", "PRレビューをインポート".
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh *), Bash(git branch *), Bash(git remote *)
user-invocable: true
---

# Import PR Comments (ingestion)

Add review items from a GitHub Pull Request's review comments. The generic item goes
into `review.md`; the PR-specific data goes into a separate `sources/pr.json` ledger,
so PR bookkeeping never mixes into review state.

**Trigger phrases**: "import PR comments", "PRコメントを取り込んで", "PRレビューをインポート"

## Input

- `review_dir` — where the record lives (default: standalone; see `code-review-session-base`
  skill (`references/review-init-guide.md`)).
- An open PR on the current branch.

## Process

### 1. Resolve the record and PR

1. Resolve `review_dir`; ensure `review.md` exists (create via `code-review-session-base`
   skill (`references/review-init-guide.md`) if not).
2. **Find the open PR**: `gh pr view --json number,url,state` for the current branch.
   If none or not OPEN/DRAFT: stop and report "No open PR found for the current branch."
3. **Derive owner/repo**: `gh repo view --json nameWithOwner --jq '.nameWithOwner'`.

### 2. Fetch comments

1. **Review bodies**: `gh pr view --json reviews --jq '.reviews[] | {id, author: .author.login, body, state}'` — drop empty bodies and DISMISSED reviews.
2. **Inline comments**: `gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {id, author: .user.login, body, path, line: (.original_line // .line), diff_hunk}'`.

### 3. Exclude already-imported

Read `{review_dir}/sources/pr.json` (create `{ "comments": {} }` if absent). Skip any
comment whose id is already recorded there with `imported: true`. If none remain:
report "No new PR comments to import." and stop.

### 4. Preview and confirm

```markdown
## PR Comment Import Preview

**PR**: #{number} ({url})
**New comments**: {count}

| # | Author | Type | Summary |
|---|--------|------|---------|
| 1 | @author | inline | {brief summary} |
| 2 | @author | review-body | {brief summary} |

Proceed with import?
```

Wait for confirmation.

### 5. Write items + ledger

For each new comment:

1. **Item in `review.md`** (see `code-review-session-base` skill (`references/review-state.md`)):
   - **Source**: `pr:comment/{commentId}`
   - **Status**: `open`
   - **Detail**: the comment body (and, for inline, `{path} L{line}`)
   - **Summary**: a one-line gist
2. **Record in `sources/pr.json`**, keyed by comment id:
   ```json
   { "comments": { "{commentId}": {
       "author": "{login}", "type": "inline|review-body",
       "path": "{path}", "line": {line}, "url": "{url}",
       "imported": true, "replied": false } } }
   ```

Update the `Resolved: X / Y` denominator to the new total.

### 6. Report

```markdown
{count} items imported from PR #{number}.

Run `code-review-session-resolve` to work through them, then `code-review-session-reply-pr` to reply.
```

## Notes

- Classification/approach is decided in `code-review-session-resolve`, not here — this skill
  only records the raw comment as an `open` item. (An inline comment with a clear ask
  resolves quickly there; a vague review-body gets discussed.)
- `sources/pr.json` is the single home for PR-specific state (author, location,
  replied). `review.md` stays generic.

## Success Criteria

- [ ] Only new comments imported (deduped via `sources/pr.json`)
- [ ] Preview shown and confirmed before writing
- [ ] Each comment → an `open` item (`Source: pr:comment/{id}`) + a `sources/pr.json` record
- [ ] PR-specific data kept out of `review.md`
