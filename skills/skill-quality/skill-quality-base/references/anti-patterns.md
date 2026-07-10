# Content Anti-Patterns

Common failure modes in skill content, grouped by the content-quality topic they violate (see SKILL.md, Layer B). Use this to detect problems when reviewing a skill.

## Context economy (B1)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Explaining what the agent knows | "A PDF is a file format that contains text..." | Wastes context; agent already knows it |
| Scope creep | One skill covering review + security + perf + docs | Tries to do too much, activates imprecisely, does nothing well |
| Exhaustive detail | Documenting every edge case in `SKILL.md` | Agent struggles to extract what's relevant; pursues inapplicable paths |
| Reference without a load trigger | "see references/ for details" | Agent doesn't know *when* to load it, so it doesn't |

**Detection**: definitions of common concepts; long feature lists in one skill; `SKILL.md` over ~500 lines; reference files with no "read this when…" condition.

## Why & concrete criteria (B2)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Generic advice | "Write clean code" | Agent already knows this; adds no experiential insight |
| Missing rationale | "Always use interfaces" | Agent can't judge exceptions without knowing why |
| Ungrounded threshold | "Functions ≤ 20 lines" with no basis | Agent can't judge the 21-line edge case |
| Assumed context | "Follow team standards" | Agent doesn't know your standards |
| Gotcha buried in a reference file | soft-delete rule in `references/db.md` | Agent hits the bug before loading the file |

**Detection**: adjectives without measurable rules; rules without "because [specific problem]"; references to unspecified conventions; gotchas outside `SKILL.md`.

## Self-evaluable output (B3)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Unmeasurable success | "Output should be high quality" | Agent cannot verify; no self-feedback loop |
| Process-focused criteria | "✓ Read code ✓ Find issues ✓ Write review" | All steps done, but the deliverable may still be wrong |
| Generic example | "AI: Provides helpful guidance" | No concrete input/output to match against |

**Detection**: "high quality" / "useful" / "correct" without definition; checklists that verify steps instead of the deliverable; abstract examples.

## Triggering description (B4)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Keyword-based trigger | "Triggers on 'code review'" | "Review this code *tutorial*" triggers incorrectly |
| No exclusions on an ambiguous trigger | broad description, no "Should NOT trigger" | False positives in adjacent contexts |

**Detection**: keyword lists without intent; missing exclusions where the trigger overlaps neighboring skills.

## Calibration (B5)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Menu of options | "Use pypdf, pdfplumber, PyMuPDF, or pdf2image…" | No default; agent wastes time choosing |
| Rigid steps for a flexible task | scripted exact steps for code review | Prevents context-dependent judgment |
| One-off answer instead of a method | "Join orders to customers on customer_id where region='EMEA'" | Useful only for this exact task; doesn't generalize |

**Detection**: equal-weight option lists; prescriptive sequences where variation is fine; instructions that solve one instance rather than teaching the approach.
