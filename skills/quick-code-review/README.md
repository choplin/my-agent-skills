# quick-code-review

A one-pass review of a code change. It checks functional correctness, security,
performance, and maintainability in one reviewer context and returns only
material, evidence-backed findings in the conversation.

## Skill

| Skill | Description |
|---|---|
| [`quick-code-review`](./quick-code-review/SKILL.md) | Review a diff, commit, branch comparison, or uncommitted changes without persisting, fixing, or gating |

The skill requires the separately installed `review-lenses` skill, which owns
the common finding policy and four baseline code Lens definitions. For broader
artifact review with independent Lens coverage, use `artifact-review`.

## Installation

Install this skill through the repository's `skills add` workflow documented in
the root README.
