---
name: post-task
description: Use this skill after completing implementation and review. Triggers on phrases like "task complete", "finish up", "wrap up this task", "commit and document", or after self-review passes.
allowed-tools: Read, Write, Edit, Glob, Grep
user-invocable: false
---

# Post Task

Capture knowledge from the completed task. This is the final step after commit.

## Purpose

Preserve valuable learnings from the session before they are lost to session clear.

## Trigger

After commit is completed. The workflow is:

```
self-review → user review → commit → post-task
```

## Process

### 1. Session Review

Review what happened during the session to identify knowledge worth preserving:

- External information researched (sources matter)
- Patterns that appeared 2+ times in the session
- Domain knowledge shared by user
- Project-specific conventions discovered
- Decisions made during implementation
- Specs/plans with lasting value
- Review feedback patterns (from review.md if exists)
- **Spec omissions surfaced late**: items the user raised in user-review that were classified as Design Change, or gaps that only appeared once something ran. These are the outer-loop signal — what the spec/kickoff failed to ask up front.

### 2. Propose Knowledge Capture

Present a list of items to capture, categorized by type:

| Signal | Proposal | Destination |
|--------|----------|-------------|
| Researched external information | Capture with sources | CLAUDE.md or Skill |
| Same workflow appeared 2+ times | Package as Skill | Skill |
| User shared domain knowledge | Make reusable | Skill |
| Project-specific knowledge or code snippets | Document | CLAUDE.md |
| Decision future developers should know | Create ADR | docs/adr/ |
| Spec/plan has lasting value | Preserve as Design Doc | docs/ |
| **Recurring spec omission / late Design Change** | Propose a new interview question or a spec-template prompt so the next spec asks about it up front | `kickoff` SKILL / `references/spec-template.md` |

**Outer-loop feedback (C-3)**: when the same kind of omission keeps surfacing in user-review across tasks, the fix is not in this task's code — it is in what the workflow asks before implementing. Propose the concrete addition (a kickoff question, or a checklist line in the spec template) and, if approved, make the edit. This is how the outer loop learns; see `docs/2026-06-11-loop-engineering-research.md` §3, §5.

### 3. User Approval

Present the proposal list. User selects which items to capture.

### 4. Execute

For each approved item:

- **Skill**: Invoke skill-authoring skill for proper skill creation
- **CLAUDE.md**: Append to appropriate section
- **ADR**: Create in docs/adr/ following ADR format
- **Design Doc**: Copy spec/plan to docs/ with appropriate naming
- **Workflow improvement (C-3)**: edit `kickoff` SKILL (add an interview question) or `references/spec-template.md` (add a prompt/checklist line) so future specs ask about the recurring omission up front

## Output Format

```markdown
## Knowledge Capture Proposal

Based on this session, I recommend capturing the following:

### Skill Candidates

1. **{topic}**: {why it should be a skill}
   - Source: {where this knowledge came from}

### CLAUDE.md Additions

1. **{topic}**: {what to add}
   - Section: {target section in CLAUDE.md}

### ADR Candidates

1. **{decision}**: {why it's worth recording}
   - Context: {what led to this decision}

### Design Doc Candidates

1. **{spec/plan}**: {why it has lasting value}
   - Location: `.claude/dev-workflow/story/{story-dir}/spec.md`

---

Which items would you like me to capture?
```

## Success Criteria

- [ ] All valuable learnings from session are identified
- [ ] Each proposal includes rationale (why it's worth capturing)
- [ ] User can select which items to capture
- [ ] Selected items are properly created in their destinations

## Next Session

After post-task completes:

**If part of Epic**:
- **Reference**: `.claude/dev-workflow/epic/{epic-dir}/epic.md`
- **Next phase**: `create-spec` for next Story

**If standalone Story/Task**:
- **Reference**: None
- **Next phase**: Done (or start new task with `/dev-workflow:kickoff`)
