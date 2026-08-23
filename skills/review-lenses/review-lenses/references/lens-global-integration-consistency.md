# `global.integration-consistency`

## Objective

Falsify the claim that independently completed outputs form one coherent,
working result.

## Required inputs

- final execution graph and dependency outcomes
- integrated artifacts and integration checks
- issue-level decisions and prior findings

## Checks

- Compare contracts and assumptions across issue boundaries.
- Reproduce the critical end-to-end path.
- Find missing integration work hidden by individually completed issues.
- Check that later work consumed the actual completed blocker outcomes.
- Identify stale generated artifacts, schemas, or documentation.

## Non-goals

- Do not relitigate a binding design solely from preference.

## Severity guidance

A broken critical path or incompatible cross-issue contract is blocker. A
material but non-critical integration failure is major.
