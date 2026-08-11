# Product README patterns

Use this reference to choose a small, product-specific structure. A README should help adoption; it should not contain every section listed here.

## Contents

- [Reader journey](#reader-journey)
- [Coverage boundary](#coverage-boundary)
- [Stage order and section responsibilities](#stage-order-and-section-responsibilities)
- [Opening pattern](#opening-pattern)
- [Positioning and differentiation](#positioning-and-differentiation)
- [Section structure](#section-structure)
- [Visual proof](#visual-proof)
- [Decoration](#decoration)
- [Suggested sections by product type](#suggested-sections-by-product-type)
- [Optional sections](#optional-sections)
- [Quality checklist](#quality-checklist)

## Reader journey

Use these stages as the design model, not as fixed section names. A reader who starts at the top should move through them in order.

| Stage | Reader question | Reader state at the end |
| --- | --- | --- |
| Orient | What is this, and is it for me? | Can identify the product, intended user, problem, and outcome. |
| Motivate | Why should I try it? | Has a concrete, credible reason to continue. |
| Activate | How do I reach a first success? | Has completed or can confidently follow the shortest verified path. |
| Deepen | How do I continue, adapt, and trust it? | Knows the next relevant task and where to find its guidance. |

Readers may scan or enter midway. Make headings descriptive and give each section enough context to stand on its own.

## Coverage boundary

A product README normally owns `Orient` through `Activate`. Decide before drafting whether it also owns `Deepen`.

Include deeper material when the README is the canonical user documentation, the repository is small enough to keep the path clear, or readers need the information immediately after first success. Otherwise, keep the README focused and route readers to the appropriate documentation type:

- tutorials for guided learning;
- how-to guides for specific tasks;
- reference for complete technical facts;
- explanation for concepts and design rationale.

Do not split the difference by adding fragments of every documentation type. Include only the deeper sections the agreed scope requires.

## Stage order and section responsibilities

Section names may vary, but each section needs one primary job. Use this mapping to choose and order them:

| Stage | Typical sections or elements | Primary responsibility | Keep out |
| --- | --- | --- | --- |
| Orient | Name, tagline, literal description, audience | Establish identity and relevance immediately. | Setup detail, architecture, feature inventory |
| Motivate | Visual proof, representative output, positioning, use cases, conditional differentiation | Turn relevance into a concrete reason to try the product. | Unsupported claims, exhaustive feature lists, long comparisons |
| Activate | Prerequisites, installation, Quickstart, expected result | Carry the reader through the shortest complete path to first success. | Optional variants, advanced configuration, unrelated concepts |
| Deepen | Core concepts, common recipes, selected configuration, limitations, security, support, documentation links | Help successful users choose and complete their next action. | Exhaustive API or option reference, unrelated operations, duplicated documentation |

Within a stage, order sections by dependency. For example, put prerequisites before installation, installation before Quickstart, and the expected result directly after the action that produces it. Put contributing, development, acknowledgements, and license sections after the product-use journey unless repository convention dictates otherwise.

Before keeping a section, ask: “Does this help the primary reader reach the end state of its assigned stage?” Remove it, move it later, or link to it when the answer is no.

## Opening pattern

Use this shape unless the repository or product calls for a smaller opening:

```markdown
# Product name

> Short, literal tagline.

One sentence identifying the product, primary user, and outcome when the
tagline does not do all three.

<visual proof or approved review stub when selected>

<positioning>
```

Prefer a tagline that identifies the category or outcome over a clever but ambiguous slogan. If the tagline is memorable but not literal, follow it with the explanatory sentence.

Do not draft around an unsettled tagline. When the user has not supplied or approved one and the repository does not designate canonical wording, propose a few evidence-based candidates, explain what each emphasizes, and agree on the wording first.

## Positioning and differentiation

### Positioning

Include concise positioning near the top for nearly every product README. It answers **Why should I care?** without comparing the product with alternatives.

Use three to five items. Make the bold lead a short, self-contained message that carries the benefit at a glance. The explanation after it may be longer when the mechanism, evidence, or implication needs room.

Prefer:

> **Short benefit message.** Explanation, mechanism, or evidence.

Example:

```markdown
## Why ReviewFlow?

- **Align before the diff.** Surface design decisions while they are still cheap to change.
- **Keep decisions traceable.** Connect the rationale to the resulting implementation.
- **Stay in your existing workflow.** Use the repository and review process already in place.
```

Do not let the explanatory clause bury the message, use feature names alone, repeat the tagline, split one benefit into several bullets, or use comparative superlatives without evidence.

A dedicated section is optional. Place the items directly in the opening when they read naturally there. When a heading improves scanning, prefer the product-specific `Why <product>?`; use another descriptive heading when it better fits the product or repository tone. Do not add `What you get` merely to satisfy a template.

### Explicit differentiation

Add a separate differentiation section only when all of these are true:

1. Readers face a meaningful alternative, including another product, manual work, an in-house solution, or an established workflow.
2. The product has a material difference in audience, workflow, operating model, control, integration, or an intentional trade-off.
3. The difference can be verified from the repository, official information, or user-provided facts.
4. Explaining the difference helps readers make an adoption decision.

Omit the section when alternatives are vague, differences are minor, positioning already answers the question, or comparison would require speculation.

Prefer `How it is different`, `When to choose <product>`, or a neutral comparison table. Explain whom the product is designed for and what it prioritizes. Do not criticize another product, construct a weak comparison, or claim to be uniquely best. When useful, state when another approach is a better fit.

Place differentiation before Quickstart when it is essential to the initial adoption decision; otherwise place it after readers have seen the product and first-success path.

## Section structure

- Make each H2 answer one reader question and each H3 break down that answer.
- Open with the conclusion, purpose, or promised outcome.
- Use numbered lists for procedures and bullets for benefits or options.
- Use tables only when readers need to compare repeated fields.
- Keep explanatory prose short but retain it when rationale or context matters.
- Avoid H4 and deeper nesting unless the README is necessarily long.
- Use bold text for scannable labels or key phrases, not full paragraphs.
- Move exhaustive material into task-oriented documentation and link it where needed.

## Visual proof

Consider screenshots and short videos early because they are often effective in `Orient` and `Motivate`. Use them when visible product state, workflow, or output proves an important claim faster or more credibly than prose. Let the claims determine the medium and number of assets; do not treat either as a requirement.

A designed visual is a separate, optional device. Use a hero, workflow illustration, architecture or relationship diagram, comparison panel, conceptual overview, or another composition when it materially improves identity, orientation, or comprehension. Keep its role explicit: an editorial graphic is not evidence of product behavior, while a design that contains real product output must preserve that evidence accurately.

Choose media by the claim it must prove:

| Claim | Useful media |
| --- | --- |
| The product produces a distinctive result | Finished-state or before/after screenshot |
| The workflow is fast or simple | A focused 20–40 second video or GIF |
| CLI behavior is the value | Input plus meaningful terminal output |
| Several components must be understood together | A small architecture or flow diagram |

Do not add media only as decoration. Keep the positioning visible near the opening instead of letting a large image push all useful explanation far below it.

When suitable media is missing, use `showcase-capture-plan` to design the asset before capture. Put a temporary review stub in the exact README position where the asset would appear:

```markdown
> **Planned visual — approval required**
> **Claim:** <reader-facing claim this asset must prove>
> **Asset:** <screenshot or video; proposed dimensions, format, or duration>
> **Scene:** <exact product state or sequence and visible evidence>
> **Capture:** <terminal, browser, or screen surface; framing and privacy constraints>
> **Alt text:** <draft alt text>
```

Keep the stub concise but specific enough to review the claim, medium, content, and placement in context. Use one stub per proposed asset. Do not create broken links or imply that an unprovided asset exists.

For a designed visual, use this variant:

```markdown
> **Planned visual design — approval required**
> **Purpose:** <what this part of the README should communicate>
> **Type:** <hero, workflow, relationship diagram, comparison, or other form>
> **Asset:** <proposed dimensions or aspect ratio and export format>
> **Content:** <real screenshots, output, logo, text, or other source material>
> **Message:** <core reader-facing message and important constraints>
> **Evidence:** <claim preserved by real product material, or "Editorial image; not product evidence">
> **Alt text:** <draft alt text>
```

Agree on what the visual must communicate, then load `repository-context-pen-design`. That skill owns visual-concept agreement, two to four comparable directions in one editable `.pen` file, user selection, refinement, final approval, verification, and export. Keep real screenshots and output unchanged as separate source layers.

Get explicit user approval for the stubs before loading a surface capture skill. After approval, preserve the approved claim and evidence requirements in the capture plan, capture the real product path, and replace the stubs with the final assets. If rehearsal shows that the approved claim cannot be reproduced, stop and return to planning instead of changing the story during capture.

## Decoration

Match the repository's established tone. Icons and emoji are optional.

- Limit them to stable navigation or emphasis, such as at most one consistent icon per H2.
- Do not use them as the only representation of meaning.
- Avoid introducing them into a restrained README without a reason.
- Use fewer in security, infrastructure, enterprise, and other trust-sensitive products.
- Prefer headings, whitespace, and concise writing when those provide enough hierarchy.

## Suggested sections by product type

### Application or hosted service

Value proposition → screenshot or demo → key use cases → getting started or sign-up → common workflow → configuration/integrations → limitations → support.

Do not force local installation instructions onto a hosted product. Make account, pricing, data-handling, or availability constraints visible when they materially affect adoption.

### CLI

Value proposition → representative terminal session → installation → quick start → common commands → configuration → shell/platform support → troubleshooting.

Show both the command and meaningful output. State whether a command changes remote or local state.

### Library or SDK

Value proposition → minimal code example → installation → supported runtimes → core concepts → common recipes → API reference → compatibility and migration.

Use an example that demonstrates the library's distinguishing behavior, not merely an import statement.

### API or service

Value proposition → minimal request and response → authentication/setup → base URL or client setup → common workflow → error behavior → limits/versioning → full reference.

Use placeholders for credentials and explain where credentials come from. Never include live secrets.

### Developer tool or repository template

Value proposition → before/after or generated result → prerequisites → quick start → project structure or mental model → customization → CI/editor integration → limitations.

Separate instructions for users of the tool from instructions for contributors to the tool.

## Optional sections

Include only when they change a user's decision or next action:

- status or maturity;
- feature comparison or explicit non-goals;
- architecture overview;
- security and privacy;
- deployment or self-hosting;
- observability and operations;
- upgrade and migration guidance;
- examples or recipes;
- FAQ and troubleshooting;
- support and community;
- contributing and development;
- license and attribution.

Keep lengthy contribution, operations, API, and troubleshooting material in dedicated documents when the repository already has a documentation structure.

## Quality checklist

### Message

- [ ] The first screen explains the product and intended user.
- [ ] The tagline is user-approved or established as canonical product language.
- [ ] The tagline is concise and literal, or followed by a literal description.
- [ ] The value proposition describes an outcome, not a list of implementation details.
- [ ] Positioning states three to five distinct user outcomes when the product warrants it.
- [ ] Each positioning item leads with a concise message; supporting detail does not bury it.
- [ ] Explicit differentiation appears only when the inclusion criteria are satisfied.
- [ ] Comparative claims are material, positive, and verifiable.
- [ ] Claims are supported by repository evidence or clearly qualified.
- [ ] The README distinguishes current behavior from planned work.

### First success

- [ ] Prerequisites appear before dependent steps.
- [ ] The shortest supported path is easy to identify.
- [ ] Commands and examples are copy-pasteable and use current interfaces.
- [ ] The expected result tells the reader whether the attempt succeeded.
- [ ] Alternatives do not interrupt the main path.

### Navigation

- [ ] The overall order supports orienting, motivating, activating, and deepening.
- [ ] Every user-facing section has one primary stage and contributes to that stage's end state.
- [ ] A front-to-back reading reaches first success without later-stage material interrupting it.
- [ ] The agreed coverage boundary is clear, and out-of-scope material has a useful destination.
- [ ] Each main section answers one clear reader question.
- [ ] Procedures, benefits, comparisons, and rationale use appropriate structures.
- [ ] Section order follows the reader's decisions.
- [ ] Distinct audiences have explicit routes.
- [ ] Detailed reference material has a clear destination.
- [ ] Links, anchors, image paths, and document names resolve.

### Trust

- [ ] Compatibility, maturity, and material limitations are discoverable.
- [ ] Security-sensitive examples use obvious placeholders.
- [ ] Visual media proves a claim and has meaningful alt text.
- [ ] The choice and number of visual assets follow from the `Orient` and `Motivate` claims rather than a quota.
- [ ] Missing media appears as a reviewable stub with a concrete claim and shot specification, not a broken placeholder.
- [ ] Capture started only after the user approved the stubs.
- [ ] Approved stubs were replaced with verified assets rather than left in the final README.
- [ ] A designed visual, when included, starts from an approved communication brief, presents multiple comparable directions before refinement, preserves any real product evidence, and retains an editable `.pen` source.
- [ ] Icons, emoji, and bold text match the product tone and remain accessible.
- [ ] Badges are current and useful.
- [ ] Support, issue reporting, and license information are accurate when included.

### Maintenance

- [ ] The README does not duplicate volatile reference data without a reason.
- [ ] Examples can be checked manually or automatically.
- [ ] Version-specific instructions say which version they apply to.
- [ ] No setup step depends on unexplained local state.
