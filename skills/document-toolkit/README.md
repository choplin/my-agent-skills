# document-toolkit

Skills for operating on documents as objects: verifying what one claims, and
keeping a whole set of them high-signal.

How a document reads and whether it holds together is `document-writing`.
Whether it works on the reader it was written for is `document-reader`.

## Skills

| Skill | Description |
|-------|-------------|
| `fact-check` | Fact-check technical documents for accuracy |
| `distill` | Rework an existing set of documents: consolidate overlaps, refresh stale ones, split oversized ones, retire what no longer earns reach |
| `trim` | Strip still-correct but no-longer-needed content out of a set, under a keep-or-drop policy the set's owner sets per content axis |

## When Skills Activate

- **fact-check**: "fact-check this", "verify this document", "check accuracy"
- **distill**: "distill these docs", "consolidate these notes", "these documents overlap", "tidy up this doc set", "ドキュメントを整理して"
- **trim**: "trim these docs", "strip the parts we no longer need", "these docs carry too much history", "ドキュメントを削ぎ落として"

`fact-check` works on a single document. `distill` and `trim` both work on a
set, and split by what they change: `distill` changes which documents exist and
corrects what has become wrong, while `trim` leaves every document in place and
removes content that is still correct but no longer needed — a call `trim` puts
to the set's owner rather than making itself.

None of the three judges the writing, and none judges the effect on a reader. A
document can pass `fact-check` and still be unreadable — that is
`document-writing-review`'s work — and it can be accurate and readable and still
leave its audience unconvinced, which is `document-reader-review`'s.

`fact-check` and `document-reader-review` both look at what the document says,
and split on what makes a finding survive. `fact-check` reports a claim as
INCORRECT only if it is false, and works through the claims systematically. A
reader review reports a claim as doubted whether or not it is true, and only
where a reader happened to doubt it — a correct document nobody believes is a
defect it catches and `fact-check` cannot.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
