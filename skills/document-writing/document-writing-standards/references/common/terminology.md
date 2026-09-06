# Terminology Lenses

Language: **common**. Concept introduction is a planning and editorial judgment;
consistency and antecedent resolution can also be local checks. Follow each
lens's role in the standards index rather than assuming that all terminology
work is copyediting.

Worked examples of correct and defective introductions, and the vague words each
language falls back to, live in [Japanese examples](../ja/examples.md) and
[English examples](../en/examples.md), keyed by lens ID.

Documents that fail this layer can be read sentence by sentence and still not
be understood, because the reader is asked to carry a term whose meaning was
never fixed, to resolve a reference that has no unique target, or to supply a
contrast or frame that exists only outside the document.

---

## `terminology.definition`

```yaml
lens: terminology.definition
language: common
layer: terminology
packing_group: terminology
objective: Judge whether the intended reader has the conceptual understanding
  needed at the point of use, with attention proportional to novelty and
  argumentative centrality.
checks:
  - A concept central to the argument that the audience cannot yet understand.
  - A familiar term whose particular load-bearing property remains implicit.
  - A new central concept named before its motivation and boundaries can be
    understood.
  - A secondary concept given more explanatory weight than its role warrants.
  - An abstraction named even though ordinary prose would be clearer.
  - An abbreviation the audience cannot resolve at its first needed use.
non_goals:
  - Do not define established domain knowledge merely because it is technical.
  - Do not require every term to be defined before its first textual occurrence.
  - Do not require a formal term for a minor or one-off concept.
```

### What is judged

Judge the reader's conceptual state, not first-use position alone. Four inputs
govern the decision: audience prior knowledge, whether the concept is standard
or document-specific, its argumentative centrality, and the exact property the
argument depends on. First use is only a useful inspection point.

### Rules

- Assume established domain knowledge that the named audience can reasonably
  supply. Explain only the aspect this document uses when that aspect may not be
  part of the shared understanding.
- Develop a central unfamiliar concept from motivating context, examples, and
  boundaries toward a usable definition. Naming may come early as a provisional
  handle or late as a culmination; choose the order that supports understanding.
- Introduce a secondary unfamiliar concept briefly at the point of need.
- Leave a minor abstraction unnamed when repeating its concrete meaning costs
  less than teaching and maintaining a term.
- Expand an abbreviation when the audience needs the expansion, not by an
  audience-free first-use ritual.
- When several concepts are gathered under an umbrella, explain the relation
  that makes the grouping useful. They need not literally reduce to one thing.

### Severity

Treat the issue as major when the argument depends on a concept the reader
cannot construct. Late definition is not itself a severity. This lens produces
an editorial observation, not an auto-applicable finding.

---

## `terminology.consistency`

```yaml
lens: terminology.consistency
language: common
layer: terminology
packing_group: terminology
objective: Falsify the claim that one concept is named by one term throughout,
  and that each term keeps one status across the document.
checks:
  - The same concept under two or more names.
  - One term used for two different concepts.
  - A formalized term later replaced by a vague word.
  - A concept classified one way in one section and another way elsewhere.
  - Terms that are not the conventional usage in the field.
  - Orthographic variants of the same word.
non_goals:
  - Do not enforce a term the document has not adopted; report the
    inconsistency and pick the document's own dominant usage.
```

### Rules

- **One concept, one term.** Report every alias and name which occurrence to
  keep, choosing the document's dominant usage unless the standard usage of the
  field says otherwise.
- **No retreat to vague words.** Once a term has been formalized, do not fall
  back to a wide category word. Using a general word *before* the term is
  introduced is fine.
- **Consistent status across sections.** Where a thing is classified one way in
  one section, it must not be classified differently elsewhere. Definitions,
  classifications, and the standing of a term hold across the whole document.
- **Conventional terms and translations.** Choose the usage established in the
  field. Do not substitute a similar-looking word on general intuition. This
  matters most for translated terminology, where a near-synonym reads as an
  error to anyone who knows the field.
- **Orthographic variants** of one term (spacing, kana/kanji, hyphenation,
  capitalization) are findings at `minor`.

### Severity

