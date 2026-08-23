# `graph.dependency-integrity`

## Objective

Find missing, reversed, circular, stale, or non-causal dependency relations.

## Required inputs

- execution graph and dependency semantics
- node outcomes, contracts, and acceptance
- changes to downstream inputs

## Checks

- Verify every blocked edge represents a real required input.
- Search for implicit dependencies in requirements and changed contracts.
- Detect cycles and nodes unblocked before their inputs exist.
- Find hierarchy incorrectly used as execution order.

## Non-goals

- Do not add ordering solely for review convenience.

## Severity guidance

Use blocker for a dependency error that makes the execution graph impossible or
invalidates completed work. Use major for a material stale or missing relation.
