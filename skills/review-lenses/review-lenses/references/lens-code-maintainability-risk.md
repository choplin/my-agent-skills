# `code.maintainability-risk`

## Objective

Find change-introduced structure or contracts that create a concrete risk of
future defects or make a required maintenance operation unsafe.

## Required inputs

- the diff and applicable repository conventions
- nearby ownership boundaries, invariants, and extension points
- a concrete maintenance task or change path affected by the candidate issue

## Checks

- Find one invariant represented inconsistently in multiple changed locations.
- Identify misleading names, contracts, or abstractions that cause callers to use
  the changed behavior incorrectly.
- Trace new coupling across ownership or lifecycle boundaries and name the change
  that would require unsafe coordinated edits.
- Find unreachable, contradictory, or silently shadowed configuration and control
  paths introduced by the change.
- Check whether new abstractions hide required variation or expose variation that
  has no current consumer.
- Tie each candidate to a specific defect mechanism or maintenance operation; do
  not stop at “hard to read.”

## Non-goals

- Do not report formatting, naming taste, or stylistic preference alone.
- Do not demand broad cleanup of pre-existing code.
- Do not treat every abstraction, duplication, or long function as a defect.

## Severity guidance

Use major only when the structure already makes a required change unsafe or
causes contradictory behavior. Use minor for a bounded, concrete defect risk.
Pure readability observations do not qualify as actionable findings.
