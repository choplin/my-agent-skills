---
name: document-writing-base
description: >-
  Shared machinery for the line-edit, copyedit, audit, and selected-finding
  application lanes in the document-writing family. Preserves editorial context,
  distinguishes heuristic observations from conformance findings, applies only
  authorized changes, and verifies that editing did not damage the document.
user-invocable: false
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: documentation
---

# Document Writing Base

This skill serves downstream editorial passes. It does not replace assignment,
discovery, focus, content modeling, plotting, or developmental editing.

Read the selected lens definitions in `document-writing-standards` before use.
Respect their roles: planning principles produce upstream decisions, editorial
heuristics produce contextual observations, and conformance checks may produce
directly applicable findings.

## Lane contract

```yaml
stage: line | copyedit | audit | apply
guidance: <lens IDs, roles, or layers>
deliverable: revised-document | observations | findings
intervention: content-preserving | selected-findings
verify: true | false
```

The caller may narrow these values. Never expand its authority implicitly.

## Required context

Receive the document plus as much of this packet as exists:

```yaml
editorial_context:
  audience: <identity and relevant prior knowledge>
  use: <reading or work situation>
  outcome: <intended understanding, decision, or action>
  document_kind: <genre or technical-document kind>
  focus: <governing idea>
  plot: <current durable artifact or concise equivalent>
  house_style: <if any>
  protected_content: []
  permitted_intervention: <boundary>
```

If the context needed to judge a heuristic is absent, report the limitation or
route the work to `document-writing-review`; do not pretend that an isolated
sentence test can recover document intent.

Reviewers may be independent of one another and blind to other findings. They
must still receive the relevant editorial context. Do not give them a leading
claim about where a defect is expected.

## Line edit

Read the document as connected prose, not as a bag of sentences. Use editorial
heuristics to inspect paragraph movement, continuity, emphasis, transitions,
sentence realization, voice, and cadence. Produce one coherent revision within
the content and structural boundary.

When a good remedy requires a new claim, new explanation, section movement, or
changed emphasis, do not improvise it locally. Return an observation to the
earliest owning stage: focus, content model, plot, or developmental edit.

## Copyedit

Select applicable `check` lenses for the prose language and house style. Detect
only locally falsifiable defects. Apply them in dependency order when necessary:

1. terminology and reference;
2. proposition or clause integrity;
3. syntax, mechanics, notation, and diction.

Re-check an exact anchor immediately before applying a finding. A missing or
changed anchor is stale. Deduplicate findings by cause and anchor.

## Conflict rules

- Preserve a hedge that expresses real uncertainty.
- Prefer a resolvable referent over superficial concision.
- Establish argument roles before optimizing topic, order, or linkage.
- In Japanese, recover required arguments before judging proposition hierarchy;
  establish hierarchy before connective or boundary choices.
- In English, establish explicit argument roles before information order and
  clause linkage; grammar outranks a stylistic boundary preference.
- A copyedit never overrides the current focus or plot.

If two heuristics disagree, decide from audience, purpose, and passage movement;
do not resolve by vote or a universal priority table.

## Preservation and verification

For every applying lane, compare before and after. Verify that the edit did not:

- remove or add a claim, condition, limitation, contrast arm, or instruction;
- change epistemic status or source attribution;
- break a cross-reference or representation;
- flatten the plotted emphasis or reader movement;
- introduce a new local defect.

Repair only damage caused by this pass. New substantive opportunities are
observations for an upstream revision, not hidden scope expansion.

## Report

Return the revised document or located results first, then state:

- editorial context used and any missing context;
- stage and intervention boundary;
- material line-edit choices or applied conformance findings;
- observations routed upstream;
- verification result and unresolved items.
