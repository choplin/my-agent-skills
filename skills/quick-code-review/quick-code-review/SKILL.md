---
name: quick-code-review
description: >-
  Reviews a code change once for material functional, security, performance,
  and maintainability defects and returns evidence-backed findings directly.
  Applies when someone asks for an ordinary review of a diff, commit, branch,
  or uncommitted changes and does not need multi-lens coverage reporting.
allowed-tools: Read, Glob, Grep, Bash, Skill, Task
metadata:
  description-role: trigger
---

# Quick code review

Review one code change for material defects. Return findings in the conversation;
do not fix the change, persist a review record, or gate acceptance.

Require the `review-lenses` skill. If it is unavailable, stop before reviewing
and tell the caller to install it; do not reconstruct or approximate its policy.
Apply that skill and read:

- `references/finding-policy.md`;
- `references/lens-code-functional-correctness.md`;
- `references/lens-code-security-regression.md`;
- `references/lens-code-performance-regression.md`;
- `references/lens-code-maintainability-risk.md`.

Resolve those paths relative to the installed `review-lenses` skill.

## Input

- `scope` — the diff, commit, branch comparison, or working-tree changes to
  review. Default to the current branch diff when the caller does not specify it.
- `constraints` — applicable repository instructions, intended behavior, and
  caller-supplied non-goals.

Inspect the diff, the applicable repository instructions, and enough surrounding
code to prove or disprove each candidate issue. Do not rely on the diff alone
when a changed contract has callers or consumers elsewhere.

## Review baseline

Apply all four loaded code Lenses in one reviewer context. Keep their finding
categories distinct, then deduplicate candidates with the same cause and
evidence while preserving every Lens that found them. Apply the loaded common
finding policy as the admission threshold for the final finding set.

## Output

Return findings ordered by material impact. Each finding contains:

- a one-line summary;
- the shortest useful file and line location;
- the triggering scenario and concrete consequence;
- the supporting evidence;
- the smallest adequate remediation;
- severity when it is useful: `blocker`, `major`, or `minor`.

Keep uncertainty explicit. End with a short statement when no qualifying finding
was found. Do not create a persistent record or modify the reviewed files.

## Success criteria

- [ ] The canonical finding policy and all four canonical baseline code Lenses
      were loaded from `review-lenses` and applied.
- [ ] Every returned finding satisfies the canonical finding policy.
- [ ] Deduplication preserves every Lens that independently found the issue.
- [ ] The reviewed change and external state remain unmodified.
