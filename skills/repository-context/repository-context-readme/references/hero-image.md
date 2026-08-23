# README hero-image workflow

Use this workflow only when the visual-hero opening pattern is selected. Use
the separate tagline workflow for the hero's wording.

## Contents

- [Choose the hero's job](#choose-the-heros-job)
- [Inspect before creating](#inspect-before-creating)
- [Define the communication brief](#define-the-communication-brief)
- [Put the plan in context](#put-the-plan-in-context)
- [Route production](#route-production)
- [Replace and verify](#replace-and-verify)

## Choose the hero's job

Classify the proposed hero image before designing it:

- **Product evidence:** shows real interface state, output, or workflow and must
  preserve the behavior that supports a claim.
- **Editorial identity:** communicates product identity or a concept without
  claiming to show actual behavior.
- **Hybrid:** composes real product evidence inside an editorial frame; keep the
  evidence unchanged and distinguish the surrounding design from it.

Use a visual hero only when identity, visible product state, representative
output, or a composed message materially improves `Orient` or `Motivate`. Do
not add one merely to make the README look complete.

## Inspect before creating

Inspect existing logos, screenshots, recordings, output samples, diagrams, and
brand constraints. Reuse an asset only when it:

- communicates the intended message or proves the intended claim;
- represents the current product;
- fits the visual-hero opening and reader journey;
- has adequate resolution, crop, contrast, and legibility;
- contains no secrets, private data, misleading state, or obsolete branding.

## Define the communication brief

Before producing a new hero image, define:

1. audience and README placement;
2. purpose, core message, or reader-facing claim;
3. evidence that must remain visible, if any;
4. dimensions or aspect ratio and export format;
5. exact scene, state, or source material;
6. framing, repository identity, and visual constraints;
7. privacy and authenticity constraints;
8. draft alt text and intended export path.

Prefer real product output when the hero represents behavior. Label a purely
editorial hero as such in the brief rather than letting it imply evidence.

## Put the plan in context

Place this review stub at the hero's intended README location:

```markdown
> **Planned visual design — approval required**
> **Purpose:** <what the hero should communicate>
> **Type:** <product-evidence, editorial, or hybrid hero>
> **Asset:** <proposed dimensions or aspect ratio and export format>
> **Content:** <real screenshots, output, logo, text, or other source material>
> **Message:** <core reader-facing message and important constraints>
> **Evidence:** <claim preserved by real product material, or "Editorial image; not product evidence">
> **Alt text:** <draft alt text>
```

Only when the brief establishes that an uncomposed real screenshot is itself
the finished hero, use this capture-specific variant instead:

```markdown
> **Planned visual — approval required**
> **Claim:** <reader-facing claim this screenshot must prove>
> **Asset:** <screenshot; proposed dimensions and format>
> **Scene:** <exact product state and visible evidence>
> **Capture:** <terminal, browser, or screen surface; framing and privacy constraints>
> **Alt text:** <draft alt text>
```

Keep the stub concise but specific enough to review the message, evidence,
content, and placement. Do not create a broken image link or imply that the
asset exists. Ask the user to approve or revise the stub and stop before
production; approval of the README request alone does not authorize a new hero
image.

## Route production

After approval, use `repository-context-pen-design` as the default production
path for a new hero image. Pass it the approved brief, source paths, draft alt
text, and intended export path.

Route source acquisition and exceptional cases as follows:

- When the approved hero needs real interface state, terminal output, or another
  product still, load `showcase-capture-plan` and its routed capture skill first.
  Pass the unchanged clean capture to `repository-context-pen-design` as source
  evidence.
- When the approved work only annotates or frames an existing clean capture,
  use the appropriate showcase annotation skill; use `showcase-pen-annotate`
  when the composition must remain editable in Pen.
- Only when the approved brief says that the real screenshot itself is the
  finished hero, use `showcase-capture-plan` and the routed
  `showcase-capture-terminal`, `showcase-capture-browser`, or
  `showcase-capture-screen` skill as the complete production path.

If rehearsal cannot reproduce an approved claim, return to planning instead of
changing the story during production. For a draft-only task, leave the approved
or pending stub in place and do not start capture or design.

## Replace and verify

Replace the approved stub with the finished hero image and meaningful alt text.
Verify:

- rendered placement, dimensions, crop, contrast, and legibility;
- repository-relative asset paths and links;
- represented product version and state;
- preservation of any approved real evidence;
- absence of secrets, private data, synthetic product state, or misleading
  implications.

For Pen-produced work, preserve and report the editable `.pen` source, candidate
frame names, selected final frame, and export path.
