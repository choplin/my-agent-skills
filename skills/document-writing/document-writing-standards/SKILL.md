---
name: document-writing-standards
description: >-
  Supplies planning principles, editorial heuristics, and local conformance
  checks for Japanese and English documents. Apply the relevant guidance while
  planning, drafting, or editing; do not treat every lens as a mechanical defect
  detector.
user-invocable: false
metadata:
  description-role: trigger
---

# Document Writing Standards

This catalog supports a larger editorial workflow. It does not decide the
document's purpose or replace a plot. The same observation can be useful at
different stages, but the authority of a lens depends on its role.

## Roles

- **Planning principle:** informs the assignment, focus, content model, or plot.
  It produces a decision, question, or plot note—not a located prose finding.
- **Editorial heuristic:** helps an editor notice a possible problem and choose
  among revisions in context. It produces an observation and alternatives. The
  text may legitimately depart from the heuristic.
- **Conformance check:** detects a locally falsifiable defect after the larger
  decisions are stable. It may produce a finding suitable for direct
  application.

Do not collapse these roles into a single scoring or auto-fix pass. In
particular, a request for more support, a different concept introduction, or a
new section may be the right developmental edit. The “smallest local fix” is not
the governing objective.

All roles share one purpose: let the intended reader spend attention on the
subject rather than reconstructing the document. That judgment necessarily uses
the audience's prior knowledge, the document's purpose, and the plot.

## Lens index

`planning`, `editorial`, and `check` below are permitted uses, not phases that
must all run.

| Lens ID | Language | Layer | Uses | Reference |
|---|---|---|---|---|
| `logic.claim-support` | common | logic | planning, editorial | [logic.md](references/common/logic.md) |
| `logic.epistemic-status` | common | logic | planning, editorial | [logic.md](references/common/logic.md) |
| `logic.internal-consistency` | common | logic | planning, editorial | [logic.md](references/common/logic.md) |
| `terminology.definition` | common | terminology | planning, editorial | [terminology.md](references/common/terminology.md) |
| `terminology.consistency` | common | terminology | editorial, check | [terminology.md](references/common/terminology.md) |
| `reference.antecedent` | common | terminology | check | [terminology.md](references/common/terminology.md) |
| `reference.discourse-grounding` | common | terminology | editorial | [terminology.md](references/common/terminology.md) |
| `structure.paragraph-unity` | common | structure | editorial | [structure.md](references/common/structure.md) |
| `structure.signposting` | common | structure | editorial | [structure.md](references/common/structure.md) |
| `structure.sentence-cohesion` | common | structure | editorial | [structure.md](references/common/structure.md) |
| `structure.enumeration-landing` | common | structure | editorial | [structure.md](references/common/structure.md) |
| `structure.document-shape` | common | structure | planning, editorial | [structure.md](references/common/structure.md) |
| `structure.representation-choice` | common | structure | planning, editorial | [structure.md](references/common/structure.md) |
| `structure.genre-purity` | common | structure | planning, editorial | [structure.md](references/common/structure.md) |
| `prose.plain-expression` | common | expression | editorial | [expression.md](references/common/expression.md) |
| `prose.self-reference` | common | expression | editorial | [expression.md](references/common/expression.md) |
| `prose.concision` | common | expression | editorial | [expression.md](references/common/expression.md) |
| `prose.sentence-load` | common | expression | editorial | [expression.md](references/common/expression.md) |
| `prose.voice` | common | expression | editorial | [expression.md](references/common/expression.md) |
| `rhythm.cognitive-pacing` | common | rhythm | planning, editorial | [rhythm.md](references/common/rhythm.md) |
| `ja.argument-recovery` | ja | terminology | editorial, check | [composition.md](references/ja/composition.md) |
| `ja.topic-continuity` | ja | structure | editorial | [composition.md](references/ja/composition.md) |
| `ja.proposition-realization` | ja | structure | editorial | [composition.md](references/ja/composition.md) |
| `ja.connective-calibration` | ja | structure | editorial | [composition.md](references/ja/composition.md) |
| `ja.proposition-integrity` | ja | structure | editorial, check | [conventions.md](references/ja/conventions.md) |
| `ja.sentence-boundaries` | ja | expression | editorial | [composition.md](references/ja/composition.md) |
| `ja.notation` | ja | expression | check | [conventions.md](references/ja/conventions.md) |
| `ja.syntax` | ja | expression | check | [conventions.md](references/ja/conventions.md) |
| `ja.diction` | ja | expression | editorial, check | [conventions.md](references/ja/conventions.md) |
| `ja.cadence` | ja | rhythm | editorial | [rhythm.md](references/ja/rhythm.md) |
| `en.argument-explicitness` | en | terminology | editorial, check | [composition.md](references/en/composition.md) |
| `en.information-order` | en | structure | editorial | [composition.md](references/en/composition.md) |
| `en.clause-linkage` | en | structure | editorial | [composition.md](references/en/composition.md) |
| `en.sentence-boundaries` | en | expression | editorial, check | [composition.md](references/en/composition.md) |
| `en.voice` | en | expression | editorial | [composition.md](references/en/composition.md) |
| `en.mechanics` | en | expression | check | [conventions.md](references/en/conventions.md) |
| `en.diction` | en | expression | editorial, check | [conventions.md](references/en/conventions.md) |
| `en.cadence` | en | rhythm | editorial | [rhythm.md](references/en/rhythm.md) |

