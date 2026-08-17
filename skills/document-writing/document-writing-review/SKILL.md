---
name: document-writing-review
description: >-
  Raises a document to a sound technical-writing baseline in one pass, running
  independent per-lens reviewers across every layer and applying their findings
  in dependency order. Targets how the document reads and holds together —
  plain expression, paragraph structure, defined terms, resolvable references,
  internal logic — not whether its subject matter is correct. Applies when
  prose is hard to follow, argues loosely, or reads as machine-written, and
  when a draft needs to be brought to a publishable standard.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: trigger
---

# Document Review

The default lane. Full-layer detection, findings applied, revised document
returned.

Apply `document-writing-base` for the whole procedure. This skill supplies only
the lane values.

```yaml
lenses: all layers except rhythm
deliverable: revised-document
reviewers: per-packing-group
verify: true
```

## Why this lane spends where it does

Detection runs one reviewer per packing group rather than per lens, because the
result is a revised document rather than a list a person reads. When findings
are applied automatically, a consistent application matters more than an
exhaustive detection: a lens that misses one instance of padding costs little,
while two reviewers editing the same paragraph from different angles costs
coherence.

Where the caller wants maximum detection instead, that is
`document-writing-audit`.

## Choosing another lane

- The document's content and structure must not move, only its sentences —
  `document-writing-prose`.
- Nothing should be changed automatically; the caller will read every finding —
  `document-writing-audit`.
- Findings already exist and were selected by a person —
  `document-writing-apply`.
- The document is meant to be read continuously and its pacing matters — stay
  here and ask for `rhythm.cognitive-pacing` explicitly.

## What this lane does not decide

It does not judge whether the document is right about its subject. A document
can leave this lane clean and still be wrong; route that to
`document-toolkit-fact-check`.

It applies `structure.document-shape` findings, which rename headings, reorder
sections, and convert between prose and lists. These override choices the writer
may have made deliberately, so they are reported individually under
`structural_changes` rather than folded into the revision summary.