`blocker` where one term denotes two concepts and the reader cannot tell which
is meant. `major` for aliasing and for retreat to a vague word. `minor` for
orthographic variants.

---

## `reference.antecedent`

```yaml
lens: reference.antecedent
language: common
layer: terminology
packing_group: terminology
objective: Find expressions whose referent the reader cannot resolve, or can
  resolve only by reading backwards.
checks:
  - Demonstratives and pronouns with more than one candidate antecedent, or none.
  - Abstract phrases that do not resolve uniquely from context.
  - References to material that has not appeared yet.
```

### Rules

- Every demonstrative and pronoun must have exactly one candidate in reach.
  Where it does not, name the referent.
- Where an abstract phrase does not resolve uniquely, fix it in place with an
  appositive in parentheses rather than forcing the reader to look back.
- Do not refer forward to a concept or a document that has not been introduced.
- Language-specific profiles decide when an omitted or grammatically controlled
  argument is recoverable. This common lens judges overt referring expressions.

Machine-written prose accumulates these because each sentence is locally
plausible. Phrases like "this point" or "in such cases" read as if they refer to
something, and the defect appears only when a reader tries to resolve them.

### Severity

`blocker` where no referent exists or two are equally available. `major` where
the referent is recoverable only by re-reading.

---

## `reference.discourse-grounding`

```yaml
lens: reference.discourse-grounding
language: common
layer: terminology
packing_group: terminology
objective: Falsify the claim that every focus, contrast, negation, metaphor,
  and retrospective reference relies only on a question, alternative,
  proposition, or mapping available to the reader at that point.
checks:
  - Focus constructions used before the text has raised a question or supplied
    alternatives that make the focus meaningful.
  - Negated alternatives that have not appeared and do not follow naturally
    from what the reader has seen.
  - A positive claim followed by a reversed denial of an equally inactive
    alternative.
  - Metaphors whose source-to-target mapping has not been established by
    concrete material.
  - Retrospective phrases that have a grammatical antecedent but rely on a
    proposition or distinction available only in drafting history.
non_goals:
  - Do not require an alternative to be stated verbatim when the preceding
    facts make the reader likely to infer it.
  - Do not reject a sentence that introduces and grounds its own comparison,
    or an ordinary topic-comment form that leaves no omitted context to recover.
  - Do not reject a conventional metaphor whose mapping is fixed and
    unambiguous in the document's field.
  - Do not infer drafting history, translation, or machine authorship from the
    form alone. Judge only the document up to the finding's location.
```

### The prefix test

Read from the document's start through the candidate expression, without later
text or conversation history. Identify:

1. the question, alternative, proposition, or mapping the expression assumes;
2. the earlier passage, immediate inference, or self-contained comparison that
   made it available; and
3. why focus, contrast, negation, or metaphor carries more information than a
   plain assertion here.

If the first or second answer cannot be located, the expression is ungrounded.
If both can be located but the third cannot, leave this lens and route needless
rhetoric to `prose.plain-expression`.

### Rules

- **Negate only a live alternative.** The negative side of a contrast must be
  an option already proposed, a reading the preceding text makes plausible, or
  a belief attributed to a real source. A sentence may establish its own
  comparison where it names the decision axis and grounds the distinction; its
  position before or after the positive claim does not matter.
- **Focus only an active question.** Forms equivalent to “what matters is X”
  or “what the evidence shows is X” require a question or competing candidates
  already present in the reader's model. A resolvable pronoun alone does not
  create that reason.
- **Ground a metaphor before spending it.** The reader must be able to map the
  metaphor's relevant parts onto concrete material already supplied, or onto a
  mapping made explicit in the sentence itself. Otherwise state the relation
  directly.
- **Treat conversation as source material, not document context.** A rejected
  draft, corrective feedback, prompt constraint, or abandoned interpretation
  is not available to the reader merely because it appeared during drafting.
- **Delete before backfilling.** Resolve an ungrounded expression first by
  stating its positive proposition or concrete relation plainly. Move an
  omitted premise earlier only when the document independently needs it. Never
  invent a reader misconception merely to license a contrast.

### Severity

`major` where the passage answers a question, rejects an alternative, or spends
a metaphor that the reader has had no reason to construct. `minor` where the
required state is available but only after avoidable re-reading.
