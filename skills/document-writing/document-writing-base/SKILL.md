---
name: document-writing-base
description: >-
  The shared review machinery behind the document-writing lanes: the lane
  contract, blind per-lens detection, conflict resolution between lenses,
  layer-ordered application, the single verification pass, and the report
  format that separates structural changes. Applied by document-writing-review,
  -prose, -audit, and -apply, each of which supplies only its lane values.
user-invocable: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: documentation
---

# Document Writing Base

Inspect a document through the lenses defined in `document-writing-standards`,
each by an independent reviewer, then apply the findings in layer order.

A calling lane supplies four values and nothing else. Everything below is the
same for every lane.

Read the lens definitions for the selected lenses from
`document-writing-standards` before constructing any reviewer brief. Do not
paraphrase a lens from memory.

## Lane contract

```yaml
lenses: <lens IDs, or a layer selection>
deliverable: revised-document | findings
reviewers: per-lens | per-packing-group | single
verify: true | false
```

Where the request names an axis explicitly — a lens subset, findings-only, a
reviewer budget — it overrides the lane's value for that axis and leaves the
rest.

## Responsibility boundary

Own:

- resolving the lens set for this document from the lane and the language;
- running blind, independent per-lens reviews;
- normalizing findings and resolving conflicts between them;
- applying findings in layer order;
- running one lens verification pass and one before/after preservation check;
- reporting the revision, the structural changes, and what remains unresolved.

Do not:

- judge whether the document's claims are true — that is
  `document-toolkit-fact-check`;
- rigorously review a finished artifact before acceptance — that is
  `artifact-review`;
- judge whether the document convinces its readers or leaves them stuck — that
  is `document-reader-review`;
- decide what the document should say, add content, or fill gaps in it;
- reorganize a document set, or decide which documents should exist — that is
  `document-toolkit-distill`;
- loop until no findings remain.

## 1. Resolve the target and the lens set

Confirm the document is a concrete file or supplied text. Determine its
language, its purpose if `structure.genre-purity` is selected, and its reading
behavior: continuous, task-led, lookup, or mixed.

Select every applicable common lens, then exactly one language profile by
reading the prose. For Japanese, the profile is `ja.argument-recovery`,
`ja.topic-continuity`, `ja.proposition-realization`,
`ja.connective-calibration`, `ja.proposition-integrity`,
`ja.sentence-boundaries`, `ja.notation`, `ja.syntax`, `ja.diction`, and—when
rhythm is selected—`ja.cadence`. For English, it is
`en.argument-explicitness`, `en.information-order`, `en.clause-linkage`,
`en.sentence-boundaries`, `en.voice`, `en.mechanics`, `en.diction`, and—when
rhythm is selected—`en.cadence`. For any other language, run the common lenses
alone and report that no language profile was available.

Select `rhythm.cognitive-pacing` and the matching profile's cadence lens from
reading behavior: include both for continuously read material, omit both for
lookup material, and scope both to the continuous passages of a mixed document.
Task-led material includes them only where an explanatory passage must be read
continuously. A caller may override this selection explicitly. Never decide
from a label such as README or design note.

Do not reduce the lens set from length or from a prediction that a lens will
find nothing. For any natural-language prose, run the matching profile's full
terminology, structure, and expression set; a clean lens returns no finding.
Apply common lenses when the object named by their objective exists:

- run `logic.*` where the passage asserts, qualifies, supports, or relates claims;
- run `terminology.*` where it introduces or repeatedly names concepts;
- run `reference.*`, `structure.sentence-cohesion`, and applicable `prose.*` on
  explanatory or argumentative prose;
- run `structure.enumeration-landing` on an enumeration,
  `structure.document-shape` on a multi-section document,
  `structure.representation-choice` where the material carries state, flow,
  dependency, hierarchy, time, or repeated-axis relationships, and
  `structure.genre-purity` where a document purpose is available;
- run common and profile rhythm lenses only as selected from reading behavior.

