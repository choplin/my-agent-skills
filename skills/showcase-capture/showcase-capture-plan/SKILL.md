---
name: showcase-capture-plan
description: Plan presentation media for a product, app, or developer tool before capturing it. Use when the user wants to decide what screenshots or demo video to make, asks for a demo script, storyboard, shot list, product-tour plan, or media plan for an app or CLI. Produces a video script and/or still-image shot list, then routes each shot to terminal, browser, or general screen capture.
---

# Showcase capture plan

Turn a product's value into a small, capturable set of shots. Plan before opening a capture tool; do not capture a long, exploratory session and try to edit it into a story later.

## Gather only the needed context

Establish the audience, destination, format (video, stills, or both), desired length/count, and the feature or outcome to show. Inspect the product enough to identify the shortest believable happy path. Use representative, non-sensitive data.

If a fact is uncertain, label it as an assumption in the plan instead of inventing a UI state or product capability.

## Choose the story

Use this order unless the intended audience needs another structure:

1. Orient: state the user problem or outcome.
2. Demonstrate: show the few actions that make the outcome credible.
3. Land: show the result, saved state, or next useful action.

Prefer one idea per shot. For every claim, state the evidence that must be visible: especially show the meaningful state before an action and the state after it. Hold consequential intermediate states long enough to read; cut setup, waiting, repeated navigation, and other transitions that do not establish the claim.

Target 30–40 seconds for a browser demo by default. Preserve explanatory states; shorten the result by removing dead time and duplicate coverage, not by rushing the proof.

## Produce the plan

Use the templates in `references/capture-plan-template.md`. Create a concise plan containing:

- **Video**: target duration; a beat-by-beat script with on-screen action, spoken/narration copy when applicable, expected state, evidence shown, hold/transition timing, and capture surface.
- **Stills**: a shot list with the exact scene, visible proof point, framing/crop, and capture surface.
- **Capture routing**: assign each shot to `showcase-capture-terminal`, `showcase-capture-browser`, or `showcase-capture-screen`.
- **Readiness**: fixtures/accounts, seeded data, viewport/window size, required reset point, privacy checks, and the fixed final artifact name.

For a mixed deliverable, share the same narrative but do not merely extract random frames from video: specify composed stills separately.

## Route the capture

| Surface | Delegate to |
| --- | --- |
| CLI, REPL, or text UI | `showcase-capture-terminal` |
| Web application controllable in a browser | `showcase-capture-browser` |
| Native app, multi-window workflow, browser automation that cannot produce the needed result, or any other visible surface | `showcase-capture-screen` |

Finish by naming the next capture skill and giving it the relevant rows of the plan.
