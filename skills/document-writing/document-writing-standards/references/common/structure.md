# Structure Lenses

Language: **common**. These are planning principles and editorial heuristics.
They may suggest joining sentences, moving text, changing representation, or
revising the plot. Interpret them against audience, purpose, focus, and genre;
their metadata describes the usual reach of a change, not automatic authority.

Concrete instances — connectives, heading forms, landing phrasings — live in
[Japanese examples](../ja/examples.md) and [English examples](../en/examples.md),
keyed by lens ID. Load the file for the document's language.

Structure is where prose that is locally readable still fails to be followable.
The reader can parse every sentence and still not be able to say what the
argument was.

---

## `structure.paragraph-unity`

```yaml
lens: structure.paragraph-unity
language: common
layer: structure
packing_group: structure
objective: Falsify the claim that each paragraph carries one job and establishes
  that job before its supporting material becomes ambiguous.
checks:
  - Paragraphs mixing several stages of movement (investigation, report,
    verification, evaluation).
  - Paragraphs whose governing topic or claim arrives only after supporting
    material that cannot yet be placed.
  - Co-ordinate ideas expressed in non-parallel form.
content_impact: reordering
```

### Rules

- Give each paragraph a recoverable governing job. One paragraph may carry
  several related moves when their connection is the point; split it when the
  reader can no longer place them under the same job.
- Establish the paragraph's subject or governing claim before the reader needs
  it to place supporting material. The language profile decides whether that
  requires a topic sentence first or permits an inductive entry.
- End the paragraph in conformity with how it began.
- Express co-ordinate ideas in parallel grammatical form.

### Severity

`major` where the topic sentence is missing or buried; `minor` for parallelism.

---

## `structure.signposting`

```yaml
lens: structure.signposting
language: common
layer: structure
packing_group: structure
objective: Find places where the reader cannot tell how a passage relates to
  what came before it, or where material is placed so that the sequence breaks.
checks:
  - Paragraph openings whose relation to the previous paragraph is not encoded
    by syntax, wording, order, or a connective.
  - Arguments that conclude, then handle objections, then restate the conclusion.
  - Forward references placed mid-argument.
  - Defenses of an example placed inside the passage they interrupt.
  - Information needed for a later payoff disclosed early.
  - A likely misreading left unaddressed before the real reason is given.
content_impact: reordering
```

### Rules

- **Make the relation available at the paragraph boundary.** Use the target
  language's syntax, wording, order, or connective conventions. Do not require
  the same surface marker in every language.
- **Argue in one direction.** Handle objections and doubts first, then state
  the conclusion once. Do not state it, defend it, and restate it.
- **Place forward references at a resting point.** A pointer to a later section
  belongs at the end of a paragraph or section, not inside an argument in
  progress.
- **Defer defenses of an example.** A pre-emptive defense (that the example
  looks contrived) goes at the head of the next section, not in the middle of
  the example's climax.
- **Do not disclose the payoff early.** Figures and specific facts that a later
  passage turns on must not appear in the paragraph before it.
- **Reject an actual wrong reading explicitly** where the preceding text makes
  the reader likely to reach it: name the reading, deny it, then give the real
  reason. `reference.discourse-grounding` decides whether that reading is live.
- **Explain a live contrast.** Once both alternatives are available, state why
  one fails and the other holds. A counterfactual may ground the distinction.
  Do not add an imagined misconception merely to make a contrast possible.

### Severity

`major` for an unrecoverable relation at a paragraph boundary or an argument
that loops back on its own conclusion; `minor` for placement.

---

## `structure.sentence-cohesion`

```yaml
lens: structure.sentence-cohesion
language: common
layer: structure
packing_group: structure
objective: Find adjacent propositions in explanatory or argumentative prose
  whose logical relation the reader must guess.
checks:
  - Adjacent propositions with no identifiable relation such as cause, result,
    condition, contrast, sequence, elaboration, or example.
  - A connective that names a different relation from the one the propositions
    actually support.
  - A run of individually clear assertions whose order and cumulative point
    cannot be recovered.
non_goals:
  - Do not require an explicit connective where syntax or meaning already makes
    the relation unambiguous.
  - Do not join propositions merely to make sentences longer.
  - A single proposition split by target-language sentence boundaries belongs
    to the language profile; this lens relates distinct propositions.
content_impact: none
```

### Rules

- Assign the relation between each adjacent pair in explanatory or
  argumentative prose. If no relation can be assigned, the sequence is not yet
  an argument.
- Require the relation to be recoverable; leave its natural realization through
  syntax, ordering, particles, or connectives to the language profile.
- Preserve a deliberate hard break where each assertion stands independently
  and the break supplies emphasis rather than hiding a relation.

### Severity

`major` when the missing relation changes how the reader understands the
argument; `minor` when the relation is recoverable but adds local processing
cost.

---

## `structure.enumeration-landing`

```yaml
lens: structure.enumeration-landing
language: common
layer: structure
packing_group: structure
objective: Find lists of properties, categories, or principles that are never
  connected to anything concrete.
checks:
  - Enumerations followed by no mapping onto the case, data, or scenario the
    section is about.
  - Items landed in a uniform, mechanical phrasing that adds nothing.
  - Lists used where the items are not co-ordinate.
content_impact: reordering
```

### Rules

