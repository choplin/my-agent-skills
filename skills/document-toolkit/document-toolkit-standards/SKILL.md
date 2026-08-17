---
name: document-toolkit-standards
description: >-
  The technical-writing standards behind document quality, defined as reusable
  review lenses: plain expression, paragraph structure, terminology discipline,
  internal logic, and per-language notation and diction for Japanese and
  English. Apply while drafting or revising a technical document, chapter,
  article, README, design note, or explanatory prose, so the text meets the
  standard as written instead of being repaired afterwards.
user-invocable: false
metadata:
  description-role: trigger
---

# Document Standards

A catalog of writing standards expressed as **lenses**. A lens is a bounded
inspection procedure with one falsification objective: a fresh reader who knows
only that lens can judge a document against it and return findings.

The catalog has two consumers:

- **While writing.** Read the layers relevant to what is being drafted and
  follow them. A document written to these standards does not need the review
  workflow to reach a decent baseline.
- **While reviewing.** `document-toolkit-quality` selects lenses from this
  catalog, hands each to an independent agent, and applies the results.

The standards target one objective: **a reader should spend their attention on
the subject, not on parsing the text.** Every lens either removes something
that costs attention without adding information, or repairs something that
makes the text fail to hold together.

## Layers

Lenses are grouped into layers by what a fix touches. The layer determines the
order in which findings may be applied: a fix at an upper layer rewrites the
text that lower layers inspect, so applying bottom-up wastes work.

| Phase | Layer | Fix touches |
|---|---|---|
| 1 | **logic** | what the document asserts and how claims connect |
| 2 | **terminology** | which words name which concepts, and what they refer to |
| 3 | **structure** | paragraph and section boundaries, order, headings |
| 4 | **expression** + the language layer | sentences, wording, notation |
| 5 | **rhythm** (opt-in) | pacing; adds text rather than removing it |

Phase 5 runs last because `rhythm.cognitive-pacing` is the only lens that adds
text. Run it before phase 4 and the expression lenses delete what it just added.

## Lens index

| Lens ID | Layer | Packing group | Reference |
|---|---|---|---|
| `logic.claim-support` | logic | logic | [lenses-logic.md](references/lenses-logic.md) |
| `logic.epistemic-status` | logic | logic | [lenses-logic.md](references/lenses-logic.md) |
| `logic.internal-consistency` | logic | logic | [lenses-logic.md](references/lenses-logic.md) |
| `terminology.definition` | terminology | terminology | [lenses-terminology.md](references/lenses-terminology.md) |
| `terminology.consistency` | terminology | terminology | [lenses-terminology.md](references/lenses-terminology.md) |
| `reference.antecedent` | terminology | terminology | [lenses-terminology.md](references/lenses-terminology.md) |
| `structure.paragraph-unity` | structure | structure | [lenses-structure.md](references/lenses-structure.md) |
| `structure.signposting` | structure | structure | [lenses-structure.md](references/lenses-structure.md) |
| `structure.enumeration-landing` | structure | structure | [lenses-structure.md](references/lenses-structure.md) |
| `structure.document-shape` | structure | shape | [lenses-structure.md](references/lenses-structure.md) |
| `structure.genre-purity` | structure | shape | [lenses-structure.md](references/lenses-structure.md) |
| `prose.plain-expression` | expression | expression | [lenses-expression.md](references/lenses-expression.md) |
| `prose.self-reference` | expression | expression | [lenses-expression.md](references/lenses-expression.md) |
| `prose.concision` | expression | expression | [lenses-expression.md](references/lenses-expression.md) |
| `prose.sentence-load` | expression | expression | [lenses-expression.md](references/lenses-expression.md) |
| `prose.voice` | expression | expression | [lenses-expression.md](references/lenses-expression.md) |
| `ja.notation` | japanese | japanese | [lenses-japanese.md](references/lenses-japanese.md) |
| `ja.diction` | japanese | japanese | [lenses-japanese.md](references/lenses-japanese.md) |
| `en.mechanics` | english | english | [lenses-english.md](references/lenses-english.md) |
| `en.diction` | english | english | [lenses-english.md](references/lenses-english.md) |
| `rhythm.cognitive-pacing` | rhythm | rhythm | [lenses-rhythm.md](references/lenses-rhythm.md) |

