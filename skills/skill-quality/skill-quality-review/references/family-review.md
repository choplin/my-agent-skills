# Family review mode

Use this when the user names a cooperating skill family or repository scope. It
extends the normal role-aware review to relationships no single `SKILL.md` owns.

## Reconstruct the relevant paths

Bound the requested family. Identify entry points from explicit triggers,
callers, or standing instructions, then follow named delegates, references,
scripts, schemas, and deliverables until an external boundary.

Record unresolved dynamic edges instead of guessing them. Directory adjacency
or similar names alone do not prove that two skills cooperate.

Represent only the paths needed to explain a finding:

```text
entry point -> caller -> delegate/reference/script -> deliverable or consumer
```

Run the loadability preflight on each in-scope skill.

## Judge ownership and context on each path

For a suspected issue, identify:

- what rule, handoff, field, schema, or artifact exists;
- where it is defined;
- which component actually uses or enforces it;
- which execution paths load it.

Then apply the role-aware standard:

- Guidance shared across a path should have one clear source; repeated summaries
  that load together are usually removable.
- Workflow handoffs may be checked at both sides when each boundary can
  independently reject an invalid transfer. Preserve that guard and explain why
  both copies matter.
- Deterministic schemas and fields need an actual producer/consumer or external
  contract. Remove unused contract data.
- A reference should load only where its guidance or operation becomes relevant.
- Historical structures that no longer affect a current path are residue, not
  compatibility.

Classify a finding by its main consequence rather than forcing a fixed inventory:
local content quality, duplicated context, unclear ownership, unused contract,
or historical residue are useful labels when they clarify the report.

Report the bounded paths, exclusions, and unresolved edges with the findings.
Do not build exhaustive ownership tables when a smaller piece of evidence settles
the judgment.
