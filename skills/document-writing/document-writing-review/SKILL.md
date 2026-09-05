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
lenses: all applicable layers; rhythm selected from reading behavior
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
- The caller needs a different rhythm choice from the one implied by reading
  behavior — stay here and override `rhythm.cognitive-pacing` explicitly.

## What this lane does not decide

It does not judge whether the document is right about its subject, or whether it
works on the reader it was written for. A document can leave this lane clean and
still be wrong, and it can be clean and correct and still fail to convince
anyone. Route subject-matter verification to `document-toolkit-fact-check`, and
whether readers follow, believe, and can act on it to `document-reader-review`.

It applies structural findings, which may rename headings, reorder sections, or
change representation among prose, lists, tables, diagrams, and code. These
override choices the writer may have made deliberately, so they are reported
individually under `structural_changes` rather than folded into the revision
summary.
