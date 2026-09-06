# Durable editorial artifacts

Persist intermediate artifacts when the work spans sessions, agents, or a
substantial document. The artifacts are the handoff contract; conversation
history is not.

## Storage

When the user or repository names a working location, use it. Otherwise, for a
file-backed document, create a sibling directory named `<document>.writing/`.
For supplied text with no durable destination, keep artifacts in the response
unless persistence would clearly help and an in-scope workspace is available.

Use one directory per artifact kind and immutable, zero-padded revisions:

```text
guide.md.writing/
  brief/001.md
  discovery/001.md
  focus/001.md
  content-model/001.md
  plot/001.md
  plot/002.md
  reverse-outline/001.md
  draft/001.md
  draft/002.md
  acceptance/001.md
```

Omit inapplicable kinds. Do not create `state.yaml` or `history.jsonl`. The
revision files are the history.

## Revision header

Begin each artifact with minimal YAML frontmatter:

```yaml
---
artifact: plot
revision: 2
supersedes: plot/001.md
based_on:
  - path: focus/002.md
    digest: sha256:<digest of that exact file>
  - path: content-model/001.md
    digest: sha256:<digest of that exact file>
---
```

The body is free-form Markdown. End with a short `Revision note` describing
what changed and why. Do not add empty metadata merely to satisfy a schema.

Past revisions are immutable. To change one, write the next numbered revision
and point `supersedes` at the prior revision. The first revision omits
`supersedes`. Paths are relative to the artifact root unless the source is
external.

## Detecting upstream changes

Before using an artifact:

1. Resolve each `based_on.path`.
2. Compute the SHA-256 digest of the whole referenced file.
3. Compare it with the recorded digest.
4. Check whether a newer revision now supersedes the referenced revision.
5. If either check differs, inspect the actual change and create a new
   downstream revision that records the reviewed upstream revision.

An upstream change does not automatically invalidate every word downstream.
It requires review. Even when no body text changes, create a new revision if it
is important to record that the newer premise was considered.

The latest usable artifact is a revision not superseded by another revision in
the same lineage. Branches are allowed; do not silently choose between two
heads when they embody materially different decisions.

A generated status page or index may be used for convenience only if it can be
rebuilt from these files. It is never authoritative state.

## Handoff packet

Pass the exact latest relevant artifacts, not a summary from memory. A drafting
or editorial reviewer normally needs:

- assignment or brief;
- focus;
- content model;
- plot;
- source locations or discovery notes;
- current draft;
- known deviations and unresolved decisions.

A copyeditor may receive a narrower packet, but must still know the audience,
document kind, house style, protected terminology, and intervention boundary.
