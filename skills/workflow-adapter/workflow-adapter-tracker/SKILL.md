---
name: workflow-adapter-tracker
description: >-
  Routes completed Project, Milestone, Issue, relation, and transition
  operations to Linear or octa. Internal entry point for provider-neutral
  workflow skills that need to persist work records.
user-invocable: false
metadata:
  description-role: trigger
---

# Write work records

Accept the requested operations, complete caller-owned record fields, and an
existing locator or repository context when available. Do not decide scope,
split work, add acceptance criteria, or promote lifecycle state.

Honor an explicit provider request first. Otherwise use octa for an octa
locator or when `octa-imported-from-linear` exists in the repository's absolute
Git common directory; use Linear when it does not. With the marker present,
treat a Linear locator as import provenance and resolve its octa record rather
than writing back to Linear. Never switch providers after a readiness or write
failure.

Delegate unchanged operations to `linear-workflow-adapter` or
`octa-workflow-adapter`. Return their durable locators and any unapplied
operation.
