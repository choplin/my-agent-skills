# Review: {title}

## Under Review

<!-- Optional: what this review covers — a diff, branch, spec/plan, or PR. -->

## Items

<!-- Items are appended by ingestion ops (ai-review / import-pr / import-ci) and by
     direct feedback during resolve. Keep only generic review state here; source
     -specific data lives in sources/{source}.json. -->

### Item {N}: {one-line summary}

- **Source**: {ai | pr:comment/{id} | ci:job/{id} | direct}
- **Status**: open | resolved | skipped | postponed
- **Detail**: {the finding or feedback}
- **Approach**: {optional — the proposed response; filled during resolve}
- **Resolution**: {optional — what was done / why deferred; filled when it leaves `open`}

## Status

- **Phase**: open
- **Resolved**: 0 / 0 <!-- informational; derived from item statuses (resolved+skipped+postponed over total) -->

<!-- review.md is the single source of truth for review state. Source-specific
     bookkeeping (PR comment ids, CI run refs, replied flags) lives in
     sources/{source}.json, not here. -->
