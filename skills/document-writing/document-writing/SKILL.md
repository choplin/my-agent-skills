---
name: document-writing
description: >-
  Turns source material, decisions, or an established brief into a coherent
  technical document through an explicit document plot before prose is drafted.
  Applies when writing a new multi-section document or substantially rebuilding
  one, especially when several agents or passes must preserve the same audience,
  argument, evidence, and intended reader outcome without relying on conversation
  history. Produces the document and reports any acceptance criteria it could not
  satisfy. Existing drafts that only need review, audit, or copyediting belong to
  the narrower document-writing lanes.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: trigger
---

# Document Writing

Write the document through an explicit plot. The plot is the shared source of
intent between planning, drafting, review, and revision; conversation history is
never part of the handoff contract.

This skill owns the document-level outcome. Apply `document-writing-standards`
while drafting and `document-writing-review` after the first complete draft.
Those skills remain responsible for local writing defects; they do not replace
the plot or decide what the document must accomplish.

## Operating contract

Produce these artifacts in order:

1. `brief`
2. `plot`
3. `pre_review_draft`
4. `final_document`
5. `acceptance`

They may be working notes in the response or files beside the requested output.
Persist them only when the user asks for working artifacts or the surrounding
workflow requires a durable handoff. Regardless of storage, keep their fields
explicit: later stages must not recover missing intent from chat history.

Do not begin prose until the plot passes the plot gate. Do not declare the
document complete merely because the writing lenses are clean.

Before building the brief, record execution capabilities:

```yaml
capabilities:
  standards: loaded | unavailable
  review_lane: loaded | unavailable
  isolated_drafting: available | unavailable
  isolated_review: available | unavailable
  isolated_acceptance: available | unavailable
```

Mark a skill `loaded` only after its full instructions are available in the
current run. Knowing its name or approximating its behavior from this skill is
not loading it. Mark isolation `available` only when work can actually run in a
separate context; adopting a different persona in the same context is inline
self-review, not isolation.

## 1. Build the brief

Extract the brief from the request and source material:

```yaml
brief:
  audience:
    identity: <who will read>
    prior_knowledge: <what they can already be expected to know>
  use: <the situation in which they will use the document>
  reader_outcome: <what they should understand, decide, or be able to do>
  reading_behavior: continuous | task-led | lookup | mixed
  pacing:
    rhythm: required | not-required | sectional
    sections: []
    reason: <how the reading behavior determines the selection>
  scope:
    includes: []
    excludes: []
  grounds:
    - id: <stable ID>
      locator: <file, URL, supplied passage, or named decision>
      kind: source | user-decision | assumption
  constraints: []
  unknowns: []
```

Infer ordinary details when the evidence makes one reading clearly more likely,
and record the inference under `unknowns`. Ask the user only when different
answers would materially change the document's audience, claims, or scope. Never
label an assumption as a source or user decision.

The brief passes when another agent could state, from the brief alone, who the
document is for, what it must enable, which grounds may support it, what is out
of scope, and how the reading behavior determines pacing.

Select pacing from actual reading behavior, never from a label such as README or
design note:

- `continuous`: set rhythm to `required` when the material sustains a progression
  across multiple passages. Set it to `not-required` only when the document is too
  short to have meaningful pacing, and record that reason.
- `mixed`: set rhythm to `sectional` and name the continuously read sections.
- `task-led` or `lookup`: set rhythm to `not-required` unless the user explicitly
  asks for narrative pacing.

This selection is the explicit rhythm decision for every downstream standards
and review pass. A file-type label never overrides it.

## 2. Build the plot

A plot is not a heading outline. It specifies the reader's progression and the
logical work performed by every part of the document.

