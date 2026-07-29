---
name: code-review-session-resolve
description: The resolution loop of the code-review-session family — work the open items in review.md to a terminal outcome (resolved / skipped / postponed). For each item the AI proposes a response; the user approves it, discusses to refine it, or defers it. Direct feedback typed in the session is added as an item and resolved the same way. Triggers on "resolve review items", "work through the review", "レビュー対応", "指摘を解決".
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Skill, Task
metadata:
  description-role: documentation
---

# Resolve (resolution loop)

Drive the `open` items in `review.md` to a terminal outcome. This is the core of the
review process; ingestion skills (`code-review-session-import-ai`, `code-review-session-import-pr`,
`code-review-session-import-ci`) fill the record, and this skill empties it — moving freely
back and forth with them as new items arrive.

**Trigger phrases**: "resolve review items", "work through the review", "レビュー対応", "指摘を解決"

## The model

For each `open` item: **the AI proposes a response, the user decides.** The AI never
applies a change before the user agrees to the approach. An item ends in one of:

| Outcome | When |
|---------|------|
| `resolved` | Addressed — a change was made, or it was handled/explained without one |
| `skipped` | The user declines it |
| `postponed` | Acknowledged but out of scope here — needs a larger/design-level change; becomes a follow-up |

Statuses are minimal (`open` → terminal). The propose→approve→apply steps happen live
within a turn; the item's `Approach` field records the proposed response so a discussed
-but-not-yet-applied item survives a session boundary.

## Input

- `review_dir` — where the record lives (default: standalone; see `code-review-session-base`
  skill (`references/review-init-guide.md`)).
- Direct feedback from the user during the session.

## Process

### 0. Load the record

Find `review.md` at `{review_dir}/review.md` (standalone: search
`.agents/code-review-session/*/review.md`). If it does not exist, create it (via
`code-review-session-base` skill (`references/review-init-guide.md`)) so direct feedback has a
home. Normalize any legacy values (see `code-review-session-base` skill
(`references/review-state.md`)).

Present a short summary: how many items, how many `open`, grouped by `Source`.

### 1. Pick the next item (or take direct feedback)

- Work `open` items, or take a new point the user raises now (add it as an item with
  `Source: direct`, `Status: open`).
- **Always one item at a time.** Propose, get a decision, apply — then move to the next.
  Never batch several proposals or apply multiple items together, even if the user asks
  to "go faster"; keep each item on its own propose→decide→apply cycle.

### 2. Propose a response

Read the item's `Detail`. Judge whether the response is unambiguous:

- **Clear** (you can state exactly WHERE and WHAT): propose it directly.
- **Ambiguous** (either the location or the change is unclear): clarify first with the
  `discuss-toolkit-dig` skill, then propose.
- **Out of scope** (it would need a new/changed requirement or a design-level change):
  say so and propose `postponed` — do not attempt the change here.

Present the proposal **always paired with the original comment**, and record it in the
item's `Approach`. Quote the item's `Detail` verbatim (the original reviewer comment) so
the user judges the response against the exact wording, not a paraphrase:

```markdown
**Item {N}** ({source}): {summary}
**Original comment**:
> {verbatim Detail — the original reviewer comment}
**Proposed**: WHERE: {file:location} / WHAT: {specific change}   (or: POSTPONE — {why out of scope})

Agree? (or refine / "skip")
```

Never present a proposal without the original comment beside it. Do **not** change any
code yet.

### 3. User decides

- **Agree** ("OK", "やって", "go ahead"): apply the change now. When applied, set
  `Status: resolved` and fill `Resolution`, then move to the next item.
- **Refine / discuss**: adjust the approach, re-present. Keep the item `open`.
- **Skip** ("skip", "やめて"): set `Status: skipped`.
- **Postpone** (agreed it is out of scope): set `Status: postponed`, and in `Resolution`
  note what larger change it needs.

After each item, report briefly and go to the next (or wait for more feedback).

For PR-sourced items, resolution is recorded on the item; replying on the PR is a
separate step (`code-review-session-reply-pr`).

#### Plan mode

If applying an item needs a plan (Claude Code EnterPlanMode), continue resolving the
remaining items afterward; the record is the source of truth for what is left.

### 4. Conclude

When no `open` items remain — or the user signals done ("LGTM" / "以上"):

1. Set `## Status` Phase to `done`.
2. If any items are `postponed`, note that follow-ups remain.
3. Offer `code-review-session-report` to produce a completion summary for downstream (a
   driving workflow, a report, or a tracker), and — if there are PR-sourced items —
   `code-review-session-reply-pr` to reply on the PR.

The user can `/clear` and resume later by re-invoking this skill; `open` items and
their recorded `Approach`es are read back from `review.md`.

## Anti-patterns to Avoid

| Anti-pattern | Why It's Wrong | Correct Behavior |
|--------------|----------------|------------------|
| Applying a change before the user agrees | Wrong approach causes rework | Always propose and wait for agreement |
| Batching several items into one proposal | Loses per-item decision; hides context | One item at a time — propose, decide, apply, next |
| Proposing without the original comment | User can't judge against exact wording | Always quote the item's `Detail` beside the proposal |
| Forcing a design-level change through here | It needs an out-of-scope decision | Mark `postponed`; surface it as a follow-up |
| Proposing multiple interpretations | Adds cognitive load | Use `discuss-toolkit-dig` to narrow down |
| Concluding without an explicit signal | The user may have more feedback | Wait for "LGTM" / "以上" or an empty open list |

## Success Criteria

- [ ] Each `open` item driven to `resolved` / `skipped` / `postponed`
- [ ] Items are worked strictly one at a time (no batching)
- [ ] Every proposal is presented paired with the original comment (verbatim `Detail`)
- [ ] A response is proposed and agreed before any code change
- [ ] Ambiguous items go through `discuss-toolkit-dig` before a proposal
- [ ] Out-of-scope items are `postponed`, not forced
- [ ] Direct feedback is captured as items and resolved the same way
- [ ] On conclusion, Phase set to `done`; report/reply offered
