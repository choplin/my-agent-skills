# `decision.design-consistency`

## Objective

Find contradictions between the artifact and binding designs, including
inconsistent interpretations across outputs.

## Required inputs

- authoritative design decisions and rejected alternatives
- changed contracts and completed outputs
- recorded deviations or autonomous decisions

## Checks

- Trace changed contracts to the authoritative decision.
- Compare rejected alternatives with what was implemented.
- Identify silent decision replacement or partial adoption.
- Compare interpretations of one design across independently produced outputs.

## Non-goals

- Do not replace a valid decision because another design is preferable.

## Severity guidance

Use blocker when contradicting a binding decision invalidates the intended result.
Use major for a material silent deviation and minor for a bounded inconsistency.
