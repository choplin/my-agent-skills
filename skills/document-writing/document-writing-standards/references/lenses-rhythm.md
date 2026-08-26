# Rhythm Lens

Layer: **rhythm** (phase 5). Opt-in. Never selected by a default preset.

Every other lens in this catalog removes, replaces, or moves text. This one
**adds** text, which is why it runs last: apply it before the expression lenses
and they delete what it just introduced.

## When to enable it

Enable it for writing meant to be read continuously — a book chapter, a
long-form article, an explanatory essay. There the reader's momentum is part of
the objective, and prose that is correct but uniformly flat fails at it.

Do not enable it for reference material, procedures, READMEs, or design notes.
Sustained momentum is not their objective, and the devices this lens asks for
would cost the reader attention that the subject should be getting.

## The relationship to the rest of the catalog

Two apparent conflicts are not conflicts:

- **Hedging.** This lens asks for alternation between assertion and hesitation.
  `logic.epistemic-status` asks that uncertainty not be flattened into
  assertion. They agree. Where they differ is that a hesitation this lens
  introduces must still be honest: a belief the text will later overturn is a
  belief the writer actually held, not a device fabricated for pacing.
- **Naming after explanation.** This lens asks that a concept be introduced as
  a name for something the reader already feels, rather than as an opening
  definition. `terminology.definition` judges the position of a term's *first
  use*, not the order of exposition, so explaining and then naming satisfies
  both.

The real constraint is placement, not principle. Anything this lens adds is
still subject to `prose.self-reference` and `reference.discourse-grounding`: a
sentence introduced for pacing is padding if it talks about the document, and
it is ungrounded if it imports a belief, contrast, or metaphor the reader has
had no reason to construct.

---

## `rhythm.cognitive-pacing`

```yaml
lens: rhythm.cognitive-pacing
layer: rhythm
packing_group: rhythm
objective: Falsify the claim that the document sustains a reason to keep
  reading, rather than running at one cognitive mode from start to finish.
checks:
  - Runs of three or more long declarative sentences with no short footing or stop.
  - Dense paragraphs running three or more deep with no sparse paragraph between.
  - A fixed viewpoint distance held for a whole section.
  - An opening that states an agenda without creating any open tension.
  - A section opening that declares what the section will cover.
  - Theory introduced before the reader has felt the problem it names.
  - A close that ends on abstraction instead of landing on something concrete.
content_impact: none
```

### Rules

- **Beat.** Set footing with a short sentence, run with a longer one, stop with
  a short one. Alternate assertion with hesitation rather than asserting
  throughout.
- **Density.** After two or three dense paragraphs, place a sparse one. Its
  function is limited to one of three things: fixing a settled point in a line,
  presenting what is judged next, or switching viewpoint distance. Alternate
  paragraphs that sit close to the specifics with paragraphs that step back.
- **Opening.** The first few sentences open one unresolved tension. The form is
  free — restating the reader's experience, a question answered immediately, a
  general proposition the text will test, a belief stated and then broken by
  fact. What is prohibited is only the bare agenda list with no stance. An
  agenda carrying a stance is fine.
- **Section entry.** Do not open by declaring what the section covers. Enter by
  restating the unease the previous section left, by writing the objection the
  reader would raise, or from the writer's own admission. Put the bridge between
  sections at the head of the next section, not at the foot of the previous one;
  a "next we look at…" at a section's end is a `prose.self-reference` finding.
- **Theory as naming.** Introduce a theory or a concept after the reader has an
  unnamed unease for it to name. Leading with the theory and confirming it with
  an example takes the discovery away.
- **Close.** Land the accumulated abstraction on something the reader already
  holds — the opening scene, their own experience, the question raised early —
  before closing. One tension may be left open.
- **Boundaries.** Second-person address, requests to the reader, and the
  writer's own caveats belong at a chapter opening or close, not in the middle
  of an argument.
- **No fabricated tension.** Do not create pacing by attributing an unsupported
  belief to the reader, reviving an alternative rejected during drafting, or
  introducing a metaphor before its concrete relation exists. Every addition
  must pass `reference.discourse-grounding` against the document prefix.

### Applying findings from this lens

Every finding must name the situational material the addition will be built
from: an event, a datum, a statement, a tradeoff, or a state of the writer's
judgment. Where the section offers no such material, leave the passage flat.
Manufacturing a beat out of sentences about the document is the failure mode
this lens most easily produces, and `prose.self-reference` will correctly delete
the result. Manufacturing a disagreement or discovery from drafting history is
the other failure mode; `reference.discourse-grounding` will delete or flatten
it.

### Severity

`minor` throughout. Nothing this lens finds prevents the document from being
understood.
