---
name: document-toolkit-quality
description: >-
  Raises a document to a sound technical-writing baseline in one pass, by
  running independent per-lens reviewers over it and applying their findings in
  dependency order. Targets how the document reads and holds together — plain
  expression, paragraph structure, defined terms, resolvable references,
  internal logic — not whether its subject matter is correct. Applies when
  prose is hard to follow, argues loosely, or reads as machine-written, and
  when a draft needs to be brought to a publishable standard.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: trigger
---

# Document Quality

Inspect a document through the lenses defined in `document-toolkit-standards`,
each by an independent reviewer, then apply the findings in layer order and
return the revised document with a record of what changed.

Read the lens definitions for the selected lenses from
`document-toolkit-standards` before constructing any reviewer brief. Do not
paraphrase a lens from memory.

## Responsibility boundary

Own:

- resolving the preset and the lens set for this document;
- running blind, independent per-lens reviews;
- normalizing findings and resolving conflicts between them;
- applying findings in layer order;
- running one verification pass;
- reporting the revision, the structural changes, and what remains unresolved.

Do not:

- judge whether the document's claims are true — that is
  `document-toolkit-fact-check`;
- falsify a completion or acceptance claim — that is
  `artifact-review-toolkit-adversarial`;
- decide what the document should say, add content, or fill gaps in it;
- reorganize a document set, or decide which documents should exist — that is
  `document-toolkit-distill`;
- loop until no findings remain.

Use `document-toolkit-review` instead when a single free-form critique or
revision is wanted and a lens sweep is more machinery than the task needs.

## Presets

| Preset | Lenses | Deliverable | Reviewers | Verify |
|---|---|---|---|---|
| **`standard`** (default) | all layers except `rhythm` | revised document | one per packing group (~5) | yes |
| **`prose`** | `prose.*` and the language layer | revised document | 1–2 | yes |
| **`audit`** | all layers except `rhythm` | findings only | one per lens (~18) | no |
| **`apply`** | none — findings are supplied | revised document | 0 | yes |

Take the preset from the request. Where none is stated, use `standard`. When
the request names an axis explicitly — a lens set, findings-only, a reviewer
budget — that overrides the preset's value for that axis and leaves the rest.

Exactly one language layer is included, chosen by reading the document:
`ja.notation` and `ja.diction` for Japanese, `en.mechanics` and `en.diction` for
English. For any other language, run the neutral layers alone and report that no
language layer was available. `rhythm.cognitive-pacing` is added only on an
explicit request, and only for writing meant to be read continuously.

`audit` spends the most because its output is read by a person: independence
matters more than cost when nothing is applied automatically. `standard` spends
less on detection because consistent application matters more than exhaustive
detection when the result is a revised document.

`audit` → human selection → `apply` is the lane for keeping control of what
gets changed.

## Workflow

### 1. Resolve the target and the preset

Confirm the document is a concrete file or supplied text. Determine its
language, and its purpose if `structure.genre-purity` is selected. Resolve the
preset and produce the lens list.

Where the document is very short, or the request names one narrow concern,
prefer `prose` or an explicit lens subset over `standard`. Running eighteen
lenses over three paragraphs is waste, not thoroughness.

For `apply`, skip to step 4.

### 2. Detect

Run one reviewer per packing group, or per lens where the preset says so. Run
them in parallel.

Give each reviewer only:

- the document;
- the lens definitions it is assigned, quoted from
  `document-toolkit-standards`;
- the entries for those lenses from the example file matching the document's
  language, where one exists;
- the finding schema;
- the document's language and, where relevant, its purpose.

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

### 3. Normalize and resolve conflicts

Merge findings into one list. Deduplicate by anchor and cause, keeping which
lenses raised each.

Conflicts between lenses are resolved by rule, not by vote:

- `logic.epistemic-status` outranks `prose.plain-expression` and
  `prose.concision` on any hedge. A hedge that marks real uncertainty stays,
  even when another lens called it padding.
- `terminology.definition` outranks `prose.concision` on an introduction. An
  explanation preceding a term is not redundancy.
- `structure.*` outranks `prose.*` on the same passage: the structural fix runs
  first and the expression finding is re-derived in the verification pass if it
  still holds.
- `reference.antecedent` outranks `prose.concision` on a naming that repeats.
  Repeating a noun is cheaper than an unresolvable pronoun.

Drop findings that restate the lens rather than locating a defect, and findings
whose anchor cannot be found in the document.

### 4. Apply by phase

Apply in layer order, never bottom-up. Within a phase, findings are
independent and may be applied together.

1. `logic.*`
2. `terminology.*`, `reference.*`
3. `structure.*`
4. `prose.*` and the language layer (`ja.*` or `en.*`)
5. `rhythm.*` — only when selected

Constraints on application:

- **Do not change what the document asserts.** Every fix preserves the claims.
  Where a `logic.*` finding cannot be resolved without deciding something the
  document does not say, leave it unapplied and report it. Filling that gap is
  the author's call.
- **Re-anchor before each phase.** Earlier phases have moved text. Locate each
  finding's anchor in the current document; where it no longer matches, treat
  the finding as stale and report it unapplied.
- **Record `content_impact` for every applied finding.**

For `apply`, the findings come from the caller. Before applying, verify that
each anchor still exists in the current document. Report every finding whose
anchor is gone as stale and unapplied rather than guessing a new location.

### 5. Verify once

Re-run only the lenses that application most often breaks:

- `structure.signposting` — connectives lost when paragraphs merged or split
- `reference.antecedent` — referents removed by deletion
- `terminology.consistency` — wording changed unevenly across the document
- `prose.concision` — padding introduced while rewriting

Apply what this pass finds, once. **Do not run a second round.** Lenses are not
fully independent, so a fix for one can reopen another; an unbounded loop has no
convergence guarantee and no predictable cost. Report anything still open as
unresolved.

### 6. Report

Return the revised document, then:

```yaml
preset:
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
    language: <count>
  notable: []            # applied findings at blocker severity

unresolved:
  - finding: <id and lens>
    why: needs-author-decision | stale-anchor | conflicting-findings

verification: applied | nothing-found | not-run
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
- [ ] Every structural change appears individually in `structural_changes`.
- [ ] Verification ran exactly once, and remaining findings are reported as
      unresolved rather than iterated on.
- [ ] For `apply`, every stale anchor is reported rather than relocated by guess.
