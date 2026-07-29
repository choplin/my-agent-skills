---
name: showcase-capture-plan
description: Plan presentation media for a product, app, or developer tool before capturing it. Use when the user wants to decide what screenshots or demo video to make, asks for a demo script, storyboard, shot list, product-tour plan, or media plan for an app or CLI. Produces a video script and/or still-image shot list, routes each shot to terminal, browser, or general screen capture, and names a tool-specific annotation handoff only when a still requires one.
user-invocable: false
metadata:
  description-role: documentation
---

# Showcase capture plan

Turn a product's value into a small, capturable set of shots. Plan before opening a capture tool; do not capture a long, exploratory session and try to edit it into a story later.

## Gather only the needed context

Establish the audience, destination, format (video, stills, or both), desired length/count, and the feature or outcome to show. Inspect the product enough to identify the shortest believable happy path. Use representative, non-sensitive data.

If a fact is uncertain, label it as an assumption in the plan instead of inventing a UI state or product capability.

Define each shot by the user benefit or product claim it proves, not merely by the operation performed. Before accepting a shot, ask:

- Does this frame make the difference from the user's previous workflow visible?
- Does the claim require several states, objects, or results rather than one isolated result?
- Are the available choices, relationships, or result scale part of the evidence?

Plan enough context to answer those questions. A search followed by opening one item may prove that search works, but several related results followed by a meaningful selection may be necessary to prove discovery or synthesis.

## Choose the story

Use this order unless the intended audience needs another structure:

1. Orient: state the user problem or outcome.
2. Demonstrate: show the few actions that make the outcome credible.
3. Land: show the result, saved state, or next useful action.

Prefer one idea per shot. For every claim, state the evidence that must be visible: especially show the meaningful state before an action and the state after it. Hold consequential intermediate states long enough to read; cut setup, waiting, repeated navigation, and other transitions that do not establish the claim.

Target 30–40 seconds for a browser demo by default. Preserve explanatory states; shorten the result by removing dead time and duplicate coverage, not by rushing the proof.

Preserve visual continuity when one result motivates the next action. Do not insert a reset or clear merely to make every beat look pristine; use one only when it improves comprehension or establishes the required reset point.

## Produce the plan

Use the templates in `references/capture-plan-template.md`. Create a concise plan containing:

- **Video**: target duration; a beat-by-beat script with on-screen action, spoken/narration copy when applicable, expected state, evidence shown, hold/transition timing, and capture surface.
- **Stills**: a shot list with the exact scene, visible proof point, framing/crop, target dimensions or aspect ratio, output format, any intended annotation or composition, capture surface, and selected annotation tool when needed.
- **Capture routing**: assign each shot to `showcase-capture-terminal`, `showcase-capture-browser`, or `showcase-capture-screen`.
- **Readiness**: fixture provenance, the real execution path, visible environment, viewport/window size, operation-specific completion signals, required reset point, continuity requirements, privacy checks, and the fixed final artifact name.
- **Reproduction bundle**: the capture source, representative fixture, setup helper, fixed display settings, and final output names that must remain available for a future re-take.

For a mixed deliverable, share the same narrative but do not merely extract random frames from video: specify composed stills separately.

## Protect execution fidelity

Fixtures may be artificial, but the demonstrated product path must be real. Prefer **real execution against representative seeded data**: run actual initialization, indexing, application logic, search, selection, and preview behavior instead of replaying stub output or prewritten logs.

Treat the rehearsal as a lightweight acceptance test. If the planned claim cannot be reproduced, or observed behavior contradicts product documentation, stop and report the expected and observed behavior. Do not adjust the fixture, script, or framing to conceal a product inconsistency.

## Route the capture

Route by the surface being captured, not by whether the output is a still or video. Do not introduce a separate still-capture handoff: each surface skill owns both media types.

| Surface | Delegate to |
| --- | --- |
| CLI, REPL, or text UI | `showcase-capture-terminal` |
| Web application controllable in a browser | `showcase-capture-browser` |
| Native app, multi-window workflow, browser automation that cannot produce the needed result, or any other visible surface | `showcase-capture-screen` |

Finish by naming the next capture skill and giving it the relevant rows of the plan. The capture skill owns surface-specific state preparation, acquisition, crop, resize, padding, format export, and verification when those operations preserve the represented state.

When a still explicitly requires annotations, a comparison layout, compositing, or decorative framing, choose a concrete annotation path:

| Editing path | Delegate to |
| --- | --- |
| Quick local edit performed by a person in CleanShot X on macOS | `showcase-cleanshot-annotate` |
| Reusable layers, comparison layout, shared review, or AI-human iteration in Figma | `showcase-figma-annotate` |
| Local, agent-writable layers in a repository-adjacent `.pen` artifact | `showcase-pen-annotate` |

Route the clean captured source and exact edit specification to the selected skill. Do not invent a generic finishing handoff or add annotation to an ordinary screenshot. Treat a preventable secret, personal detail, notification, or wrong product state as a re-capture requirement rather than a redaction task.
