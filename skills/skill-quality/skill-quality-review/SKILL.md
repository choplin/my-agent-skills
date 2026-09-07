---
name: skill-quality-review
description: >-
  Applies the qualitative skill standard with model judgment and returns
  evidence-backed findings in one advisory pass. Optional family mode
  reconstructs execution paths across cooperating skills; deliverable mode
  runs the skill on a few real tasks and reads the outputs qualitatively.
metadata:
  description-role: documentation
---

# skill-quality-review: one advisory review pass

Review a target skill **once** and hand back findings a human acts on. This is the
normal path for assessing skill quality: the reviewer interprets the qualitative
standard against the target's context, content, and observable behavior. A
mechanical evaluation is a separate path whose reproducible signal must be defined
before the run; constructing a faithful signal has a high practical setup cost.

> Load `skill-quality-standard` as the normative source, then read its
> `references/anti-patterns.md`. This skill checks conformance with that standard;
> it does not define good skill content independently.

## Nature of the judgment

Apply the standard with judgment. Its requirements supply shared lenses and
evidence expectations, not a formula that determines the answer. Weigh findings by
their likely effect on an agent using the skill, explain contextual trade-offs, and
make uncertainty visible.

The result is an advisory qualitative assessment, not a guarantee or a
measurement. This skill **never**:

- **gates** — it does not accept/revert edits;
- **loops** — it runs once, not iteratively;
- **auto-edits** — it proposes findings, the human decides;
- **emits a numeric score** — findings are specific and quotable.

Route to `skill-quality-evaluate` only when the user can define a reproducible
pass/fail signal for the relevant output before evaluation begins.

## Review modes

Run `static` always. Add `family` when the user explicitly names a cooperating
skill family or repository scope; it expands the static read rather than
replacing it. Add `deliverable` when the skill is runnable and its output is
observable. The default remains one target skill in static mode.

| Mode | Reads | Needs | Answers |
|------|-------|-------|---------|
| **static** | the `SKILL.md` (+ references) | nothing | is the *content* well-written? |
| **family** | callers, delegates, references, schemas, and consumers on execution paths | an explicit family or repository scope | is the *cooperating system* economical and consistently owned? |
| **deliverable** | outputs from running the skill on real tasks | runnable skill + observable output | does the skill *actually help*? |

When `family` is selected, read `references/family-review.md` before static
review. It owns path reconstruction, ownership/use inventories, finding
classifications, and the handoff-boundary exception.

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

Evaluate the target against `skill-quality-standard`.

### 0. Preflight — does the skill even load? (B0, mechanical)

Run first, always:

```
skill-quality-standard/scripts/lint-frontmatter.sh <target-skill-dir>
```

Exit 0 = the frontmatter parses and has its `name`/`description` → continue to the
standard. **Non-zero = stop.** Report the lint output as the finding, with overall
**Needs Major Revision**, and do not assess B1–B6: a skill whose frontmatter is broken
is never loaded, so its content is moot and any conformance verdict would concern a
file the agent never reads.

Do not eyeball this instead of running it, and do not "fix" it by judgment. The
canonical failure is an unquoted `description` with a `: ` (colon + space) somewhere
mid-sentence — YAML reads it as a nested key and the whole file fails to parse. It
reads perfectly to a human, the skill simply never appears, and the user reports it
as "the skill doesn't trigger" (a B4 symptom) when B4 is not the problem at all.

### 1. Read the target skill

1. Locate and read the target's `SKILL.md`.
2. Read its `references/` files (note whether each has an explicit load trigger).

### 2. Check each standard requirement

- **B1 context economy** — Any content explaining what the agent already knows (cut
  candidates)? Coherent unit or scope-creeping? `SKILL.md` lean with heavy material
  in `references/` behind specific load conditions? Does the body contain only the
  execution spine needed across runs, with branch-specific procedures routed at
  their decision points? For a substantial multi-step workflow, does the body keep
  only sequence and handoff contracts while each step's detail loads from its own
  reference when that step begins? Does any instruction eagerly load unrelated
  step references? Is non-execution background kept out of the normal workflow
  and exposed, if useful, only through a narrow audit/revision reference? Is each
  reference directly discoverable without duplicating its contents in the body?
