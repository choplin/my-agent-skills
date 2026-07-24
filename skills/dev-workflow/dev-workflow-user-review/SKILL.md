---
name: dev-workflow-user-review
description: Drive the user-review phase for a dev-workflow Story. Applies the human acceptance criteria (Verify=human), delegates the item-resolution loop to review-tools-resolve, handles postponed (design-level) items via create-spec, and concludes via review-tools-report and post-task.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Skill, Task
user-invocable: true
---

# User Review (dev-workflow Story wrapper)

Run the human review of a completed **Story**. Two things happen here: the human
**acceptance** judgment (the `Verify: human` criteria), and the **resolution** of the
review items — the latter delegated to `review-tools-resolve`.

**Trigger phrases**: "user review", "ユーザーレビュー", "レビュー対応"

## Scope

Story-level work only. All single deliverables admitted by dev-workflow are
Stories; autonomous work is selected before kickoff and has no dev-workflow state.

## Process

### 1. Resolve the Story and bind the session

1. Run `python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID"`. Take the active Story from `active_path`; if `null`, identify from `work_units[]` by `matches_current_branch`, else ask. Directory: `.claude/dev-workflow/story/{story-dir}/`.
2. **Bind this session** to the Story:
   ```bash
   python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/story/{story-dir}"
   ```

### 2. Human acceptance judgment (Verify = human)

The `Verify: human` acceptance criteria can only be judged by a person — that judgment
is this review's acceptance gate, not a review item.

1. Assess the criteria against the implementation using the
   `dev-workflow:acceptance-reviewer` subagent (a wrapper around the
   `dev-workflow-acceptance-review` skill; apply the skill inline if the subagent is
   unavailable). It reports each human criterion as PASS (with evidence) or NEEDS REVIEW.
2. Present them to the user for sign-off.
3. If the user judges a criterion **not met**, the implementation was not actually
   complete for that criterion:
   - a small in-scope correction → capture it as direct feedback for Step 3 (an item);
   - a larger/design-level gap → treat it as a **postponed** follow-up (Step 4), or
     return to implementation.

Do not fabricate a PASS — an unconfirmed human criterion stays NEEDS REVIEW until the
user signs off.

### 3. Resolve the review items

```
Skill(skill: "review-tools-resolve")
- review_dir: .claude/dev-workflow/story/{story-dir}/
```

`review-tools-resolve` presents the open items (the AI code findings seeded by
self-review, plus any imported PR/CI items and direct feedback — including anything from
Step 2) and works each to `resolved` / `skipped` / `postponed` via propose → approve →
apply. On "LGTM" / "以上" it sets Phase `done`.

**PR / CI items**: to pull the Story's PR review comments or CI failures in, invoke
`review-tools-import-pr` / `review-tools-import-ci` (and later `review-tools-reply-pr`)
with the same `review_dir`.

### 4. Drive postponed follow-ups (design-level)

`postponed` items need a spec-level change — a dev-workflow artifact. For each:

1. `Skill(skill: "dev-workflow-create-spec")` to add/edit the affected success criteria,
   then re-implement and re-run `dev-workflow-self-review` for the affected changes.
2. Process these before completion, or record them (with the user's agreement to defer)
   for post-task's outer-loop capture — they signal what the spec/kickoff missed.

### 5. Conclude

Once Phase is `done`, acceptance is signed off, and postponed items are handled or
deferred:

1. `Skill(skill: "review-tools-report")` with the Story's `review_dir` — the completion
   summary (resolved / postponed / skipped).
2. `Skill(skill: "dev-workflow-post-task")`, feeding it the report (postponed items are
   the outer-loop signal).

## Success Criteria

- [ ] Active Story resolved and session bound
- [ ] Human acceptance criteria judged and signed off (not fabricated); unmet ones → feedback or postponed / back to implementation
- [ ] Item resolution delegated to `review-tools-resolve`
- [ ] `postponed` items driven via `dev-workflow-create-spec` + re-review (or deferred with the user's agreement)
- [ ] Completion summary via `review-tools-report`; `dev-workflow-post-task` run
- [ ] No review state written to `state.json` (it lives in review.md)

## Next Session

Review state persists in `review.md`. After `/clear`, `dev-workflow-resume-work` detects
`in_review` and dispatches back here to continue the open items.