An explicitly requested narrow concern or a lane such as
`document-writing-prose` may reduce the common set according to its contract,
but it still runs the complete matching profile set permitted by that lane.
List a lens as selected even when it returns no finding; do not use detected
defects to reconstruct the selection after review.

A lane with `deliverable: revised-document` and no detection phase skips to
step 4.

## 2. Detect

Run one reviewer per lens or per packing group, as the lane specifies. Run them
in parallel.

Give each reviewer only:

- the document;
- the lens definitions it is assigned, quoted from `document-writing-standards`;
- the entries for those lenses from the example file matching the document's
  language, where one exists;
- the finding schema;
- the document's language and, where relevant, its purpose and reading behavior;
- target rendering, accessibility, and maintenance constraints, when
  `structure.representation-choice` is assigned and those constraints are known.

Do not give a reviewer:

- another reviewer's findings;
- the request's framing of what is wrong with the document;
- a suspicion about a particular passage;
- unrelated conversation history.

A reviewer that returns generic writing advice instead of located findings has
not done the review. Retry once, then mark the lens unexamined rather than
counting it as covered.

Require every finding to carry an `anchor` quoted exactly from the document,
long enough to locate uniquely.

## 3. Normalize and resolve conflicts

Merge findings into one list. Deduplicate by anchor and cause. Put the lens that
owns the remediation in `lens` and preserve the others in `also_raised_by`.

Conflicts between lenses are resolved by rule, not by vote:

- `logic.epistemic-status` outranks `prose.plain-expression` and
  `prose.concision` on any hedge. A hedge that marks real uncertainty stays,
  even when another lens called it padding.
- `terminology.definition` outranks `prose.concision` on an introduction. An
  explanation preceding a term is not redundancy.
- `structure.*` outranks `prose.*` on the same passage: the structural fix runs
  first and the expression finding is re-derived in the verification pass if it
  still holds.
- A common lens identifies a translation-stable defect; a language-profile lens
  owns its natural realization. When both locate the same cause, normalize them
  into one finding, use the profile lens for `lens`, and retain the common lens
  in `also_raised_by`.
- `ja.argument-recovery` runs before `ja.topic-continuity` and
  `ja.proposition-realization`. Recover missing roles before deciding how the
  Japanese sentence should rank or connect them.
- `ja.proposition-integrity` outranks `structure.sentence-cohesion` on the same
  clauses. The Japanese lens owns one proposition split across sentences; the
  structure lens owns relations between distinct propositions.
- `ja.proposition-realization` runs before `ja.connective-calibration` and
  `ja.sentence-boundaries`. Establish the hierarchy before deciding how
  explicitly to mark it or where to end the sentence. `prose.sentence-load`
  still blocks a repair that would create an unmanageable sentence.
- `en.argument-explicitness` runs before `en.information-order` and
  `en.clause-linkage`; `en.clause-linkage` runs before
  `en.sentence-boundaries`. `en.mechanics` outranks a stylistic boundary choice
  where grammar requires a complete clause.
- `structure.representation-choice` owns a prose-versus-list finding also raised
  by `structure.document-shape`. Keep `document-shape` for headings and order,
  and do not apply two representation fixes to the same material.
- `reference.antecedent` outranks `prose.concision` on a naming that repeats.
  Repeating a noun is cheaper than an unresolvable pronoun.
- `reference.discourse-grounding` outranks `structure.signposting` and
  `rhythm.cognitive-pacing` on a missing premise. Delete or flatten the marked
  expression unless the source material independently requires moving that
  premise earlier; do not invent a reader misconception to save the device.

Drop findings that restate the lens rather than locating a defect, and findings
whose anchor cannot be found in the document.

For `deliverable: findings`, stop here and report.

## 4. Apply by phase

Apply in layer order, never bottom-up. Use each lens's declared `layer`, not its
ID prefix or language. Within a phase, findings are independent unless a
conflict rule above orders them.

1. `logic.*`
2. `terminology.*`, `reference.*`
3. `structure.*`
4. every lens with `layer: expression`
5. every lens with `layer: rhythm` — only when selected

