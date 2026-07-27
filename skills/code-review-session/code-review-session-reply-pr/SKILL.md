---
name: code-review-session-reply-pr
description: Output — draft and optionally post replies to the PR review comments that were imported via code-review-session-import-pr, using the resolution recorded on each item and the PR data in sources/pr.json. Triggers on "reply to PR comments", "PRコメントに返信", "返信案を作って".
allowed-tools: Read, Edit, Glob, Grep, Bash(gh *), Bash(git log *), Bash(git remote *), Bash(git branch *), mcp__github__add_reply_to_pull_request_comment, mcp__github__add_issue_comment
user-invocable: true
---

# Reply to PR Comments (output)

Post replies on the PR for items sourced from it. Uses each item's recorded
`Resolution` (from `code-review-session-resolve`) and the PR data in `sources/pr.json`.

**Trigger phrases**: "reply to PR comments", "PRコメントに返信", "返信案を作って", "draft PR replies"

## Input

- `review_dir` — where the record lives (default: standalone; see `code-review-session-base`).
- `review.md` with `pr:comment/*` items, and `{review_dir}/sources/pr.json`.

## Process

### 1. Load record + PR data

1. Find `review.md` at `{review_dir}/review.md` (standalone: search
   `.agents/code-review-session/*/review.md`). If not found, stop.
2. Read `{review_dir}/sources/pr.json` for comment ids, authors, types, and the
   `replied` flags. Derive owner/repo via `gh repo view --json nameWithOwner`.

### 2. Collect unreplied items

1. Take items whose `Source` is `pr:comment/{id}` and whose ledger record has
   `replied: false`.
2. **Default scope: inline only** — unless the user asks to include review-body
   comments ("review-bodyも含めて", "全コメントに返信", "reply to all"), skip `review-body`.
3. If none remain: report "All PR comments have been replied to." and stop.

### 3. Resolve commit references

For items resolved with a code change: `git log --oneline` on the branch; match the
item's file(s) to the commit that addressed it; keep the short SHA (7 chars).

### 4. Draft replies

Per item, from its `Status`/`Resolution`:

- **resolved with a change**: `{one-sentence description}. Fixed in {sha}.`
- **resolved without a change**: `{one-sentence explanation}.`
- **skipped / postponed**: `{reason it was declined or deferred}.`

### 5. Present drafts

```markdown
## PR Comment Reply Drafts

**PR**: #{number}
**Scope**: inline only (include review-body with "全コメントに返信")
**Unreplied items**: {count}

| # | Item | Reply |
|---|------|-------|
| {N} | {summary} | {draft} |

Edit any drafts, then say "post" to submit.
```

Wait for input.

### 6. Post (on explicit request only)

**Only when the user says "post" / "投稿して" / "submit".** Per item, using the id from
`sources/pr.json`:

- **inline**: `mcp__github__add_reply_to_pull_request_comment` (`owner`, `repo`,
  `pullNumber`, `commentId`, `body`).
- **review-body**: `mcp__github__add_issue_comment` (`owner`, `repo`, `issue_number` =
  PR number, `body` = `@{author} {reply}`).

After each successful post, set that comment's `replied: true` in `sources/pr.json`.
Report `{count} replies posted to PR #{number}.`

## Reply Style Guide

- Concise: one line ideal, two max. No pleasantries. State facts.
- Commit SHAs: 7 chars, not backtick-wrapped (GitHub auto-links).
- Match the original comment's language. Identifiers/paths in `` ` `` backticks.

## Success Criteria

- [ ] Only unreplied PR items (per `sources/pr.json`); inline by default
- [ ] Drafts presented; posting only on explicit request
- [ ] `replied: true` recorded in `sources/pr.json` after posting
