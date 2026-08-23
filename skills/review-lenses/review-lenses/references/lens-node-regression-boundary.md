# `node.regression-boundary`

## Objective

Find behavior outside the intended change that the artifact breaks.

## Required inputs

- the changed artifact and intended scope
- nearest preserved contracts and downstream consumers
- targeted regression evidence

## Checks

- Identify the nearest behavior and contracts that must remain unchanged.
- Run or inspect targeted regression checks.
- Examine error, fallback, compatibility, and migration paths.
- Trace public or shared changes into downstream callers.

## Non-goals

- Do not report unrelated pre-existing defects.
- Do not broaden the regression surface without a concrete consumer.

## Severity guidance

Use blocker when a critical preserved contract is broken, major for material
downstream breakage, and minor for a bounded compatibility defect.
