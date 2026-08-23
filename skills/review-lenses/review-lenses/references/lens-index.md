# Lens index

Use this file only to select and pack Lenses. After selection, load the linked
Lens files and no other Lens definitions.

## Selection table

| Lens ID | Scope | Mandatory when | Triggers | Effort | Packing group | Definition |
|---|---|---|---|---|---|---|
| `code.functional-correctness` | node | target is `code-change` | any code behavior changes | high | code-baseline | [functional correctness](lens-code-functional-correctness.md) |
| `code.security-regression` | node | target is `code-change` | any code changes; deepen for authorization, secrets, input, dependency, or trust-boundary changes | medium | code-baseline | [security regression](lens-code-security-regression.md) |
| `code.performance-regression` | node | target is `code-change` | any code changes; deepen for hot paths, I/O, concurrency, data growth, or resource-lifetime changes | medium | code-baseline | [performance regression](lens-code-performance-regression.md) |
| `code.maintainability-risk` | node | target is `code-change` | any code changes; deepen for new abstractions, duplicated invariants, or cross-module coupling | medium | code-baseline | [maintainability risk](lens-code-maintainability-risk.md) |
| `global.goal-alignment` | global | review scope is `global` | completion or quality claim over an integrated result | medium | outcome | [goal alignment](lens-global-goal-alignment.md) |
| `global.integration-consistency` | global | review scope is `global` | independently completed outputs are integrated | high | integration | [integration consistency](lens-global-integration-consistency.md) |
| `node.acceptance-evidence` | node | — | acceptance is weakly observable; checks are missing, indirect, or partly failed; completion is unsupported | low | outcome | [acceptance evidence](lens-node-acceptance-evidence.md) |
| `node.regression-boundary` | node | — | shared or public behavior changed; downstream fan-out is high; adjacent behavior lacks coverage | medium | integration | [regression boundary](lens-node-regression-boundary.md) |
| `scope.yagni` | node or global | — | new abstraction or configuration axis; work exceeds current need; future variants justify scope | low | scope-decision | [YAGNI](lens-scope-yagni.md) |
| `graph.dependency-integrity` | graph | — | dependencies changed; completed outputs changed downstream inputs; graph has multiple paths | medium | graph | [dependency integrity](lens-graph-dependency-integrity.md) |
| `graph.parallel-safety` | graph | — | concurrent nodes touch shared modules, contracts, artifacts, state, or environments | medium | graph | [parallel safety](lens-graph-parallel-safety.md) |
| `graph.execution-strategy` | graph | — | wave plans have different risk; assurance allocation matters; repeated failure obscures cause | medium | graph | [execution strategy](lens-graph-execution-strategy.md) |
| `decision.design-consistency` | node or global | — | durable design may have been replaced, partially adopted, or interpreted inconsistently | medium | scope-decision | [design consistency](lens-decision-design-consistency.md) |
| `decision.residual-risk` | global | — | checks were skipped; findings remain unresolved; one-way autonomous decisions occurred | low | scope-decision | [residual risk](lens-decision-residual-risk.md) |

## Packing rules

Prefer one Lens per fresh reviewer. Bundle only within the same packing group
when reviewer capacity is smaller than the selected Lens set. Retain a separate
finding category for every bundled Lens. A quick ordinary code review may bundle
the four `code-baseline` Lenses into one reviewer; artifact review separates them
when capacity allows.

Domain Lenses normally receive their own reviewer.

## Domain and caller-supplied Lenses

Add a domain Lens only after a concrete risk requires a procedure more specific
than the baseline catalog. Candidate IDs include:

- `domain.security-authorization`
- `domain.data-integrity`
- `domain.data-migration`
- `domain.api-compatibility`
- `domain.concurrency`
- `domain.performance`
- `domain.accessibility`

A domain or caller-supplied Lens must define an ID, scope, effort, falsification
objective, required inputs, reproducible checks, non-goals, and severity guidance.
Use `custom.<descriptive-name>` for a one-off risk and record why catalog Lenses
are insufficient. Keep caller-owned Lenses with their caller; promote one only
when a second unrelated caller needs it.
