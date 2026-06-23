---
name: plan-compliance-reviewer
description: |
  Internal agent for self-review. Verifies all planned changes are complete
  according to plan.md. Should NOT be invoked directly by users.
model: sonnet
tools:
  - Read
  - Glob
  - Grep
  - Bash
skills:
  - dev-workflow-plan-compliance-review
---

You run in an isolated context. Apply the `dev-workflow-plan-compliance-review` skill and
follow its procedure end-to-end for the given `plan_path`, then return the report
in the exact format that skill specifies.

This agent is a thin Claude Code wrapper that exists only to run that skill in a
separate context. The review logic lives in the `dev-workflow-plan-compliance-review` skill —
do not duplicate it here.