Constraints on application:

- **Do not change what the document asserts.** Every fix preserves the claims.
  Where a `logic.*` finding cannot be resolved without deciding something the
  document does not say, leave it unapplied and report it. Filling that gap is
  the author's call.
- **Re-anchor before each phase.** Earlier phases have moved text. Locate each
  finding's anchor in the current document; where it no longer matches, treat
  the finding as stale and report it unapplied.
- **Record `content_impact` for every applied finding.**

## 5. Verify once

Where the lane sets `verify: true`, re-run only the lenses that application most
often breaks:

- `structure.signposting` — connectives lost when paragraphs merged or split
- `structure.sentence-cohesion` — relations lost when sentences were rewritten
- `structure.representation-choice` — a structural edit left material in an
  unsuitable form
- `reference.antecedent` — referents removed by deletion
- `reference.discourse-grounding` — contrasts or frames introduced by rewriting
- `terminology.consistency` — wording changed unevenly across the document
- `prose.concision` — padding introduced while rewriting
- for Japanese: `ja.argument-recovery`, `ja.topic-continuity`,
  `ja.proposition-realization`, `ja.connective-calibration`,
  `ja.proposition-integrity`, and `ja.sentence-boundaries`
- for English: `en.argument-explicitness`, `en.information-order`,
  `en.clause-linkage`, `en.sentence-boundaries`, and `en.voice`
- the matching cadence lens when rhythm was selected

Apply what this pass finds, once. **Do not run a second round.** Lenses are not
fully independent, so a fix for one can reopen another; an unbounded loop has no
convergence guarantee and no predictable cost. Report anything still open as
unresolved.

Then compare the document supplied to step 1 with the revised document. This is
a workflow invariant, not a lens: it requires two versions and cannot be judged
from one document in isolation. Account for every premise, condition,
limitation, contrast arm, and relation between claims that appeared before
application. Each must still perform the same role, have moved intact, or have
an intentional removal justified by an applied finding that preserves what the
document asserts.

When available, give this comparison to a verifier that did not integrate the
findings. Give it only the before and after documents, the applied findings, and
this preservation rule. If a role was dropped accidentally, restore it from the
original document once where doing so requires no authorial decision; otherwise
report it unresolved. Do not invent a replacement premise or infer a new claim.

## 6. Report

Return the revised document where the lane produces one, then:

```yaml
lane:
lenses_run: []
lenses_unexamined: []

structural_changes:      # every applied finding with content_impact: structural
  - what: <heading renamed / section moved / list converted>
    where: <section>
    reason: <lens and finding>

changes:
  by_layer:
    logic: <count>
    terminology: <count>
    structure: <count>
    expression: <count>
    rhythm: <count>
  by_language:
    common: <count>
    ja: <count>
    en: <count>
  notable: []            # applied findings at blocker severity

unresolved:
  - finding: <id and lens>
    why: needs-author-decision | stale-anchor | conflicting-findings

verification: applied | nothing-found | not-run
revision_preservation: pass | repaired | unresolved | not-run
```

**Report `structural_changes` prominently and separately, above the change
counts.** Renaming a heading, moving a section, or converting prose to a list
overrides a choice the writer may have made deliberately. These changes are
applied, not proposed, so the report is the only place the writer sees them.
Never fold them into a general revision summary.

State plainly when a lens went unexamined. Silence about coverage reads as
coverage.

## Success criteria

- [ ] Every selected lens is either run or listed as unexamined.
- [ ] No reviewer saw another reviewer's findings before its own pass finished.
- [ ] Findings were applied in layer order, and no phase 4 fix preceded a phase
      1–3 fix on the same passage.
- [ ] No applied fix changed what the document asserts.
- [ ] Every premise, condition, limitation, contrast arm, and relation in the
      input remains accounted for after application.
- [ ] Every structural change appears individually in `structural_changes`.
- [ ] Verification ran at most once, and remaining findings are reported as
      unresolved rather than iterated on.
