---
name: skill-authoring
description: This skill should be used when the user wants to create a skill, improve an existing skill, or ensure a skill produces expected results. Triggers on "create a skill", "improve this skill", "skill isn't working", "fix this skill", "スキルを作りたい", "スキルを改善", "スキルを修正", "スキルがうまく動かない". Works together with plugin-dev:skill-development which handles file structure and formatting. This skill focuses on content quality. Should NOT trigger for plugin structure questions (use plugin-structure), command creation (use command-development), or agent creation (use agent-development).
user-invocable: true
---

# Skill Authoring: Content Quality Guide

## Relationship with plugin-dev:skill-development

> [!IMPORTANT]
> This skill is incomplete without plugin-dev:skill-development.
> Always load both skills together when creating or improving skills.

This skill complements plugin-dev:skill-development:

| Component | Responsibility |
|-----------|----------------|
| **plugin-dev:skill-development** | File structure, YAML frontmatter, writing style, progressive disclosure |
| **skill-authoring (this skill)** | Content quality based on Three Principles |

When creating a skill, both skills should be used together. plugin-dev:skill-development provides the structure; this skill ensures the content is effective.

## Three Principles for Effective Skills

### Principle 1: "Why" and Concrete Criteria

**Goal**: Capture what the user wants and the context behind their decisions - not general best practices.

**Key insight**: AI already knows general best practices. Writing "follow best practices" or "write clean code" adds zero information. Skills must go beyond what AI already knows to capture:
1. **Lessons from experience** - judgment criteria learned from specific problems or failures
2. **The basis for those judgments** - why a particular approach worked or didn't work in practice

**The Problem with Generic Guidance**:
- "Write clean code" - AI already knows this; adds no experiential insight
- "Follow best practices" - AI knows many practices; which worked/failed in actual projects?
- "Be concise" - AI can be concise in many ways; what trade-offs proved effective?

**What Concrete Criteria Look Like**:
- Experience-based judgment: "We prioritize readability over brevity"
- The problem that led to it: "Because junior developers struggled with terse code and made more bugs"
- Rule derived from that problem: "Always add explanatory comments for non-obvious logic"

**Example Transformation**:

Bad (vague, no criteria):
```
Write clean, maintainable code.
```

