# codebase-structure

Skills for designing and maintaining a codebase structure that a person can
verify against a shared domain and use-case model from static evidence.

## Skills

| Skill | Description |
|-------|-------------|
| `codebase-structure` | Design a target structure when the concepts and boundaries are not decided yet |
| `codebase-structure-review` | Judge a proposed or implemented structure without changing it |
| `codebase-structure-refactor` | Move existing code toward a decided target while preserving external behavior |
| `codebase-structure-base` | Shared decision model: the reviewability goal, concept model, and boundary forces |

Design and refactor both compose with review — a design is worth reviewing before
it is implemented, and a refactor after. `codebase-structure-base` carries the
routing between the three and loads whenever structural work starts.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.

