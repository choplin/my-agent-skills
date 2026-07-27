---
title: "Adversarial Verification — Design Principle"
date: 2026-07-10
type: principle
status: accepted
tags:
  - adversarial-verification
  - agent-skills
  - quality-assurance
  - loop-engineering
  - design-rationale
summary: >
  When building anything with LLM agents — an answer, a skill document, an
  automated improvement loop — deliberately engineer an independent adversary
  or verifier into the system rather than relying on self-critique. The value
  comes from the generation/verification asymmetry, but only when the verifier
  is decorrelated, independent, and its signal verifiable; a weak or correlated
  verifier is worse than none. Concrete skills are named only in the final
  section so the principle survives renames.
---

# Adversarial Verification — Design Principle

This is the durable statement of a cross-cutting principle for this repository:
**when an LLM agent produces something consequential, do not trust a single
pass — build an independent adversary or verifier into the system on purpose.**
The upper sections are near-invariant; only the last section names concrete
skills.

## The principle

A generator checking its own work is a conflict of interest. The blind spots in
generation and the blind spots in self-critique come from the same weights, so
they correlate: the model tends not to catch at review time what it missed at
generation time, and it is biased to rate its own output favorably
(self-preference). Therefore, for consequential work, route the check through an
**independent** party whose failure modes differ from the generator's.

This is worth doing because of an asymmetry: **refuting a candidate is usually
easier than producing one.** An independent verifier that only has to find one
concrete flaw buys more quality per unit of compute than asking the generator to
be more careful.

## What makes it work — and what breaks it

Two properties must be engineered deliberately; the benefit does not come from
"using more than one model/agent" as such.

- **Decorrelation.** A reviewer catches only what the generator missed *when its
  error modes differ*. Same-model, same-context, or role-play-only "adversaries"
  (a persona named "Red Team") share blind spots — their agreement is weak
  evidence, not strong. Maximize heterogeneity (different model family >
  different model > forced-divergent method); where you cannot, say so and
  downgrade the evidential weight of any convergence.
- **Verification advantage.** Point the adversary at *verifiable* claims and make
  it refute by reproduction — run the code, recompute, check the source — not by
  assertion. "Fails on input X" is a signal; "I doubt this" is not.

The critical caveat, and the reason this is a principle and not just "add an
adversary": **a weak or correlated verifier is worse than no verifier.** An
adversarial loop amplifies whatever signal it is given. If the signal is noisy
or biased, iterating drives the artifact *away* from quality (Goodhart's law:
the output learns to satisfy the letter of a bad check). So the principle is
precise:

> Build in an adversary that is **valid, independent, and verifiable**. When you
> cannot make it so, lower the confidence you place in its verdict — do not let
> the loop run on a signal you don't trust.

## One axis, two regimes

Adversarial verification is a single principle that shows up at different points
on a generation → improvement axis. Recognizing which regime you are in tells
you what the adversary and its signal should be.

| | Inference-time | Artifact / loop-time |
|---|---|---|
| Target | one answer to one question | a reusable artifact (e.g. a skill document) |
| Adversary | an independent model/panelist | a verifier or verification anchor in an improvement loop |
| Signal | natural-language critique, per task | pass/fail, accumulated across iterations |
| Persistence | ephemeral (discarded after use) | accumulates into the artifact |
| Main risk | sycophantic convergence, ghost/false critique | a low-precision signal degrading the artifact over iterations |

The two regimes fail the same way (a correlated or weak adversary) and are
defended the same way (decorrelation + verifiable signal + confidence
downgrade when neither holds). The inference-time regime is cheaper to make
trustworthy because a human reads the synthesis each time; the loop-time regime
is more powerful but more dangerous because the signal compounds without a human
in the loop, so the bar for signal validity is higher, and domains where "done"
is not machine-checkable stay with a human.

## How this repository applies it

Concrete, rename-prone names are confined here.

- **`ai-council-adversarial-panel`** is the inference-time realization: 2+
  heterogeneous panelists answer blind, cross-critique across rounds, and a
  facilitator adjudicates (never averages) into one calibrated answer. Its
  invariants (independence, adversariality, no-averaging) and anti-patterns
  (ghost panelist, sycophantic convergence, diversity illusion, confidence
  theater) are this principle made operational.
- **`ai-council`** (root) is the weaker, one-shot sibling — parallel opinion
  gathering without cross-feedback. Useful, but its convergence is weaker
  evidence; the adversarial member exists for when that is not enough.
- **Native `/goal` usage** applies the loop-time discipline by giving the host a
  persistent, explicit target. Work whose direction must be approved by a human
  stays in `dev-workflow`; autonomous work expected to surface parked decisions
  uses `exec-plan`. The routing boundary is the "don't run the loop on a signal
  you don't trust" caveat applied to loop engineering.
- **`artifact-review-toolkit`** holds the review procedures themselves: a
  lens-selected, independence-preserving adversarial pass over a concrete
  artifact, and a lighter one-off review. **`code-review-session`** is the
  ingestion/adjudication plumbing a verifier stage reuses to record and resolve
  what a review returns.
- **Direction — autonomous skill-quality loops.** Applying the loop-time regime
  to skill documents themselves (a verifier that hardens its own checks against
  a skill-generator, or machine-checkable anchors driving iteration) is a wanted
  direction, bounded by the same caveat: build it only where the verification
  signal is valid enough that iterating helps rather than harms, and leave
  non-machine-checkable, domain-specific judgment to a human.

## Sources

- Ryousuke Wayama (@wayama_ryousuke), *adversarial-panel: 多モデル敵対的レビュー
  という品質保証* — the inference-time port of GAN's adversarial structure to
  natural-language critique. <https://github.com/makinux/adversarial-panel>
- LayerX, *Agent Skills 自動最適化における敵対的検証の設計* — the artifact/loop-time
  regime (skill documents as a training loop with verification gates;
  CoEvoSkills co-evolution and OpenSkill verification anchors), including the
  reported result that a low-precision verification signal (~57%) degrades
  performance as iterations increase. <https://zenn.dev/layerx/articles/9f25ec86a31730>
