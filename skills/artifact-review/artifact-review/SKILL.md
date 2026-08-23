---
name: artifact-review
description: >-
  Reviews a finished code change, document, issue output, execution graph, or
  integrated project result through predefined risk-selected Lenses and fresh
  independent reviewers. Produces evidence-backed findings, explicit coverage
  gaps, residual risks, and a budget-aware verdict without revising the target.
  Applies when an artifact needs rigorous examination before it is accepted.
metadata:
  description-role: trigger
---

# Artifact review

Attempt to falsify the quality or completion claims made for a concrete artifact.
Select review procedures from a stable Lens index, preserve reviewer independence,
and return evidence-backed findings. Do not repair the artifact or mutate external
state.

Require the `review-lenses` skill. If it is unavailable, stop before reviewing
and tell the caller to install it; do not reconstruct or approximate its policy.
Apply that skill, read `references/finding-policy.md` before planning, and read
`references/lens-index.md` to select Lens IDs. Resolve those paths relative to
the installed `review-lenses` skill. After selection, read only the corresponding
Lens files linked by the index; do not load unselected Lens definitions.

## Responsibility boundary

Own:

- deriving risk signals from the artifact, its intended outcome, constraints,
  available acceptance criteria, and evidence;
- selecting required and triggered Lens IDs;
- packing selected Lenses into the available reviewer budget;
- running blind, fresh-context reviews when the host supports isolation;
- validating, normalizing, and deduplicating reviewer output;
- reporting findings, coverage gaps, residual risks, and verdict.

Do not:

- change code, documents, trackers, Git, or the reviewed artifact;
- resolve findings or accept risk;
- invent missing requirements or acceptance criteria;
- expose one reviewer to another's result before independent passes finish;
- run multi-round debate or seek consensus;
- treat model count alone as independent evidence.

Use isolated reviewers when the host provides them. Otherwise run selected Lenses
sequentially inline, clearing the working notes for one Lens before applying the
next, and record degraded independence.

## Input contract

Build a self-contained review package:

```yaml
target:
  kind: code-change | document | issue-output | execution-graph | project-output
  artifact: <artifact, paths, refs, or exact retrieval instructions>
  intended_outcome: <goal or behavior the artifact is meant to achieve>
  acceptance: <observable criteria when they exist>
  constraints: <repository instructions, binding decisions, non-goals, and allowed scope>

evidence:
  checks: <raw commands and results>
  supporting_artifacts: <completed inputs needed to judge the target>

review:
  scope: node | graph | global
  required_lenses: []
  risk_signals: {}

budget:
  max_reviewers: <positive integer>
  max_lenses: <positive integer or omitted>
  model_policy: capability-floor
```

`acceptance` may be absent when the project has no explicit criteria. Preserve
that as a coverage fact rather than inventing criteria. Ask for a missing artifact
or intended outcome only when its absence prevents meaningful review; otherwise
mark the affected area unexamined.

## Workflow

### 1. Validate the target

Confirm that the target is concrete and retrievable, its intended outcome is
understandable, and supplied evidence can be inspected or reproduced. Separate
producer assertions from raw evidence.

Reject requests that ask reviewers to debate an open proposition rather than
inspect a produced artifact.

### 2. Derive risk signals

Infer only signals supported by the package, such as:

- code changes, public API changes, or schema changes;
- persistent-data or migration impact;
- authorization, secrets, or trust-boundary impact;
- concurrency or distributed-state behavior;
- independently completed artifacts being integrated;
- design deviation or an autonomous one-way decision;
- wide downstream dependency fan-out;
- weak or missing executable evidence;
- speculative scope or a new abstraction;
- repeated implementation or verification failure.

Preserve caller-supplied signals, but correct contradictions supported by direct
artifact evidence and report the correction.

### 3. Select Lens IDs

Use the `review-lenses` skill's `references/lens-index.md` in this order:

