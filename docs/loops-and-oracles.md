---
title: "Loops and Oracles — Why the Execution and Quality Skills Are Shaped This Way"
created: 2026-06-11
updated: 2026-08-23
---

# Loops and Oracles

The design principles behind this repository's execution, review, and
skill-quality groups: when an autonomous loop is the right structure, when it
mass-produces polished garbage, and what each skill does about it.

## Two halves of one problem

- **Spec-driven** answers *how to define the right target*. It locates error in
  ambiguity of intent and builds quality in through an agreed document up front
  (feedforward).
- **Loop engineering** answers *how to converge on a fixed target*. It locates
  error in false completion reports and drift, and converges by iterating
  against a machine-checkable predicate (feedback).

They are not alternatives. The specification is the specification *of the loop's
completion predicate*. Only the implement→verify segment can be looped;
negotiating intent and judging value are human-paced.

## Three error classes

- **(a) Specification omissions** — unknown unknowns. Impossible to write into
  any predicate; found only once something real is running.
- **(b) Implementation-approach flaws not expressed in the specification** —
  partially caught by an LLM evaluator, but noisily.
- **(c) Mechanical correctness** — tests, build, lint. Predicate-able.

**A loop fully covers only (c).** Most real rework is (a) and (b), and the
countermeasure for those is not a tighter loop but a shorter outer loop: get a
reviewable artifact in front of a human sooner.

```
Outer loop (human evaluates): intent → implement → review → omission → revise → …
Inner loop (machine evaluates):        implement ⇄ predicate
```

An inner-loop agent evaluates *against* the specification, so it can never
conclude the specification itself is wrong. A strong loop over a weak predicate
is Goodhart's law with a build step.

## Where the oracle lives

The radical form — the human gives only a goal and the loop produces the
specification too — removes the human approval gate. But the alignment
information the human used to inject has to go somewhere, and there are only
three destinations:

1. Compressed into the goal statement and the evaluator — viable only when the
   goal can be written completely in a few lines.
2. **An external oracle exists**: cloning, porting, implementing a published
   specification, hitting a benchmark. Nearly every convincing autonomous demo
   is this class.
3. The human reviews the whole artifact at the end — deferring the alignment
   conversation to the most expensive possible point.

So the real axis is **where the oracle lives**. When the answer lives in the
world, a goal-driven loop is correct. When the answer lives only in a person's
head — ordinary product development — the specification has to stay outside the
loop as a contract, and the honest promise of looping is not "a perfect
specification" but *a verifiable floor plus cheap retries*. Looping does not
eliminate rework; it makes rework cheap.

Route per work item rather than per repository: ask whether acceptance criteria
can be written directly, and whether they are mechanically checkable. That test
doubles as an oracle detector.

## Principles the skills implement

**Verification is the watershed.** Whether the agent can run its own pass/fail
check decides whether autonomy is possible at all. Without one, the human
becomes the verification loop.

**Separate the generator from the evaluator.** A single agent praises its own
work even when the work is poor; the skepticism of an independent evaluator is
tunable.

**Bound the loop.** Production practice favors capped loops with escalation over
while-true. Infinite forcing is not achievable anyway — a host that blocks
turn-end eventually overrides itself.

**Don't chase every review finding.** A reviewer prompted to find gaps will
report some even when the work is sound; chasing all of them produces
over-engineering. Findings need a correctness/requirements filter before they
gate anything.

**Prune each model generation.** Every harness component encodes an assumption
about what the model cannot do alone. Build structure so it is easy to delete,
and prefer model-independent assurance (verification gates) over scaffolding
that compensates for a specific generation's weakness.

## How that lands in this repository

- **`skill-quality`** — the optimization loop refuses to run without a
  mechanical pass/fail signal (no oracle, no loop), proposes edits only from
  train traces, and accepts only what beats a held-out split. Where no
  mechanical signal exists, `skill-quality-review` is advisory and never a gate.
- **`artifact-review`** — the rigorous pass uses fresh independent reviewers
  against risk-selected definitions from `review-lenses`, and reports coverage
  gaps rather than implying completeness. This is generator/evaluator separation
  made explicit.
- **`orchestration-toolkit`** — delegated execution ends at a global adversarial
  review and a final human approval gate, because delegation multiplies (b)-class
  error faster than it multiplies output.
- **`planning-toolkit`** — the outcome contract is where criteria get made
  checkable, and blocking research and design are resolved before work is
  declared autonomous-ready.
- **`exec-plan`** — reversible decisions are made autonomously and one-way doors
  are parked for one human review, which is the cheap version of shortening the
  outer loop.

## Sources

- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Harness design for long-running apps](https://www.anthropic.com/engineering/harness-design-long-running-apps)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- [anthropics/cwc-long-running-agents](https://github.com/anthropics/cwc-long-running-agents) (event demo, unmaintained)
- [shinpr/claude-code-workflows](https://github.com/shinpr/claude-code-workflows) — bounded self-verification loop with escalation

## History

- **2026-08-23** — Updated the review mapping to the focused
  `artifact-review` skill and its shared `review-lenses` dependency after the
  former toolkit split.
- **2026-08-03** — Rewritten from a dated research record into a standing
  statement of design principles. The review of the `dev-workflow` plugin, its
  improvement roadmap, and the assessments of individual articles were dropped
  with that plugin; the durable concepts were kept and mapped onto the skill
  groups that now carry them.
- **2026-06-11** — Created as research notes on loop engineering versus
  spec-driven development.
