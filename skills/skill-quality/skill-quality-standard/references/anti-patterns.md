# Content Anti-Patterns

Common failure modes in skill content, grouped by the content-quality topic they violate (see SKILL.md, Layer B). Use this to detect problems when reviewing a skill.

## Context economy (B1)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Explaining what the agent knows | "A PDF is a file format that contains text..." | Wastes context; agent already knows it |
| Scope creep | One skill covering review + security + perf + docs | Tries to do too much, activates imprecisely, does nothing well |
| Exhaustive detail | Documenting every edge case in `SKILL.md` | Agent struggles to extract what's relevant; pursues inapplicable paths |
| All branches inline | Full AWS, GCP, and Azure procedures in `SKILL.md` | Every run loads two irrelevant workflows; keep shared routing in the body and branch detail in references |
| All step details inline | A five-step workflow includes each step's full procedure in `SKILL.md` | Work on one step carries instructions for completed and future steps; keep orchestration in the body and load one step reference when that step begins |
| Eager step loading | "Read all files in `references/` before starting" | Defeats progressive disclosure by loading mutually irrelevant step details together |
| Background in the execution spine | Research history or design provenance between procedural steps | Always spends context despite not changing execution; retain it as a supporting reference only when future audit or revision needs it |
| Reference without a load trigger | "see references/ for details" | Agent doesn't know *when* or *why* to load it, so it either ignores it or loads it needlessly |
| Orphaned reference | A useful research or procedure file never named by `SKILL.md` | The agent cannot discover it from the loaded skill |
| Duplicated layers | The same rules summarized in `SKILL.md` and repeated in a reference | Wastes context and creates two copies that can drift |

**Detection**: definitions of common concepts; long feature lists in one skill;
`SKILL.md` over ~500 lines; multiple branch- or step-specific procedures loaded
together; instructions to read every reference before starting; step references
loaded before their step begins; background that does not affect an action or
decision; reference files without a specific "read this when…" or "read this
only to audit/revise…" condition; useful files not discoverable from `SKILL.md`;
material duplicated across layers.

## Why & concrete criteria (B2)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Generic advice | "Write clean code" | Agent already knows this; adds no experiential insight |
| Missing rationale | "Always use interfaces" | Agent can't judge exceptions without knowing why |
| Ungrounded threshold | "Functions ≤ 20 lines" with no basis | Agent can't judge the 21-line edge case |
| Assumed context | "Follow team standards" | Agent doesn't know your standards |
| Gotcha buried in a reference file | soft-delete rule in `references/db.md` | Agent hits the bug before loading the file |

**Detection**: adjectives without measurable rules; rules without "because [specific problem]"; references to unspecified conventions; gotchas outside `SKILL.md`.

## Judgeable outcome (B3)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Ungrounded success | "Output should be high quality" | Agent and reviewer have no evidence or rationale on which to judge it |
| Process-focused criteria | "✓ Read code ✓ Find issues ✓ Write review" | All steps done, but the deliverable may still be wrong |
| Generic example | "AI: Provides helpful guidance" | No concrete input/output to match against |
| Artificial binary proxy | "Pass if the prose contains all five headings" | Replaces qualitative usefulness with an easy-to-count structure |

**Detection**: "high quality" / "useful" / "correct" without evidence or rationale;
checklists that verify steps instead of the deliverable; abstract examples;
binary or numeric proxies that omit the qualitative property they claim to measure.

## Triggering description (B4)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Keyword-based trigger | "Triggers on 'code review'" | "Review this code *tutorial*" triggers incorrectly |
| Negative boundary catalogue | "Should NOT trigger for tutorials, plans, or prose reviews" | Makes adjacent work salient while leaving the intended situation underspecified |

**Detection**: keyword lists without intent; `not for` / `should not trigger`
catalogues; redirects to sibling skills. For observed false positives, require a
more precise positive intent rather than another exclusion.

## Calibration (B5)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Menu of options | "Use pypdf, pdfplumber, PyMuPDF, or pdf2image…" | No default; agent wastes time choosing |
| Rigid steps for a flexible task | scripted exact steps for code review | Prevents context-dependent judgment |
| One-off answer instead of a method | "Join orders to customers on customer_id where region='EMEA'" | Useful only for this exact task; doesn't generalize |

**Detection**: equal-weight option lists; prescriptive sequences where variation is fine; instructions that solve one instance rather than teaching the approach.

## Current contract (B6)

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Compatibility by default | "Keep the legacy output for backward compatibility" with no identified consumer or contract | Makes an unevidenced former state constrain current behavior |
| Historical narration | "This used to call the v1 tool; it now calls v2" | Loads an irrelevant execution path alongside the active one |
| Behavior defined by rejection | "Do not produce the old JSON response" | Activates the rejected format without specifying the desired deliverable |
| Implicit contrast | "Use the report workflow instead of the previous export flow" | Forces the agent to distinguish two models when only one should be in context |

**Detection**: flag history markers (`legacy`, `formerly`, `previously`,
`backward-compatible`, `no longer`, `replaced`, `deprecated`) and contrast forms
(`not X`, `instead of X`, `rather than X`, negative imperatives). Classify each
match by meaning, not syntax. It is a defect when the sentence imports a former or
rejected design into the current instructions. It is valid when it directly
expresses a present invariant or safety boundary. Compatibility content is valid
only when it names the current interoperability, migration, deprecation, or
versioned schema/protocol requirement that makes it executable.
