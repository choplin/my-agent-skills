# `scope.yagni`

## Objective

Find changes that cannot be justified by the current goal, requirements,
constraints, or a present repeated use.

## Required inputs

- intended outcome, current requirements, and non-goals
- changed artifact and justification for new abstractions or extension points

## Checks

- Trace every material addition to a current requirement or present use.
- Challenge abstractions with only one present implementation.
- Find deferred capability implemented ahead of evidence.
- Identify opportunistic cleanup that enlarged blast radius.

## Non-goals

- Do not equate all abstraction or refactoring with waste.
- Do not reject small reversible structure that directly reduces current risk.

## Severity guidance

Unjustified cross-cutting scope is major. A small removable addition with limited
blast radius is minor.