1. include every caller-required Lens;
2. include every Lens mandatory for the target kind or review scope;
3. add Lenses whose triggers match supported risk signals;
4. add Lenses required by unresolved prior findings;
5. add defense-in-depth Lenses only while budget remains.

Every `code-change` review includes the four baseline code Lenses: functional
correctness, security regression, performance regression, and maintainability
risk. Every `global` review includes goal alignment and integration consistency.

Never silently drop a required or mandatory Lens. Pack compatible Lenses or run
reviewers sequentially. Return `inconclusive` if execution limits still leave a
mandatory Lens unexamined.

A novel material risk may use `custom.<descriptive-name>` with a written
falsification objective and an explanation of why no catalog Lens applies. Do
not add a one-off custom Lens to the catalog.

### 4. Pack Lenses into reviewers

Keep Lens selection separate from reviewer count. Prefer one Lens per fresh
reviewer. When capacity is smaller than the selected set, bundle only Lenses in
the same packing group from the index and preserve separate finding categories.
Run independent passes in parallel when capacity allows.

Use different model families when the host makes them available and they meet
the capability floor. Otherwise use fresh contexts and distinct methods, and
record reduced independence. Do not invent unavailable model identifiers.

### 5. Construct blind briefs

Give each reviewer only:

- the target artifact and intended outcome;
- available acceptance criteria, binding constraints, and non-goals;
- raw evidence and reproduction instructions;
- the assigned Lens file from `review-lenses`;
- the `review-lenses` finding policy and the common output schema below.

Do not include another reviewer's output, the producer's confidence, the
caller's preferred verdict, hints about a suspected bug unless that suspicion is
itself under review, or unrelated conversation history.

### 6. Run and validate independent passes

A valid contribution applies its assigned Lens, inspects evidence, and returns
the required schema. A status line, generic summary, tool error, or unsupported
verdict is not a review.

Retry one malformed or failed review. If it fails again, replace the reviewer or
mark that Lens unexamined. A missing contribution never counts as coverage.

### 7. Normalize and adjudicate

Normalize each actionable finding to:

```yaml
id:
lens:
severity: blocker | major | minor
claim:
evidence:
affected_requirements:
affected_artifacts:
remediation:
confidence: high | medium | low
```

Keep supported non-defect information under `observations` rather than weakening
the actionable-finding threshold. Deduplicate findings with the same cause and
evidence while preserving every Lens that found them. Do not use majority vote:

- reproducible evidence outweighs unsupported intuition;
- a blocker remains a blocker when another reviewer missed it;
- conflicting evidence remains an explicit disagreement;
- absence of findings is weak evidence when coverage or independence degraded.

The caller decides whether to remediate or accept risk.

### 8. Return the review record

```yaml
review_plan:
  selected_lenses: []
  assignments: []
  omitted_due_to_budget: []

verdict: ready | remediation-required | inconclusive

findings: []
observations: []

coverage:
  examined: []
  unexamined: []
  degraded_independence: []

residual_risks: []
human_decisions: []
```

Use `remediation-required` when a supported blocker or major finding contradicts
the intended outcome, an applicable acceptance criterion, or a binding
constraint. Use `inconclusive` when mandatory coverage or essential evidence is
missing. `ready` means no supported blocking finding within reported coverage;
it is not human approval.

For standalone use, render the same record readably. Preserve structured fields
for programmatic callers.

## Success criteria

- [ ] The review plan accounts for every required, mandatory, selected, packed,
      and budget-omitted Lens by stable ID.
- [ ] Every code-change review loads all four baseline code Lenses from
      `review-lenses`.
- [ ] Every actionable finding satisfies the common finding policy and names its
      Lens, concrete evidence, affected requirement or artifact, severity, and
      smallest adequate remediation.
- [ ] No `ready` record contains a supported blocker or major contradiction, or
      an unexamined mandatory Lens.
- [ ] Coverage lists every unexamined area and reduction in independence.
- [ ] Conflicting evidence remains visible rather than becoming consensus or a
      majority vote.
- [ ] The reviewed artifact and external state remain unmodified.
