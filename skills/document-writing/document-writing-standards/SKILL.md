---
name: document-writing-standards
description: >-
  Reusable review lenses that define common technical-document invariants and
  natural Japanese or English prose. Apply them while drafting or revising a
  technical document or explanatory passage.
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
- **While reviewing.** The review lanes — `document-writing-review`, `-prose`,
  `-audit`, `-apply` — select lenses from this catalog through
  `document-writing-base`, hand each to an independent agent, and apply the
  results.

The standards target one objective: **a reader should spend their attention on
the subject, not on parsing the text.** Every lens either removes something
that costs attention without adding information, or repairs something that
makes the text fail to hold together.

Lenses judge an observable defect, not the likely origin of the prose. A form
that occurs often in machine-generated or translated text is not a finding
unless the lens can show the attention cost or loss of meaning in this
occurrence. Correlation may identify a place to inspect; it is never evidence
by itself.

## Layers

Every lens has two independent dimensions. Its directory or `language` field
selects the language profile; its `layer` determines what a fix touches and the
order in which findings may be applied. Japanese and English lenses do not form
one late phase: an omitted argument is repaired before proposition structure,
and proposition structure before sentence cadence.

| Phase | Layer | Fix touches |
|---|---|---|
| 1 | **logic** | what the document asserts and how claims connect |
| 2 | **terminology** | which words name which concepts, and what they refer to |
| 3 | **structure** | sentences, paragraphs, sections, order, and representation |
| 4 | **expression** | sentence boundaries, wording, voice, notation |
| 5 | **rhythm** (selected by reading behavior) | document pacing and language cadence |

Phase 5 runs last because pacing work may add a grounded opening, turn, or
landing. Run it before phase 4 and expression fixes may delete what it added.

## Lens index

| Lens ID | Language | Layer | Reference |
|---|---|---|---|
| `logic.claim-support` | common | logic | [logic.md](references/common/logic.md) |
| `logic.epistemic-status` | common | logic | [logic.md](references/common/logic.md) |
| `logic.internal-consistency` | common | logic | [logic.md](references/common/logic.md) |
| `terminology.definition` | common | terminology | [terminology.md](references/common/terminology.md) |
| `terminology.consistency` | common | terminology | [terminology.md](references/common/terminology.md) |
| `reference.antecedent` | common | terminology | [terminology.md](references/common/terminology.md) |
| `reference.discourse-grounding` | common | terminology | [terminology.md](references/common/terminology.md) |
| `structure.paragraph-unity` | common | structure | [structure.md](references/common/structure.md) |
| `structure.signposting` | common | structure | [structure.md](references/common/structure.md) |
| `structure.sentence-cohesion` | common | structure | [structure.md](references/common/structure.md) |
| `structure.enumeration-landing` | common | structure | [structure.md](references/common/structure.md) |
| `structure.document-shape` | common | structure | [structure.md](references/common/structure.md) |
| `structure.representation-choice` | common | structure | [structure.md](references/common/structure.md) |
| `structure.genre-purity` | common | structure | [structure.md](references/common/structure.md) |
| `prose.plain-expression` | common | expression | [expression.md](references/common/expression.md) |
| `prose.self-reference` | common | expression | [expression.md](references/common/expression.md) |
| `prose.concision` | common | expression | [expression.md](references/common/expression.md) |
| `prose.sentence-load` | common | expression | [expression.md](references/common/expression.md) |
| `prose.voice` | common | expression | [expression.md](references/common/expression.md) |
| `rhythm.cognitive-pacing` | common | rhythm | [rhythm.md](references/common/rhythm.md) |
| `ja.argument-recovery` | ja | terminology | [composition.md](references/ja/composition.md) |
| `ja.topic-continuity` | ja | structure | [composition.md](references/ja/composition.md) |
| `ja.proposition-realization` | ja | structure | [composition.md](references/ja/composition.md) |
| `ja.connective-calibration` | ja | structure | [composition.md](references/ja/composition.md) |
| `ja.proposition-integrity` | ja | structure | [conventions.md](references/ja/conventions.md) |
| `ja.sentence-boundaries` | ja | expression | [composition.md](references/ja/composition.md) |
| `ja.notation` | ja | expression | [conventions.md](references/ja/conventions.md) |
| `ja.syntax` | ja | expression | [conventions.md](references/ja/conventions.md) |
| `ja.diction` | ja | expression | [conventions.md](references/ja/conventions.md) |
| `ja.cadence` | ja | rhythm | [rhythm.md](references/ja/rhythm.md) |
| `en.argument-explicitness` | en | terminology | [composition.md](references/en/composition.md) |
| `en.information-order` | en | structure | [composition.md](references/en/composition.md) |
| `en.clause-linkage` | en | structure | [composition.md](references/en/composition.md) |
| `en.sentence-boundaries` | en | expression | [composition.md](references/en/composition.md) |
| `en.voice` | en | expression | [composition.md](references/en/composition.md) |
| `en.mechanics` | en | expression | [conventions.md](references/en/conventions.md) |
| `en.diction` | en | expression | [conventions.md](references/en/conventions.md) |
| `en.cadence` | en | rhythm | [rhythm.md](references/en/rhythm.md) |

