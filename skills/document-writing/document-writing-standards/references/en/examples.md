# Examples — English

Concrete instances of the common and English-profile lenses. Keyed by lens ID.
Load alongside the lens definition; the lists are
illustrative, not exhaustive.

Examples for planning principles and editorial heuristics illustrate contextual
judgments, not constructions that must always produce a finding.

English-only conventions carry their own rules and examples in
[conventions.md](conventions.md); composition rules live in
[composition.md](composition.md).

---

## `en.argument-explicitness`

```text
Before: After moving the records to the central store, no longer knew which restrictions applied.
After: After the platform team moved the records to the central store, its administrators no longer knew which restrictions applied.
```

Name the actor understood by the introductory modifier and the subject of the
main clause. Do not require repetition when coordinated predicates still share
one local subject and role.

---

## `en.information-order`

```text
Before: Because each department knows how its data is produced, who may use it, and under which restrictions, and because violations can cause incidents, difficult for a central administrator is governing every dataset.
After: A central administrator cannot easily govern every dataset because each department holds the production and usage knowledge, including restrictions whose violation can cause incidents.
```

Place the governing claim early when a long opening would delay it beyond easy
retention. Keep a short initial condition when the reader needs that frame first.

---

## `en.clause-linkage`

```text
Before: Each department owns the usage rules. The central team takes custody of the data. It needs company-wide authority.
After: Because each department owns the usage rules, transferring custody to a central team requires company-wide authority.
```

Rank the ground as a dependent clause and retain the requirement as the main
claim. Do not add causation if the source establishes only sequence.

---

## `en.sentence-boundaries`

```text
Before: The data leaves its owner. Moving under a central administrator. Who lacks the local usage knowledge.
After: The data leaves its owner and moves under a central administrator who lacks the local usage knowledge.
```

Join fragments that complete one movement. Keep separate sentences where the
topic, time, viewpoint, or argumentative job changes.

---

## `en.voice`

```text
Before: The restrictions are interpreted and access is approved.
After: Each department interprets its restrictions and approves access.
```

Restore the actor when ownership matters. Keep the passive when the actor is
unknown or irrelevant and the affected object is already the topic.

---

## `en.cadence`

```text
Before: Departments produce data. Departments store data. Departments define usage rules.
After: Departments produce and store their own data, and they define its usage rules. Distribution starts there.
```

Develop the parallel facts together, then use the short sentence as deliberate
footing. Do not vary length merely to avoid a visible pattern.

---

## `en.diction`

- Summary tense: “The worker reads the record, validated it, and then writes the
  result” becomes “The worker reads the record, validates it, and then writes the
  result” when all three actions belong to the same summary viewpoint.
- Capability and permission: use *can* for ability and *may* for permission when
  the distinction changes the instruction.
- Amount readings: keep “10 items or less” and “less than 20 minutes”; prefer
  “fewer retries” for individually counted attempts.
- Ambiguous *while*: replace it with *during*, *whereas*, *although*, or a more
  direct clause relation only when the intended relation is otherwise unclear.

---

## `prose.plain-expression`

**Empty qualifiers**: crucial, essential, key, vital, fundamental,
comprehensive, holistic, robust, seamless, powerful, very, extremely,
significantly, incredibly.

- Bad: A comprehensive analysis reveals that the key factor is data quality.
- Good: Evaluation turns on who knows the right answer.

**Empty verbs**: delve into, dive deep, unpack, explore, leverage, touch on,
shed light on, highlight the fact that.

- Bad: This chapter delves into the theory of consistency.
- Good: This chapter covers the theory of consistency.

**Announcement in place of the claim**: It is important to note that…, It's
worth mentioning that…, One key takeaway is…, The crucial point here is…

Allowed announcements of form: Put another way…, As a slogan…

**Connective padding with no new information**: In terms of…, From the
perspective of…, When it comes to…, In the context of…, and runs of
Furthermore / Moreover / Additionally.

