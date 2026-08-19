---
name: linear-workflow-adapter
description: >-
  Applies caller-specified work-record operations in Linear. Internal provider
  implementation selected by workflow-adapter-tracker for repositories using
  Linear.
user-invocable: false
metadata:
  description-role: documentation
---

# Write work records to Linear

Apply the requested operations through the wired Linear MCP. Use `linear-base`
for repository resolution and provider rules.

Preserve supplied names, bodies, placement, relations, type, priority, and
lifecycle intent. Read before updates so unspecified fields and labels survive;
do not groom or complete missing content. Re-read mutations and return the
Linear locator plus any requested field or operation that was not applied.
