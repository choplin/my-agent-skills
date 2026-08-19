---
name: workflow-adapter-tracker
description: >-
  Routes Project, Milestone, Issue, relation, and transition reads or
  caller-specified mutations to Linear or octa. Internal entry point for
  provider-neutral workflow skills that access work records.
user-invocable: false
metadata:
  description-role: trigger
---

# Access work records

Accept a requested read or mutation, complete caller-owned fields for writes,
an existing locator or repository context when available, and any provider
coordination handle already held by the caller. Do not decide scope, split
work, add acceptance criteria, or promote lifecycle state.

Honor an explicit provider request first. Otherwise use octa for an octa
locator or when `octa-imported-from-linear` exists in the repository's absolute
Git common directory; use Linear when it does not. With the marker present,
treat a Linear locator as import provenance and resolve its octa record rather
than writing back to Linear. Never switch providers after a readiness or write
failure.

Delegate unchanged operations to `linear-workflow-adapter` or
`octa-workflow-adapter`. Return their durable locators and any unapplied
operation; for reads, return the requested records.
