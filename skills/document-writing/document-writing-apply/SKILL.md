---
name: document-writing-apply
description: >-
  Applies a person-selected set of local document conformance findings, rejects
  stale or substantive instructions, and verifies that the edits preserve the
  document. Applies after document-writing-audit or equivalent human review.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
metadata:
  description-role: trigger
---

# Apply Document Findings

Use the apply path in `document-writing-base`.

```yaml
stage: apply
guidance: lenses named by accepted findings
deliverable: revised-document
intervention: selected-findings
verify: true
```

Accept only findings that conform to the check schema in
`document-writing-standards`. Re-resolve each exact anchor immediately before
application and mark absent or changed anchors stale. Reject any item whose
remedy adds substance, changes a claim or its epistemic status, reorganizes the
reader progression, or otherwise exceeds `content_impact: none`; route it to
holistic review instead.

Apply accepted findings in dependency order defined by
`document-writing-base`. Verify only damage introduced by this application.
Do not detect or silently fix unrelated defects.
