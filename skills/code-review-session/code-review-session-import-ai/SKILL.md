---
name: code-review-session-import-ai
description: >-
  Runs an AI code review of a change and records each finding as an open item
  in a code-review session record. Preserves review rounds and target revisions
  so later runs can avoid stale or repeated review. It does not fix anything
  and gates nothing.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Skill, Task
metadata:
  description-role: documentation
---

# Import AI review findings (ingestion)

Add review items from an **AI code review**. This is one of the ways items enter
the record (alongside `code-review-session-import-pr`,
`code-review-session-import-ci`, `code-review-session-run-checks`, and direct
feedback). It **ingests** findings — it does not resolve or fix them; that is
`code-review-session-resolve`'s job.

Select this skill when the requested deliverable is a **persistent review record**.
A one-off "review this diff and tell me what's wrong" wants findings in the
conversation and no record: that is `quick-code-review` on its own.

## Who performs the review

This skill contains no review procedure. It calls one:

| Reviewer | Use when |
|----------|----------|
| `quick-code-review` (default) | One-pass functional, security, performance, and maintainability review of the change |
| `artifact-review` | The change needs independent multi-Lens coverage — broad blast radius, low reversibility, weak evidence, or cross-artifact risk |
| A reviewer named by the caller | The caller specifies one; honor it |

The caller may also pass findings it already has, in which case this skill only
records them.

## Input

- `review_dir` — where the record lives (default: standalone; see
  `code-review-session-base` skill (`references/review-init-guide.md`)).
- `scope` — the change to review (default: current branch diff).
- `reviewer` — optional; which reviewer to invoke (default
  `quick-code-review`).
- `findings` — optional; findings already produced, to record without reviewing.
- `mode` — optional; force `full` review. Other modes are derived from recorded
  rounds and the current target.

## Process

### 1. Resolve the record

Resolve `review_dir` and ensure `review.md` exists (create via
`code-review-session-base` skill (`references/review-init-guide.md`) if not).
Read `code-review-session-base` skill (`references/ai-review-rounds.md`) and
load or initialize `{review_dir}/sources/ai.json`.

### 2. Plan the round

Resolve the current target revision and stable content fingerprint when possible.
Compare them with the latest completed round for the same scope, then select
`full`, `incremental`, `provided-findings`, or `skipped` by the loaded AI-round
procedure. Allocate the next round ID and record the attempt before invoking a
reviewer.

If the mode is `skipped`, record why, report that no review-relevant input
changed, and stop without changing `review.md`.

### 3. Obtain findings

Unless `findings` was supplied, invoke the selected reviewer over `scope`. Require
each finding to carry a one-line summary, the location, and the detail; a severity
and confidence if the reviewer offers them. Build iterative context as specified
by the loaded AI-round procedure. In particular, let prior items guide an ordinary
incremental review without exposing prior reviewer conclusions inside
`artifact-review`'s blind Lens passes.

If the reviewer fails or its output cannot be normalized, record the round as
`failed` with the reason and stop without adding items.

### 4. Record findings and finish the round

For each finding, append an item to `review.md` under `## Items` (see
`code-review-session-base` skill (`references/review-state.md`)):

- **Source**: `ai:round/{round}`
- **Status**: `open`
- **Detail**: the finding text, including its location
- **Summary**: the one-line heading

Determine the next item number from the highest existing item. **Dedupe**: skip a
finding that matches an existing item (same location + gist) so re-running the
ingestion does not double-add.

In `sources/ai.json`, associate each new item with the round and store available
location, severity, and confidence metadata. Record duplicates under
`matched_items`. Mark the round `completed` only after both the generic items and
the companion ledger agree.

Update the `Resolved: X / Y` denominator to the new total.

### 5. Report

```markdown
AI review round {round} completed ({reviewer used}, {mode}, {base..head or scope}).
{count} items added; {duplicate count} matched existing items.

Open items: {open count}. Run `code-review-session-resolve` to work through them.
```

This skill does not fix anything or change the review Phase. It leaves the items
`open` for `code-review-session-resolve`.

## Success Criteria

- [ ] The review itself is delegated to a reviewer; no review procedure is
      re-implemented here
- [ ] Every attempted review has a round in `sources/ai.json` with its target
      revision and terminal outcome
- [ ] Each new finding is an `open` item with `Source: ai:round/{round}` and
      source-specific metadata stays in the AI ledger
- [ ] Duplicates against existing items are skipped
- [ ] Iterative context prevents stale repetition without weakening
      `artifact-review` reviewer independence
- [ ] Does not run project checks (that is `code-review-session-run-checks`)
- [ ] Does not fix, gate, or change the review Phase
