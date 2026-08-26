# document-writing

Use this family both while writing new technical prose and while improving an
existing document. `standards` supplies the rules used during drafting. The
other skills inspect an existing document, revise it, or apply findings that
have already been selected.

Distinct from `document-toolkit`, which operates on documents as objects —
verifying their claims, reworking a set, stripping what a set no longer needs —
and from `document-reader`, which judges a document from the reader's side.
These skills judge how a document reads and whether it holds together.

## Choose by task

| Task | Skill | Result |
|------|-------|--------|
| Write new prose or continue a draft | `standards` | The relevant writing rules are applied as the text is composed |
| Improve an existing draft throughout | `review` | A revised document, including content-preserving structural changes |
| Fix wording without changing content or structure | `prose` | A sentence-level revision |
| Inspect a document without changing it | `audit` | Located findings for a person to review |
| Apply findings a person has already selected | `apply` | A revised document containing only the selected changes, plus verification repairs |

Do not select `base` directly. It is the shared machinery used by the four
review lanes.

## Writing new prose

`standards` is the writing-time entry point. It applies when a task creates or
continues technical prose, including a chapter, article, README, design note,
or explanation. The task and its source material determine what the document
says; `standards` determines how to express and organize it.

Load only the layers the draft needs:

- For any draft, use the expression layer, the document's language layer, and
  that language's examples.
- For an argument, design rationale, or explanation, add logic and terminology.
- For a document longer than a few sections, add structure.
- For a chapter, article, or narrative explanation meant to be read
  continuously, add rhythm.

`standards` is not a user-invoked review lane. It activates as part of the
writing task so that the first draft follows the rules instead of relying on a
later repair pass.

## Working with an existing document

Choose a review lane according to how much authority it should have:

- Use `review` when the whole document may be improved. It can rename headings,
  reorder sections, and convert between prose and lists while preserving the
  document's claims.
- Use `prose` when the document's content and structure are settled. It changes
  sentences only.
- Use `audit` when a person must approve every change. It returns findings and
  does not edit the document.
- Use `apply` after that approval. It applies the surviving findings in
  dependency order and rejects findings whose anchors are stale.

The controlled workflow is `audit` → a person keeps, drops, or edits the
findings → `apply`.

## Skills

| Skill | Description |
|-------|-------------|
| `standards` | The standards as 22 lenses across five layers, for Japanese and English. Read directly while drafting; also the catalog the lanes select from |
| `base` | The shared review machinery: blind per-lens detection, conflict resolution, layer-ordered application, one verification pass, the report format |
| `review` | Full-layer detection, findings applied, revised document. The default lane |
| `prose` | Sentence-level lenses only. Content and structure are not touched |
| `audit` | Full-layer detection, one reviewer per lens, findings only, no edits |
| `apply` | Applies findings a person already selected, re-verifying every anchor |

## When Skills Activate

- **standards**: "write a design note", "draft this README", "turn these notes into an explanation", "この内容から記事を書いて"
- **review**: "この文書をまともにして", "clean up this draft", "this reads like it was written by an AI", "make this publishable", "文章の品質を上げて"
- **prose**: "fix the wording only", "don't restructure it, just the sentences", "文章だけ直して"
- **audit**: "tell me what's wrong with this document", "review it but don't change it", "指摘だけして"
- **apply**: "apply these findings", "この指摘を反映して"

## How the lanes differ

Four axes: which lenses run, whether a revised document or findings comes back,
how many reviewers, and whether the verification pass runs. Each lane fixes
those four values and delegates everything else to `base`.

`review` and `audit` make opposite trades on the same lens set. `review` runs
one reviewer per packing group, because a revised document needs application to
be coherent more than it needs detection to be exhaustive. `audit` runs one per
lens, because nothing is applied and a missed defect survives.

## Layers and order

Lenses sit in five layers, and findings apply in that order: logic, terminology,
structure, expression with the language layer, then rhythm. An upper-layer fix
rewrites the text a lower layer would otherwise have polished, so applying
bottom-up wastes work. `rhythm` runs last as the only lens that adds text.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