- **B2 why & concrete criteria** — For each piece of guidance: concrete? has
  rationale? Can the agent apply it on an edge case without asking for
  clarification? Gotchas present (where the domain has them) and kept in `SKILL.md`?

  | Guidance (quote) | Concrete? | Has rationale? | Issue |
  |------------------|-----------|----------------|-------|

- **B3 judgeable outcome** — Does the skill make the desired deliverable and the
  relevant evidence concrete enough for reasoned judgment? Does it evaluate the
  result rather than completed steps? Has a qualitative property been replaced by
  a convenient binary proxy?

  | Criterion (quote) | Observable evidence | Judgment supported? | Deliverable-focused? | Issue |
  |-------------------|---------------------|---------------------|----------------------|-------|

- **B4 triggering description** — Intent-based or bare keywords? Is the intended
  situation precise and positive, without exclusion catalogues or sibling
  redirects? Likely false positives / false negatives?
- **B5 calibration** — Prescriptive where fragile, free where it tolerates
  variation? Defaults instead of menus? Procedures that generalize instead of
  one-off answers?
- **B6 current contract** — Does the skill state desired behavior directly? Does
  historical or contrastive wording make the agent consider a former/rejected
  design? Does every retained compatibility statement name a current external
  contract, migration, deprecation, or versioned schema/protocol requirement?

  Sweep for both explicit history markers and implicit contrast forms listed in
  the standard. Judge their meaning: retain intrinsic present constraints and safety
  boundaries; report former-state and rejected-alternative framing even when it
  avoids words such as `legacy`.

Cross-check against `skill-quality-standard`
(`references/anti-patterns.md`).

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
each shortfall back to a standard requirement where you can (e.g. "output missed the edge
case → B2 has no gotcha for it"; "agent tried three approaches → B5 gives no
default"). Deliverable evidence sharpens the static findings; it does not replace
them.

> If a mechanical pass/fail signal *does* exist and you want a real pass rate rather
> than a qualitative read, stop and use `skill-quality-evaluate` instead — that is
> its job, and it feeds the optimize loop.

## Report

Return, in this order:

1. **Coverage** — the B0 preflight verdict (clean, or the lint output); which modes
   ran; for family mode, the bounded skills, reconstructed paths, unresolved
   dynamic edges, and exclusions; if `deliverable` was skipped or left unjudged,
   which case and why.
2. **Overall conformance** — Pass / Needs Improvement / Needs Major Revision.
3. **Family findings** (family mode only) — grouped by the five primary kinds,
   with the ownership/use evidence and affected execution paths.
4. **Per-topic findings (B1–B6)** — Strong / Adequate / Weak, with verbatim quotes
   (copy the exact text, don't paraphrase — the point is to let the reader verify
   without re-reading the source); fold in deliverable evidence where it applies.
5. **Priority fixes** — ordered by impact, with concrete before/after
   recommendations.
6. **Strengths** — what to preserve, including intentional boundary enforcement.

Use the labels as qualitative summaries, not calculated grades:

- **Per topic** — *Strong* when the evidence shows the requirement working;
  *Adequate* when gaps are limited and unlikely to change outcomes; *Weak* when a
  gap plausibly makes the agent stall, guess, waste context, or ship the wrong
  result.
- **Overall** — choose Pass / Needs Improvement / Needs Major Revision by the
  material effect of the findings together. Explain why the combined evidence
  warrants that judgment. A failed B0 remains Needs Major Revision because the
  skill cannot load at all.

Before returning, self-check: B0 was actually *run*, not assumed; every B1–B6
verdict cites at least one verbatim quote; Coverage names which modes ran and, if
family mode ran, its boundary, paths, unresolved edges, and exclusions; every
family finding has one primary kind and ownership/use evidence; retained handoff
guards state why both sides enforce them; if deliverable was skipped, Coverage
names which fallback case and why; no numeric score appears anywhere (a number
invites gating — see Boundary).

Findings only. Applying them, and any iterate-and-recheck, is the human's call (or,
where a trustworthy mechanical signal exists, `skill-quality-optimize`'s).
