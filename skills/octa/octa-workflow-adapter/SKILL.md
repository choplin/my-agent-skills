---
name: octa-workflow-adapter
description: >-
  Applies caller-specified work-record operations through octa. Internal
  provider implementation selected by workflow-adapter-tracker for repositories
  using octa.
user-invocable: false
metadata:
  description-role: documentation
---

# Write work records through octa

Apply the requested operations through the repository-local `octa` CLI. Use
`octa-base` and its referenced CLI and workflow-configuration contracts for
provider rules, including Issue leases.

Preserve supplied names, bodies, placement, relations, type, and lifecycle
intent; do not groom or complete missing content. Report priority as unapplied
because octa does not store it. Re-read mutations and return repository identity
and record numbers plus any requested operation that was not applied.
