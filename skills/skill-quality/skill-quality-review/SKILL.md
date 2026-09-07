---
name: skill-quality-review
description: >-
  Reviews a skill by first identifying whether its parts provide guidance,
  coordinate a workflow, or perform a task, then applies only the
  relevant qualitative standard. Returns a small set of evidence-backed,
  advisory findings; optional family and deliverable reads widen the evidence.
metadata:
  description-role: documentation
---

# Skill quality review

Review a target skill once and return findings a human can act on. Load
`skill-quality-standard` as the normative source and read its
`references/anti-patterns.md`.

This review uses model judgment. It is advisory, does not produce a numeric
score, and does not imply that a skill guarantees behavior.

## Choose the review scope

Run a static review for every target. Add:

- **family** when the user names a cooperating skill family or repository scope;
  read `references/family-review.md` before reviewing;
- **deliverable** when the skill can be run safely on a few realistic tasks and
  its output can be meaningfully inspected.

If deliverables cannot be produced or judged, complete the static review and say
what was not observed. Do not present a static review as behavioral proof.

## Review procedure

### 1. Confirm loadability

Run:

```sh
skill-quality-standard/scripts/lint-frontmatter.sh <target-skill-dir>
```

If it fails, report the structural error first. The remaining text may still be
useful to diagnose, but it is not an active skill until loadability is fixed.
Treat exit 0 as a common-trap check, not proof of valid YAML; use the repository's
real parser when one is available.

### 2. Identify what the skill contributes

Read `SKILL.md` and follow the named references and resources needed to understand
its substantial parts and load conditions. Inspect scripts, schemas, and assets
that implement a claimed interface; do not inventory unrelated files.

Identify which value sources apply: capability uplift, encoded intent, or both.
Classify its primary role as guidance, workflow, or task, then classify each
substantial part as interpretive, coordinated, or deterministic. Treat these as
review judgments, not metadata requirements.

For capability uplift, ask what useful ability or consistency the skill adds
beyond the base model. For encoded intent, ask whether it faithfully conveys the
intended practice or constraint rather than whether that intent is universally
best.

For each relevant property of the intended result, identify whether it is
qualitatively reviewable, mechanically checkable, or both. Do not infer
mechanical checkability merely from a clear purpose or a structured output.

State the classification briefly with the evidence that matters. A mixed skill
is normal; the question is whether each part receives the appropriate degree of
control.

### 3. Apply the common standard

Check whether the skill:

- adds information or control the model needs;
- has a coherent scope;
- states its current direction and boundaries directly;
- makes its intended result reviewable at the appropriate qualitative,
  coordination, or deterministic level;
- spends context only on material that changes action or judgment;
- places conditional detail behind a clear load condition.

Prefer subtraction when content can be removed, merged, or generalized without
losing a real direction, boundary, domain fact, handoff, or machine contract.

### 4. Apply the relevant role guidance and part-level control

Apply role guidance without assuming a role determines its control level:

- **Guidance** — Look for useful principles, rationale, scope, and representative
  judgment.
- **Workflow** — Look for necessary order, handoffs, invariants, and stop
  conditions.
- **Task** — Look for the knowledge, tools, inputs, and outputs needed to perform
  the work.

Then calibrate each substantial part independently:

- **Interpretive** — Preserve contextual judgment; flag rule catalogs and false
  objectivity.
- **Coordinated** — Constrain only real dependencies and handoffs; flag decorative
  steps, default checklists, and detail loaded outside its stage.
- **Deterministic** — Look for clear machine boundaries and stable operations;
  flag both prose reimplementation and scripts or schemas that merely encode
  qualitative judgment.

The absence of a checklist, schema, script, or mechanical validator is not a
finding unless the task actually needs one.

### 5. Inspect observable behavior when available

For deliverable mode, use a few realistic tasks and fresh context for each. Read
the resulting artifacts and relevant trace. Use them as examples of how the
skill shapes behavior, not as proof of universal performance.

If a genuinely reproducible mechanical signal exists and the user wants a
measurement, `skill-quality-evaluate` is the separate quantitative path. Do not
turn this qualitative review into that path.

## Report

Lead with the conclusion and the highest-impact reason. Then provide no more than
five material findings, ordered by likely effect on a model using the skill. For
each finding include:

- the problem;
- the source passage or observed behavior supporting it;
- the consequence;
- the smallest useful change, preferring deletion or generalization where it
  preserves the task.

Also state:

- the role/control classification used;
- the modes and files covered;
- any unobserved deliverable or unresolved family boundary;
- what should be preserved.

Do not force an equal finding count across categories. If the skill is already
simple and fit for its role, say so rather than inventing improvements.

Applying edits or running an optimization loop requires a separate request.
