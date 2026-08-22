---
name: repository-context-readme
description: >-
  Writes or revises the main product README so prospective users understand
  the value of the software and reach a first successful outcome. Applies
  whenever a repository's primary README for an application or developer tool
  is being written or audited — the value proposition, the first run, and what
  the software is for.
metadata:
  description-role: trigger
---

# Create a product README

Treat the README as the product's front door, not as an exhaustive manual. Its default job is to help readers understand the product, decide to try it, and reach a first successful outcome. Include deeper guidance only when the repository needs the README to serve that role.

Design the document so a front-to-back reading naturally moves through `Orient → Motivate → Activate → Deepen`, stopping at the agreed scope. Readers may also enter midway, so make each section locally understandable.

Apply `repository-context-base` before deciding what belongs in the README or
another repository document. The README is current, shared user documentation;
tentative reasoning and active work state do not become part of it merely
because they informed the draft. If the base skill is unavailable, stop before
changing the canonical README rather than reconstructing its placement model.

## Inspect before writing

Read the repository-local instructions and the current README, if present. Inspect enough of the implementation, configuration, examples, tests, package metadata, and documentation to verify:

- the product's actual purpose and current capabilities;
- the primary user and the problem they arrive with;
- supported installation and usage paths;
- prerequisites, compatibility constraints, maturity, and important limitations;
- existing screenshots, demos, examples, license information, and deeper documentation.

Prefer repository evidence over aspirational language. Do not invent features, commands, performance claims, compatibility, testimonials, or roadmap commitments. Mark material uncertainty as an assumption or ask the user when it would change the README substantially.

Preserve repository-specific conventions and unrelated user edits. For a revision, diagnose the existing README before restructuring it; retain useful content even when moving it.

## Load the companion writing skills

Before setting the reading contract or drafting, load and apply the installed `documentation-writer` and `document-writing-standards` skills. They are required companions to this skill, not optional references.

- Use `documentation-writer` while setting the reading contract and information architecture. Apply it to define the audience, reader goal, coverage boundary, and exclusions; separate tutorial-like activation from how-to, reference, and explanation material; and decide which deeper material belongs in the README or in dedicated documentation. Adapt its workflow to the agreed README funnel rather than treating the whole README as one Diátaxis document type.
- Use `document-writing-standards` while drafting and again as a final copyedit. In `Orient` and `Motivate`, apply it to make the prose simple, direct, and engaging without becoming rhetorical or promotional. In `Activate` and `Deepen`, apply it to preserve accuracy, logical connections, and sufficient explanation without excess. Keep the README technical in tone throughout.

## Set the reading contract

Identify:

1. **Primary reader** — the person deciding whether to adopt or try the product.
2. **Primary outcome** — the smallest meaningful result that proves the product's value.
3. **Next destination** — where readers should go for exhaustive reference, operations, contribution, or support.
4. **Meaningful alternatives** — competing products, manual work, in-house solutions, or an existing workflow that readers are likely to compare.
5. **Coverage boundary** — whether this README stops after `Activate` or also covers part or all of `Deepen`.

Write for the primary reader first. Add secondary paths only after the main path is clear. If the README serves distinct audiences, label their routes instead of interleaving their instructions.

Default to covering `Orient`, `Motivate`, and `Activate`. Include `Deepen` when the README is the repository's canonical user documentation, the product is small enough to explain without obscuring first success, or readers need selected concepts, configuration, limitations, or trust information to continue safely. Otherwise, link to dedicated tutorials, how-to guides, reference, and explanation.

Agree on the coverage boundary before drafting when it would materially change the README's length or structure. Treat an explicit user request or an established repository convention as agreement. Otherwise, propose the boundary and its rationale; if work can proceed safely without an answer, state the assumption.

## Agree on the tagline

Before drafting the README, determine whether the product tagline is already settled. Treat it as settled only when the user has supplied or approved it, or the repository identifies it as canonical product language. Do not silently invent, select, or preserve a tagline merely because one appears in the current README.

When the tagline is unsettled, finish enough repository inspection to ground the wording, then propose a small set of short, literal candidates. Explain the meaningful distinction between them, such as which audience, category, or outcome each emphasizes. Discuss the wording with the user and pause before drafting until they explicitly choose or revise a candidate. Record the agreed tagline as part of the reading contract.

