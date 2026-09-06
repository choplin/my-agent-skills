# Logic Lenses

Language: **common**. These are planning principles and editorial heuristics.
They change what the document asserts, how it supports it, and how confidently
it states it, so they do not flow directly through copyedit or automatic
finding application. Use them with the assignment, sources, focus, and plot.

Worked before/after pairs, and the hedging and concession vocabulary of each
language, live in [Japanese examples](../ja/examples.md) and
[English examples](../en/examples.md), keyed by lens ID.

**These lenses do not judge whether a claim is true.** They judge whether the
document supports it, marks its status honestly, and holds together with
itself. A document can pass this whole layer and still be wrong about its
subject; route that to `document-toolkit-fact-check`.

---

## `logic.claim-support`

```yaml
lens: logic.claim-support
language: common
layer: logic
packing_group: logic
objective: Examine whether material claims have the kind and amount of support
  their role, genre, audience, and stated confidence require.
checks:
  - Load-bearing assertions whose grounds appear nowhere in the document or its
    declared sources.
  - Causal claims whose mechanism the intended reader needs but cannot supply.
  - Claims broader than the examples offered for them.
  - Distinct things collapsed into one.
  - Multi-causal phenomena reduced to a single cause.
```

### Rules

- **Make needed support available at the useful scale.** A causal mechanism may
  be local, developed in a later passage, represented visually, cited to an
  accepted source, or treated as prior knowledge. Decide from the claim's role
  and the audience; do not require one explanatory sentence per causal claim.
- **Match the claim to its evidence.** Where the example supports only part of
  the claim, narrow the claim to what the example covers. Do not widen the
  example.
- **Do not merge what should be distinguished.** Separate decisions, separate
  causes, and different kinds of problem must not be gathered under one word.
- **Do not reduce a multi-causal case to one cause.** Where an example carries
  several kinds of problem, separate them and map each to the concept that
  explains it.
- **Develop support when the argument needs it.** The remedy may add evidence,
  mechanism, an example, a limitation, or an entire movement to the plot. It may
  instead narrow or remove the claim. Choose the smallest change only after
  deciding which argument the document ought to make.

### Severity

Treat an unsupported load-bearing claim as a major editorial issue. A mechanism
the audience can supply, or one intentionally deferred and signposted, is not an
issue merely because it is absent from the sentence.

---

## `logic.epistemic-status`

```yaml
lens: logic.epistemic-status
language: common
layer: logic
packing_group: logic
objective: Falsify the claim that fact, opinion, hypothesis, and inference are
  distinguishable in the text, and that each is stated at the confidence its
  grounds support.
checks:
  - Speculation, inference, or an unverified possibility written as established
    fact.
  - Guarantees of detection, prevention, or resolution stated unconditionally.
  - Conclusions hedged with no reason to hedge.
  - Statements presented as verified that the writer did not verify.
  - Opinion presented in the register of fact.
```

### Rules

- **Do not convert uncertainty into assertion.** A hedge is removed only where
  it weakens a claim the text has already grounded. Preserve it where it carries
  an unverified possibility, a person's belief, an inference from evidence, a
  doubt the reader would raise, or a counterfactual.
- **Do not weaken a grounded conclusion.** Where the grounds are in the text,
  state it plainly. Deliberate softening for register is allowed.
- **Do not promise what holds conditionally.** Detection, guarantees, and
  resolution are stated with their conditions.
- **Do not narrate the unverified as verified.** Where the writer has not
  checked something, the text must not read as if they had.
- **Mark opinion as opinion** where the surrounding text is factual, and mark a
  hypothesis as a hypothesis where it has not been tested.
- **Concessions state facts only.** In a concession, do not assert as the
  writer's own causal claim something the text will later correct. Attribute the
  surface reading to the reader or to received opinion.
- **Be honest about a contrived example.** Where an example may look
  constructed, acknowledge the doubt and give short grounds — drawn from what
  the reader is likely to have experienced, not from the writer's assertion that
  it is realistic.

This lens is the counterweight to `prose.plain-expression` and
`prose.concision`, both of which cut hedges. Where they conflict, this lens
wins: a preserved hedge costs a few words, and a false assertion costs the
reader's trust in the document.

### Severity

`blocker` where speculation is stated as fact in a way that would change a
reader's decision. `major` for unconditional guarantees and for unmarked
opinion. `minor` for groundless hedging.

---

## `logic.internal-consistency`

```yaml
lens: logic.internal-consistency
language: common
layer: logic
packing_group: logic
objective: Find places where the document contradicts itself, or leaves what it
  opened unclosed.
checks:
  - Passages asserting incompatible things about the same object.
  - Concepts treated differently in different sections.
  - Questions that promise an answer and never deliver it.
  - Forward references whose target never delivers.
  - Concessions and limitations that end the passage without resuming the
    argument.
  - Conclusions restated in a form the argument did not reach.
```

### Rules

- **A concept keeps one treatment across sections.** Where a definition,
  classification, or standing changes between sections, report both sites.
- **Every promised answer is delivered.** Answer or remove a question that the
  document presents as something it will resolve. A final thematic tension may
  remain open when no later answer was promised and the ending makes that choice
  distinguishable from an omission.
- **Every forward reference delivers.** A promise that a later section takes
  something up must be discharged where it says. An unpaid forward reference is
  a defect, not a stylistic choice.
- **A concession resumes.** After a concessive or an adversative, the argument
  continues. Do not end on the reversal and leave the reader suspended.
- **The stated conclusion is the one the argument reached.** Report conclusions
  that are stronger, broader, or simply different from what the preceding text
  established.

### Severity

`blocker` for a direct contradiction between two passages. `major` for an
unanswered question, an undelivered forward reference, or a conclusion the
argument did not reach.
