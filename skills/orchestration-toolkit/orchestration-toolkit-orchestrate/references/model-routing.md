# Model Routing and Agent Budgets

Use capability floors rather than provider-specific model names as the stable
policy. Resolve actual models from the current host immediately before dispatch;
model catalogs and pricing change.

## Contents

1. Roles and capability floors
2. Routing signals
3. Escalation
4. Default budgets
5. Host mapping

## 1. Roles and capability floors

| Role | Capability floor |
|---|---|
| **Orchestrator** | The strongest practical reasoning model available. Must reconcile sources, schedule a graph, recognize one-way decisions, integrate evidence, and preserve the human gate. There is exactly one and it is the main session. |
| **Economical executor** | The least costly available model that can reliably complete a self-contained implementation Issue from explicit inputs and acceptance. It must use tools, follow repository conventions, test its output, and stop at a capability boundary. |
| **Deep executor** | A high-judgment implementation model for cross-cutting, ambiguous, hard-to-reverse, or repeatedly failing code work. |
| **Adversary** | A model capable of independently inspecting the supplied artifact, reproducing evidence, applying one assigned Lens, and returning structured findings. Prefer error-mode diversity over raw model count. |

“Economical” never means “cheapest model regardless of capability.” Select the
lowest-cost model above the Issue's capability floor.

## 2. Routing signals

Route an `impl` Issue to an economical executor when all are true:

- direction and acceptance are fixed;
- completed blocker outcomes supply all required decisions;
- the change is bounded and follows an existing repository pattern;
- failures are local and reversible;
- required checks are known;
- the executor need not modify the Project graph.

Route to a deep executor when any material signal applies:

- public API, shared schema, persistent data, security, authorization, billing,
  privacy, or trust-boundary impact;
- repository-wide or cross-repository consequences;
- multiple viable architectures must be judged;
- acceptance requires filling a product or design gap;
- reversal would be costly or destructive;
- the Issue has unexpectedly broad implementation reach;
- an economical executor reached a capability boundary or failed one corrected
  retry;
- a `deep` override is present.

`design`, `research`, and `orchestration` Issues use the high-judgment tier.

## 3. Escalation

An economical executor must return control when it discovers:

- an unresolved one-way decision;
- missing or contradictory acceptance;
- an unrecorded dependency;
- a required scope expansion;
- an unexpected security, data, or compatibility boundary;
- inability to make progress without guessing.

On failure:

1. Repair a malformed brief, missing input, or mechanical environment problem.
2. Retry once with the same capability tier.
3. If the same substantive failure remains, use a deep executor, repair the
   Issue/graph, or request human direction.

Do not spend retries on an unchanged prompt and environment merely because
budget remains.

## 4. Default budgets

The orchestrator is always one and is not budgeted. Track executor and
adversarial capacity separately.

```yaml
executor:
  max_concurrency: <all safely available subagent slots>
  retry_limit_per_issue: 1

adversarial:
  node_passes: risk-based
  graph_passes: exception-based
  mandatory_global_lenses: 2
  default_final_reviewers: 2
  minimum_fresh_reviewers: 1
  max_concurrency: <available slots after execution wave>
```

Budget controls how much independent assurance is added; it does not waive:

- executor self-check;
- orchestrator evidence inspection;
- fresh review coverage of both mandatory global lenses;
- final human approval.

When capacity is constrained, reduce in this order:

1. duplicate lenses with low marginal coverage;
2. independent review on low-risk leaf Issues;
3. execution concurrency;
4. graph review except at material decision points;
5. pack compatible global lenses into one fresh reviewer.

Never remove the global review or human gate. Reviewers normally run after an
execution wave releases its agent slots, so no permanent reviewer reservation is
required.

## 5. Host mapping

Treat this table as examples, not timeless identifiers. Verify what the host can
actually launch and report substitutions.

| Host | Orchestrator / deep executor | Economical executor |
|---|---|---|
| **Codex** | Strongest current frontier reasoning model; when available, the `sol` tier | Current balanced implementation model; when available, the `terra` tier |
| **Claude Code** | Current Opus-class model | Current Sonnet-class model |
| **Other hosts** | Strongest tool-capable reasoning model exposed by the host | Least costly tool-capable model that satisfies the Issue floor |

For adversarial review, prefer a different model family from the producer when
available. If only one family exists, use fresh contexts and distinct Lens
methods, then mark independence as degraded. Never invent a model identifier or
claim diversity that the launched agents did not have.
