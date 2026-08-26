# Logic Lenses

Layer: **logic** (phase 1). Language-neutral. Fixes change what the document
asserts, how it supports it, and how confidently it states it. Findings here are
applied first because they rewrite text that every later layer would otherwise
polish.

Worked before/after pairs, and the hedging and concession vocabulary of each
language, live in [examples-ja.md](examples-ja.md) and
[examples-en.md](examples-en.md), keyed by lens ID.

**These lenses do not judge whether a claim is true.** They judge whether the
document supports it, marks its status honestly, and holds together with
itself. A document can pass this whole layer and still be wrong about its
subject; route that to `document-toolkit-fact-check`.

---

## `logic.claim-support`

```yaml
lens: logic.claim-support
layer: logic
packing_group: logic
objective: Falsify the claim that each assertion is supported by what the
  document actually provides.
checks:
  - Assertions whose grounds appear nowhere in the text.
  - Causal claims stated without their mechanism.
  - Claims broader than the examples offered for them.
  - Distinct things collapsed into one.
  - Multi-causal phenomena reduced to a single cause.
```

### Rules

- **State the mechanism of a causal claim in one sentence.** Do not assert that
  A leads to B and leave out why.
- **Match the claim to its evidence.** Where the example supports only part of
  the claim, narrow the claim to what the example covers. Do not widen the
  example.
- **Do not merge what should be distinguished.** Separate decisions, separate
  causes, and different kinds of problem must not be gathered under one word.
- **Do not reduce a multi-causal case to one cause.** Where an example carries
  several kinds of problem, separate them and map each to the concept that
  explains it.
- **Quote what is being denied.** Where a negation belongs in the document,
  write the proposition itself exactly, in quotation marks. A vague denial that
  not everything is solved states nothing. `reference.discourse-grounding`
  decides whether the negated proposition is available to the reader at all;
  this rule does not license introducing one.

### Severity

`major` where an assertion the argument depends on has no stated grounds, or
where the claim exceeds its evidence. `minor` where the mechanism is inferable
but unstated.

---

## `logic.epistemic-status`

```yaml
lens: logic.epistemic-status
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
layer: logic
packing_group: logic
objective: Find places where the document contradicts itself, or leaves what it
  opened unclosed.
checks:
  - Passages asserting incompatible things about the same object.
  - Concepts treated differently in different sections.
  - Questions posed and never answered.
  - Forward references whose target never delivers.
  - Concessions and limitations that end the passage without resuming the
    argument.
  - Conclusions restated in a form the argument did not reach.
```

### Rules

- **A concept keeps one treatment across sections.** Where a definition,
  classification, or standing changes between sections, report both sites.
- **Every question the document poses is answered.** Where it is not, either
  answer it or remove the question. Do not open what is not closed.
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
