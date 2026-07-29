---
name: skill-quality-review
description: >-
  Reviews a skill's quality in one advisory pass and returns findings, never
  as a gate or a loop. Static mode scores SKILL.md against the content-quality
  rubric; deliverable mode runs the skill on a few real tasks and reads the
  outputs qualitatively, falling back to static mode when the outputs cannot
  be observed.
metadata:
  description-role: documentation
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

### 0. Preflight — does the skill even load? (B0, mechanical)

Run first, always:

```
skill-quality-base/scripts/lint-frontmatter.sh <target-skill-dir>
```

Exit 0 = the frontmatter parses and has its `name`/`description` → continue to the
rubric. **Non-zero = stop.** Report the lint output as the finding, with overall
**Needs Major Revision**, and do not score B1–B5: a skill whose frontmatter is broken
is never loaded, so its content is moot and any rubric verdict would be advice on a
file the agent never reads.

Do not eyeball this instead of running it, and do not "fix" it by judgment. The
canonical failure is an unquoted `description` with a `: ` (colon + space) somewhere
mid-sentence — YAML reads it as a nested key and the whole file fails to parse. It
reads perfectly to a human, the skill simply never appears, and the user reports it
as "the skill doesn't trigger" (a B4 symptom) when B4 is not the problem at all.

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

1. **Coverage** — the B0 preflight verdict (clean, or the lint output); which modes
   ran; if `deliverable` was skipped or left unjudged, which case and why.
2. **Overall assessment** — Pass / Needs Improvement / Needs Major Revision.
3. **Per-topic findings (B1–B5)** — Strong / Adequate / Weak, with verbatim quotes
   (copy the exact text, don't paraphrase — the point is to let the reader verify
   without re-reading the source); fold in deliverable evidence where it applies.
4. **Priority fixes** — ordered by impact, with concrete before/after
   recommendations.
5. **Strengths** — what to preserve.

Grade against a stated basis, so two reviewers converge instead of each picking a
band by feel (don't reimport the B2 "ungrounded threshold" anti-pattern into your
own verdict):

- **Per topic** — *Strong*: no issue found. *Adequate*: cosmetic or a single
  non-critical gap. *Weak*: an anti-pattern match, or a gap that would cause a
  real failure (agent stalls, guesses, or ships wrong output).
- **Overall** — *Pass*: no Weak topic. *Needs Improvement*: 1–2 Weak, none that
  would misdirect the agent. *Needs Major Revision*: 3+ Weak, or any Weak in B2
  gotchas / B3 self-evaluability (those actively mislead), **or a failed B0
  preflight** (nothing else can matter).

Before returning, self-check: B0 was actually *run*, not assumed; every B1–B5
verdict cites at least one verbatim quote; Coverage names which modes ran and, if
deliverable was skipped, which fallback case and why; no numeric score appears
anywhere (a number invites gating — see Boundary).

Findings only. Applying them, and any iterate-and-recheck, is the human's call (or,
where a trustworthy mechanical signal exists, `skill-quality-optimize`'s).