## Design the information architecture

Read `references/readme-patterns.md` and select only the sections justified by the product. Adapt the order to the reader's decision journey; do not copy a maximal template.

Assign every user-facing section one primary stage and order sections by stage:

1. **Orient:** identify the product, intended reader, problem, and outcome.
2. **Motivate:** show concrete value and enough proof to justify trying it.
3. **Activate:** provide the shortest verified path to first success and its expected result.
4. **Deepen, when in scope:** help successful users continue, adapt, and trust the product without turning the README into exhaustive documentation.

Do not place optional concepts, configuration, alternatives, or contributor material where they interrupt the path to first success. Put repository utility sections such as contributing and license information after the user journey unless a convention requires another location.

Lead with:

- a precise product name;
- the agreed short, literal tagline;
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

Treat screenshots and short videos as strong options for `Orient` and `Motivate`: they can help readers recognize the product, understand its workflow, and judge its value before investing in setup. Decide whether to use them, which medium fits, and how many are justified by the claims the README must prove. Do not add media to satisfy a quota.

Inspect existing media first. Reuse it only when it proves the intended claim, represents the current product, and fits the planned reader journey. When suitable media is missing, use the `showcase-capture` skill family in this order:

1. Load `showcase-capture-plan` and define the claim, medium, visible evidence, scene or sequence, framing or duration, README placement, privacy constraints, draft alt text, and capture surface.
2. Put a clearly labeled review stub at the intended location in the README. Use the stub format in `references/readme-patterns.md`; do not create a broken image link or imply that the asset already exists.
3. Ask the user to approve or revise the stubs. Stop before capture; approval of the README request alone does not authorize producing the planned media.
4. After approval, follow the capture plan and load the routed surface skill: `showcase-capture-terminal`, `showcase-capture-browser`, or `showcase-capture-screen`. Use an annotation skill only when the approved plan requires annotation or composition.
5. Replace each approved stub with the captured asset and meaningful alt text. Verify the rendered placement, asset path, represented product state, and absence of sensitive information.

If the task is draft-only, include the review stubs in the draft and request approval without modifying the repository or starting capture.

### Optionally design a README visual

Separately decide whether a composed visual would materially improve the README. This may be a hero image, workflow illustration, architecture or relationship diagram, comparison panel, conceptual overview, or another graphic that communicates faster than prose. Do not add one as decoration or use it to imply behavior that has not been verified.

When a new visual is justified:

1. Define the communication brief: audience, purpose, core message, README placement, visual type, dimensions or aspect ratio, approved source assets, accessibility requirements, and any claim or evidence that must remain visible. Prefer real product output or screenshots when the visual represents behavior.
2. Put a clearly labeled visual-design review stub at the intended README location using `references/readme-patterns.md`. Ask the user to approve or revise what the visual must communicate. Stop while those communication choices remain open.
3. After approval, load `repository-context-pen-design` and pass it the complete brief, source paths, repository identity or visual constraints, draft alt text, and intended export path. Follow its visual-concept agreement, multiple-direction comparison, selection, refinement, and verified-export workflow.
4. Replace the stub with the approved export and meaningful alt text. Verify the rendered README placement, image path, dimensions, represented product state, and absence of private, synthetic, or misleading content. Preserve and report the `.pen` source path, candidate frame names, and selected final frame.

If the visual requires a captured product still, complete the approved capture workflow first and pass the clean capture as source evidence. If the task only annotates or frames that still, route it to `showcase-pen-annotate` instead. If the task is draft-only, leave the review stub in place and do not start Pen/Pencil MCP work.

## Write and edit

Name the user, action, and outcome. Prefer copy-pasteable commands and realistic examples over abstract claims.

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

Read the finished README from the top once as a continuous journey. Confirm that each section advances the reader to the next agreed stage, no later-stage detail interrupts activation, and the ending routes readers to material outside the README's coverage.

## Deliver

When file changes are requested, update the repository's canonical README unless the user names another target. Summarize:

- the reader journey the README now supports;
- the most important structural or content decisions;
- requested or newly planned media;
- the approval or capture status of every visual stub;
- verification performed and any remaining gaps.

When only a draft or review is requested, do not modify files. Return the proposed README or prioritized findings in the requested format.
