# `code.functional-correctness`

## Objective

Find functional defects introduced or materially worsened by the code change.

## Required inputs

- the diff and intended behavior
- applicable repository instructions and contracts
- surrounding callers, consumers, and tests needed to trace changed behavior

## Checks

- Trace changed data flow, control flow, state transitions, and error propagation.
- Exercise boundary values, invalid inputs, partial failures, fallback paths, and
  compatibility behavior.
- Compare changed assumptions with actual callers and downstream consumers.
- Identify tests that pass without exercising the changed behavior or its failure
  mode.
- For every candidate, name the exact input, state, environment, or call path that
  produces the wrong result.

## Non-goals

- Do not report unrelated pre-existing defects.
- Do not infer a bug solely because implementation differs from preference.
- Do not require exhaustive tests when a smaller check proves the behavior.

## Severity guidance

Use blocker when the principal intended behavior demonstrably fails. Use major
for material incorrect behavior on a supported path and minor for a bounded edge
case with limited exposure.
