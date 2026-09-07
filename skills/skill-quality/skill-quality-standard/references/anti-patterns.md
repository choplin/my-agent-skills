# Content anti-patterns

Use these as examples of misplaced control, not as an exhaustive defect list.
Classify the skill and the affected passage before applying them.

## Classification failures

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| One shape for every skill | Requiring every normative skill to have steps, a deliverable template, and a validator | Confuses guidance with workflow and machinery |
| Whole-skill labeling | Calling a mixed task skill "deterministic" because one file transform is scriptable | Pushes exact control into planning and judgment that should remain flexible |
| Mechanical-looking taxonomy | Required metadata or a scoring tree for deciding how much freedom the model gets | Pretends contextual classification is deterministic and creates another contract to maintain |

## Common failures

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Explaining what the model knows | "A PDF is a file format that contains text..." | Spends context without changing action or judgment |
| Scope creep | One skill covering review, security, performance, and documentation without a common task | Activates imprecisely and mixes unrelated guidance |
| Exhaustive detail | Documenting every imagined edge case | Makes irrelevant paths salient and suppresses useful judgment |
| Historical residue | "This used to call v1; it now calls v2" | Loads a discarded execution model alongside the current one |
| Duplicated layers | The same rules in `SKILL.md` and a reference | Wastes context and creates competing copies |
| Unused contract data | A field or artifact is produced but no consumer reads it | Adds coordination cost without affecting behavior |

## Guidance failures

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Empty adjective | "Use good judgment" | Gives the model no direction it did not already have |
| Rule catalog | A principle expanded into dozens of narrow cases | Replaces transferable reasoning with one author's enumerated interpretation |
| False objectivity | "Pass if the review contains all five headings" | Substitutes a countable proxy for qualitative usefulness |
| Specification theater | Qualitative guidance expanded into YAML/JSON, a checklist, and a validator | Adds context and maintenance while still not guaranteeing behavior |
| Unexplained hard boundary | "Always use interfaces" | Prevents the model from judging exceptions because the reason is missing |

Good guidance may remain qualitative. Ask whether it supplies a useful direction,
consideration, trade-off, or boundary—not whether it can be converted into a
binary test.

## Workflow failures

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Decorative sequence | Numbered steps whose order has no dependency | Turns a flexible task into ceremony |
| All stage detail inline | A long orchestration skill includes every stage's full procedure | Loads completed and future work into the current stage |
| Eager reference loading | "Read every file in `references/` before starting" | Defeats progressive disclosure |
| Missing handoff | A stage produces an artifact whose next consumer and required properties are unclear | Leaves the actual coordination contract implicit |
| Checklist by default | A short, obvious procedure duplicated as progress boxes | Adds tracking state without preventing a meaningful omission |

## Deterministic-operation failures

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Prose reimplementation | Repeatedly asking the model to hand-write the same stable file transform | Recreates avoidable variance and cost |
| Scripted judgment | A script assigns a quality verdict to prose from keyword presence | Encodes a weak proxy as authority |
| Invented intermediate schema | Requiring planning thoughts in JSON although no tool or consumer needs JSON | Constrains reasoning without establishing a real boundary |
| Validator without ground truth | A shell script checks formatting and claims the result is useful | Validates what is easy to count rather than what matters |

Use scripts and schemas when they implement stable operations or real interfaces.
Their presence is not evidence that the surrounding task is deterministic.

## Description and placement failures

| Anti-pattern | Example | Problem |
|--------------|---------|---------|
| Keyword trigger | "Triggers on `code review`" | Matches words rather than user intent |
| Negative catalog | "Not for tutorials, plans, or prose" | Makes adjacent work salient without defining the positive scope |
| Reference without a load condition | "See references for details" | The model cannot decide when the context cost is justified |
| Orphaned reference | Useful material never named by `SKILL.md` | The activated skill cannot discover it |

When reviewing, prefer removing, merging, or generalizing misplaced content.
Move detail only when it remains useful and has a clear load condition.