Bad (has criteria, but generic rationale without user's context):
```
Functions should:
- Not exceed 20 lines (split if longer)
- Have a single responsibility (one reason to change)

Rationale: Cognitive load research shows working memory handles 7±2 items.
```
This looks concrete but AI has no basis for "20 lines" - it's not from the user's experience. AI cannot judge edge cases (is 21 lines really a problem for THIS user?).

Good (reflects lessons learned from actual experience):
```
Problem: When functions handle multiple concerns, changing one part often
breaks another part unexpectedly.

Rule: Functions should have a single responsibility
- "Single responsibility" = only one reason to change the function
- If fixing a bug in validation could break pricing logic, split them
- Example: processOrder() doing validation + pricing + inventory
  → split into validate(), calculatePrice(), updateInventory()
```

The key difference: The rule exists because of actual problems encountered,
not because "best practices say so." The interview revealed this is
a recurring pain point with concrete examples - AI now understands the
experiential basis for this rule.

### Principle 2: Self-Complete (Success Criteria for Deliverables)

**Why this matters**: AI's self-feedback loop is essential for high-quality output. Without clear success criteria for the deliverable, AI cannot evaluate its own work - it completes all steps, assumes success, but the output misses user expectations. Clear deliverable criteria enable AI to iterate internally before presenting to user.

**Goal**: Define success criteria for the **deliverable** (not the process) so AI can self-evaluate its output and iterate toward improvement.

**Critical Distinction**:
- Process verification: "Did I complete step 1? step 2? step 3?" → All steps done, but output may still be wrong
- Deliverable verification: "Does my output meet the user's expectations?" → Enables self-correction before user sees it

Process steps can all complete successfully while still producing a deliverable that misses user expectations. Success criteria must evaluate the **final output**.

**Checklist Requirements**:
Each criterion must be (without these, AI's self-feedback loop cannot function):
- **Binary**: Answerable with Yes or No (not "somewhat" or "mostly")
- **Observable**: Verifiable by reading the output (not requiring external testing)
- **Specific**: No ambiguity in interpretation (two people would agree on the answer)

### Principle 3: Clear Trigger Conditions

**Why this matters**: Skill activation timing varies greatly by skill nature. Triggers that are too broad result in "always available but never used" - the skill gets ignored because it's not specific enough to be useful. Triggers must be derived from user intent through interview.

**Goal**: Define when the skill should activate based on user INTENT, not just keywords.

**What Clear Triggers Look Like**:
- **Intent-based**: Describes the problem user is trying to solve
- **Context-aware**: Includes relevant situational details
- **Exclusion-defined** (optional): Only needed when trigger is ambiguous; if trigger is sufficiently specific, exclusions are just noise

**Invocation Settings** (also require user intent):
- `user-invocable`: Whether skill appears in slash command menu (user can invoke directly)
- `disable-model-invocation`: Whether AI should auto-invoke this skill based on context
- These settings reflect HOW the skill fits into user's workflow - ask during interview

**Example Transformation**:

Weak:
```yaml
description: This skill should be used when the user mentions "code review"
```

Strong:
```yaml
description: This skill should be used when the user wants to review code
changes for quality issues, specifically asking to "review my PR",
"check this code for bugs", "find problems in this implementation",
or wants feedback on code they've written. Should NOT trigger for:
reviewing documentation, reviewing architectural designs, reading code
to understand it (without feedback intent), or security-specific audits
(use security-review skill instead).
```

## Integration with plugin-dev:skill-development Process

### At Step 1 (Understanding the Skill)

**Use dig skill for structured interview:**

Load `discuss-toolkit-dig` and provide context:
- **Subject**: "skill requirements for [skill name]"
- **Context for dig**: Creating a skill that satisfies Three Principles requires understanding:
  1. User's experiential rationale (not generic best practices) - lessons learned from specific problems or failures
  2. Binary/observable success criteria for the deliverable
  3. Intent-based trigger conditions with clear exclusions

dig will dynamically determine what questions to ask based on user responses and the above context. Do NOT prescribe specific questions like "What are the trigger conditions?" - let dig explore the subject naturally through its three axes (Intent & Motivation, Use Cases & Edge Cases, Constraints & Priorities).

**After dig completes, verify Three Principles are covered:**

- [ ] **Principle 1**: Experiential rationale extracted (not just best practices). Ask "when did this fail in the past?" if not covered.
- [ ] **Principle 2**: Success criteria are binary and observable.
- [ ] **Principle 3**: Triggers are intent-based with exclusions.

### At Step 4 (Edit the Skill)

**Concrete actions:**
- Apply Three Principles when writing SKILL.md content:
  - Include thresholds and decision criteria (not "write clean code")
  - Include rationale ("because...") so AI can handle edge cases
  - Include binary/observable success checklist
  - Include "Should NOT trigger" in description

**Content checklist:**
- [ ] Every rule has specific threshold or decision logic
- [ ] Every rule includes rationale for edge case handling
- [ ] Success criteria are binary and observable
- [ ] Description includes intent AND exclusions

### At Step 5 (Validate and Test)

**Concrete actions:**
- Check against `references/anti-patterns.md`
- Validate with the `skill-authoring-quality-review` skill for comprehensive review. Under Claude Code you can dispatch the `skill-authoring-quality-reviewer` subagent (a thin wrapper around that skill) to run the review in an isolated context; on agents without subagents, apply the `skill-authoring-quality-review` skill inline.
- Verify all Three Principles are satisfied

**Validation checklist:**
- [ ] No vague guidance (adjectives without measurable rules)
- [ ] No unmeasurable success criteria
- [ ] No keyword-only triggers
- [ ] No rules without rationale

## Additional Steps (skill-authoring specific)

### Between Step 5 and Step 6: User Approval

**Purpose**: Pre-usage final confirmation (distinct from Step 6's "usage-based improvement")

After AI determines the skill is ready (validation passed), seek user approval:

1. Present the created skill to user with summary:
   ```markdown
   ## Skill Summary: [name]

   ### Purpose
   [2-3 sentences: WHY this skill exists, what problem it solves]

   ### Core Decision Rules
   - [Rule 1]: [Criterion with rationale]
   - [Rule 2]: [Criterion with rationale]

   ### Success Criteria
   - [ ] [Criterion 1]: [Verification method]
   - [ ] [Criterion 2]: [Verification method]

   ### Trigger Conditions
   **Should trigger when**: [Intent-based conditions]
   **Should NOT trigger when**: [Exclusions]
   ```

2. **If user approves**: Skill is ready for use (may later enter Step 6 based on actual usage)
3. **If user denies**: Return to relevant phase (interview or editing) - this is pre-usage iteration, not Step 6

**Distinction from Step 6:**
- User Approval: Post-creation, pre-usage confirmation (AI's judgment verified by user)
- Step 6 (Iterate): Post-usage improvement (based on actual usage experience)

### Improvement Loop (during Step 5)

After `skill-authoring-quality-review` validation:
1. Review findings
2. Fix identified issues
3. Re-validate
4. Repeat until all principles pass
5. Then seek User Approval

## Quality Indicators

A well-authored skill enables AI to:

1. **Make decisions without clarification**: Given a novel situation, AI can determine the correct action using provided rules and rationale
2. **Self-evaluate output**: AI can verify each success criterion and identify what needs fixing
3. **Know exactly when to activate**: AI can distinguish intended triggers from false positives
4. **Explain reasoning**: AI can articulate WHY a particular approach is correct, citing the skill's rationale

**Warning Signs of Poor Quality**:
- AI frequently asks for clarification when using the skill
- Output "seems fine" but doesn't match user expectations
- Skill triggers in unintended contexts
- AI cannot explain why it chose a particular approach

## Success Criteria for This Skill

- [ ] Three Principles explained: SKILL.md body explicitly states and explains all three principles with concrete examples
- [ ] Concrete criteria: Every rule in created skill has specific threshold or decision logic
- [ ] Self-complete: Created skill contains binary success checklist
- [ ] Clear triggers: Description includes intent AND exclusions
- [ ] No generic advice: No adjectives (clean, good, proper, appropriate, reasonable) appear without accompanying measurable criteria

## References

- `references/anti-patterns.md` - Common mistakes with before/after fixes
