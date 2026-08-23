# `graph.parallel-safety`

## Objective

Falsify the claim that a proposed execution wave can run independently and
integrate without invalidating concurrent work.

## Required inputs

- proposed wave and predicted files, contracts, resources, and environments
- worktree or isolation model
- integration and migration order

## Checks

- Compare predicted files, contracts, and resources.
- Identify shared state that worktrees or process isolation do not isolate.
- Check integration and migration ordering.
- Find tests whose concurrent execution is unsafe.

## Non-goals

- Do not serialize work merely because it is in one repository.

## Severity guidance

Use blocker when concurrent execution can corrupt shared state or invalidate both
outputs. Use major when rework or integration failure is likely.
