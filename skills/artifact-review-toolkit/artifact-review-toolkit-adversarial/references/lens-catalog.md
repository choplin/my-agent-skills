# Adversarial Lens Catalog

A Lens is a predefined falsification procedure, not a persona. Select Lens IDs
from triggers, then assign them to fresh reviewers. Every Lens uses the common
finding schema from the parent skill.

## Contents

1. Selection and packing
2. Global lenses
3. Node lenses
4. Graph lenses
5. Decision lenses
6. Domain extension points
7. Caller-supplied lenses

## 1. Selection and packing

| Packing group | Compatible lenses |
|---|---|
| **outcome** | `global.goal-alignment`, `node.acceptance-evidence` |
| **integration** | `global.integration-consistency`, `node.regression-boundary` |
| **scope-decision** | `scope.yagni`, `decision.design-consistency`, `decision.residual-risk` |
| **graph** | `graph.dependency-integrity`, `graph.parallel-safety`, `graph.execution-strategy` |

Prefer one Lens per agent. Bundle only within a packing group when budget
requires it. Domain lenses normally receive their own reviewer.

Severity meanings:

- **blocker**: acceptance or a binding constraint is demonstrably unmet; the
  completion claim cannot stand.
- **major**: material failure or unsupported risk likely requires remediation.
- **minor**: bounded defect that does not invalidate the overall claim.
- **observation**: supported information useful for human judgment but not a
  defect by itself.

## 2. Global lenses

### `global.goal-alignment`

```yaml
scope: global
packing_group: outcome
mandatory_when: global review
effort: medium
objective: Falsify the claim that the integrated result achieves the original
  finite goal and every stated acceptance criterion.
required_inputs:
  - original goal and stated acceptance
  - final artifacts and completed Issue outputs
  - acceptance evidence
checks:
  - Map every acceptance item to concrete evidence.
  - Find goal requirements with no corresponding deliverable.
  - Find completed work that does not contribute to the goal.
  - Test whether autonomous decisions changed the intended outcome.
non_goals:
  - Do not line-review every implementation artifact.
  - Do not propose unrelated product improvements.
```

Missing acceptance evidence is at least major; a demonstrably unmet acceptance
item is blocker.

### `global.integration-consistency`

```yaml
scope: global
packing_group: integration
mandatory_when: global review
effort: high
objective: Falsify the claim that independently completed outputs form one
  coherent, working result.
required_inputs:
  - final execution graph and dependency outcomes
  - integrated artifacts and integration checks
  - Issue-level decisions and prior findings
checks:
  - Compare contracts and assumptions across Issue boundaries.
  - Reproduce the critical end-to-end path.
  - Find missing integration work hidden by individually Done Issues.
  - Check that later work consumed the actual completed blocker outcomes.
  - Identify stale generated artifacts, schemas, or documentation.
non_goals:
  - Do not relitigate a binding design solely from preference.
```

A broken critical path or incompatible cross-Issue contract is blocker.

## 3. Node lenses

### `node.acceptance-evidence`

```yaml
scope: node
packing_group: outcome
triggers:
  - acceptance is weakly observable
  - checks are missing, indirect, or partially failed
  - executor made an unsupported completion claim
effort: low
objective: Falsify the claim that this Issue's acceptance is satisfied by the
  supplied artifact and evidence.
checks:
  - Map each criterion to artifact evidence or a reproducible check.
  - Exercise relevant failure behavior and boundary inputs.
  - Separate checked facts from producer assertions.
non_goals:
  - Do not broaden the Issue's acceptance.
```

### `node.regression-boundary`

```yaml
scope: node
packing_group: integration
triggers:
  - shared module or public behavior changed
  - downstream fan-out is high
  - existing coverage does not exercise adjacent behavior
effort: medium
objective: Find behavior outside the intended change that the artifact breaks.
checks:
  - Identify the nearest preserved contracts.
  - Run or inspect targeted regression checks.
  - Examine error, fallback, and compatibility paths.
non_goals:
  - Do not report unrelated pre-existing defects.
```

### `scope.yagni`

```yaml
scope: node | global
packing_group: scope-decision
triggers:
  - new abstraction, framework, extension point, or configuration axis
  - implementation reaches beyond named acceptance
  - future variants are used as justification
effort: low
objective: Find changes that cannot be justified by current acceptance,
  constraints, or a present repeated use.
checks:
  - Trace every material addition to a current requirement.
  - Challenge abstractions with only one present implementation.
  - Find deferred capability implemented ahead of evidence.
  - Identify opportunistic cleanup that enlarged blast radius.
non_goals:
  - Do not equate all abstraction or refactoring with waste.
```

