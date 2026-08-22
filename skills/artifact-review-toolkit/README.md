# artifact-review-toolkit

How a work artifact gets reviewed. This group owns the review procedures
themselves — who reviews, through which lens, under what independence — and
returns findings to whoever asked. It never records or resolves them: keeping a
review record and driving items to a terminal outcome is
[`code-review-session`](../code-review-session/README.md)'s job.

"Artifact" here means a concrete produced thing: a code change, a document, an
issue's output, an execution graph, an integrated project result.

## Skills

| Skill | Description |
|-------|-------------|
| [`artifact-review-toolkit-quick`](./artifact-review-toolkit-quick/SKILL.md) | A one-off code review of a change, redirected to whichever review capability the host provides. Findings come back in the conversation |
| [`artifact-review-toolkit-adversarial`](./artifact-review-toolkit-adversarial/SKILL.md) | Falsify a completion or quality claim through predefined lenses and independent fresh reviewers. Returns a structured record with verdict, findings, and coverage gaps |

Pick `quick` when an ordinary review is enough. Pick `adversarial` when a
completion claim must be attacked: broad blast radius, low reversibility, weak
executable evidence, or an acceptance claim that has to hold.

## Lenses, not personas

Adversarial review is not an improvised "be critical" prompt. Every review uses a
stable Lens ID with:

- a falsification objective;
- explicit triggers;
- required inputs;
- concrete checks;
- non-goals;
- severity guidance.

Lenses are selected from risk **first**, then packed into the reviewer budget
that is actually available. This separates the assurance-coverage decision from
the number of agents that can execute it — a smaller budget bundles compatible
lenses, it does not silently narrow what gets examined.

The catalog lives in
[`artifact-review-toolkit-adversarial/references/lens-catalog.md`](./artifact-review-toolkit-adversarial/references/lens-catalog.md)
and covers goal, integration, acceptance, regression, scope, graph, and decision
concerns, with reserved names for domain lenses. A caller with its own durable
review concerns supplies its own lenses rather than pushing them into the shared
catalog.

## Independence is engineered, not asserted

Reviewers receive the artifact, its acceptance, binding constraints, raw
evidence, and their assigned Lens. They do not receive another reviewer's
output, the producer's confidence, or the caller's preferred verdict.
Independent passes are aggregated only after they finish, and disagreement stays
visible instead of being averaged into consensus.

Agent count is not assurance. When model diversity is unavailable, the review
still runs on fresh contexts and distinct methods — and says that independence
was reduced.

This is deliberately different from `ai-council-adversarial-panel`, which debates
a contested *question* through cross-critique and revision. This group reviews a
concrete *output* through independent falsification and returns structured
findings.

The principle behind both is recorded in
[`docs/adversarial-verification.md`](../../docs/adversarial-verification.md).

## Review is not resolution

These skills return findings. They do not repair the artifact, accept a risk, or
decide what happens next — the caller does.

- A code review whose findings must be tracked: `code-review-session-import-ai`
  records them as items.
- A tracker execution: the calling execution workflow routes findings back to
  its Issue record.

## Deferred by design

- **Domain lens definitions.** The catalog reserves names for security,
  authorization, data integrity, migration, API compatibility, concurrency,
  performance, and accessibility without defining speculative procedures for
  them. Promote one when a concrete run requires it, or when the same `custom.*`
  Lens recurs.
- **Lens versioning and registry machinery.** Lens IDs are stable names; the
  catalog is not versioned and has no machine-readable registry. Add versioning
  when review reproducibility must distinguish materially different definitions
  under one ID, and tooling only when manual selection or packing starts causing
  observed errors.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
