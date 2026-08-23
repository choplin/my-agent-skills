# `global.goal-alignment`

## Objective

Falsify the claim that the integrated result achieves its original finite goal
and every stated requirement or acceptance criterion.

## Required inputs

- original goal and stated requirements or acceptance criteria, when present
- final artifacts and completed issue outputs
- evidence offered for completion

## Checks

- Map every stated requirement or acceptance item to concrete evidence.
- Find goal requirements with no corresponding deliverable.
- Find completed work that does not contribute to the goal.
- Test whether autonomous decisions changed the intended outcome.
- Distinguish absent criteria from failed criteria; do not invent missing ones.

## Non-goals

- Do not line-review every implementation artifact.
- Do not propose unrelated product improvements.

## Severity guidance

A demonstrably unmet binding requirement is blocker. Missing evidence for a
stated material requirement is at least major; the absence of project-defined
criteria is a coverage fact, not automatically a finding.
