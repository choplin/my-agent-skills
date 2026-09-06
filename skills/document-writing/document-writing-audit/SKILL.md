---
name: document-writing-audit
description: >-
  Inspects stable Japanese or English prose for locally falsifiable conformance
  defects without editing it. Applies when a person wants located copyedit
  findings to approve and apply later; it is not a substitute for developmental
  or holistic editorial review.
allowed-tools: Read, Glob, Grep, Bash, Task
metadata:
  description-role: trigger
---

# Document Audit

Use the audit path in `document-writing-base`.

```yaml
stage: audit
guidance: applicable lenses whose index includes check
deliverable: findings
intervention: content-preserving
verify: false
```

Return only located, falsifiable defects using the finding schema in
`document-writing-standards`. Do not convert planning principles or editorial
heuristics into findings. If the document appears to have a broken focus,
missing substance, wrong order, or disproportionate explanation, state that a
holistic `document-writing-review` is needed; do not encode the diagnosis as a
set of local commands.

Change no files or supplied text. Exact unique anchors are required because the
approved findings may later be passed to `document-writing-apply`.
