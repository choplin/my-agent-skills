# Anti-Patterns by Principle

Each Principle has common failure modes. Use this to detect problems in skill content.

## Principle 1: "Why" and Concrete Criteria

| Anti-pattern | Example | Problem |
|-------------|---------|---------|
| Generic Advice (no experiential basis) | "Write clean code" | AI already knows this; adds no lessons from experience |
| Missing Rationale | "Always use interfaces" | AI can't judge exceptions without knowing WHY |
| Assumed Context | "Follow team standards" | AI doesn't know your standards |

**Detection**: Rules AI already knows; adjectives without experience-based thresholds; rules without "because [specific problem occurred]"; references to unspecified conventions.

## Principle 2: Self-Complete (Success Criteria)

| Anti-pattern | Example | Problem |
|-------------|---------|---------|
| Unmeasurable Success | "Output should be high quality" | AI cannot verify; no self-feedback loop |
| Generic Examples | "AI: Provides helpful guidance" | No concrete input/output to match |
| Process-focused Criteria | "✓ Read code ✓ Find issues ✓ Write review" | All steps done, but deliverable may still be wrong |

**Detection**: "High quality", "useful", "correct" without definition; abstract examples; checklists that verify process steps instead of deliverable quality.

## Principle 3: Clear Trigger Conditions

| Anti-pattern | Example | Problem |
|-------------|---------|---------|
| Keyword-Based Triggers | "Triggers on 'code review'" | "Review this code tutorial" triggers incorrectly |
| Scope Creep | "Handles review, security, performance, docs..." | Tries to do too much, does nothing well |

**Detection**: Keyword lists without intent; long feature lists; missing exclusions.
