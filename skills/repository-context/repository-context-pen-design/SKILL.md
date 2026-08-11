---
name: repository-context-pen-design
description: >-
  Designs editable visuals for repository-owned product and developer
  documentation in a local pen.dev `.pen` file through Pencil MCP tools, from
  visual-concept agreement through multiple comparable directions, selection,
  refinement, and verified export. Use for hero images, workflow illustrations,
  architecture or relationship diagrams, comparison panels, and conceptual
  overviews in READMEs, documentation sites, Architecture Guides, and related
  explanatory material.
---

# Design repository documentation visuals in pen.dev

Translate an approved communication brief into an editable visual. The calling
documentation workflow owns the audience, message, claim, document placement,
and integration into the final document. This skill owns how to express that
message visually and how to explore, select, refine, and export the design.

Apply `repository-context-base` to keep the visual tied to current, shared
repository documentation. If the base skill is unavailable, stop before
creating or changing the canonical `.pen` source. Do not use this skill to
discover a document's audience, message, claim, or placement. Return to the
calling workflow when those decisions are unresolved. Use
`showcase-capture-plan` and its routed capture skill when a visual needs real
product evidence from visible output.
Use `showcase-pen-annotate`
instead when the job is only to annotate or frame one captured still.

## Establish the design contract

Require a communication brief containing:

- the target document, audience, purpose, core message, and placement within
  that document;
- the visual type, such as hero, workflow, relationship diagram, comparison, or conceptual overview;
- any factual claim and the real evidence that must remain visible;
- approved source assets and their repository paths;
- the target `.pen` path;
- target dimensions or aspect ratio, export format, and output directory;
- visual constraints, repository or product identity, privacy constraints, and draft alt text.

Distinguish editorial illustration from product or implementation evidence. Do
not invent product behavior, reconstruct an interface, alter real output, or
use decorative treatment to imply an unsupported capability. If required
evidence is missing or unsuitable, return to capture or to the calling
documentation workflow instead of designing around the gap.

## Agree on the visual concept

Inspect the approved assets and translate the communication brief into a concise visual concept. Define:

- the focal point and reading order;
- the proposed composition or visual metaphor;
- how real evidence and editorial elements remain distinguishable;
- the intended tone, hierarchy, and accessibility approach;
- which design dimensions should vary across candidate directions.

Present the concept in words and ask the user to approve or revise it. Stop
before drawing. Approval of the document, communication brief, or request to
create a visual does not by itself approve the visual concept.

## Prepare the Pen workspace

Pencil MCP can operate only the document currently open in the pen.dev desktop app. Require the app to be running with the exact target `.pen` file open as the active document. If that state has not already been established, ask the user to open or create the target file in the desktop app, make it active, and reply when ready; then pause.

After concept approval and the user's readiness confirmation, call `get_editor_state` with `include_schema: true` before any other Pencil tool. Verify that its returned file path identifies the expected target `.pen` file. If no editor is available or another file is active, do not issue any further Pencil read or mutation; ask the user to open and activate the expected file, then retry `get_editor_state`. Preserve the verified file path and selection as the editing context.

Repeat the desktop-app, active-document, and returned-path checks after resuming in a new session and after every pause in which the user may have switched documents. Never infer the target from the current selection, a similar filename, or the previously stored path alone.

Access `.pen` contents only through Pencil MCP tools. The format is encrypted: never parse, inspect, search, or patch it with filesystem text tools. Treat it as opaque for ordinary file operations such as Git status and commit.

List available guidance with `get_guidelines` and load the most relevant compatible guide before using `batch_design`. Use `batch_get` to inspect reusable nodes or imported sources and `snapshot_layout` with bounded depth to find safe canvas space. Follow the returned schema; do not construct operations or node properties from memory.

When a required local image is not already on the canvas, ask the user to drag or paste it into pen.dev, select the imported node, and reply when ready. Do not upload a private asset to a public URL or replace it with an approximation.

## Build comparable directions

Build two to four materially distinct directions from the same approved concept. Keep the message, evidence, source content, dimensions, and constraints stable enough for comparison. Vary only meaningful design choices such as composition, hierarchy, framing, typography, color treatment, density, or visual metaphor. Establish the full comparison set before polishing one candidate.

Keep the directions in one `.pen` file as separately named frames:

- `repository-context/<document-slug>/<asset-name>/candidate-<number>` for each direction;
- `repository-context/<document-slug>/<asset-name>/source/<name>` for imported evidence or assets;
- `repository-context/<document-slug>/<asset-name>/final` for the selected, refined result.

Place new root frames with `FindEmptySpace`, set `clip: true`, and keep `placeholder: true` while constructing them. Use small, reviewable `batch_design` operations and preserve returned node IDs. Remove the placeholder state only when a frame is complete.

Keep screenshots and other real output unchanged and aspect-correct as separate source layers. Build labels, connectors, backgrounds, framing, and editorial elements as independent editable nodes. Do not use Pencil image-generation operations unless the approved brief explicitly permits synthetic editorial imagery, and never use generated material as product evidence.

## Compare and select

For every candidate:

1. run `snapshot_layout` with `problemsOnly: true` and fix structural problems;
2. call `get_screenshot` on the candidate frame;
3. confirm that the message, evidence, dimensions, and accessibility constraints remain intact.

Present all candidates together with a concise rationale and the material trade-offs of each. Ask the user to select one direction, combine named elements, or revise the visual concept, then pause. Do not choose a winner or export a final asset implicitly.

If the user revises the concept, record the new agreement and rebuild only the directions affected by it. If the user combines elements, name the exact source candidates and elements before refining.

## Refine, approve, and export

Preserve the candidate frames and refine the selected direction in the `final` frame. If the user edits the `.pen` file directly, repeat the workspace verification, then resume from the verified file path and stored frame ID; re-inspect rather than inferring completion from the current selection or a similar frame name.

Before final approval:

1. inspect the final nodes with `batch_get`;
2. run `snapshot_layout` with `problemsOnly: true`;
3. render the exact final frame with `get_screenshot`;
4. verify legibility, reading order, dimensions, source fidelity, editability, privacy, and alignment with the approved concept;
5. show the rendered frame and ask for explicit final approval.

After approval, use `export_nodes` with the exact final frame ID, requested format, scale, and output directory. Inspect the exported image outside the `.pen` file and report:

- the approved communication purpose and selected direction;
- the `.pen` path and candidate frame names;
- the final frame ID, export path, dimensions, format, and scale;
- the checks performed and any unresolved limitation.

Return these details to the calling documentation workflow so it can replace
the review stub, finalize alt text, and verify the rendered placement.
