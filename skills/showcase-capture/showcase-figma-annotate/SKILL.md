---
name: showcase-figma-annotate
description: Create or continue an editable Figma annotation composition around a clean showcase screenshot, hand it to a person for visual adjustment, then re-inspect and return the verified result. Use when a planned still needs reusable annotation layers, comparison layouts, shared review, or repeated AI-human editing in a Figma Design file rather than a one-off local CleanShot edit.
user-invocable: false
metadata:
  description-role: documentation
---

# Annotate a showcase still in Figma

Use a Figma Design file as the shared editable artifact. Preserve the screenshot as a locked base layer; express arrows, labels, highlights, comparison panels, backgrounds, and framing as separate native layers.

Before every Figma write or programmatic inspection, load and follow `figma-use`. If no target Figma Design file exists, use `figma-create-new-file` rather than inventing a file key.

## Establish the artifact contract

Require:

- a clean PNG or JPEG and the proof point that must remain visible;
- a Figma Design file and target page, or authorization to create one;
- an explicit edit brief;
- the final frame name, dimensions or aspect ratio, and output format.

If the source is only a local file and the connected Figma tool cannot import it directly, ask the user to drag it into the target file and select it. Continue after verifying the selected image, file, and page. Do not upload a local screenshot to a public URL merely to make it importable.

Reject a source with preventable secrets, personal data, notifications, or a wrong product state. Return it for re-capture instead of using a Figma layer to conceal the defect.

## Build an editable composition

Inspect the file before writing and match its page, typography, color, and naming conventions. Create or reuse one frame at the planned output dimensions. Use this stable structure:

- `showcase/final/<shot-name>` for the exported frame;
- `showcase/source/<shot-name>` for the locked screenshot base;
- `showcase/annotation/<number-or-purpose>` for each editable overlay.

Keep the source image unmodified and aspect-correct. Place visual annotations above it as separate nodes. Use absolute positioning for overlays that point to source coordinates; use auto layout for label contents, comparison panels, and other structurally related groups.

Build incrementally, return all created or mutated node IDs, and capture a screenshot after each meaningful pass. Never use image generation, reconstructed UI, object removal, or generative fill for product evidence.

## Hand off to the human editor

Give the user the Figma file, page, final frame name, and numbered edit brief. State which base layer must remain locked and which annotation layers are safe to adjust. Ask the user to reply when the edit is complete, then pause.

Keep the file key and final frame node ID as the resume handle. Do not treat a disconnected session, another selected frame, or an unverified node with the same display text as the completed artifact.

## Recover, verify, and return

After the user reports completion, reconnect to the same file and resolve the final frame by its stored node ID. Re-inspect its layer structure and capture the frame image for visual review. Confirm:

- the source base remains unchanged and aspect-correct;
- every planned edit is present as an editable layer;
- callouts remain legible and do not obscure the proof point;
- comparison panels preserve scale and alignment unless the brief says otherwise;
- the final frame dimensions and visual result match the plan;
- no unrequested, private, synthetic, or misleading content appears.

Return the frame screenshot to the session. When the deliverable also requires a persistent local file, export the exact final frame as PNG through an available supported Figma export path, or ask the user to export it to the agreed path. Do not claim that an inline screenshot was saved locally.

If verification fails, make only the requested structured correction or give the user a concise follow-up brief, then repeat the handoff.
