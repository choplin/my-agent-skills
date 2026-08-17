---
name: document-writing-apply
description: >-
  Applies a set of already-reviewed writing findings to a document in
  dependency order, re-verifying each finding's anchor against the current text
  and reporting anything it cannot locate as stale. Applies when findings from
  a document audit have been read and selected by a person, or when a caller
  holds located findings and wants them applied without a fresh review.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
metadata:
  description-role: trigger
---

# Document Apply

The application-only lane. No detection; findings come from the caller.

Apply `document-writing-base` for the application, verification, and report
steps, entering at step 4. This skill supplies only the lane values.

```yaml
lenses: none — findings are supplied
deliverable: revised-document
reviewers: 0
verify: true
```

## Input contract

Findings must follow the schema in `document-writing-standards`. The fields this
lane depends on:

- `lens` and `layer` — determine the phase a finding is applied in. A finding
  with neither cannot be ordered and is rejected rather than guessed at.
- `location.anchor` — exact quoted text, long enough to locate uniquely.
- `remediation` — concrete enough to apply without re-deriving the defect.
- `content_impact` — decides whether the change is reported under
  `structural_changes`.

Findings normally come from `document-writing-audit`, after a person has kept,
dropped, or edited them. A caller may also supply hand-written findings in the
same shape.

## Stale anchors

The document has usually been edited between the audit and this call — that is
the point of the human step in between. Before applying anything, locate each
anchor in the document as it stands.

**Report every anchor that no longer matches as stale and unapplied. Do not
relocate it by guess.** A finding was written against text that no longer
exists; applying its remediation somewhere nearby produces an edit nobody
reviewed, at a location nobody chose.

Re-anchor again before each phase, because earlier phases move text.

## Why order still matters

Findings are applied in the same layer order the base defines: logic,
terminology, structure, expression and language, rhythm. A supplied set is not
pre-sorted, and applying an expression fix before a structural one wastes it —
the paragraph it polished may be merged in the next phase.

## What this lane does not do

It does not detect. A finding the caller did not supply is not applied, and no
lens is run to look for one. Where the applied set leaves obvious defects
untouched, report that rather than fixing it: the caller's selection is the
decision this lane exists to respect.

The one exception is the verification pass, which re-runs the four lenses that
application itself breaks. That pass repairs damage this lane caused; it does
not extend the caller's selection.
