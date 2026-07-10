# Verification signals: the loss function of skill optimization

The verification signal decides, for each task, whether the skill's deliverable
**passes or fails**. It is the loss function of the whole loop. Law 1: its
quality caps the quality of everything downstream — an imprecise signal makes
iteration degrade output rather than improve it. Design it before running.

A usable signal is **mechanical and reproducible**: two runs on the same
deliverable return the same verdict, and the verdict does not consult the same
judgment that produced the deliverable. Three designs, in order of preference.

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

## 3. Self-criteria (agent-judged deliverable criteria)

When neither an oracle nor anchors exist, fall back to the deliverable success
criteria from `skill-authoring` B3: **binary, observable, specific** checks a
fresh agent applies by reading the output. Set `signal.kind = self-criteria` and
`command = null`.

- Each criterion must be answerable Yes/No, verifiable by reading the output (no
  external state), and unambiguous (two judges agree).
- Reduce self-judgment noise: use a *separate, fresh* agent context to judge (not
  the one that produced the output), and phrase criteria so a skeptic and an
  advocate would score them the same.
- This is the weakest signal. Treat a self-criteria loop's result as provisional
  and spot-check held-out deliverables by hand.

## The boundary: what cannot be a signal

Some qualities cannot be mechanized — "is this blog post interesting?", "is this
prose elegant?", subjective product taste. No amount of iteration automates them;
across the whole research literature this remains the part left to humans.

When the deliverable's quality lives in such a judgment:

- **Do not run the optimization loop on it.** A loop with a signal that cannot
  discriminate will happily "converge" on worse output.
- Use `skill-optimize-evaluate` once to establish a baseline on whatever *is*
  checkable, and hand the subjective dimension to a human reviewer.
- Split the deliverable: mechanize the checkable parts (facts, structure,
  constraints), keep the taste-dependent parts human-gated.
