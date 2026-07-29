---
name: document-toolkit-review
description: Use this skill when the user wants a document, plan, or proposal reviewed or revised, and you need to fix the stance and the deliverable up front. Triggers on "review this", "review this critically", "critique this", "find problems with", "what's wrong with", "review objectively", "how does this read", "assess this content", "revise this", "improve this writing", "make this clearer", "polish this document". Should NOT trigger for fact-checking accuracy (use document-toolkit-fact-check), for reworking a whole set of documents (use document-toolkit-distill), for dropping information a set no longer needs rather than rewording what it keeps (use document-toolkit-trim), nor for falsifying a completed artifact's claim against observable acceptance criteria (use artifact-review-toolkit-adversarial).
allowed-tools: Read, Write, Edit, MultiEdit
metadata:
  description-role: documentation
---

# Document Review

A thin selector over two axes. The review/revision *substance* — what to look at,
which flaws matter, how to phrase feedback — is yours to supply natively; this
skill only pins **the stance to take** and **the deliverable to produce**, because
those are what is tedious to restate every time. Do not expand this into a rubric.

Working values (candor, no flattery, honest critical assessment) already live in
the global instructions and apply here — don't restate them.

## Pick two things, then do the work

**Axis 1 — Stance:**
- `critical` — adversarial: hunt flaws, gaps, weak assumptions with no flattery.
- `objective` — neutral, from the reader's perspective: does it serve its reader, where does it lose them.

**Axis 2 — Deliverable:**
- `review` — return an assessment: findings and concrete, actionable feedback; do not edit the document.
- `revise` — return an improved document: apply the changes (Read/Edit/Write), producing the better version rather than just describing it.

If the user's phrasing already fixes an axis (e.g. "critique this" → critical+review,
"polish this" → revise), take it; otherwise ask only for the axis that's genuinely
ambiguous. Then produce that deliverable in that stance, drawing the specifics from
your own judgment of the document at hand.
