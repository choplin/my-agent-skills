# Japanese Composition Lenses

Language: **Japanese**. These lenses define how Japanese realizes reference,
topic continuity, proposition hierarchy, connection, and sentence boundaries.
They supplement the language-common semantic lenses; examples do not substitute
for these norms.

## `ja.argument-recovery`

```yaml
lens: ja.argument-recovery
language: ja
layer: terminology
packing_group: japanese-reference
objective: Find omitted actors, objects, complements, sources, targets, or
  scopes whose recovery makes the reader search backward or choose among
  candidates.
checks:
  - An omitted argument carried across a sentence or paragraph boundary.
  - Several predicates sharing an omitted noun after its semantic role changes.
  - A transitive or relational predicate left abstract because its object,
    target, or scope is missing.
  - Zero anaphora with no unique, locally active referent.
non_goals:
  - Do not repeat an argument when one local topic remains active and keeps the
    same role across predicates.
  - Do not require Japanese subjects or objects mechanically.
  - Overt but ambiguous demonstratives belong to reference.antecedent.
content_impact: none
```

Restore the smallest noun phrase that makes the role unique. Repeat a noun when
a predicate change also changes its role; do not replace one difficult omission
with a chain of 「これ」「それ」「そこ」.

## `ja.topic-continuity`

```yaml
lens: ja.topic-continuity
language: ja
layer: structure
packing_group: japanese-structure
objective: Find passages where the reader cannot tell whether a topic
  continues, narrows, contrasts, or changes.
checks:
  - A zero subject retained after the acting or discussed entity changes.
  - は, が, も, or a contrastive は that presents the wrong information status.
  - The same topic needlessly reintroduced in consecutive sentences.
  - A new topic introduced without enough naming to distinguish it from the old.
non_goals:
  - Do not map は to main clause or が to subordinate clause mechanically.
  - Do not force an explicit subject while one topic remains uniquely active.
content_impact: none
```

Use は to maintain or contrast a topic and が to introduce or focus a subject
only where that information structure is intended. Name the topic again at a
real switch; omit it where repetition would falsely restart the passage.

## `ja.proposition-realization`

```yaml
lens: ja.proposition-realization
language: ja
layer: structure
packing_group: japanese-structure
objective: Find a recoverable proposition hierarchy that Japanese syntax leaves
  flat, reverses, or delays until the reader must rebuild it.
checks:
  - A main claim and its reason, condition, limitation, evidence, or consequence
    presented as co-equal assertions.
  - A subordinate clause placed where the main predicate arrives only after the
    reader must retain several unresolved relations.
  - A connective or conjunctive form that makes the dependent proposition look
    like the conclusion.
  - A contrast forced into subordination even though both sides need equal weight.
required_output:
  - main proposition
  - dependent proposition or co-ordinate counterpart
  - relation
  - chosen Japanese realization
content_impact: none
```

Realize reason, condition, concession, and consequence through an appropriate
clause form such as 「ため」「ので」「なら」「場合」「ても」「ものの」. Use a
separate sentence with 「しかし」「一方」「ところが」 where the alternatives
remain co-ordinate. Put the main clause first when delaying it would overload
working memory; put grounds first when the reader needs them to interpret the
claim.

## `ja.connective-calibration`

```yaml
lens: ja.connective-calibration
language: ja
layer: structure
packing_group: japanese-structure
objective: Find relations that Japanese leaves under-marked, or marks twice
  through both syntax and a redundant connective.
checks:
  - A cause, consequence, contrast, restriction, example, or continuation that
    must be inferred from adjacency alone.
  - Repeated paragraph or sentence openings with generic additive connectives.
  - A connective repeating a relation already unambiguously encoded by a clause.
  - A connective whose strength or direction does not match the relation.
non_goals:
  - Do not require a connective where particles, inflection, order, or lexical
    meaning already makes the relation effortless to recover.
  - Do not delete a connective that carries contrast, scope, or pacing.
content_impact: none
```

Choose among clause linkage, particles, ordering, and an explicit connective.
The target is a recoverable relation, not a target count of connectives.

## `ja.sentence-boundaries`

```yaml
lens: ja.sentence-boundaries
language: ja
layer: expression
packing_group: japanese-expression
objective: Find Japanese sentence boundaries that merely restart the grammar
  while one local movement continues, or joins that overload one sentence.
checks:
  - A boundary separating a claim from its reason, condition, qualification,
    example, or result without adding emphasis or reducing load.
  - Consecutive independent assertions that repeatedly reactivate the same topic.
  - Dependent material promoted to a sentence with the same cadence as its main claim.
  - A joined sentence whose nested modifiers or delayed predicate exceed what
    the reader can retain.
non_goals:
  - Do not infer a defect from sentence length or count alone.
  - Preserve a hard stop that changes topic, time, viewpoint, argumentative
    stage, or supplies deliberate emphasis.
  - Do not repair fragmentation by creating a sentence-load defect.
content_impact: none
```

Remove a boundary only after `ja.argument-recovery` and
`ja.proposition-realization` establish what the clauses share and how they
relate. A readable paragraph may contain several short sentences when each stop
has a job.
