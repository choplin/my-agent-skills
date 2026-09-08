# `graph.execution-strategy`

## Objective

Find unsupported assumptions in wave order, capability routing, retry,
integration, and assurance allocation.

## Required inputs

- candidate execution plan and dependency graph
- capability floors, reversibility, and assurance budget
- prior failure and retry evidence

## Checks

- Compare work placement with capability floors and reversibility.
- Find critical nodes receiving weaker assurance than low-risk leaves.
- Challenge retries that preserve the failed configuration.
- Identify useful work left idle without a real blocker.

## Non-goals

- Do not optimize for maximum parallelism alone.

## Severity guidance

Use major when the strategy creates a likely critical-path failure or knowingly
repeats an unresolved failure mode. Use minor for bounded assurance misallocation.