- After enumerating properties or a taxonomy, land each item on the concrete
  material already in front of the reader, one at a time.
- Vary how the items land — identifying the cause, recognizing the case,
  matching a specific fact, conceding what must be given up. Uniform landings
  read as filler.
- A list whose items are not co-ordinate is a structural defect, not a
  formatting one: split it or convert it to prose.

An unlanded enumeration is a common and expensive machine-written defect. The
reader understands every item and still cannot use any of them, because nothing
in the list has been attached to the situation under discussion.

### Severity

`major`. An enumeration that never lands is close to information-free.

---

## `structure.document-shape`

```yaml
lens: structure.document-shape
language: common
layer: structure
packing_group: shape
objective: Falsify the claim that the headings identify their content, the
  sections are in a usable order, and prose and lists are used for the right
  material.
checks:
  - Headings that state a procedure rather than the subject or the question.
  - Headings that give away the section's conclusion.
  - Headings with no information content.
  - Sections whose order forces forward references.
  - Prose carrying material that is a list; lists carrying material that is an
    argument.
content_impact: structural
```

### Rules

- **A heading names the question the section answers, or the object it treats.**
  A noun phrase naming the object is acceptable. Interrogative or declarative
  form does not matter; identifying the content does.
- Use procedural headings when the reader is following a procedure and topical
  headings when the reader is locating or understanding material.
- A heading may disclose a conclusion when scanability or decision-making
  benefits from it. Preserve discovery only when the document's progression
  depends on the reader reaching the conclusion in sequence.
- **Order sections so the argument does not need forward references** to be
  followable.
- **Choose prose or list by the material.** Definitions, taxonomies, and
  co-ordinate options belong in lists. An argument with dependent steps belongs
  in prose; a bulleted argument hides the connectives that carry it. Machine
  writing over-uses lists for exactly this reason: the list format lets the
  connective be omitted.

### Reporting

Return document-shape concerns as plot or developmental-edit observations.
Record the intended structural change and its reason because it overrides an
authorial choice; do not send it through the local finding-application lane.

### Severity

`major` for a heading that does not identify its content or an order that
forces forward references; `minor` for prose/list choice.

---

## `structure.representation-choice`

```yaml
lens: structure.representation-choice
language: common
layer: structure
packing_group: shape
objective: Find material whose chosen representation makes its important
  relationships materially harder to inspect than another available form.
checks:
  - State transitions and transition conditions buried in prose or a flat list.
  - Data flow or dependency direction that must be reconstructed from sentences.
  - Hierarchy or containment expressed as an undifferentiated sequence.
  - A timeline or phase sequence whose order is difficult to scan.
  - Repeated fields or comparisons across common axes not aligned in a table.
  - A diagram or table used where prose, a list, or code would expose the
    relevant relationship more directly.
required_inputs:
  - target rendering, accessibility, and maintenance constraints, when known
content_impact: structural
```

### Rules

- Choose the form that exposes the relationship the reader needs: prose for a
  connected argument, a list for co-ordinate items or steps, a table for
  repeated fields and shared comparison axes, a diagram for direction, state,
  dependency, hierarchy, containment, or branching flow, and code where exact
  executable form is the subject.
- Prefer the smallest representation that makes the relationship inspectable.
  A short linear sequence may remain prose; a diagram is not a quota.
- Do not default to Mermaid or any other syntax. Select a form the target can
  render accessibly and the maintainer can update. Where those constraints are
  unknown, identify the needed representation without inventing a format
  requirement.
- Preserve every claim and epistemic status when changing form. A diagram or
  table reorganizes supported material; it does not supply missing facts.

### Reporting

Return representation changes as plot or developmental-edit observations.
Changing form overrides an authorial choice and may add or remove a document
element, so record the relationship to expose, the chosen form, and the reason.

### Severity

`major` when the current form obscures a relationship needed for the reader's
task; `minor` when another form would reduce scanning or comparison cost without
changing comprehension.

---

## `structure.genre-purity`

```yaml
lens: structure.genre-purity
language: common
layer: structure
packing_group: shape
objective: Examine whether each passage serves a reader need in a shape suited
  to that need, and whether mixtures remain navigable and intentional.
checks:
  - Tutorial material interrupted by reference tables or design rationale.
  - How-to guides that stop to explain why the mechanism works.
  - Reference material carrying narrative instruction.
  - Explanation carrying step-by-step procedure.
required_inputs:
  - the document's stated or evident purpose
content_impact: structural
```

### The four purposes

| Purpose | Serves | Shape |
|---|---|---|
| **Tutorial** | learning | a lesson: guided steps to a first success |
| **How-to** | a task | a recipe: steps that solve one stated problem |
| **Reference** | lookup | a description of the machinery, ordered for retrieval |
| **Explanation** | understanding | a discussion of why something is as it is |

### Rules

- Determine the reader need of the passage and the larger document. A label or
  directory name does not settle the genre.
- Separate or link material when a change of purpose interrupts the current
  use. A tutorial may include the explanation required for the next action; a
  reference may link to fuller explanation rather than absorb it.
- Mixed documents are normal. Make their boundaries and navigation clear rather
  than pursuing purity as an end in itself.

### Severity

Treat the issue as major only where the mixture defeats the reader's current
purpose. A short useful aside is not a defect by category alone.
