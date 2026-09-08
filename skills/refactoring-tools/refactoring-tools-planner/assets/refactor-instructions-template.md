# Refactor Instructions Template

Use every required heading below. Replace all guidance with repository-specific
content. Add subsections when useful, but do not leave placeholders in the final
document.

## Contents

1. Document preamble
2. Objective
3. Project Understanding
4. Behaviors To Preserve
5. Non-Negotiables
6. Stop And Ask Conditions
7. Baseline Commands
8. Debt Map
9. Implementation Phases
10. Verification Requirements
11. Reporting Format
12. Out-of-scope Items
13. Evidence Index

## Document preamble

State that this is the complete execution contract for a fresh implementation
agent. Tell it to read the whole document before editing, follow repository
instructions, and implement only the approved phases.

Include the intended invocation when relevant:

```text
/goal .agents/refactoring-tools/refactor-instructions.md に書かれたことを完遂しろ
```

Do not assume `/goal` semantics enforce any safety rule; spell every important
constraint out in the document.

## Objective

Define the bounded structural outcome, why it matters, and the observable
meaning of completion. Explicitly state that external behavior remains unchanged
unless a separately approved item says otherwise.

## Project Understanding

Summarize only what the implementation work needs:

- product purpose and important workflows;
- entry points and major module responsibilities;
- relevant data/control flow and external dependencies;
- persistence, generated artifacts, and sensitive boundaries;
- repository instructions and environment constraints.

Distinguish observations from material inferences.

## Behaviors To Preserve

List concrete contracts with their evidence and verification route. Include
relevant API/CLI/UI behavior, serialized shapes, error behavior, ordering,
idempotency, transactionality, concurrency semantics, schema compatibility,
authorization, side effects, and operational behavior.

Avoid “preserve existing behavior” without enumerating what that means.

## Non-Negotiables

At minimum require:

- inspect the worktree before editing;
- preserve and avoid absorbing unrelated changes;
- record the baseline before implementation;
- keep changes small and reversible;
- avoid unrelated formatting, features, upgrades, and opportunistic cleanup;
- do not change a contract merely because it appears undesirable;
- verify every phase independently;
- stop on unexplained regression or newly discovered ambiguity.

Add repository-specific constraints such as generated-file policy, transaction
boundaries, migration rules, or prohibited commands.

## Stop And Ask Conditions

Write objective triggers, not a vague “ask if unsure.” Include the relevant
condition, affected phase or debt ID, and what evidence is missing. Cover any
remaining uncertainty around public contracts, persisted data, deletion,
security-sensitive behavior, third-party effects, and architectural one-way
doors.

## Baseline Commands

Use a table like:

| Command | Working directory | Purpose | Prerequisites | Analysis result |
|---|---|---|---|---|

Use exact repository-native commands. Mark commands not run as `not run` with a
reason. State how the implementation agent should handle a pre-existing failure:
record it, determine whether it affects the planned work, and do not mislabel it
as a regression.

## Debt Map

Use one subsection or table row per retained finding:

- ID and title;
- evidence;
- current structural problem and concrete consequence;
- affected behavior/contracts and blast radius;
- confidence and change risk;
- bounded recommendation;
- verification;
- disposition: implement, characterize first, proposal only, or out of scope.

Order by implementation dependency and value. Merge findings with the same root
cause. Exclude taste-only observations.

## Implementation Phases

Begin with a phase summary showing dependencies. For each phase include:

1. Objective and linked debt IDs.
2. In-scope files, symbols, or boundaries.
3. Ordered implementation steps.
4. Behaviors and contracts to preserve.
5. Exact validation commands and manual checks.
6. Stop-and-ask triggers.
7. Observable exit criteria.

Phase 0 must reconfirm `git status`, repository instructions, and baseline
results. Add characterization coverage before moving behavior that lacks a
safety net. Keep high-risk redesigns out of executable phases unless explicitly
approved.

## Verification Requirements

Provide a matrix from preserved behavior and debt IDs to automated or manual
evidence. Require focused checks after each phase and the applicable full suite
at the end. Include final diff review, generated-artifact checks, and
repository-specific integration or operational checks where relevant.

Tests passing is necessary evidence, not proof of untested contract
preservation.

## Reporting Format

Require a final report containing:

- phases completed, skipped, or changed;
- files and contract boundaries changed;
- commands run with pass/fail results;
- baseline failures versus new regressions;
- behavior-preservation evidence;
- decisions made and deviations from this document;
- unresolved risks, proposal-only work, and follow-ups.

The implementation agent must not claim completion for skipped validation.

## Out-of-scope Items

List concrete exclusions: unrelated features and bugs, schema or data migrations,
dependency upgrades, public-contract changes, speculative performance work,
style-only cleanup, and each repository-specific excluded area. Explain where an
excluded item is adjacent enough to tempt scope creep.

## Evidence Index

Map important claims and debt IDs to repository-relative files plus symbols or
line numbers, tests, docs, configuration, or command output. This makes the
document auditable after handoff.
