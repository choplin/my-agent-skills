# Verification signals: the loss function of skill optimization

The verification signal decides, for each task, whether the skill's deliverable
**passes or fails**. It is the loss function of the whole loop. Law 1: its
quality caps the quality of everything downstream — an imprecise signal makes
iteration degrade output rather than improve it. Design it before running.

A usable signal is **mechanical and reproducible**: two runs on the same
deliverable return the same verdict, and the verdict does not consult model
judgment. Two designs qualify.

## 1. Oracle (pass/fail from ground truth)

An external check that returns only a binary verdict — a test suite, a reference
implementation to diff against, a schema validator, a compiler/linter exit code.
The ground truth stays *outside* the optimization loop; the loop sees only
pass/fail (CoEvoSkills reaches 71.1% pass rate this way vs 30.6% with no skill).

- Best when the task has a checkable correct answer (code that must pass tests,
  output that must match a schema, a transform with a reference result).
- Wire it as `--signal-cmd` in `init.sh`; the command exits 0 on pass.
- **Never let the improver read the oracle's internals** — only its verdict.

## 2. Verification anchor (mechanically-checkable facts)

When there is no full oracle, extract *anchors* from an authoritative source —
known reference values, published statistics, invariants that must hold — and
build a mechanical test around them (OpenSkill). The deliverable passes iff it is
consistent with the anchors.

- Best when parts of a correct answer are checkable even if the whole is not
  (a report must cite the real figure; a query must return the known row count).
- Weaker than an oracle: it checks necessary conditions, not sufficiency. Precision
  matters — anchors that a wrong deliverable can still satisfy give false passes,
  which is exactly what degrades the loop.

## The boundary: what cannot be a signal

Some qualities cannot be mechanized — "is this blog post interesting?", "is this
prose elegant?", subjective product taste. No amount of iteration automates them;
across the whole research literature this remains the part left to humans.

When the relevant quality lives in such a judgment, use
`skill-quality-standard` + `skill-quality-review`. A model may apply those
qualitative criteria with judgment and explain its evidence, but that result is
not a verification signal and never enters the quantitative gate. If one bounded
part of a deliverable is mechanically checkable, evaluate may report that part's
measurement while leaving the qualitative assessment separate.
