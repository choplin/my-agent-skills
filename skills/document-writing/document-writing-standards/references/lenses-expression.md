# Expression Lenses

Layer: **expression** (phase 4). Language-neutral. Fixes stay inside a sentence
or a paragraph; `content_impact` is `none` for nearly every finding here.

Every rule below holds in any language. The words that instantiate each rule do
not, so the word lists and the before/after pairs live in the example files:
[examples-ja.md](examples-ja.md) and [examples-en.md](examples-en.md), keyed by
lens ID. Load the file for the document's language and use it as the concrete
form of these rules — the list is illustrative, not exhaustive.

This layer carries the largest share of what makes machine-written prose
expensive to read. The defects are not errors of fact: the text is often correct
and still costs the reader far more attention than the content is worth.

---

## `prose.plain-expression`

```yaml
lens: prose.plain-expression
layer: expression
packing_group: expression
objective: Find text that performs erudition or rhetoric instead of carrying
  information, where a plain wording exists and would say the same thing.
checks:
  - Empty intensifiers and empty qualifiers that add no proposition.
  - Verbs that name the act of writing instead of what was written.
  - Announcements of importance in place of the important thing.
  - Rhetorical devices used where a plain statement would do.
  - Figures of speech whose referent is not determined.
  - Words chosen for register rather than precision.
non_goals:
  - Do not flatten genuine uncertainty into assertion. That is
    logic.epistemic-status, and it protects hedges this lens would otherwise cut.
  - Do not remove a device that is doing real work at a turning point.
```

### Rules

- **Empty qualifiers.** A word marking emphasis without stating what is
  emphasized carries no proposition. Delete it, or replace it with the content
  it was standing in for.
- **Empty verbs.** A verb describing the act of writing, rather than what was
  written, ends the sentence with nothing said. The same applies to declaring a
  stance toward the material instead of taking it.
- **Announcement in place of the claim.** Predicting that something is important
  is not stating it. Write the claim. Announcing the *form* of what follows —
  that it is a restatement, a slogan, a summary — is allowed.
- **Undetermined figures.** A metaphor whose referent the reader cannot pin
  down, or a twisted idiom, costs more than it conveys. Use a plain verb.
- **Restraint, not prohibition, for devices.** Rhetorical questions, suspense,
  one-line paragraphs used as punch lines, and antithesis are permitted where
  the tension does argumentative work. Flag them where a plain statement
  suffices, and flag repetition of the same device.
- **Bold emphasis** in body text is limited to the logical hinges — a negation
  that prevents misreading, a section's conclusion. One or two per section.
  Everything else is made prominent by sentence order and structure.
- **Do not escalate.** Do not dramatize turning points, and do not stack
  consequences to alarm the reader about risk. A sentence of fact is usually
  enough.
- **Register borrowing.** Do not reuse a word that sounds like a technical term
  in a non-technical position. Use the ordinary phrasing.

### Severity

Empty qualifier or verb, padded announcement: `minor`. A figure the reader
cannot resolve, or a passage whose actual claim is unrecoverable behind the
rhetoric: `major`.

---

## `prose.self-reference`

```yaml
lens: prose.self-reference
layer: expression
packing_group: expression
objective: Find sentences whose subject is the document itself rather than the
  subject matter.
checks:
  - Apply the topic test to every paragraph-initial sentence and every
    standalone short sentence.
  - Find section-opening declarations of what the section will cover.
  - Find section-closing previews of what comes next.
  - Find restatements of the document's own character or scope.
non_goals:
  - Do not delete the four permitted forms listed below.
```

### The topic test

One axis decides it: **does this sentence update the situation, or the
document?**

- **Updates the situation** — reports something about the subject: an event,
  data, a statement, a measurement, a tradeoff, or the writer's own state of
  judgment (a belief held, a decision deferred, a concession). Keep.
- **Updates the document** — reports only how this chapter, this section, or the
  discussion so far looks, or what will be written next. Delete.

Document-updating sentences also appear in short, assertive form. Shortening one
into a crisp declarative makes it read like a deliberate beat, and that is the
main route by which it survives revision. **Rhythm is not a reason to keep a
sentence.** Judge the topic first; judge the phrasing only on sentences that
pass.

### Permitted forms

Four kinds of sentence about the document may stay:

1. **Rebutting a misreading** — the misreading is quoted exactly and then
   rejected. A vague disclaimer with no quoted target does not qualify.
2. **Posing and discharging a question** — at a boundary, stating the question
   the chapter takes up once tension exists, and marking where its answer
   arrives. Declaring what the document will *not* do is not a question.
3. **Addressing the reader at a boundary** — a request or caveat at a chapter
   opening or close.
4. **Opening and closing an example frame** — entering a hypothetical and
   leaving it, placed at a section boundary.

