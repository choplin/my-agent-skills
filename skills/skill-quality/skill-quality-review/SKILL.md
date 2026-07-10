---
name: skill-quality-review
description: Review a skill's quality in one advisory pass and return findings (never a gate, never a loop). Two modes that degrade gracefully — static, scoring the SKILL.md against the content-quality rubric (context economy, why & concrete criteria, self-evaluable output, triggering description, calibrated control); and deliverable, running the skill on a few real tasks and reading the outputs qualitatively. When the deliverable can't be observed, do static only and say so. Use to validate a newly created or modified skill, sanity-check one before committing to the skill-quality-optimize loop, or diagnose a skill that produces poor results or frequent clarification requests. This is the portable procedure; under Claude Code it is also wrapped by the skill-quality-reviewer subagent for isolated execution. Should NOT trigger for the autonomous mechanical optimize loop (use skill-quality-optimize), pass/fail benchmarking against a mechanical signal (use skill-quality-evaluate), plugin structure questions, or authoring a skill from scratch (use skill-creator).
user-invocable: true
---

# skill-quality-review: one advisory review pass

Review a target skill **once** and hand back findings a human acts on. This is the
advisory, human-in-the-loop counterpart to the mechanical `skill-quality-optimize`
loop — it covers the skills the loop can't (subjective deliverables, no mechanical
signal) and the case where you just want a read before committing to a loop.

> Load `skill-quality-base` for the content-quality rubric
> (`references/content-quality-rubric.md`) and anti-patterns
> (`references/anti-patterns.md`). This skill applies that rubric; it does not
> restate it, so the two stay in sync.

## Boundary (why this is safe)

A one-shot advisory review does not compound, so the verifier-precision failure
that governs the loop (`skill-quality-base` law 1) does not apply here. To keep it
that way, this skill **never**:

- **gates** — it does not accept/revert edits;
- **loops** — it runs once, not iteratively;
- **auto-edits** — it proposes findings, the human decides;
- **emits a score as its verdict** — findings are specific and quotable, not a
  number. (A number invites gating on it and re-imports the failure mode.)

If you want an accept/revert loop driven by a trustworthy mechanical signal, that
is `skill-quality-optimize`, not this.

## Two modes

Run **both** when you can. `static` is always available (reading text is free);
`deliverable` is an add-on that needs the skill to be runnable and its output
observable.

| Mode | Reads | Needs | Answers |
|------|-------|-------|---------|
| **static** | the `SKILL.md` (+ references) | nothing | is the *content* well-written? |
| **deliverable** | outputs from running the skill on real tasks | runnable skill + observable output | does the skill *actually help*? |

### Graceful fallback

`deliverable` can be impossible or untrustworthy. Two distinct cases — record which:

- **Can't produce the output** — no real tasks, output has side effects on external
  systems, interactive/non-capturable, etc. → run `static` only.
- **Can produce but can't confidently judge** — output needs domain expertise you
  lack, or an LLM read would be too unreliable to trust → run the skill, but mark
  the deliverable **unjudged** rather than guessing a verdict.

Either way, **do static and say what you skipped and why**. Never present a
static-only review as if the deliverable had been observed — a silent skip reads as
"fully reviewed" when half the picture is missing.

## Static mode

Evaluate the target against the rubric loaded from `skill-quality-base`.

### 1. Read the target skill

1. Locate and read the target's `SKILL.md`.
2. Read its `references/` files (note whether each has an explicit load trigger).

### 2. Score each rubric topic

- **B1 context economy** — Any content explaining what the agent already knows (cut
  candidates)? Coherent unit or scope-creeping? `SKILL.md` lean with heavy material
  in `references/` behind "read this when…" triggers?
- **B2 why & concrete criteria** — For each piece of guidance: concrete? has
  rationale? Can the agent apply it on an edge case without asking for
  clarification? Gotchas present (where the domain has them) and kept in `SKILL.md`?

  | Guidance (quote) | Concrete? | Has rationale? | Issue |
  |------------------|-----------|----------------|-------|

- **B3 self-evaluable output** — Do deliverable success criteria exist? For each:
  binary? observable? specific? evaluates the *deliverable*, not the process?

  | Criterion (quote) | Binary? | Observable? | Specific? | Deliverable (not process)? | Issue |
  |-------------------|---------|-------------|-----------|----------------------------|-------|

- **B4 triggering description** — Intent-based or bare keywords? Exclusions where the
  trigger overlaps neighbors? Likely false positives / false negatives?
- **B5 calibration** — Prescriptive where fragile, free where it tolerates
  variation? Defaults instead of menus? Procedures that generalize instead of
  one-off answers?

Cross-check against `skill-quality-base` (`references/anti-patterns.md`).

## Deliverable mode

Read the outcomes the skill produces, not its text. Keep it lightweight — this is
one advisory read, not the `skill-quality-evaluate` benchmark.

### 1. Gather a few real tasks

2–3 realistic tasks the skill is meant to handle, ideally from actual usage. Fewer
than the loop needs — you are sampling behavior, not computing a pass rate.

### 2. Run the skill and read the outputs

For each task, execute the skill as an agent actually would (load it, follow it,
produce the deliverable) in a fresh context, then read what came out — including the
trace, not just the final artifact. Wasted steps, near-misses, and instructions the
agent ignored are all findings.

### 3. Turn outcomes into findings

For each task, note what the deliverable got right and where it fell short, and tie
each shortfall back to a rubric topic where you can (e.g. "output missed the edge
case → B2 has no gotcha for it"; "agent tried three approaches → B5 gives no
default"). Deliverable evidence sharpens the static findings; it does not replace
them.

> If a mechanical pass/fail signal *does* exist and you want a real pass rate rather
> than a qualitative read, stop and use `skill-quality-evaluate` instead — that is
> its job, and it feeds the optimize loop.

## Report

Return, in this order:

1. **Coverage** — which modes ran; if `deliverable` was skipped or left unjudged,
   which case and why.
2. **Overall assessment** — Pass / Needs Improvement / Needs Major Revision.
3. **Per-topic findings (B1–B5)** — Strong / Adequate / Weak, with specific quotes;
   fold in deliverable evidence where it applies.
4. **Priority fixes** — ordered by impact, with concrete before/after
   recommendations.
5. **Strengths** — what to preserve.

Findings only. Applying them, and any iterate-and-recheck, is the human's call (or,
where a trustworthy mechanical signal exists, `skill-quality-optimize`'s).
