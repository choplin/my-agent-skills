---
name: product-showcase-readme
description: Create or revise the main product README so prospective users can understand its value and reach a first successful outcome. Use when asked to write or audit the primary repository README for software such as an application or developer tool. Exclude contributor-only documentation and detailed references. Also exclude release notes and landing pages unless the README is explicitly in scope.
metadata:
  description-role: trigger
---

# Create a product README

Treat the README as the product's front door, not as an exhaustive manual. Design a scannable path that helps readers orient, become motivated, activate the product, and deepen their use. Readers may enter at any section, so make each section locally understandable as well as part of the overall journey.

## Inspect before writing

Read the repository-local instructions and the current README, if present. Inspect enough of the implementation, configuration, examples, tests, package metadata, and documentation to verify:

- the product's actual purpose and current capabilities;
- the primary user and the problem they arrive with;
- supported installation and usage paths;
- prerequisites, compatibility constraints, maturity, and important limitations;
- existing screenshots, demos, examples, license information, and deeper documentation.

Prefer repository evidence over aspirational language. Do not invent features, commands, performance claims, compatibility, testimonials, or roadmap commitments. Mark material uncertainty as an assumption or ask the user when it would change the README substantially.

Preserve repository-specific conventions and unrelated user edits. For a revision, diagnose the existing README before restructuring it; retain useful content even when moving it.

## Set the reading contract

Identify:

1. **Primary reader** — the person deciding whether to adopt or try the product.
2. **Primary outcome** — the smallest meaningful result that proves the product's value.
3. **Next destination** — where readers should go for exhaustive reference, operations, contribution, or support.
4. **Meaningful alternatives** — competing products, manual work, in-house solutions, or an existing workflow that readers are likely to compare.

Write for the primary reader first. Add secondary paths only after the main path is clear. If the README serves distinct audiences, label their routes instead of interleaving their instructions.

## Design the information architecture

Read `references/readme-patterns.md` and select only the sections justified by the product. Adapt the order to the reader's decision journey; do not copy a maximal template.

Lead with:

- a precise product name;
- a short, literal tagline;
- a one-sentence description when the tagline alone does not identify the product, audience, and outcome;
- a concrete proof point, such as a representative example, screenshot, output, or short workflow;
- concise positioning near the top;
- the shortest verified path to the primary outcome.

Treat positioning and explicit differentiation as separate devices:

- **Positioning — nearly always include.** State three to five outcomes readers get from the product. Lead each item with a short, memorable message; use the rest of the item for the longer explanation, mechanism, or evidence. Group the items under `Why <product>?` when a section improves scanning, but do not require a dedicated heading when the opening already carries them clearly. Do not compare with alternatives here.
- **Differentiation section — include conditionally.** Add it only when readers face a meaningful alternative, the product has material and verifiable differences, and explaining them improves the adoption decision. Describe target users, design priorities, workflows, or trade-offs positively. Do not criticize alternatives or invent comparative claims.

Place prerequisites before commands that depend on them. Keep conceptual explanation close to the example it clarifies. Move exhaustive reference content to dedicated documentation and link it at the point of need.

Badges are metadata, not a value proposition. Include only current, maintained badges that help an adoption decision.

## Plan visual proof

Use screenshots, representative output, diagrams, or short video only when they prove a meaningful claim faster than text. Inspect existing media before requesting new assets.

When useful media is missing, give the user a concrete media brief: the claim to prove, required scene and state, recommended framing or duration, README placement, privacy constraints, and draft alt text. Do not insert fabricated media or broken placeholders. Delegate capture planning to `showcase-capture-plan` when the user wants the assets produced.

## Write and edit

Use plain, specific language. Name the user, action, and outcome. Prefer copy-pasteable commands and realistic examples over abstract claims.

Structure at both levels:

- make each top-level section answer one reader question;
- open each section with its conclusion or purpose;
- use numbered lists for procedures, bullets for benefits, and tables for genuine comparisons;
- keep rationale in short paragraphs rather than removing prose entirely;
- use H2 for the main journey and H3 for its subdivisions; avoid unnecessary deeper nesting.

Use icons or emoji moderately only when they match the repository and product tone. Keep their use consistent, never make them the sole carrier of meaning, and prefer hierarchy and whitespace over decoration. Use bold text for scannable labels and key phrases, not entire paragraphs.

For every command or code example:

- use the repository's supported interface and current names;
- include required setup and the expected result;
- keep secrets, personal data, and machine-specific paths out;
- distinguish required steps from alternatives;
- specify the working directory when it is not obvious.

Use links with descriptive labels. Keep the top of the README useful without requiring readers to follow a link. Avoid duplicate sources of truth: summarize stable concepts in the README and link to details that change independently.

When revising an existing README, make the smallest coherent edit that fixes the reader journey. Do not rewrite solely for tone.

## Verify

Validate factual claims against the repository. Run the documented happy path when safe and practical. At minimum, verify referenced files, anchors, commands, package names, environment variables, and version requirements.

Review the positioning claims, differentiation claims, structure, visual proof, and first-success path using the checklist in `references/readme-patterns.md`. Report any command or claim that could not be verified.

## Deliver

When file changes are requested, update the repository's canonical README unless the user names another target. Summarize:

- the reader journey the README now supports;
- the most important structural or content decisions;
- requested or newly planned media;
- verification performed and any remaining gaps.

When only a draft or review is requested, do not modify files. Return the proposed README or prioritized findings in the requested format.
