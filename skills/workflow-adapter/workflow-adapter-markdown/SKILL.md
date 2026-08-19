---
name: workflow-adapter-markdown
description: >-
  Writes completed, caller-owned Markdown to llm-wiki without redesigning its
  content. Internal entry point for workflow skills that need to create or
  update a durable Markdown note.
user-invocable: false
metadata:
  description-role: trigger
---

# Write Markdown

Accept `create` with a title and complete body, or `update` with a note locator
and a complete replacement or explicit patch. Accept destination context and
provider metadata only when the caller already has them.

Use `llm-wiki-base` for readiness and scope, `llm-wiki-retrieve` to locate an
existing note, and `llm-wiki-capture` for write mechanics. Derive scope from an
explicit destination, an existing locator, or the current Git repository; ask
only when scope remains ambiguous.

Treat the Markdown body as opaque. Do not add sections, merge ideas, or change
claims. Apply only provider-owned filename and frontmatter mechanics, then
return the note locator. Stop and report a missing provider, ambiguous match,
collision, or failed write instead of choosing another destination.
