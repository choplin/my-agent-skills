---
name: workflow-adapter-tracker
description: >-
  Routes Project, Milestone, Issue, relation, and transition reads or
  caller-specified mutations to an installed tracker provider. Internal entry
  point for provider-neutral workflow skills that access work records.
user-invocable: false
metadata:
  description-role: trigger
---

# Access work records

Accept a requested read or mutation, complete caller-owned fields for writes,
an existing locator or repository context when available, and any provider
coordination handle already held by the caller. Do not decide scope, split
work, add acceptance criteria, or promote lifecycle state.

Honor an explicit provider or an existing locator first. Otherwise select the
installed tracker provider for the repository. Delegate unchanged operations
to that provider's workflow adapter; this catalog currently ships
`octa-workflow-adapter`. Reject unsupported provider requests or locators
instead of translating them into another provider's records, and never switch
providers after a readiness or write failure.

Return the provider's durable locators and any unapplied operation; for reads,
return the requested records.
