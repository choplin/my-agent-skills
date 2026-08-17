# English Lenses

Layer: **english** (phase 4, alongside expression). These lenses apply only to
documents written in English. Determine that by reading the document.

Findings here are `content_impact: none`. They are among the cheapest lenses in
the catalog to run and the easiest to apply, because every rule is mechanical.

These two lenses are the English counterpart of `ja.notation` and `ja.diction`.
The rules come from the elementary usage rules and the misused-words reference
of Strunk's *The Elements of Style*; the compositional rules of that work
(paragraph unity, topic sentences, active voice, positive form, concrete
language, omitting needless words, word order, emphasis) are language-neutral
and live in the `structure.*` and `prose.*` lenses instead.

---

## `en.mechanics`

```yaml
lens: en.mechanics
layer: english
packing_group: english
objective: Find punctuation and sentence-boundary constructions that violate the
  usage conventions of English technical prose.
checks:
  - Possessive singulars formed without 's.
  - Series without a comma after each term but the last.
  - Parenthetic expressions not enclosed on both sides.
  - Co-ordinate clauses joined without a comma before the conjunction.
  - Independent clauses joined by a comma.
  - Sentences broken in two where one is required.
  - Opening participial phrases that do not refer to the grammatical subject.
```

### Rules

- **Possessive singular takes `'s`,** whatever the final consonant: *the
  service's owner*, *Charles's request*. Exceptions are the possessive pronouns
  (*its*, *hers*, *theirs*) and established forms of ancient names.
- **Serial comma.** In a series of three or more terms with one conjunction, put
  a comma after each term except the last: *read, transform, and write*. Keep it
  consistent across the document.
- **Enclose parenthetic expressions between commas on both sides.** A missing
  closing comma is the common failure. A restrictive clause takes no commas at
  all; the distinction between restrictive and non-restrictive is a meaning
  change, not a style choice.
- **Comma before a conjunction introducing a co-ordinate clause**: *The
  migration ran, but the index was never rebuilt.*
- **No comma splice.** Two independent clauses take a semicolon, a period, or a
  conjunction — never a bare comma.
- **Do not break a sentence in two.** A dependent fragment punctuated as a
  sentence is a defect unless the emphasis is deliberate and rare.
- **An opening participial phrase must refer to the grammatical subject.**
  *Having rebuilt the index, the query returned in 20ms* attributes the rebuild
  to the query. (A dangling opener whose referent cannot be recovered at all is
  also a `reference.antecedent` finding.)

### Severity

`minor` for possessives, serial commas, and clause punctuation. `major` for a
comma splice that makes the clause boundary ambiguous, and for a dangling
participle that misattributes the action.

---

## `en.diction`

```yaml
lens: en.diction
layer: english
packing_group: english
objective: Find word choices and register inconsistencies that break the
  conventions of English technical prose.
checks:
  - Words used in a sense their established usage does not carry.
  - Mixed American and British spelling.
  - Contractions and register shifting within one document.
  - Person and number shifting between sections.
non_goals:
  - Choosing between competing terms for one concept is
    terminology.consistency. This lens covers the word's register and form.
  - Cutting an empty intensifier is prose.plain-expression.
```

### Rules

- **Use words in their established sense.** The recurring offenders in technical
  prose:
  - *comprise* — the whole comprises the parts; it is not "is comprised of".
  - *less* / *fewer* — *fewer* for countables.
  - *which* / *that* — *that* introduces a restrictive clause, *which* a
    non-restrictive one, and takes commas.
  - *effect* / *affect*, *principal* / *principle*, *complement* /
    *compliment*, *discreet* / *discrete*.
  - *literally* for emphasis, *utilize* where *use* is meant, *methodology*
    where *method* is meant.
  - *due to* where *because of* is meant.
  - *e.g.* / *i.e.* used interchangeably.
- **One spelling convention.** American or British, consistently: *behavior* and
  *behaviour* do not mix, nor *-ize* and *-ise*.
- **One register.** Contractions are acceptable in documentation that has chosen
  an informal register, but they must not appear in a document that is otherwise
  formal.
- **One person and number.** Do not alternate between *we*, *you*, and the
  impersonal across sections. (Which one is appropriate inside an argument is
  `prose.voice`.)

### Severity

`major` for mixed register or mixed spelling convention across a document.
`minor` for individual word choices.
