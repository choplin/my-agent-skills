---
name: dev-workflow-acceptance-review
description: Verify an implementation against the human-judged acceptance criteria in a dev-workflow spec — the Given-When-Then criteria whose `Verify:` line is `human` and cannot be checked by a command. Use during self-review to evaluate acceptance criteria. This is the portable review procedure; under Claude Code it is also wrapped by the dev-workflow:acceptance-reviewer subagent for isolated execution. Should NOT be used to re-judge criteria with an executable `Verify:` command (those are machine-checked separately).
---

# Acceptance Criteria Review

Verify an implementation against the **human-judged** acceptance criteria in a
spec — the ones that cannot be checked by a command. Runs inline on any agent;
under Claude Code it is also dispatched as the `dev-workflow:acceptance-reviewer`
subagent (a thin wrapper around this skill) for an isolated context.

## Input

- `spec`: the spec's **Acceptance Criteria** content (Given-When-Then with `Verify:`
  lines) as text. self-review supplies it from the Story's Linear Issue; this skill
  stays Linear-agnostic — it judges the criteria it is given, not a file path.

## Scope

Each criterion has a `Verify:` line. Criteria with an executable `Verify:`
command are checked deterministically by self-review's machine-verification pass
**before** this review — do not re-judge them. **Only evaluate criteria whose
`Verify:` is `human`** (subjective/UX/judgment). For those, you cannot produce a
hard PASS programmatically, so mark them PASS only with clear evidence,
otherwise NEEDS REVIEW. Never guess.

## Process

### 1. Read the supplied spec

From the supplied `spec` content, extract:
- **Acceptance Criteria** (Given-When-Then format) — focus on `Verify: human` criteria
- **Out of Scope** (to avoid false negatives)

### 2. Verify Each Criterion

For each acceptance criterion:

1. **Check Given**: Verify preconditions are satisfied
2. **Execute When**: Perform the described action
   - Run tests if applicable
   - Check code existence
   - Verify file structure
3. **Verify Then**: Confirm expected result matches actual

### 3. Determine Result

| Result | Condition |
|--------|-----------|
| PASS | Expected result is satisfied with evidence |
| FAIL | Expected result NOT satisfied - include what's wrong |
| NEEDS REVIEW | Cannot be determined programmatically (requires user judgment) |

## Verification Methods

| Criterion Type | Method |
|----------------|--------|
| File exists | Glob to find file, Read to verify content |
| Code contains X | Grep to search, Read to verify context |
| Tests pass | Bash to run test command |
| Build succeeds | Bash to run build command |
| UI/UX behavior | Mark as NEEDS REVIEW |
| Performance | Mark as NEEDS REVIEW |

## Output Format

Return results in this exact format:

```markdown
## Acceptance Criteria Review

### Results

| # | Criterion | Result | Details |
|---|-----------|--------|---------|
| 1 | {criterion name} | PASS | {verification method and evidence} |
| 2 | {criterion name} | FAIL | **Problem**: {what's wrong} |
| 3 | {criterion name} | NEEDS REVIEW | {why AI cannot determine} |

### Summary

- PASS: X
- FAIL: X
- NEEDS REVIEW: X
```

## Important Notes

- **Evidence-based**: Every PASS must include verification evidence
- **Actionable FAILs**: Every FAIL must describe what's wrong specifically
- **Honest NEEDS REVIEW**: Don't guess on UI/UX or subjective criteria
- **No modifications**: Only read and report, never fix issues