## Language profiles

Select common guidance plus the profile matching the prose:

| Prose language | Profile files | Examples |
|---|---|---|
| Japanese | [composition](references/ja/composition.md), [conventions](references/ja/conventions.md), [rhythm](references/ja/rhythm.md) | [examples](references/ja/examples.md) |
| English | [composition](references/en/composition.md), [conventions](references/en/conventions.md), [rhythm](references/en/rhythm.md) | [examples](references/en/examples.md) |

Common lenses state relationships intended to survive translation. Profiles own
natural omission, information order, proposition and clause linkage, sentence
boundaries, notation, diction, and cadence. For another language, use common
guidance and report that no language profile is available. Code, identifiers,
and quotations do not change the prose language.

Japanese profile instructions and examples are written in Japanese so that the
norm and its realization can be compared without translation. English profile
instructions and examples are written in English.

## Choosing guidance by editorial stage

### Assignment, focus, content model, and plot

Use the planning roles. Especially consider claim support and epistemic status,
concept centrality and introduction, document kind, document shape,
representation, and cognitive pacing. Record their results in the planning
artifact rather than manufacturing prose findings.

`terminology.definition` is audience-relative. Do not define a term merely
because it is technical. Decide from:

1. whether the audience already knows it;
2. whether the concept is standard or document-specific;
3. how central it is to the argument;
4. which property of it the argument actually depends on.

A familiar term may need no definition yet require one implicit premise to be
made explicit. A central unfamiliar concept may deserve motivation and examples
before its eventual definition. A minor concept may be introduced in a phrase
or left unnamed.

### Developmental edit

Use planning principles again against the complete draft, plus structural and
rhythm heuristics. Compare the draft with the audience, focus, content model,
and plot. Observations can authorize new explanations, deleted digressions,
reordering, or a revised plot. They are not bounded to the smallest edit.

### Line or stylistic edit

Use paragraph, cohesion, expression, cadence, and language-profile heuristics.
The objective is the intended movement of the passage. Prefer a coherent pass
over independent micro-edits that optimize sentences against one another.

### Copyedit and audit

Run applicable `check` uses after structure is stable. A check finding must be
located, falsifiable, and reparable without deciding new substance. Do not
convert a heuristic into a check merely because it is easy to phrase as a rule.

## Context packets

Planning and editorial reviewers receive the relevant assignment, audience
knowledge, focus, plot, sources, and intervention boundary. A reviewer may be
blind to other reviewers' conclusions, but not to the document context required
by the lens. A copyeditor may receive a narrower packet when the substantive
decisions are explicitly frozen.

## Findings and observations

Use this schema only for `check` findings that may flow through
`document-writing-apply`:

```yaml
id: <stable within one run>
lens: <lens ID>
also_raised_by: []
language: common | ja | en
layer: logic | terminology | structure | expression | rhythm
severity: blocker | major | minor
location:
  anchor: <exact unique quotation>
  section: <nearest heading or document start>
claim: <locally falsifiable defect>
evidence: <why it violates the check>
remediation: <a content-preserving correction>
content_impact: none
```

If a proposed remedy adds a claim, changes the argument, or reorganizes the
reader progression, return an editorial observation instead:

```yaml
stage: assignment | discovery | focus | content-model | plot | developmental | line
location: <section, passage, or document-wide>
observation: <what may impede the intended reader>
relation_to_intent: <audience, focus, or plot reason>
options: []
recommendation: <contextual judgment, not an automatic command>
```

## Scope boundary

These lenses do not establish external truth. Use authoritative sources or
`document-toolkit-fact-check` for factual verification. Reader outcome is part
of the document-writing workflow and may also be tested through
`document-reader-review`; it is no longer excluded from readability judgment.
