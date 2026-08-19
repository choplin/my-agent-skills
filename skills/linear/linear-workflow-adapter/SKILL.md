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

# Access work records in Linear

Apply the requested operations through the wired Linear MCP. Use `linear-base`
for repository resolution and provider rules.

Return requested records for reads. Preserve supplied names, bodies, placement,
relations, type, priority, and lifecycle intent. Read before updates so
unspecified fields and labels survive; do not groom or complete missing
content. Re-read mutations and return the
Linear locator plus any requested field or operation that was not applied.
