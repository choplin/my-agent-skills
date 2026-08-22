---
name: workflow-adapter-markdown
description: >-
  Routes destination resolution, find, read, create, and update operations for
  caller-owned Markdown to an installed durable Markdown provider. Internal
  entry point for provider-neutral workflows that access durable notes.
user-invocable: false
metadata:
  description-role: trigger
---

# Access durable Markdown

Accept one of these caller-owned operations:

- `resolve` with current concern or an explicit destination hint;
- `find` with a title, keywords, or an existing locator;
- `read` with a locator;
- `create` with a title, complete body, and caller-owned metadata;
- `update` with a locator, complete replacement or explicit patch, and any
  caller-owned metadata changes.

Accept provider metadata only when the caller already has it. Honor an explicit
provider or an existing locator first. Otherwise select a provider from
repository instructions and installed durable Markdown adapters. If more than
one remains plausible and the choice would access different stores, ask one
focused destination question.

Delegate the operation unchanged to the selected provider adapter. Never switch
providers after a readiness or write failure.

Treat the Markdown body as opaque. Do not add sections, merge ideas, or change
claims. Let the provider adapter map only storage-owned paths, filenames,
frontmatter, links, indexes, and equivalent mechanics. Return the provider
identity, durable locator, requested stored Markdown for reads, and any
unapplied operation. Stop and report a missing provider, ambiguous match,
collision, or failed operation instead of choosing another destination.