```yaml
plot:
  promise: <the document-level question or outcome>
  throughline: <how the sections collectively deliver the promise>
  sections:
    - id: <stable ID>
      heading_intent: <what this section is for, not necessarily its final title>
      reader_question: <the question answered here>
      entry_state: <what the reader knows or believes on entry>
      exit_state: <what changes by the end>
      claims:
        - statement: <claim or instruction>
          grounds: [<ground IDs>]
          status: supported | user-decided | assumed | unresolved
      relation_from_previous: <cause, contrast, dependency, sequence, expansion, or none>
      representations:
        - content: <claim, comparison, dependency, sequence, or other material>
          relationship: <argument, co-ordination, repeated fields, state change,
            data flow, dependency, hierarchy, containment, time, or phase>
          form: prose | list | table | diagram | code
          reason: <what relationship this form makes easiest to understand>
          alternatives_rejected: []
      handoff_to_next: <what the next section may now rely on>
  open_decisions: []
```

Inventory every relationship-bearing part of the material, then apply
`structure.representation-choice` from `document-writing-standards` to select
and justify each form. Give the lens the source material, plot, and known target
rendering, accessibility, and maintenance constraints. The plot stores the
decision; the lens owns the norm used to make it.

## 3. Run the plot gate

Check the plot before drafting. It passes only when all applicable statements
below are true:

- Every item in `scope.includes` is owned by at least one section.
- Every section performs a distinct job toward `reader_outcome`.
- Each non-obvious claim names support or is visibly marked `assumed` or
  `unresolved`.
- A section's `entry_state` follows from the brief or earlier sections.
- Its `exit_state` answers its `reader_question`.
- `relation_from_previous` makes the section order defensible.
- The source's relationship-bearing material is present in the representation
  inventory.
- `structure.representation-choice` returns no finding against the source and
  planned representations.
- The throughline reaches the document promise without an unexplained jump.

Repair the plot when the gate exposes an ordering or coverage defect. Stop for
the user's decision when the defect requires a new claim, source, or scope
choice. Do not disguise that gap with fluent prose.

## 4. Create a self-contained drafting packet

Pass the writer one packet containing:

```yaml
drafting_packet:
  brief: <the complete accepted brief>
  plot: <the complete accepted plot>
  source_material: <the cited passages or resolvable source locations>
  decisions_made_after_plot: []
  output_constraints: <format, location, length, notation, and repository rules>
```

Give the complete packet to any isolated agent whose work depends on document
intent, including drafting and integration. Do not pass instructions such as
"continue the approach we discussed" or expect the agent to infer why a section
exists. If isolation is unavailable, execute the same packet inline; subagents
improve isolation but are not required.

For a document too large for one drafting context, partition only at plot section
boundaries. Give every writer the full brief and plot, the sources for its
section, and the completed preceding section needed by its `entry_state`. One
integrator still owns the complete draft.

## 5. Draft against the plot

Write one complete draft whose section boundaries follow the logical jobs in the
plot. Preserve the plot's claims and statuses; do not turn an assumption into a
fact or invent support to make a transition smooth.

Load and apply `document-writing-standards` by its writing-time selection rules.
The plot determines what the document says and how the reader progresses; the
standards determine how that material is expressed. If the standards skill is
unavailable, continue with a plain technical draft and report that the standards
pass was unavailable.

Pass the brief's pacing selection explicitly. Apply
`rhythm.cognitive-pacing` to the whole draft when rhythm is `required`, only to
the named sections when it is `sectional`, and not at all when it is
`not-required`. The brief's reading behavior governs this choice; document genre
labels do not.

Representation plans are requirements unless the source material proves the
planned form unsuitable. Record any substitution and its reason in
`decisions_made_after_plot`; do not silently collapse a planned diagram or table
into prose.

Apply `structure.sentence-cohesion` to explanatory and argumentative prose while
drafting, together with the matching language profile's terminology, structure,
and expression lenses. Include the profile's cadence lens wherever the brief
selects rhythm. Always include these profile lenses even when the document is
short and the general writing-time selection would otherwise reduce the
catalog. The common lenses own translation-stable relations; the profile owns
natural omission, hierarchy, linkage, sentence boundaries, and cadence in the
language being written.

