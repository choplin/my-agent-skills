---
name: document-writing-audit
description: >-
  Inspects a document against every writing lens and returns located findings
  without editing it, running one independent reviewer per lens for maximum
  coverage. Applies when nothing should be changed automatically — the writer
  wants to see what is wrong and decide themselves, a document is under review
  by someone else, or the findings will be selected and applied later.
allowed-tools: Read, Glob, Grep, Bash, Task
metadata:
  description-role: trigger
---

# Document Audit

The detection-only lane. Full-layer detection, one reviewer per lens, no edits.

Apply `document-writing-base` for the whole procedure, stopping after
normalization. This skill supplies only the lane values.

```yaml
lenses: all layers except rhythm
deliverable: findings
reviewers: per-lens
verify: false
```

## Why this lane spends the most

One reviewer runs for every selected lens, against one per packing group for
`document-writing-review`. The asymmetry is deliberate: nothing is applied
here, so a person reads every finding, and a missed defect is a defect that
survives. Independence buys coverage, and coverage is what this lane is for.

`document-writing-review` makes the opposite trade, because a revised document
needs application to be coherent more than it needs detection to be exhaustive.

## Do not edit

This lane returns findings and changes nothing — not the document, not
surrounding files, not the tracker. Where a fix is obvious, it belongs in the
finding's `remediation` field, not in the document.

## The audit-and-apply lane

Findings from this skill are the input contract for `document-writing-apply`.
The intended sequence is:

1. `document-writing-audit` returns located findings.
2. A person keeps, drops, or edits them.
3. `document-writing-apply` applies what survived.

That sequence is how a caller keeps control of what changes. For it to work,
every finding must carry an `anchor` quoted exactly from the document — `apply`
re-verifies each anchor against the document as it stands then, and reports as
stale anything it cannot locate. Findings without a usable anchor are unusable
downstream, so do not return one.

## Coverage reporting

List every lens that went unexamined, and every reviewer that had to be retried.
An audit that silently drops a lens reads as a clean bill of health for material
nobody looked at.
