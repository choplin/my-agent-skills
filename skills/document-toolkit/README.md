# document-toolkit

Skills for working on documents: reviewing one, verifying its claims, and
keeping a whole set of them high-signal.

## Skills

| Skill | Description |
|-------|-------------|
| `standards` | The technical-writing standards, defined as reusable lenses across five layers, for Japanese and English. Read while writing; also the catalog `quality` selects from |
| `quality` | Raise a document to a sound baseline in one pass: independent per-lens reviewers, then findings applied in layer order |
| `review` | Review or revise a document across two axes: stance (critical / objective) × deliverable (review / revise) |
| `fact-check` | Fact-check technical documents for accuracy |
| `distill` | Rework an existing set of documents: consolidate overlaps, refresh stale ones, split oversized ones, retire what no longer earns reach |
| `trim` | Strip still-correct but no-longer-needed content out of a set, under a keep-or-drop policy the set's owner sets per content axis |

## When Skills Activate

- **standards**: activates while drafting or revising technical prose; not invoked directly
- **quality**: "この文書をまともにして", "clean up this draft", "this reads like it was written by an AI", "make this publishable", "audit this document", "文章の品質を上げて"
- **review**: "review this", "critique this", "find problems", "review objectively", "how does this read", "revise this", "improve this writing", "make this clearer"
- **fact-check**: "fact-check this", "verify this document", "check accuracy"
- **distill**: "distill these docs", "consolidate these notes", "these documents overlap", "tidy up this doc set", "ドキュメントを整理して"
- **trim**: "trim these docs", "strip the parts we no longer need", "these docs carry too much history", "ドキュメントを削ぎ落として"

`standards` is the substrate: it defines the lenses and is read directly while
writing, so a draft can meet the standard without a review pass. `quality` runs
those lenses as a workflow — independent reviewers per lens, findings applied in
dependency order (logic → terminology → structure → expression → rhythm), one
verification pass, then a report that separates structural changes from the rest.
`review` stays the light option: one pass, one stance, no lens machinery.

`quality`, `review`, and `fact-check` work on a single document. `distill` and `trim` both
work on a set, and split by what they change: `distill` changes which documents
exist and corrects what has become wrong, while `trim` leaves every document in
place and removes content that is still correct but no longer needed — a call
`trim` puts to the set's owner rather than making itself.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
