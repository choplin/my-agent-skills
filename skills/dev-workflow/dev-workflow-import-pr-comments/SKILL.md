---
name: dev-workflow-import-pr-comments
description: Import PR review comments into review.md with automatic classification. Fetches comments from the current branch's open PR and appends them as Review Items.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(gh *), Bash(git branch *), Bash(git remote *)
user-invocable: true
---

# Import PR Comments

Import review comments from a GitHub Pull Request into `review.md`, classifying each comment using the ambiguity test defined in the `dev-workflow-user-review` skill.

**Trigger phrases**: "PR comments import", "import PR comments", "PRコメントを取り込んで", "PRレビューをインポート"

## Purpose

When using draft PRs for bot reviews (e.g., Copilot), review comments arrive on the PR rather than in the dev-workflow review process. This skill bridges the gap by importing those comments into `review.md` so they can be processed through the standard `dev-workflow-user-review` approach-proposal-and-agreement flow.

## Input

- `review.md` (if it does not exist, it will be auto-created using `dev-workflow-base` skill (`references/review-init-guide.md`))
- An open PR on the current branch

## Process

### 1. Verify Prerequisites

1. **Find review.md**: Look for `review.md` at:
   - `.claude/dev-workflow/story/*/review.md`
   - `.claude/dev-workflow/task/*/review.md`

   - If not found: **auto-create** review.md using `dev-workflow-base` skill (`references/review-init-guide.md`):
     - Follow the guide to determine work level (Story / Task with plan / Task no plan)
     - Resolve metadata and create review.md at the appropriate path
     - Self-Review Results: Use SKIPPED row (`| - | Self-review | SKIPPED | Self-review was not performed |`)
     - Set Phase to `REVIEWING`

   - Once the review.md's work-unit directory is known, **bind this session** to it so dev-workflow hooks track only this work (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

     ```bash
     python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set "<work-unit-dir>"
     ```

2. **Check Phase**: Read review.md and check the Phase value (normalize legacy values per `dev-workflow-base` skill (`references/state-schema.md`) — e.g. `COLLECTING FEEDBACK` → `REVIEWING`).
   - `REVIEWING`: proceed normally
   - Any other phase: warn the user ("review.md Phase is '{phase}'. Import is intended for REVIEWING phase. Continue anyway?") and wait for confirmation

3. **Find open PR**: Run `gh pr view --json number,url,state` for the current branch.
   - If no PR or state is not "OPEN"/"DRAFT": stop and report "No open PR found for the current branch."

### 2. Fetch PR Comments

Collect all review comments from the PR:

1. **Review bodies**: `gh pr view --json reviews --jq '.reviews[] | {id: .id, author: .author.login, body: .body, state: .state}'`
   - Filter out reviews with empty bodies
   - Filter out DISMISSED reviews

2. **Inline comments**: `gh api repos/{owner}/{repo}/pulls/{number}/comments --jq '.[] | {id: .id, author: .user.login, body: .body, path: .path, line: (.original_line // .line), diff_hunk: .diff_hunk}'`

3. **Derive owner/repo**: `gh repo view --json nameWithOwner --jq '.nameWithOwner'`

### 3. Exclude Already-Imported Comments

1. Read the end of review.md for the metadata comment:
   ```
   <!-- imported-pr-comments: ["id1","id2",...] -->
   ```
2. If the metadata comment exists, parse the list of already-imported IDs
3. Filter out any comments whose ID is already in the list
4. If no new comments remain: report "No new PR comments to import." and stop

### 4. Classify Each Comment

Apply the **Ambiguity Test** defined in `dev-workflow-user-review` skill (see `skills/user-review/SKILL.md` section "Classify Feedback").

Summary for reference (SSoT is user-review):
- **Minor**: WHERE and WHAT are both unambiguous -> record approach as proposed (awaiting user agreement)
- **Complex**: Either WHERE or WHAT is ambiguous -> leave OPEN for user-review to dig
- **Design Change**: Requires new/changed spec success criteria -> leave OPEN

Classification guidance by comment type:

