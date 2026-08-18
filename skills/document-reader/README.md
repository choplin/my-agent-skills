# document-reader

Skills for the question a document cannot answer about itself: **does this work
on the reader it was written for?**

Distinct from `document-writing`, which judges how a document reads and whether
it holds together, and from `document-toolkit`, which operates on documents as
objects — verifying claims, reworking a set. Those judge the document against
itself or against the world. These judge it from the reader's side, so the unit
of review is a reader with prior knowledge, not a lens over the text.

## Skills

| Skill | Description |
|-------|-------------|
| `review` | Selects readers, briefs them, dispatches them, assembles what came back. Findings only |
| `base` | The shared reader machinery: what a persona is given, the reading protocols, the verification pass and its freeze rules, the observation schema |
| `newcomer` | Meeting the subject for the first time. Sequential, no briefing, no tools |
| `skeptical-peer` | A colleague who is not convinced. Whole, heavy briefing, no tools |
| `implementer` | The person who has to build it. Sequential, checks the system afterwards |
| `decision-maker` | The person who approves or rejects. Whole, no tools |
| `domain-expert` | A practitioner who has done this before. Whole, checks afterwards |
| `revise` | Works the findings into the document, putting every content decision to the author |

## When Skills Activate

- **review**: "読者視点でレビューして", "this reads fine but is it convincing", "誰かに読ませたらどう思われるか", "poke holes in this document", "ツッコミどころを洗い出して"
- **revise**: "この指摘を反映して", "address the reader findings", "レビュー結果をもとに直して"
- The persona skills are loaded by the agents `review` dispatches, not invoked directly.

## One skill per persona

Each reader is its own skill so that a reader agent loads its own definition and
`base`, and cannot see any other reader's. A `newcomer` that has read the
skeptical peer's brief starts hunting for unanswered objections and stops being
a newcomer.

Tool grants carry the same isolation into capability: `newcomer`,
`skeptical-peer`, and `decision-maker` are granted no tools at all, so the rule
against looking things up mid-read is enforced rather than instructed.

## Reading conditions

Personas responsible for comprehension read **sequentially**, one unit at a time
with no way to look ahead, and their per-unit record is never revised in
hindsight. A stumble whose answer appears three sections later is a real defect,
and a reviewer holding the whole document will never report it.

A reader is not a blank slate, but cannot look things up mid-read. Knowledge is
granted **before** reading: domain knowledge from the persona, project knowledge
from a context briefing the caller supplies. The briefing may hold only what
existed before the document was written and the intended reader already knew —
anything more lets a persona fill the gap the document left.

The author's intent is never given to a persona. `review` holds it and compares
it against what each reader took away.

## Checking, and its limit

`implementer` and `domain-expert` may check sources — **after** the read is
closed, and only on statements they already doubted. Their doubts, stumbles, and
takeaway model are frozen before any source opens, so verification cannot repair
the read: a stumble cleared by going and reading the code is still a stumble.

A claim nobody doubted is never checked, and a clean reader review is not
evidence that a document is accurate. Working through every claim against sources
is `document-toolkit-fact-check`.

## Findings and repair are separate

A reader finding is closed by adding something the document does not contain: a
missing premise, an unanswered objection, an undisclosed cost. That is a decision
about what the document asserts, and it belongs to the author — so `review`
proposes no wording at all, and `revise` asks rather than drafts.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