Unjustified cross-cutting scope is major; a small removable extra is minor.

## 4. Graph lenses

### `graph.dependency-integrity`

```yaml
scope: graph
packing_group: graph
triggers:
  - dependencies were added or repaired during execution
  - completed outputs changed downstream inputs
  - graph contains multiple paths or milestones
effort: medium
objective: Find missing, reversed, circular, stale, or non-causal dependency
  relations.
checks:
  - Verify every blocked edge represents a real required input.
  - Search for implicit dependencies in acceptance and changed contracts.
  - Detect cycles and nodes unblocked before their inputs exist.
  - Find hierarchy incorrectly used as execution order.
non_goals:
  - Do not add ordering solely for review convenience.
```

### `graph.parallel-safety`

```yaml
scope: graph
packing_group: graph
triggers:
  - two or more nodes are proposed in one execution wave
  - nodes touch shared modules, schemas, generated artifacts, or environments
effort: medium
objective: Falsify the claim that the proposed wave can execute independently
  and integrate without invalidating concurrent work.
checks:
  - Compare predicted files, contracts, and resources.
  - Identify shared state that worktrees do not isolate.
  - Check integration and migration ordering.
  - Find tests whose concurrent execution is unsafe.
non_goals:
  - Do not serialize work merely because it is in one repository.
```

### `graph.execution-strategy`

```yaml
scope: graph
packing_group: graph
triggers:
  - several plausible wave plans have materially different risk
  - model or assurance budget must be reallocated
  - repeated failures make the cause unclear
  - the caller proposes a high-impact graph change
effort: medium
objective: Find unsupported assumptions in wave order, model routing, retry,
  integration, and assurance allocation.
checks:
  - Compare work placement with capability floors and reversibility.
  - Find critical nodes receiving weaker assurance than low-risk leaves.
  - Challenge retries that preserve the failed configuration.
  - Identify useful work left idle without a real blocker.
non_goals:
  - Do not optimize for maximum parallelism alone.
```

## 5. Decision lenses

### `decision.design-consistency`

```yaml
scope: node | global
packing_group: scope-decision
triggers:
  - implementation deviated from a durable decision
  - multiple Issues interpreted one design
  - executor made a design-level choice
effort: medium
objective: Find contradictions between the artifact and binding designs,
  including inconsistent interpretations across outputs.
checks:
  - Trace changed contracts to the authoritative decision.
  - Compare rejected alternatives with what was implemented.
  - Identify silent decision replacement or partial adoption.
non_goals:
  - Do not replace a valid decision because another design is preferable.
```

### `decision.residual-risk`

```yaml
scope: global
packing_group: scope-decision
triggers:
  - checks were skipped or inconclusive
  - findings were rejected or accepted without remediation
  - one-way autonomous decisions occurred
effort: low
objective: Find material uncertainty hidden by the completion summary and make
  the required human risk acceptance explicit.
checks:
  - Reconcile unresolved findings and coverage gaps.
  - Test whether stated residual risks describe consequence and exposure.
  - Find assumptions presented as verified facts.
  - Identify decisions that exceeded delegated authority.
non_goals:
  - Do not turn immaterial uncertainty into a blocking risk.
```

## 6. Domain extension points

Add a domain Lens only after the risk recurs or a concrete run requires it.
Candidate IDs include:

- `domain.security-authorization`
- `domain.data-integrity`
- `domain.data-migration`
- `domain.api-compatibility`
- `domain.concurrency`
- `domain.performance`
- `domain.accessibility`

A domain Lens must define scope, triggers, effort, falsification objective,
required inputs, reproducible checks, non-goals, and severity guidance. Until it
earns a catalog entry, use `custom.<descriptive-name>` and record why the generic
lenses are insufficient.

## 7. Caller-supplied lenses

A caller with its own durable review concerns may supply Lens definitions of its
own, as `<caller>.<descriptive-name>` (for example an orchestrator's lenses over
its wave planning). A supplied Lens must carry the same fields as a catalog Lens
and is selected, packed, and reported exactly like one.

Supplied lenses stay with the caller that owns them. Promote one into this
catalog only when a second, unrelated caller needs it — that is what keeps this
file a shared registry rather than a union of every caller's concerns.
