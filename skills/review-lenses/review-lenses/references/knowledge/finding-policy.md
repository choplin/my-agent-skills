# Finding policy

Apply this policy to every Lens. Lens definitions decide what to inspect; this
policy decides what qualifies as an actionable finding.

## Actionable findings

Report a candidate as a finding only when all are true:

- **Material** — it can prevent the intended outcome, violate an applicable
  requirement or constraint, cause a meaningful regression, or create a
  concrete operational or maintenance failure.
- **Discrete** — it has one identifiable cause and can be acted on independently.
- **Evidence-backed** — the artifact, a reproducible check, or a traceable
  contract identifies the affected behavior. A possibility without an affected
  path is not enough.
- **Attributable** — it lies within the reviewed artifact or change. For a change
  review, the change introduced it or made it materially worse; do not report an
  unrelated pre-existing defect.
- **Unintentional** — it is not merely a deliberate change that differs from a
  reviewer's preference.
- **Actionable** — the report can name the smallest adequate remediation without
  redesigning unrelated work.

For a conditional issue, state the input, environment, scale, state, or call path
required to trigger it. Inspect enough surrounding material to establish that the
affected consumer exists. Generic best-practice advice, speculative hardening,
trivial style preferences, and unsupported warnings are not findings.

Apply the repository instructions governing the reviewed artifact. When a rule
materially establishes the defect, invariant, or remediation, cite its smallest
supporting section. Do not invent a finding merely because a rule exists.

Report every qualifying finding. Prefer an empty finding set to lowering the
threshold merely to produce output.

## Observations and uncertainty

Place supported information that aids human judgment but does not meet the
actionable threshold under `observations`. Put missing evidence, unexamined risk,
and unresolved conflicting evidence under `coverage` or `residual_risks`; do not
convert uncertainty into a defect.

## Severity

- **blocker** — the intended outcome, an applicable acceptance criterion, or a
  binding constraint is demonstrably unmet; the completion claim cannot stand.
- **major** — a material failure or supported risk likely requires remediation
  before acceptance.
- **minor** — a bounded actionable defect that does not invalidate the overall
  result.

Severity reflects consequence and exposure, not reviewer confidence. Record
confidence separately.

## Evidence and remediation

Keep evidence precise: cite the shortest useful artifact location, command
result, contract, or reproduced behavior. Explain why that evidence establishes
the consequence. Recommend the smallest remediation that addresses the cause;
do not attach unrelated cleanup.
