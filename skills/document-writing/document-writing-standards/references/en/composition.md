# English Composition Lenses

Language: **English**. These lenses define English-specific argument
explicitness, clause linkage, information order, sentence boundaries, and voice.

## `en.argument-explicitness`

```yaml
lens: en.argument-explicitness
language: en
layer: terminology
packing_group: english-reference
objective: Find required actors, objects, complements, or referents that English
  grammar or the local meaning leaves missing or ambiguous.
checks:
  - A finite clause without the subject its construction requires.
  - A transitive or relational predicate without a recoverable object or complement.
  - Ellipsis whose recovered term changes role or has more than one candidate.
  - An introductory modifier whose understood actor differs from the main subject.
content_impact: none
```

State required arguments explicitly. Share an argument across coordinated
predicates only when it remains local, unique, and in the same semantic role.

## `en.information-order`

```yaml
lens: en.information-order
language: en
layer: structure
packing_group: english-structure
objective: Find English clauses whose ordering delays the governing claim,
  separates related words, or presents new information before its frame.
checks:
  - A long subordinate or modifying opening that makes the main clause hard to retain.
  - A subject and predicate separated by material that belongs later.
  - New or contrastive information placed where the sentence cannot carry its emphasis.
  - A paragraph whose governing proposition arrives only after its supporting details.
non_goals:
  - Do not require the main clause first when an initial condition or frame is short
    and needed to interpret it.
content_impact: none
```

Prefer given before new and place governing material early enough that the
reader can attach what follows. Use end weight for long or contrastive material
without turning it into a universal sentence-final rule.

## `en.clause-linkage`

```yaml
lens: en.clause-linkage
language: en
layer: structure
packing_group: english-structure
objective: Find relations whose English coordination or subordination gives
  propositions the wrong logical rank.
checks:
  - A reason, condition, concession, or limitation presented as a co-equal claim.
  - Independent claims joined as if one were merely dependent.
  - A coordinator or subordinator naming the wrong relation.
  - Repeated independent clauses where one should grammatically receive another.
content_impact: none
```

Use subordination for dependent grounds, conditions, and concessions; use
coordination where claims retain equal weight. Do not turn every semantic
relation into an explicit connective when English syntax already carries it.

## `en.sentence-boundaries`

```yaml
lens: en.sentence-boundaries
language: en
layer: expression
packing_group: english-expression
objective: Find grammatical English sentence boundaries that fragment one
  movement, or joins that overload it.
checks:
  - A full stop separating a dependent thought from the clause it develops.
  - A run of short subject-verb assertions that repeatedly resets one active topic.
  - Several clauses joined although each has a distinct argumentative job.
  - A boundary pattern that obscures emphasis or produces a monotone sequence.
non_goals:
  - Grammatical fragments and comma splices belong to en.mechanics.
  - Do not infer a defect from sentence length or count alone.
content_impact: none
```

Keep a boundary when it changes topic, time, viewpoint, or argumentative stage,
or supplies deliberate emphasis. Otherwise connect or subordinate without
creating an overloaded sentence.

## `en.voice`

```yaml
lens: en.voice
language: en
layer: expression
packing_group: english-expression
objective: Find English voice and person choices that hide an actor, shift the
  reader relationship, or put the wrong participant in subject position.
checks:
  - Passive voice where the omitted actor matters to the reader's task.
  - Result-listing where an actor's sequence of actions is the subject.
  - Unmotivated shifts among first, second, and third person.
  - Negative form where English can state the operative positive rule directly.
non_goals:
  - Keep passive voice when the actor is unknown, irrelevant, or the patient is
    the established topic.
content_impact: none
```
