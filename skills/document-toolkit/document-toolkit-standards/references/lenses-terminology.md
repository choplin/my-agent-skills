# Terminology Lenses

Layer: **terminology** (phase 2). Language-neutral. Fixes change which words
name which concepts and what expressions refer to. `content_impact` is `none`
for renaming inside existing sentences, `reordering` where an introduction must
move.

Worked examples of correct and defective introductions, and the vague words each
language falls back to, live in [examples-ja.md](examples-ja.md) and
[examples-en.md](examples-en.md), keyed by lens ID.

Documents that fail this layer can be read sentence by sentence and still not
be understood, because the reader is asked to carry a term whose meaning was
never fixed, or to resolve a reference that has no unique target.

---

## `terminology.definition`

```yaml
lens: terminology.definition
layer: terminology
packing_group: terminology
objective: Find terms, coinages, and abbreviations that are used before the
  document has told the reader what they mean.
checks:
  - For each specialized term, locate its first use and its introduction, and
    report every case where the first use comes first.
  - Abbreviations expanded nowhere, or expanded after their first use.
  - Terms central to a section that the section never scopes.
  - Coinages introduced as bare dictionary assertions with no grounding.
  - Several concepts collapsed under a new umbrella term with no statement that
    they reduce to the same thing.
non_goals:
  - Do not report a passage that describes a concept and names it afterwards.
    That order satisfies this lens.
```

### What is judged

**The position of the term's first use, not the order of exposition.**

This distinction decides most of the findings this lens should and should not
produce. A passage that describes something, establishes what it does, and then
gives it a name is correct and is the normal way to introduce a concept in
technical writing: at the moment the name appears, the reader already holds its
meaning. The defect is the opposite case — the name appears first and the
reader is asked to carry it until an explanation arrives, or none arrives.

Worked pairs for both orders are in the example files for the document's
language.

### Rules

- A term central to a section is scoped before the section uses it.
- Do not introduce a new concept as a bare dictionary assertion of the form
  "X is Y". Place the object first, state what it does or how it differs, and
  give the definition after that if one is still needed.
- Expand every abbreviation at first use.
- Mark the term at the point of definition so the reader can see that this is
  where it is fixed. (The marking convention is `ja.notation` or `en.diction`
  depending on the language.)
- Where a list pairs terms with their definitions, use one consistent form
  across the list, with the term marked.
- When several concepts are gathered under one new umbrella term, state in one
  sentence, immediately before naming it, that they reduce to the same thing.
  Merging needs a bridge just as separating does.

### Severity

`blocker` where a term the argument depends on is never defined. `major` where
the definition arrives after the first use.

---

## `terminology.consistency`

```yaml
lens: terminology.consistency
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
layer: terminology
packing_group: terminology
objective: Find expressions whose referent the reader cannot resolve, or can
  resolve only by reading backwards.
checks:
  - Demonstratives and pronouns with more than one candidate antecedent, or none.
  - Abstract phrases that do not resolve uniquely from context.
  - References to material that has not appeared yet.
  - Participial or subordinate openers whose subject differs from the main
    clause's subject.
```

### Rules

- Every demonstrative and pronoun must have exactly one candidate in reach.
  Where it does not, name the referent.
- Where an abstract phrase does not resolve uniquely, fix it in place with an
  appositive in parentheses rather than forcing the reader to look back.
- Do not refer forward to a concept or a document that has not been introduced.
- An opening participial or subordinate clause must share its subject with the
  main clause.

Machine-written prose accumulates these because each sentence is locally
plausible. Phrases like "this point" or "in such cases" read as if they refer to
something, and the defect appears only when a reader tries to resolve them.

### Severity

`blocker` where no referent exists or two are equally available. `major` where
the referent is recoverable only by re-reading.
