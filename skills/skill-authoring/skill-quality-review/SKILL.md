---
name: skill-quality-review
description: Review a skill for quality against the Three Principles (Why & concrete criteria, self-complete success criteria, clear triggers). Use when validating a newly created or modified skill, checking whether a skill is effective for AI use, or diagnosing a skill that produces poor results or frequent clarification requests. This is the portable review procedure; under Claude Code it is also wrapped by the skill-quality-reviewer subagent for isolated execution. Should NOT trigger for plugin structure questions, the skill-development process, or explaining the principles themselves (use the skill-authoring skill).
---

# Skill Quality Review

Evaluate a target skill against the Three Principles. This procedure is self-contained and runs inline on any agent. When dispatched as a subagent (Claude Code), perform the same steps in the isolated context and return the report.

## Source of Truth

The principles and anti-patterns are owned by the **`skill-authoring`** skill. Apply that skill's content as the review rubric:

1. Apply the `skill-authoring` skill to load the current Three Principles.
2. Apply the `skill-authoring` skill's `references/anti-patterns.md` (bundled inside that skill) for failure patterns.

Do not restate or re-derive the principles here — defer to the `skill-authoring` skill so this review stays in sync with it.

## Review Process

### Step 1: Read the Target Skill

1. Locate and read the target skill's `SKILL.md`.
2. Read any `references/` files bundled in the target skill.

### Step 2: Evaluate Principle 1 (Why & Concrete Criteria)

For each piece of guidance:

| Guidance | Has Rationale? | Specific Enough? | Issue |
|----------|----------------|------------------|-------|
| [Quote] | Yes/No | Yes/No | [Issue if any] |

**Key question**: Can AI apply this without asking for clarification?

### Step 3: Evaluate Principle 2 (Self-Complete)

Check if success criteria exist. If yes, evaluate each:

| Criterion | Binary? | Observable? | Specific? | Issue |
|-----------|---------|-------------|-----------|-------|
| [Quote] | Yes/No | Yes/No | Yes/No | [Issue] |

**Key question**: Can AI self-evaluate its output?

### Step 4: Evaluate Principle 3 (Clear Triggers)

Analyze the description field:
- Intent-based? (describes the user's goal, not just keywords)
- Exclusions defined? (should NOT trigger conditions)
- Potential false positives/negatives?

### Step 5: Generate Report

Provide:
1. **Overall Assessment**: Pass / Needs Improvement / Needs Major Revision
2. **Per-Principle Score**: Strong / Adequate / Weak with specific findings
3. **Priority Fixes**: Ordered by impact, with concrete before/after recommendations
4. **Strengths**: What to preserve
