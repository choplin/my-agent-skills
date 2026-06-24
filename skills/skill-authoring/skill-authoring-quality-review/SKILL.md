---
name: skill-authoring-quality-review
description: Review a skill for content quality against the skill-authoring guidelines (context economy, why & concrete criteria, self-evaluable output, triggering description, calibrated control). Use when validating a newly created or modified skill, checking whether a skill is effective for AI use, or diagnosing a skill that produces poor results or frequent clarification requests. This is the portable review procedure; under Claude Code it is also wrapped by the skill-authoring-quality-reviewer subagent for isolated execution. Should NOT trigger for plugin structure questions, the skill-development process, or explaining the guidelines themselves (use the skill-authoring skill).
---

# Skill Quality Review

Evaluate a target skill against the `skill-authoring` content-quality guidelines. This procedure is self-contained and runs inline on any agent. When dispatched as a subagent (Claude Code), perform the same steps in the isolated context and return the report.

## Source of Truth

The guidelines and anti-patterns are owned by the **`skill-authoring`** skill. Apply that skill as the review rubric:

1. Apply the `skill-authoring` skill to load the current Layer B content-quality topics (B1–B5).
2. Apply its `references/anti-patterns.md` for failure patterns and detection cues.

Do not restate or re-derive the guidelines here — defer to the `skill-authoring` skill so this review stays in sync with it.

## Review Process

### Step 1: Read the target skill

1. Locate and read the target skill's `SKILL.md`.
2. Read any `references/` files bundled in it (and note whether each has an explicit load trigger).

### Step 2: Evaluate context economy (B1)

- Is any content explaining what the agent already knows? (cut candidates)
- Is the skill a coherent unit, or scope-creeping across unrelated tasks?
- Is `SKILL.md` lean, with heavy material in `references/`? Does each reference have a "read this when…" trigger?

### Step 3: Evaluate why & concrete criteria (B2)

For each piece of guidance:

| Guidance (quote) | Concrete? | Has rationale? | Issue |
|------------------|-----------|----------------|-------|
| … | Yes/No | Yes/No | … |

**Key question**: Can the agent apply this on an edge case without asking for clarification? Are gotchas present (where the domain has them) and kept in `SKILL.md`?

### Step 4: Evaluate self-evaluable output (B3)

Check whether deliverable success criteria exist. If yes, evaluate each:

| Criterion (quote) | Binary? | Observable? | Specific? | Evaluates deliverable (not process)? | Issue |
|-------------------|---------|-------------|-----------|--------------------------------------|-------|
| … | Yes/No | Yes/No | Yes/No | Yes/No | … |

**Key question**: Can the agent self-evaluate its output before showing the user?

### Step 5: Evaluate triggering description (B4)

- Intent-based, or just keywords?
- Exclusions present where the trigger overlaps neighboring skills?
- Likely false positives / false negatives?

### Step 6: Evaluate calibration (B5)

- Prescriptive where the task is fragile, free where it tolerates variation?
- Defaults provided instead of menus?
- Procedures that generalize, instead of one-off answers?

### Step 7: Generate report

Provide:

1. **Overall Assessment**: Pass / Needs Improvement / Needs Major Revision
2. **Per-topic findings** (B1–B5): Strong / Adequate / Weak, with specific quotes
3. **Priority Fixes**: ordered by impact, with concrete before/after recommendations
4. **Strengths**: what to preserve
