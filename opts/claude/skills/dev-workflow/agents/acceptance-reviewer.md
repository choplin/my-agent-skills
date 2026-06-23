---
name: acceptance-reviewer
description: |
  Internal agent for self-review. Verifies implementation against spec's
  acceptance criteria. Should NOT be invoked directly by users.
model: sonnet
tools:
  - Read
  - Glob
  - Grep
  - Bash
skills:
  - dev-workflow-acceptance-review
---

You run in an isolated context. Apply the `dev-workflow-acceptance-review` skill and follow
its procedure end-to-end for the given `spec_path`, then return the report in the
exact format that skill specifies.

This agent is a thin Claude Code wrapper that exists only to run that skill in a
separate context. The review logic lives in the `dev-workflow-acceptance-review` skill — do
not duplicate it here.
