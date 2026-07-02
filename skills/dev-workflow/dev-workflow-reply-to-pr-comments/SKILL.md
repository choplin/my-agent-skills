---
name: dev-workflow-reply-to-pr-comments
description: Draft and optionally post replies to PR review comments that were imported via import-pr-comments. Generates concise reply text with commit references for addressed items and explanations for declined items.
allowed-tools: Read, Edit, Glob, Grep, Bash(gh *), Bash(git log *), Bash(git remote *), Bash(git branch *), mcp__github__add_reply_to_pull_request_comment, mcp__github__add_issue_comment
user-invocable: true
---

# Reply to PR Comments

Generate reply drafts for PR review comments imported via `dev-workflow-import-pr-comments`, and optionally post them.

**Trigger phrases**: "reply to PR comments", "PRコメントに返信", "返信案を作って", "draft PR replies"

## Purpose

After addressing review items imported from a PR, the developer needs to reply to each comment on the PR. This skill automates drafting those replies with consistent, concise formatting and accurate commit references.

## Input

- `review.md` containing items with a `Source` field (PR-imported items)
- Git log for commit references

## Process

### 1. Locate review.md and PR

1. **Find review.md** at `.claude/dev-workflow/story/*/review.md`

   - If not found: stop and report "review.md not found."
   - Once found, **bind this session** to the review.md's work-unit directory so dev-workflow hooks track only this work (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

     ```bash
     python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set "<work-unit-dir>"
     ```

2. **Extract PR info**: Parse PR number from Source fields (e.g., `PR #42 comment:123`).

3. **Derive owner/repo**: Run `gh repo view --json nameWithOwner --jq '.nameWithOwner'`.

### 2. Collect Unreplied Items

1. Read all Review Items that have a `Source` field containing `PR #`.
2. **Default scope: inline only** — Unless the user explicitly requests to include review-body comments, filter to items whose Source contains `(inline)`. Skip items with `(review-body)`.
   - Trigger phrases for including review-body: "review-bodyも含めて", "全コメントに返信", "include review-body", "reply to all"
3. Read the metadata comment at the end of review.md:
   ```
   <!-- replied-pr-comments: ["id1","id2",...] -->
   ```
4. Filter out items whose comment ID is already in the replied list.
5. If no unreplied items remain: report "All PR comments have been replied to." and stop.

### 3. Resolve Commit References

For items that were addressed with code changes:

1. Run `git log --oneline` on the current branch to get recent commits.
2. For each resolved item, identify the commit that addressed it:
   - Match by files changed: cross-reference the item's File field with `git log --name-only`
   - If multiple commits touch the same file, prefer the commit whose message relates to the item
3. Store the short commit SHA (7 characters) for use in the reply.

### 4. Generate Reply Drafts

For each unreplied item, generate a reply based on its resolution:

#### Addressed with code changes

Format: what was done + commit reference.

```
{one-sentence description using markdown: identifiers in `backticks`, links as [text](url)}. Fixed in {sha}.
```

#### Addressed without code changes

For items where no code change was needed (e.g., already handled, configuration-only, documentation clarification):

```
{one-sentence explanation of resolution}.
```

#### Not acted upon

For items intentionally declined or deferred:

```
{reason why this was not addressed}.
```

### 5. Present Drafts

Present all drafts to the user for review:

```markdown
## PR Comment Reply Drafts

**PR**: #{number}
**Scope**: inline comments only (include review-body with "全コメントに返信")
**Unreplied items**: {count}

| # | Item | Reply |
|---|------|-------|
| {N} | {item summary} | {draft reply} |
| {N} | {item summary} | {draft reply} |

Edit any drafts, then say "post" to submit replies to the PR.
```

Wait for user input.

### 6. Post Replies (on explicit request only)

**Only proceed when the user explicitly requests posting** (e.g., "post", "投稿して", "submit").

For each reply:

1. Parse the comment ID from the Source field: `PR #{number} comment:{commentId}`

2. **For inline comments** (Source contains `(inline)`):
   - Use `mcp__github__add_reply_to_pull_request_comment` with:
     - `owner`, `repo`: from step 1
     - `pullNumber`: PR number
     - `commentId`: parsed comment ID
     - `body`: the reply text

3. **For review body comments** (Source contains `(review-body)`):
   - Use `mcp__github__add_issue_comment` with:
     - `owner`, `repo`: from step 1
     - `issue_number`: PR number
     - `body`: `@{author} {reply text}` (mention the reviewer for context)

4. **Update replied tracking**: After successful posting, update the metadata comment at the end of review.md:
   ```
   <!-- replied-pr-comments: ["id1","id2","newId1"] -->
   ```

5. **Report results**:
   ```markdown
   {count} replies posted to PR #{number}.
   ```

## Reply Style Guide

- **Be concise**: one line is ideal, two lines maximum
- **No pleasantries**: skip "Thank you for the review", "Good catch", etc.
- **Commit references**: use short SHA (7 chars), e.g., `abc1234`
- **Declined items**: state the reason directly without being defensive
- **Language**: match the language of the original comment
- **Markdown formatting**: replies are rendered as markdown on GitHub, so use proper formatting:
  - Identifiers (function names, variable names, type names) in `` ` `` backticks
  - File paths in `` ` `` backticks
  - Commit SHAs are NOT backtick-wrapped (GitHub auto-links them)
  - URL links as `[text](url)`
  - Code snippets in fenced code blocks (`` ``` ``)

## Anti-patterns to Avoid

| Anti-pattern | Why It's Wrong | Correct Behavior |
|--------------|----------------|------------------|
| Posting without explicit request | User needs to review and edit drafts first | Always present drafts and wait for "post" signal |
| Verbose replies | Adds noise to PR conversation | Keep replies to 1-2 lines |
| Adding pleasantries | Wastes reviewer's time | State facts only |
| Guessing commit references | Wrong commit ref is worse than none | Only include commit SHA when confidently matched |
| Replying to already-replied comments | Creates duplicate replies | Check replied-pr-comments metadata |
| Replying to review-body by default | Review-body replies appear as standalone PR comments, not threaded — unclear which comment is being addressed | Only reply to inline comments by default; include review-body only on explicit request |
