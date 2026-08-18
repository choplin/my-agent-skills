# document-writing

Skills for the writing itself: the standards a technical document is held to,
and the lanes that inspect a document against them.

Distinct from `document-toolkit`, which operates on documents as objects —
verifying their claims, reworking a set, stripping what a set no longer needs —
and from `document-reader`, which judges a document from the reader's side.
These skills judge how a document reads and whether it holds together.

## Skills

| Skill | Description |
|-------|-------------|
| `standards` | The standards as 21 lenses across five layers, for Japanese and English. Read directly while drafting; also the catalog the lanes select from |
| `base` | The shared review machinery: blind per-lens detection, conflict resolution, layer-ordered application, one verification pass, the report format |
| `review` | Full-layer detection, findings applied, revised document. The default lane |
| `prose` | Sentence-level lenses only. Content and structure are not touched |
| `audit` | Full-layer detection, one reviewer per lens, findings only, no edits |
| `apply` | Applies findings a person already selected, re-verifying every anchor |

## When Skills Activate

- **standards**: activates while drafting or revising technical prose; not invoked directly
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

`audit` → a person keeps, drops, or edits the findings → `apply` is the lane for
keeping control of what changes.

## Layers and order

Lenses sit in five layers, and findings apply in that order: logic, terminology,
structure, expression with the language layer, then rhythm. An upper-layer fix
rewrites the text a lower layer would otherwise have polished, so applying
bottom-up wastes work. `rhythm` runs last as the only lens that adds text.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
