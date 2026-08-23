# artifact-review

Rigorous review of a finished work artifact before acceptance. The skill selects
predefined Lenses from supported risk signals, assigns them to independent fresh
reviewers when available, and returns findings with explicit coverage and
residual risk.

## Skill

| Skill | Description |
|---|---|
| [`artifact-review`](./artifact-review/SKILL.md) | Review a code change, document, issue output, execution graph, or integrated project result through risk-selected Lenses |

For `code-change` targets, four baseline Lenses always cover functional
correctness, security regression, performance regression, and maintainability
risk. Other Lenses cover goal alignment, acceptance evidence, integration,
regression boundaries, scope, execution graphs, design consistency, and residual
risk.

The separately installed `review-lenses` skill owns every Lens file, the
selection index, and the common finding policy. The orchestrator reads only the
index before choosing Lenses; each reviewer receives only its assigned
definition and the common policy.

## Installation

Install this skill through the repository's `skills add` workflow documented in
the root README.