## 6. Review, then integrate once

After the first complete draft, preserve it as `pre_review_draft`, then apply
`document-writing-review`. Treat its findings as local repairs: it may improve
expression and content-preserving structure, but it does not supersede the
accepted brief or plot. Pass the brief's rhythm selection as an explicit lens
override so a continuously read document is not reviewed with rhythm omitted.
Do not reduce `structure.representation-choice`,
`structure.sentence-cohesion`, or the matching language profile's applicable
lenses.

Preserve that lane's blind-review contract. Its lens reviewers receive the
document and their lens definitions, not the brief or plot. The integrator that
accepts or reconciles their repairs receives:

```yaml
integration_packet:
  drafting_packet: <the complete packet used for drafting>
  pre_review_draft: <the complete first draft>
  reviewed_draft: <the complete output of the review lane>
  applied_findings: []
  decisions_made_after_plot: []
```

Then integrate the result as one document. Reconcile section boundaries,
cross-references, repeated definitions, transitions, and representation changes
against the plot. Where a lens repair conflicts with a plotted claim, support,
or reader transition, preserve the plot and report the unresolved writing
finding. If `document-writing-review` is unavailable, perform one inline
copyedit against the loaded standards and report the degraded review path.

Compare `pre_review_draft` with the integrated result. For every removed or
rewritten passage that carried a premise, condition, limitation, contrast arm,
or relation between claims, locate the same role in the final document or record
an intentional, plot-consistent removal. Fluency and concision do not justify an
untracked loss.

## 7. Run document acceptance

Evaluate the complete document against the brief and plot, not against drafting
process completion.

```yaml
acceptance:
  outcome: pass | unresolved
  checks:
    audience_fit: pass | fail
    scope_coverage: pass | fail
    claim_traceability: pass | fail
    reader_progression: pass | fail
    representation_fidelity: pass | fail
    rhythm_selection: pass | fail
    revision_preservation: pass | fail
    whole_document_coherence: pass | fail
    writing_review: pass | degraded | unresolved
    independent_reconstruction: pass | fail | not-run
  lens_conformance:
    common:
      structure.representation-choice: pass | fail
      structure.sentence-cohesion: pass | fail | not-applicable
      rhythm.cognitive-pacing: pass | fail | not-selected
    profile:
      language: ja | en | unavailable
      lenses:
        <each applicable profile lens ID>: pass | fail | not-selected
  deviations:
    - check: <failed check>
      location: <section or exact anchor>
      plot_item: <brief or plot field>
      effect: <what the reader cannot understand, decide, or do>
```

Apply these tests:

- **Audience fit:** The document relies only on the prior knowledge in the brief,
  or supplies what is missing before use.
- **Scope coverage:** Every included scope item and plotted reader question has a
  corresponding passage; excluded material has not leaked in.
- **Claim traceability:** Every material assertion maps to a plotted claim and
  retains its support and epistemic status.
- **Reader progression:** Each section establishes its exit state, and the next
  section uses no premise absent from its entry state.
- **Representation fidelity:** Each planned non-prose element exists and makes
  the named relationship inspectable. Every recorded substitution remains fit
  for the same purpose.
- **Rhythm selection:** The final lens set matches the pacing decision in the
  brief, including sectional selection. File-type labels did not override it.
- **Revision preservation:** Every premise, condition, limitation, contrast arm,
  and logical relation present in `pre_review_draft` either performs the same
  role in the final document or has an intentional removal recorded against the
  plot.
- **Whole-document coherence:** The section sequence realizes the throughline;
  the result does not read as independently adequate fragments joined together.
- **Writing review:** The existing review lane completed, or its unavailable or
  unresolved coverage is reported.

