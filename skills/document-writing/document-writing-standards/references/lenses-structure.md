# Structure Lenses

Layer: **structure** (phase 3). Language-neutral. Fixes move text.
`content_impact` is `reordering` for paragraph work and `structural` for
anything that changes headings, section order, or the choice between prose and
list.

Concrete instances — connectives, heading forms, landing phrasings — live in
[examples-ja.md](examples-ja.md) and [examples-en.md](examples-en.md), keyed by
lens ID. Load the file for the document's language.

Structure is where prose that is locally readable still fails to be followable.
The reader can parse every sentence and still not be able to say what the
argument was.

---

## `structure.paragraph-unity`

```yaml
lens: structure.paragraph-unity
layer: structure
packing_group: structure
objective: Falsify the claim that each paragraph carries exactly one topic and
  announces it in its first sentence.
checks:
  - Paragraphs mixing several stages of movement (investigation, report,
    verification, evaluation).
  - Paragraphs whose first sentence does not identify what the paragraph is about.
  - Paragraphs whose actual topic sentence sits in the middle or at the end.
  - Co-ordinate ideas expressed in non-parallel form.
content_impact: reordering
```

### Rules

- One paragraph, one topic. A long paragraph that runs several stages together
  is split into one paragraph per step of the argument.
- The first sentence of a paragraph identifies its subject. Where the topic
  sentence is buried, move it to the front and let the rest follow from it.
- End the paragraph in conformity with how it began.
- Express co-ordinate ideas in parallel grammatical form.

### Severity

`major` where the topic sentence is missing or buried; `minor` for parallelism.

---

## `structure.signposting`

```yaml
lens: structure.signposting
layer: structure
packing_group: structure
objective: Find places where the reader cannot tell how a passage relates to
  what came before it, or where material is placed so that the sequence breaks.
checks:
  - Paragraph openings with no connective marking the relation to the previous
    paragraph.
  - Arguments that conclude, then handle objections, then restate the conclusion.
  - Forward references placed mid-argument.
  - Defenses of an example placed inside the passage they interrupt.
  - Information needed for a later payoff disclosed early.
  - A likely misreading left unaddressed before the real reason is given.
content_impact: reordering
```

### Rules

- **Mark the relation at the paragraph head.** Open with the connective that
  states how this step follows from the last. Machine-written prose typically
  has correct paragraphs in an unmarked sequence, which is why it reads as an
  undifferentiated flow.
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
- **Reject the wrong reading explicitly** where the reader is likely to reach
  it: name the reading, deny it, then give the real reason.
- **Ground a negation.** When writing "not A but B", add one sentence of
  grounds. A counterfactual usually serves.

### Severity

`major` for a missing connective at a paragraph boundary or an argument that
loops back on its own conclusion; `minor` for placement.

---

## `structure.enumeration-landing`

```yaml
lens: structure.enumeration-landing
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
- **Do not use a procedural heading** — one that names a writing move rather
  than a subject — or an information-free one.
- **Do not put the conclusion in the heading.** The reader should not know the
  outcome from the table of contents.
- **Order sections so the argument does not need forward references** to be
  followable.
- **Choose prose or list by the material.** Definitions, taxonomies, and
  co-ordinate options belong in lists. An argument with dependent steps belongs
  in prose; a bulleted argument hides the connectives that carry it. Machine
  writing over-uses lists for exactly this reason: the list format lets the
  connective be omitted.

### Reporting

Every finding from this lens carries `content_impact: structural`. A writer may
have chosen a section order or a heading deliberately, and the fix overrides
that choice. Findings here are reported separately from the rest so the change
is visible rather than folded into a general revision.

### Severity

`major` for a heading that does not identify its content or an order that
forces forward references; `minor` for prose/list choice.

---

## `structure.genre-purity`

```yaml
lens: structure.genre-purity
layer: structure
packing_group: shape
objective: Falsify the claim that the document serves one documentation purpose
  rather than mixing purposes that need different shapes.
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

- Determine the document's purpose from what it claims to be and who it
  addresses. Where the document does not declare one, infer it and say so in
  the finding.
- Report material that belongs to a different purpose, and where it should go.
  A tutorial that pauses for design rationale loses the learner; a reference
  that narrates cannot be scanned.
- Do not report a mixture the document's own framing justifies. A README
  deliberately spans purposes; a chapter may carry an explanation inside a
  tutorial as a marked aside.

### Severity

`major` where the mixture defeats the document's purpose for its reader;
`minor` for a short aside.