**Setting padding**: In today's fast-paced world…, As technology continues to
evolve…, Now more than ever…

**Undetermined figures and mixed metaphors**

- Bad: This unlocks a whole new world of possibilities.
- Good: This removes the manual approval step.

**Register borrowing**: do not call an ordinary sequence a "pipeline", a plain
list a "taxonomy", or a preference a "constraint" unless the term's technical
sense is meant.

**Judgment over command**: prefer "this is not worth the coupling it buys" to
"you must never do this", where the text is reasoning rather than specifying.

---

## `prose.self-reference`

Sentences that fail the topic test (all report on the document, not the
subject):

- In this chapter, we will explore…
- Now that we have seen X, let's turn to Y.
- Before we dive in, it's worth setting some context.
- To summarize what we have covered so far…
- This section does not attempt to cover Z.
- It is beyond the scope of this document to…
- Let's take a closer look.
- The remainder of this document is organized as follows.

Permitted forms:

- Rebutting a quoted misreading: Read as "never use inheritance", this is wrong.
- Posing and discharging a question: Half the answer is here; the rest is in the
  next section.
- Opening and closing an example frame: Suppose a service does X. / So much for
  the opening example.

Rewriting rather than deleting:

- Before: So far this has looked like an abstract discussion.
- After: All three properties are present in the failure described at the start.

---

## `prose.concision`

- Transition-only sentences: This is a good thing in itself. / With that said…
- Manufactured reader dialogue: You might be wondering why. The answer is yes.
- Meta framing: There is a natural extension to this idea. / This is the notion
  of X.
- Author self-defense: This is not to say that the alternative is wrong.
- Hedged conclusions where the grounds are already given: this can be a useful
  measure → this is required in practice

Compress parallel facts into one sentence with their shared status at the head:

- Good: Naturally, monthly close, customer payments, and payroll all run through
  the same path.

Not padding: connectives that carry rhythm — But then again…, And yet…

---

## `prose.sentence-load`

- Do not name what is never referenced again: `OrderTotalCalculator.java`,
  `v2.14.3`, `handleRequestInternal`. Write "the pricing utility", "the
  handler".
- Fix ambiguous abstractions in place with an appositive: "the second approach
  (recomputing on read)".
- Strip decorative precision: timestamps, HTTP status codes, coverage
  percentages, p99 figures the argument does not turn on.
- Place the emphatic element last: "The migration failed because the index was
  missing" over "Because the index was missing, the migration failed" — when the
  missing index is the point.

---

## `prose.voice`

- Passive result-listing: The cause was identified and the fix was applied.
- Actor-driven: The on-call engineer traced it to the retry loop and removed it.
- Decorative persona: Imagine a junior developer in their second year…
- Second person inside an argument: replace "you should cache this" with "the
  service caches this".
- Vague category words: "AI", "the tool", "the system" where a specific name
  exists.
- Negative where positive is available: "did not remember" → "forgot";
  "not important" → "trivial".

---

## `structure.signposting`

One way to state a relation at a paragraph boundary is an opening connective:
If so, / In fact, / But, / Even this example shows… Do not add one where order
or syntax already makes the relation clear.

- Reject a reading only when the preceding facts make it live: The reason is
  not that the schema changed. It is that two writers held the same lock.
- Ground a live contrast with a counterfactual: Had the contract been explicit,
  the mismatch would have surfaced at build time.
- Place forward references at a resting point: "The next chapter takes this up"
  belongs at the end of a paragraph or section.

---

## `structure.sentence-cohesion`

```text
Before: The cache entry expires. A worker refreshes it. Other requests receive the old value.
After: When the cache entry expires, one worker refreshes it. Meanwhile, other requests receive the old value.
```

The first relation is a condition and the second is concurrency. The repair
states those relations; it does not merely join the sentences.

```text
Keep: The migration failed. Data was lost.
```

Where the source establishes no causal relation, do not invent one with a
connective.

---

## `structure.enumeration-landing`

