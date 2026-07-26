---
name: orchestration-toolkit-adversarial-review
description: >-
  Adversarially inspect a concrete artifact or completed output with predefined,
  selectable review lenses and fresh independent agents. Use for a node,
  execution graph, code change, document, integrated Project result, or final
  completion claim that needs falsification-oriented review, structured
  findings, explicit coverage gaps, and a budget-aware verdict. Callable
  standalone or from orchestration-toolkit-orchestrate. Unlike
  ai-council-adversarial-panel, this reviews artifacts without cross-panel
  debate; unlike review-tools-ai-review, it is not limited to diffs and does not
  persist or resolve findings.
---

# Adversarial Review

Attempt to falsify a completion or quality claim about a concrete artifact.
Choose review procedures from a stable Lens catalog, preserve reviewer
independence, and return evidence-backed findings to the caller. Do not repair
the artifact or mutate external state.

Read [references/lens-catalog.md](references/lens-catalog.md) in full before
selecting or running lenses.

## Responsibility boundary

Own:

- deriving risk signals from the supplied artifact and acceptance;
- selecting required and triggered Lens IDs;
- packing selected lenses into the available adversarial-agent budget;
- running blind, fresh-context reviews;
- validating and normalizing reviewer output;
- deduplicating findings without averaging away disagreements;
- reporting verdict, residual risks, and unexamined coverage.

Do not:

- change code, documents, Linear, Git, or the reviewed artifact;
- resolve findings or accept risk;
- invent missing acceptance criteria;
- expose one reviewer to another's result before independent passes finish;
- run multi-round debate or seek consensus;
- treat model count alone as independent evidence.

Use `ai-council-adversarial-panel` instead when the object is a contested
question that benefits from cross-critique and revised positions. Use
`review-tools-ai-review` when the required outcome is specifically to ingest
code-review items into `review.md`.

## Input contract

Require a self-contained review package:

```yaml
target:
  kind: code-change | document | issue-output | execution-graph | project-output
  artifact: <artifact, paths, refs, or exact retrieval instructions>
  acceptance: <observable criteria>
  constraints: <binding decisions, non-goals, and allowed scope>

evidence:
  checks: <raw commands and results>
  supporting_artifacts: <completed inputs needed to judge the target>

review:
  scope: node | graph | global
  required_lenses: []
  risk_signals: {}

budget:
  max_agents: <positive integer>
  max_lenses: <positive integer or omitted>
  model_policy: capability-floor
```

Do not use conversation history as an implicit input. Ask for a missing artifact
or acceptance only when its absence prevents meaningful falsification; otherwise
mark the area unexamined.

## Workflow

### 1. Validate the target

Confirm that the target is concrete and retrievable, acceptance is observable,
and supplied evidence can be inspected or reproduced. Separate the producer's
claims from raw evidence.

Reject a request that only asks reviewers to debate an open proposition. Route
that to `ai-council-adversarial-panel`.

### 2. Derive risk signals

Infer only signals supported by the package, such as:

- public API or schema change;
- persistent-data or migration impact;
- authorization, secrets, or trust-boundary impact;
- concurrency or distributed-state behavior;
- multiple independently completed artifacts being integrated;
- design deviation or autonomous one-way decision;
- wide downstream dependency fan-out;
- weak or missing executable evidence;
- speculative scope or new abstraction;
- repeated implementation or verification failure.

Preserve caller-supplied signals, but correct a contradiction when the artifact
provides direct evidence and report the correction.

### 3. Select Lens IDs

Selection order:

1. include every caller-required Lens;
2. include catalog lenses marked mandatory for the selected scope;
3. add lenses whose triggers match risk signals;
4. add lenses required by prior unresolved findings;
5. add defense-in-depth lenses only while budget remains.

For `scope: global`, always include:

- `global.goal-alignment`;
- `global.integration-consistency`.

Never silently drop a required or mandatory Lens. If budget cannot cover it,
pack compatible lenses together or run agents sequentially. If execution limits
still prevent coverage, return `inconclusive`.

A novel material risk may use `custom.<descriptive-name>` with a written
falsification objective and reason no catalog Lens applies. Do not add it to the
catalog merely because it appeared once.

### 4. Pack lenses into agents

Keep Lens selection separate from agent count. Prefer one Lens per fresh agent.
When budget is smaller than the Lens set, bundle compatible lenses from the
catalog's packing groups while retaining separate finding categories.

For mandatory global review, default to two fresh agents:

- one runs `global.goal-alignment`;
- one runs `global.integration-consistency`.

Use different model families when the host makes them available and they meet
the capability floor. Otherwise use fresh contexts and distinct methods, and
record reduced independence. Do not invent unavailable model identifiers.

### 5. Construct blind briefs

Give each agent only:

- the target artifact and exact acceptance;
- binding constraints and non-goals;
- raw evidence and reproduction instructions;
- the selected Lens definition;
- the common output schema.

Do not include:

- another reviewer's output;
- the producer's confidence or conclusion;
- the orchestrator's expected verdict;
- hints about a suspected bug unless that suspicion is itself the artifact under
  review;
- unrelated conversation history.

Require concrete falsification: reproduce a failure, map a missing acceptance
item, identify an unsupported assumption, or cite an exact artifact location.
Generic best-practice advice is not a finding.

### 6. Run and validate independent passes

Run agents in parallel when capacity allows. A valid contribution must apply its
assigned Lens, inspect evidence, and return the required schema. A status line,
generic summary, tool error, or unsupported verdict is not a review.

Retry one malformed or failed review. If it fails again, replace the reviewer or
mark that Lens unexamined. Do not let a ghost contribution count as coverage.

### 7. Normalize and adjudicate

Normalize each finding to:

```yaml
id:
lens:
severity: blocker | major | minor | observation
claim:
evidence:
affected_acceptance:
affected_artifacts:
remediation:
confidence: high | medium | low
```

Deduplicate findings that have the same cause and evidence while preserving
which lenses found them. Do not use majority vote:

- reproducible evidence outweighs unsupported intuition;
- a blocker remains a blocker even when another reviewer missed it;
- conflicting evidence remains an explicit disagreement;
- absence of findings is weak evidence when coverage or independence degraded.

The caller—not this skill—decides whether to remediate or accept a risk.

### 8. Return the review record

Return:

```yaml
review_plan:
  selected_lenses: []
  assignments: []
  omitted_due_to_budget: []

verdict: ready | remediation-required | inconclusive

findings: []

coverage:
  examined: []
  unexamined: []
  degraded_independence: []

residual_risks: []
human_decisions: []
```

Use `remediation-required` when supported blocker or major findings contradict
acceptance or a binding constraint. Use `inconclusive` when mandatory coverage
or evidence is missing. `ready` means no supported blocking finding within the
reported coverage; it is not human approval.

For standalone use, render the same record readably for the user. For an
orchestrator caller, preserve the structured fields so it can record and route
findings.

## Success criteria

- [ ] The review plan accounts for every required, mandatory, selected, packed,
      and budget-omitted Lens by stable ID.
- [ ] Every actionable finding names its Lens, concrete evidence, affected
      acceptance or artifact, severity, and smallest adequate remediation.
- [ ] The verdict follows from the normalized findings and mandatory coverage:
      no `ready` record contains a supported blocker/major contradiction or an
      unexamined mandatory Lens.
- [ ] Coverage lists all unexamined areas and every reduction in model/context
      independence.
- [ ] Conflicting evidence remains visible rather than being collapsed into
      consensus or majority vote.
- [ ] The returned record contains no mutation of the reviewed artifact or
      external state.