| Comment Type | WHERE | Classification Tendency |
|-------------|-------|------------------------|
| Inline comment | Clear (file + line provided) | Check WHAT only: unambiguous -> Minor, ambiguous -> Complex |
| Review body (summary) | Often unclear | Usually Complex (both WHERE and WHAT need examination) |
| Scope-exceeding suggestion | N/A | Design Change |

For **Minor** items, also prepare the approach:
- **WHERE**: Use the file path and line from the inline comment
- **WHAT**: Extract the specific change requested from the comment body

### 5. Preview and Confirm

Present the import preview to the user:

```markdown
## PR Comment Import Preview

**PR**: #{number} ({url})
**New comments**: {count}

| # | Author | Type | Summary | Classification |
|---|--------|------|---------|----------------|
| 1 | @author | inline | {brief summary} | Minor |
| 2 | @author | review-body | {brief summary} | Complex |

Proceed with import?
```

Wait for user confirmation before writing to review.md.

### 6. Write to review.md

1. **Determine next item number**: Read existing Review Items and find the highest item number N. New items start from N+1.

2. **Append Review Items** after the last existing item (before the Status section). For each comment:

   ```markdown
   ### Item {N}: {comment summary}
   - **Status**: APPROACH PROPOSED | OPEN
   - **Classification**: Minor | Complex | Design Change
   - **Source**: PR #{number} comment:{commentId} - @{author} ({inline|review-body})
   - **Feedback**: {comment body}
   - **File**: `{path}` L{line}
   - **Approach**: WHERE: {file:line} / WHAT: {specific change}
   - **Resolution**:
   ```

   Field rules:
   - **Status**: `APPROACH PROPOSED` for Minor (approach filled in, awaiting user agreement), `OPEN` for Complex and Design Change
   - **File**: Include only for inline comments (omit entire line for review-body)
   - **Approach**: Fill in for Minor items only (leave empty for Complex/Design Change)

3. **Update Resolved counter**: Update the denominator in `Resolved: X / Y` to reflect the new total item count. Do not change the numerator.

4. **Update imported IDs metadata**: Append or update the HTML comment at the end of review.md:
   ```
   <!-- imported-pr-comments: ["id1","id2","newId1","newId2"] -->
   ```

### 7. Report and Guide Next Steps

```markdown
{count} items imported from PR #{number}.

Continue providing feedback, or say "以上" when done to start implementation.
```

## Output Format

### Successful Import

```markdown
{N} items imported from PR #{number}.

Continue providing feedback, or say "以上" when done to start implementation.
```

### No New Comments

```markdown
No new PR comments to import. All comments from PR #{number} have already been imported.
```

### Prerequisites Not Met

```markdown
Cannot import: {reason}.
```

## Integration with Workflow

```
[Normal flow]
self-review
    ↓ review.md created
    ↓ handoff → /clear → resume-work → user-review
    ↓
user-review (REVIEWING)
    ↓ user creates draft PR
    ↓ bot reviews arrive on PR
    ↓
import-pr-comments (this skill)
    ↓ comments added to review.md as Review Items
    ↓
user-review (continues REVIEWING)
    ↓ propose approach → agree → implement (iterative) for each item
    ↓ "以上" or LGTM

[Direct invocation — no prior self-review]
import-pr-comments (this skill)
    ↓ review.md not found → auto-created via review-init-guide.md
    ↓ PR comments imported as Review Items
    ↓
user-review (REVIEWING)
    ↓ propose approach → agree → implement for each item
    ↓ "以上" or LGTM
```

## Anti-patterns to Avoid

| Anti-pattern | Why It's Wrong | Correct Behavior |
|--------------|----------------|------------------|
| Duplicating classification logic | Creates drift from user-review SSoT | Reference user-review's Ambiguity Test |
| Importing without preview | User loses control over what enters review.md | Always show preview and wait for confirmation |
| Re-importing already-imported comments | Duplicates items in review.md | Track imported IDs in HTML comment metadata |
| Implementing imported items immediately | Bypasses approach-agreement flow in user-review | Only classify and record; approach agreement and implementation happen in user-review |