For `lens_conformance`, load each listed common lens and every applicable lens
in the matching language profile from `document-writing-standards`, then run
them against the final document. Give `structure.representation-choice` the
relationship inventory and target constraints. Run
`structure.sentence-cohesion` only where explanatory or argumentative prose
exists, and run the common and profile cadence lenses only where the brief
selected rhythm. A lens passes when it returns no surviving finding after the
one acceptance revision. For an unsupported language, set `profile.language`
to `unavailable` and report the coverage gap instead of substituting another
language's norms.

When an isolated reader is available, give it only the brief and finished
document and ask it to reconstruct the document's questions, claims, progression,
and relations between adjacent propositions. Compare that reconstruction with
the plot. Do not show it the plot before its read and do not ask it to reproduce
lens work; reader reconstruction and lens conformance are separate evidence.
When isolation is unavailable, perform the field-by-field tests above inline and
set `independent_reconstruction: not-run`. Never report an independent or blind
read unless a separate context actually performed it.

Revise once for acceptance failures that can be resolved from the existing brief,
plot, and sources, then run acceptance once more. Do not loop. Report failures
that require a new source, claim, or user decision as unresolved.

## Final response

Return or link the finished document first. Then report:

```yaml
document: <path or supplied result>
plot: <persisted path, included, or not-persisted>
standards: applied | unavailable
review: applied | degraded
acceptance: pass | unresolved
independent_reconstruction: pass | fail | not-run
unresolved: []
```

Do not claim success when acceptance is unresolved. A polished document that
does not deliver the brief is not complete.

## Responsibility split

Keep reusable norms in `document-writing-standards` and orchestration here:

| Responsibility | Owner | Why |
|---|---|---|
| Whether prose, list, table, diagram, or code fits the material | `structure.representation-choice` | One bounded representation judgment can be reused while drafting and reviewing |
| Whether distinct propositions connect | `structure.sentence-cohesion` | It can be falsified from one document in any language |
| What may be omitted and still recovered | the matching language profile's argument lens | Recoverability is language-specific |
| How propositions are ranked, linked, and ordered | the matching language profile's structure lenses | Natural realization differs between Japanese and English |
| Where sentences end and what cadence is natural | the matching language profile's boundary and cadence lenses | Sentence formation is language-specific |
| Whether one Japanese proposition was split apart | `ja.proposition-integrity` | It is a Japanese-specific realization defect |
| Whether the document's shape serves its stated purpose | `structure.genre-purity` | The existing lens owns purpose and genre conformance |
| Whether selected passages have usable pacing | `rhythm.cognitive-pacing` | The existing lens owns the pacing norm |
| Which passages receive the pacing lens | this workflow and `document-writing-base` | Selection needs expected reading behavior, not another genre classification |
| What the document must accomplish and in what order | this workflow | The brief and plot carry authorial intent, not a reusable defect rule |
| Whether a review revision lost content | `document-writing-base` | The check compares the input and output of every applying review lane |
| Whether the authored document lost a plotted role | this workflow | The stronger check also compares the plot, pre-review draft, and final document |

Narrow review lanes may detect these reusable defects without a plot. This
workflow still owns creating missing material and reconciling any structural
finding with the document's intended outcome.

## Success criteria

- [ ] Drafting began only after a complete brief and a passing plot gate.
- [ ] Every handoff that depended on document intent received the complete
      packet rather than an instruction that depended on conversation history;
      blind lens reviewers remained blind.
- [ ] The draft preserves claim support and epistemic status from the plot.
- [ ] The selected common lenses and every applicable lens in the matching
      language profile pass on the final document.
- [ ] Existing writing standards and review lanes were used without changing
      their responsibility boundaries.
- [ ] Every claim of isolated or independent review names an execution that
      actually ran in a separate context; inline checks are labeled inline.
- [ ] Acceptance evaluates the reader outcome and document throughline, not only
      lens cleanliness.
- [ ] At most one acceptance-driven revision was performed, and every remaining
      failure is reported.
