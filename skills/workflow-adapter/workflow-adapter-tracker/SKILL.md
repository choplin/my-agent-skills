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

Honor an explicit provider or an existing locator first. Otherwise select a
provider from repository instructions and installed tracker adapters. If more
than one remains plausible and the choice would create durable state in
different places, ask one focused destination question.

Delegate the operation unchanged to the selected provider adapter. Reject an
unsupported provider request or locator instead of translating it into another
provider's records, and never switch providers after a readiness or write
failure.

Return the provider's durable locators and any unapplied operation; for reads,
return the requested records.