## Language

The `logic`, `terminology`, `structure`, and `expression` layers are
language-neutral: every rule in them holds in any language. What differs by
language is which words instantiate a rule, so those lens files carry rules only
and the concrete forms live in example files keyed by lens ID —
[examples-ja.md](references/examples-ja.md) and
[examples-en.md](references/examples-en.md).

Exactly one language layer applies to a document, and it is selected by reading
the document rather than supplied by the caller:

| Document language | Language lenses | Example file |
|---|---|---|
| Japanese | `ja.notation`, `ja.diction` | `examples-ja.md` |
| English | `en.mechanics`, `en.diction` | `examples-en.md` |

For a document in another language, run the four neutral layers without a
language layer and without an example file, and report that no language layer
was available. Do not apply Japanese or English conventions to it.

For a document that mixes languages — English identifiers or quoted terms inside
Japanese prose is the common case — the language layer follows the prose, not
the quoted material. Code, identifiers, and quotations are out of scope for
`ja.*` and `en.*` alike.

`rhythm.cognitive-pacing` is never selected by default. It optimizes for
sustained reading momentum, which is an objective of narrative and long-form
explanatory writing, not of reference or procedural documentation. Enable it
explicitly.

## What this catalog does not cover

These lenses judge the document as a document. Whether what it says about its
subject is **true or well-founded** is outside every lens here. A document can
pass the whole catalog and still be wrong. Route subject-matter verification to
`document-toolkit-fact-check`, and claim falsification against acceptance
criteria to `artifact-review-toolkit-adversarial`.

## Finding schema

Every lens returns findings in this shape. `document-toolkit-quality` consumes
it, and its `apply` preset accepts it as input, so the fields are a contract
rather than a display format.

```yaml
id: <stable within one run>
lens: <lens ID from the index>
layer: logic | terminology | structure | expression | japanese | english | rhythm
severity: blocker | major | minor
location:
  anchor: <exact quoted text from the document, long enough to be unique>
  section: <nearest heading, or the document start>
claim: <what is wrong, in one sentence>
evidence: <why it violates the lens, citing the standard>
remediation: <the smallest edit that resolves it, concrete enough to apply>
content_impact: none | reordering | structural
```

Severity for these lenses:

- **blocker**: the reader cannot determine what the text means, or the document
  contradicts itself. Undefined term used before its introduction, a referent
  that cannot be resolved, two sections asserting opposite things.
- **major**: the reader can recover the meaning but pays for it. Buried topic
  sentence, missing connective between paragraphs, an assertion whose grounds
  are stated nowhere, speculation written as established fact.
- **minor**: local cost. A padded phrase, a notation slip, one needless proper
  noun.

`content_impact` records how far a fix reaches, and is what makes structural
edits reportable separately:

- `none` — the edit stays inside a sentence or a paragraph.
- `reordering` — the edit moves text without changing what is asserted.
- `structural` — the edit changes headings, section order, or the choice
  between prose and list. It touches decisions a writer may have made
  deliberately.

## Using the standards while writing

Do not read the whole catalog before writing. Read by layer:

- Drafting anything: **expression**, plus the language layer for the language
  being written, plus that language's example file.
- Drafting an argument, a design rationale, or an explanation: add **logic**
  and **terminology**.
- Structuring a document longer than a few sections: add **structure**.
- Writing a chapter, article, or narrative explanation meant to be read
  continuously: add **rhythm**.

Applying the standards while writing is cheaper than repairing afterwards,
because upper-layer defects force lower-layer text to be rewritten.
