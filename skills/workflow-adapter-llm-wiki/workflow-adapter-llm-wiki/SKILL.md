---
name: workflow-adapter-llm-wiki
description: >-
  Implements workflow-adapter-markdown operations through the configured
  llm-wiki knowledge base. Use as the provider adapter when a caller selects
  llm-wiki, supplies an llm-wiki locator, or repository instructions designate
  llm-wiki as the durable Markdown store.
---

# Access durable Markdown through llm-wiki

Accept one complete operation from `workflow-adapter-markdown`. Preserve the
caller's Markdown body and semantic metadata. Own only llm-wiki scope, paths,
slugs, frontmatter mechanics, indexing, and readback verification.

Apply `llm-wiki-base` before every operation. Require `llm-wiki-retrieve` for
find and read, and use `llm-wiki-capture` mechanics for create. If a required
skill, `zk`, or the initialized notebook is unavailable, report the readiness
failure and stop. Never initialize llm-wiki or choose another provider.

## Apply operations

- **Resolve:** derive the concern from an explicit destination hint or the
  shared Git directory according to `llm-wiki-base`. Outside Git, return the
  unresolved scope unless the caller already confirmed it.
- **Find:** use `llm-wiki-retrieve` to return matching scope-relative paths and
  slugs. Do not merge candidates or select an update target by similarity.
- **Read:** retrieve the identified note and return its exact stored Markdown
  with its scope-relative path and slug.
- **Create:** require a title, complete body, and at least one caller-supplied
  topical tag. Resolve the slug and search for both topic matches and a path
  collision before writing. Return collisions unless the caller explicitly
  requested create-alongside or update. Create the note without adding,
  deleting, or rewriting body content.
- **Update:** require one exact locator and either a complete replacement or an
  explicit patch. Preserve provider-owned frontmatter not named by the caller,
  apply requested metadata changes, and update llm-wiki's edit timestamp. Do
  not rename the file unless the operation explicitly requests a new slug.

Treat related-note hints as provider metadata, but never insert a wikilink into
the caller's body unless that exact body change is part of the requested patch.
Do not invoke distill, consolidate notes, archive notes, or extend an existing
note in response to a create collision.

After create or update, reindex and read the note back. Compare the caller-owned
body and requested metadata exactly. Return `llm-wiki` as the provider, the
scope-relative path and slug, the requested stored Markdown for reads, and any
unapplied operation or mismatch. A path printed by `zk new` is not proof of a
successful create until the readback matches.
