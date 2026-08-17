---
name: document-writing-prose
description: >-
  Rewrites a document's sentences to a plain, low-effort standard without
  touching its content or its structure: removes rhetoric that carries no
  information, sentences about the document rather than its subject, padding,
  and notation slips. Applies when the argument and the section layout are
  settled and only the wording is at fault, or when a caller asks for the
  writing to be cleaned up without anything being reorganized.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
metadata:
  description-role: trigger
---

# Document Prose

The narrow lane. Sentence-level lenses only, findings applied, revised document
returned.

Apply `document-writing-base` for the whole procedure. This skill supplies only
the lane values.

```yaml
lenses: prose.* and the language layer (ja.* or en.*)
deliverable: revised-document
reviewers: single       # two where the document is long
verify: true
```

## The boundary this lane holds

Every finding here is `content_impact: none`. Paragraphs are not merged or
split, sections are not reordered, headings are not renamed, and no claim is
restated. If the argument is unsound or the sections are in the wrong order,
this lane leaves it that way and says so.

That boundary is the point. A caller reaches for this lane when the document's
substance is settled — an agreed design, a reviewed decision, a published
structure — and reorganizing it would be a regression, not an improvement.

## What it removes

The lenses are `prose.plain-expression`, `prose.self-reference`,
`prose.concision`, `prose.sentence-load`, and `prose.voice`, plus the notation
and diction lenses for the document's language. Together they cover the failures
that make machine-written prose expensive to read: empty qualifiers, verbs that
name the act of writing, sentences whose subject is the document, restatement,
identifiers that are never referenced again, and the passive where an actor
acted.

## Reporting what it left alone

Where a sentence cannot be fixed without moving text — a paragraph carrying two
topics, a term that needs its introduction relocated — report it as unresolved
with the lens that would own it, rather than reaching outside the lane.

A caller who wants those fixed should use `document-writing-review`.