Land each item on material already in front of the reader:

- The first is what went wrong in the opening incident.
- The second will be familiar to anyone who has run a migration under load.

Vary how items land — naming the cause, recognizing the case, matching a
specific fact, conceding what must be given up. Uniform landings read as filler.

---

## `structure.document-shape`

- Procedural heading (avoid): Back to the Example / Revisiting the Code
- Bare genre label (avoid): Background / Notes / Details
- Headings that identify content: Why Retries Amplify Load / Ownership at the
  Transaction Boundary

---

## `structure.representation-choice`

- States plus conditional branches: use a state diagram when the reader must
  inspect the normal path and failure exits together.
- Repeated comparison axes: align each option's subject, duration, and use in a
  table.
- A short causal relation: keep two propositions in connected prose when a
  diagram would expose nothing more.
- Exact executable form: put configuration or invocation syntax in code.

Do not choose Mermaid unless the target is known to render and maintain it. The
requirement is an inspectable representation, not a particular renderer.

---

## `terminology.definition`

- Correct order (explain, then name): When several stages share a representation
  for passing data, changing that representation affects all of them. This
  dependency is **coupling**.
- Defect (name first): The goal of the design is to reduce **coupling**.
  (Coupling is not defined before this point.)
- Do not open with a bare dictionary assertion: instead of "Idempotency is the
  property that…", place the object first, state what it does, then define it.
- Expand abbreviations at first use: "write-ahead log (WAL)", not a bare "WAL".

---

## `terminology.consistency`

- Retreat to vague words (avoid): the system, the tool, the AI, the mechanism
- Inconsistent standing across sections: "the operator decides" in one section,
  "the team agrees" in another
- Aliasing: job / task / work item for one concept
- Orthographic variants: log in / login / log-in; datastore / data store

---

## `reference.discourse-grounding`

Read only from the document's start through the candidate expression.

### Ungrounded contrast

When monitoring has not appeared, reversing the clauses does not fix the
defect.

```text
Before: This is not a monitoring problem. It is a prevention problem.
Also before: The service needs prevention. Monitoring is not the answer.
After: The service must reject invalid input before processing it.
```

### Grounded contrast

Keep the contrast when the document supplies both the alternative and the
distinction.

```text
Keep: The operations team proposed more monitoring. Monitoring detects a
failure after it happens; it cannot reject invalid input before processing.
```

Keep a comparison that states its own axis and complete rule.

```text
Keep: Pricing depends on request volume, not user count.
```

### Focus

```text
Before: That is what the logs show.
After: The logs record the same timeout.
```

### Metaphor

```text
Before: This interface is the bridge between both teams.
After: Both teams exchange the same application data through this interface.
```

### Drafting context

A rejected draft or corrective instruction available only during drafting is
not a document alternative. Do not invent a reader misconception to preserve a
contrast.

---

## `logic.claim-support`

State the mechanism of a causal claim.

- Bad: Splitting by procedure makes changes ripple across the system.
- Good: Each stage shares the representation used to pass data along, so
  changing that representation reaches every stage.

Do not merge what should be distinguished.

- Bad: They kept making the same decision separately.
- Good: These were three distinct decisions, and each depended on the others.

Quote the proposition being denied. "Not everything is solved by this" states
nothing; "This does not mean 'anything specified can be delegated'" does.

---

## `logic.epistemic-status`

- Bad: rewriting "the model may still be serving stale data" as "the model is
  serving stale data"
- Good: "the model may still be serving stale data" — the possibility is
  unverified and the hedge carries that

State conditions rather than guarantees: tends to, usually, in most
deployments, only when the invariant holds.

Concessions state facts only. Attribute a surface reading you will later
correct to the reader or to received opinion: "It is tempting to summarize this
as a caching problem."

Defend a contrived example from the reader's experience, not by assertion: "This
failure is not unusual" rather than "This is a realistic scenario."

Deliberate softening for register is allowed: "required, one might say".