## Language profiles

Select every applicable common lens, then exactly one language profile by
reading the prose:

| Prose language | Profile files | Examples |
|---|---|---|
| Japanese | [composition](references/ja/composition.md), [conventions](references/ja/conventions.md), [rhythm](references/ja/rhythm.md) | [examples](references/ja/examples.md) |
| English | [composition](references/en/composition.md), [conventions](references/en/conventions.md), [rhythm](references/en/rhythm.md) | [examples](references/en/examples.md) |

Common lenses state only invariants that survive translation. Language profiles
own what may be omitted, how propositions are ranked and linked, where governing
material appears, how sentence boundaries work, and what cadence is natural.
Examples illustrate those rules; they never create a rule absent from a lens.

For another language, run common lenses alone and report that no natural-language
profile was available. Do not substitute Japanese or English composition rules.

For a document that mixes languages — English identifiers or quoted terms inside
Japanese prose is the common case — the language profile follows the prose, not
the quoted material. Code, identifiers, and quotations are out of scope for
`ja.*` and `en.*` alike.

Select `rhythm.cognitive-pacing` from actual reading behavior. Include it for
continuously read material, omit it for lookup material, and scope it to the
continuous passages in a mixed document. A file-type label such as README or
design note does not decide.

## What this catalog does not cover

These lenses judge the document as a document. Whether what it says about its
subject is **true or well-founded** is outside every lens here. A document can
pass the whole catalog and still be wrong. Whether it **lands on the reader it
was written for** is outside them too: a document can be clear, consistent, and
correct, and still leave its audience unconvinced or unable to act. Route
subject-matter verification to `document-toolkit-fact-check`, reader effect to
`document-reader-review`, and rigorous pre-acceptance artifact review to
`artifact-review`.

## Finding schema

Every lens returns findings in this shape. `document-writing-base` produces it,
and `document-writing-apply` accepts it as input, so the fields are a contract
rather than a display format.

```yaml
id: <stable within one run>
lens: <lens ID from the index>
also_raised_by: []       # other lens IDs that found the same cause
language: common | ja | en
layer: logic | terminology | structure | expression | rhythm
severity: blocker | major | minor
location:
  anchor: <exact quoted text from the document, long enough to be unique>
  section: <nearest heading, or the document start>
claim: <what is wrong, in one sentence>
evidence: <why it violates the lens, citing the standard>
remediation: <the smallest edit that resolves it, concrete enough to apply>
content_impact: none | reordering | structural
```

`lens` is the lens that owns the remediation after conflict resolution.
`also_raised_by` preserves other selected lenses that independently located the
same cause; do not encode an array in `lens` or duplicate the finding.

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
- `structural` — the edit changes headings, section order, or representation
  among prose, list, table, diagram, and code. It touches decisions a writer may
  have made deliberately.

## Using the standards while writing

Do not read the whole catalog before writing. Read by layer:

- Drafting anything: `reference.discourse-grounding`, applicable common
  **expression**, the matching language profile's **terminology**,
  **structure**, and **expression** lenses, and that language's example file.
  Omission, information order, clause linkage, and sentence boundaries remain
  relevant in short prose.
- Drafting an argument, a design rationale, or an explanation: add common
  **logic**, **terminology**, and applicable **structure** lenses.
- Choosing how to present relationship-bearing material: add
  `structure.representation-choice`.
- Structuring a document longer than a few sections: add **structure**.
- Writing material meant to be read continuously: add
  `rhythm.cognitive-pacing` and the profile's cadence lens, regardless of its
  file-type label. Omit both for lookup material and scope both to continuous
  passages in mixed material.

Applying the standards while writing is cheaper than repairing afterwards,
because upper-layer defects force lower-layer text to be rewritten.