### Remediation

Delete first and read across the gap. If deletion breaks the logic, rewrite the
sentence so it states the situation it was gesturing at. A rewrite that is still
about the document — merely shorter, or reworded — has failed. Delete it and
bridge the surrounding sentences instead.

### Severity

`major`. These sentences are pure overhead, and they are dense in
machine-written text.

---

## `prose.concision`

```yaml
lens: prose.concision
layer: expression
packing_group: expression
objective: Find text that can be removed without losing information.
checks:
  - The same claim made more than once in different words.
  - A summary placed immediately after the passage it summarizes.
  - Sentences that exist only to connect or to evaluate.
  - Intermediate steps a reader can supply unaided.
  - Multi-sentence arguments compressible into one sentence.
  - Rhetorical dialogue with an imagined reader.
non_goals:
  - Do not cut context the reader has not yet been given. Shortening an
    introduction by dropping scope, comparison axes, or open questions is
    omission, not concision.
  - Do not cut connectives that carry logical relation. That is
    structure.signposting's material.
```

### Rules

- State a claim once. Restating it from another angle is repetition, not
  reinforcement.
- Do not summarize a passage right after presenting it. One sentence of
  interpretation is enough.
- Parallel facts with the same logical role belong in one sentence, with their
  shared status marked at the head.
- Delete sentences whose only function is transition or evaluation.
- Delete rhetorical dialogue with an imagined reader — a question posed and
  answered in a word, or a reaction attributed to the reader and then confirmed.
  Make concessions plainly in the writer's own voice. A genuine reader question
  may stay as a question.
- Do not introduce an idea through a meta frame. State the idea.
- Do not defend the writer's own position. State the fact.
- Do not name a concept or a document before it has been introduced.
- Where the grounds are already established in the text, do not hedge the
  conclusion into vagueness. Name the structure and state it.
- Connectives that carry rhythm are not padding.

### Severity

`minor` per instance; `major` where a section's length is dominated by
restatement.

---

## `prose.sentence-load`

```yaml
lens: prose.sentence-load
layer: expression
packing_group: expression
objective: Find text that forces the reader to hold more than necessary, or to
  read backwards.
checks:
  - Sentences long enough, or nested deeply enough, that the subject and its
    predicate lose contact.
  - Proper nouns and identifiers introduced but never referenced again.
  - Detail unrelated to the question the section answers.
  - Asides that belong in a footnote.
  - Related words separated by intervening material.
  - Emphatic content buried mid-sentence instead of placed at the end.
```

### Rules

- **Do not name what will not be referenced again.** File names, function names,
  identifiers, and version numbers appearing once cost recall and return
  nothing. Use a general description instead.
- **Fix ambiguous abstractions in place.** Where an abstract phrase does not
  resolve uniquely, add an appositive at the point of use rather than making the
  reader search backwards.
- **Justify new context.** When a new example or scenario increases what the
  reader must hold, state up front how it differs from the previous one and why
  another is needed.
- **Strip decorative precision.** Timestamps, status codes, coverage
  percentages, and similar detail the section's question does not turn on. Keep
  the specifics the argument needs.
- **Send asides to footnotes.** Etymology, the name of a formulation, and other
  material one step off the main line belongs in a footnote, not inline.
- **Keep related words together**, and **place the emphatic element at the end
  of the sentence.**

### Severity

`minor` for a single unnecessary identifier; `major` where a sentence must be
re-read to be parsed.

---

## `prose.voice`

```yaml
lens: prose.voice
layer: expression
packing_group: expression
objective: Find narration that obscures who acts, addresses the reader wrongly,
  or blurs the object under discussion.
checks:
  - Passive constructions and result-listing where an actor performed the action.
  - Second-person address outside a boundary position.
  - Vague category words standing in for the actual object.
  - Fictional persona framing attached to an example for no purpose.
  - Statements in negative form where a positive form is available.
```

### Rules

- **Actor as subject.** In examples, write a chain of actions with an actor, not
  a list of results in the passive.
- **No decorative personas.** A fictional profile attached to an example adds a
  constraint the argument does not use.
- **Address by role.** Within an argument, name the role — developer, reader,
  operator. Second-person address belongs at a boundary: entering a scenario, or
  closing a chapter.
- **Name the object precisely.** Do not blur it with a wide category word. Once
  a term has been formalized in the text, keep using it and do not retreat to a
  vague one. Using a general word *before* the term is introduced is fine.
- **Prefer the positive form.** State what is so rather than what is not, unless
  the negation is the point.
- **Write directives as judgment, not command,** where the text is reasoning
  rather than specifying.

### Severity

`minor` for voice and address; `major` where the actor or the object of a claim
cannot be determined from the sentence.
