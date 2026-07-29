---
name: showcase-pen-annotate
description: Create or continue an editable screenshot annotation composition in a local pen.dev .pen file, hand it to a person for visual adjustment, then re-inspect and export the verified result through Pencil MCP tools. Use when a planned showcase still needs agent-writable layers, local ownership, repository-adjacent versioning, or repeated AI-human editing without moving the artifact into Figma or limiting editing to CleanShot X.
user-invocable: false
metadata:
  description-role: documentation
---

# Annotate a showcase still in pen.dev

Use a `.pen` file as the local shared artifact between the agent and human editor. Keep the captured screenshot as an unchanged base node and express arrows, labels, highlights, comparison panels, backgrounds, and framing as separate editable nodes.

Access `.pen` contents only through Pencil MCP tools. The format is encrypted: never parse, inspect, search, or patch a `.pen` file with filesystem text tools. Treat it as an opaque artifact for ordinary file operations such as Git status and commit.

## Establish the artifact contract

Require:

- a clean PNG or JPEG and the proof point that must remain visible;
- an open target `.pen` file and destination frame, or a request for the user to create one;
- an explicit edit brief;
- the final frame name, dimensions or aspect ratio, export format, and output directory.

If the source image is not already on the canvas, ask the user to drag it into pen.dev or paste it from the clipboard, select the imported image, and reply when ready. Do not upload a local screenshot to a public URL or replace it with an AI-generated approximation.

Reject a source with preventable secrets, personal data, notifications, or a wrong product state. Return it for re-capture instead of covering the defect with another node.

## Inspect before editing

Call `get_editor_state` with `include_schema: true` before any other Pencil tool whenever the schema is not already present, including after resuming in a new session. Keep the returned file path and selection as the editing context.

List the available design guidance with `get_guidelines` and load the most relevant compatible guide before using `batch_design`.

Use `batch_get` to identify the imported source and any existing annotation frame. Use `snapshot_layout` with a bounded depth to inspect placement and find safe canvas space. Do not assume node properties or construct `batch_design` operations from memory; follow the schema returned by `get_editor_state`.

## Build editable annotation layers

Create or reuse one frame at the planned output dimensions and use stable names:

- `showcase/final/<shot-name>` for the export frame;
- `showcase/source/<shot-name>` for the screenshot base;
- `showcase/annotation/<number-or-purpose>` for each overlay.

Keep the source node aspect-correct and unchanged. Lock it only when the current schema explicitly supports locking; do not invent a lock property. Otherwise avoid targeting it in later mutations. Place annotations above it as separate nodes. Use layout containers for labels and comparison panels, and explicit coordinates for arrows, highlights, and other overlays tied to source pixels.

When creating a new root frame, use `FindEmptySpace` to place it safely, set `clip: true`, and keep `placeholder: true` while constructing it. Apply small, reviewable `batch_design` operations and preserve the returned node IDs. Remove the placeholder state after the frame is complete. Do not use Pencil image-generation operations, reconstructed UI, object removal, or synthetic content for product evidence.

After a complete annotation pass:

1. run `snapshot_layout` with `problemsOnly: true` on the final frame;
2. fix clipping, overlap, or sizing problems;
3. call `get_screenshot` on the smallest meaningful final frame for visual verification.

## Hand off to the human editor

Give the user the `.pen` path, final frame name, and numbered edit brief. State which source node must remain unchanged and which annotation nodes are safe to adjust. Ask the user to save the `.pen` file and reply when editing is complete, then pause.

Keep the file path and final frame node ID as the resume handle. Do not infer completion from another open file, the current selection alone, or a similarly named node.

## Recover, verify, and export

After the user reports completion, reconnect to the exact `.pen` file. Refresh the editor schema when needed, resolve the final frame by stored node ID, inspect its nodes with `batch_get`, check structural problems with `snapshot_layout`, and render it with `get_screenshot`.

Confirm:

- the source base remains unchanged and aspect-correct;
- every planned edit remains independently editable;
- annotations are readable and do not obscure the proof point;
- comparison panels preserve scale and alignment unless the brief says otherwise;
- dimensions and visual result match the plan;
- no private, synthetic, unrequested, or misleading content appears.

Use `export_nodes` with the exact final frame node ID, requested format, scale, and output directory. Inspect the returned image path outside the `.pen` file, return that image to the session, and report the `.pen` path, frame node ID, export path, dimensions, format, and edits verified.

If verification fails, make only the requested structured correction or give the user a concise follow-up brief, then repeat the handoff.
