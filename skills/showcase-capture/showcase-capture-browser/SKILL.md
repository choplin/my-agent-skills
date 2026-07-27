---
name: showcase-capture-browser
description: Capture polished screenshots or video demonstrations of a web application in a browser. Use after a capture plan identifies a browser surface, or when the user asks to record or screenshot a web app, website, product flow, or browser-based tool for documentation, release notes, marketing, or a demo. Use browser automation/control for page-owned states and route inherently OS-owned shots to general screen capture.
---

# Browser showcase capture

Capture a controlled web-app story, not an incidental browser session. Use `showcase-capture-plan` first if the intended claim, states, or shot list is undecided. For the Playwright/Nix implementation pattern, read `references/playwright-recording.md`.

Own browser-specific state preparation, acquisition, state-preserving crop/resize/padding/export, and verification for both screenshots and video. Do not hand off merely because the requested artifact is a still. Treat the capture plan as the owner of the proof point, composition, target dimensions/format, and annotation intent.

## Prepare the browser state

- Use a dedicated profile or clean browser context with representative test data. Do not expose personal tabs, credentials, extension UI, or notifications.
- Set the planned viewport, zoom, theme, locale, and logged-in state. Use a stable URL and wait for the final meaningful content, not a loading skeleton.
- Close devtools and unrelated tabs. Reset the application to the planned entry state before each take.
- Make a narrow, reversible adjustment to test data or the app only when it is necessary to make the planned outcome reproducible; disclose that adjustment.
- Make a static demo self-contained when practical, so the exact capture target can be opened from a local file URL without a server.
- Simplify the capture UI: retain only information that supports the claim; make panels, tables, modals, selected rows, and their boundaries visually distinct.

## Direct the viewer's attention

- Show an important state transition on both sides. For example, show a pending item before review and its confirmed/resolved state afterward. Hold meaningful intermediate states for a few seconds rather than passing through them.
- Animate only the interaction that explains the claim. Use visible typing for one or two human decisions or inputs; use immediate completion or a deliberate “skip to end” for repetitive remainder work.
- Let automated work progress at a readable item-by-item pace when that progression is evidence. Do not make the viewer watch every item if a summary or completion state conveys the rest.
- Keep comparison/list views on the relevant area. Do not scroll to the end merely to prove that the page is longer.

## Perform the take with browser control

Use the available browser-control integration to navigate and perform the planned interaction. Favor browser-native screenshots for stills: they are sharp and free of OS chrome. For recording with Playwright, use its video context option and follow the reference implementation.

For video, perform only the scripted interaction at an intentional pace:

- Render a page-level demonstration cursor in headless recording. Move it smoothly to each target; change it from arrow to hand over clickable controls and add a small pulse at each click.
- Scroll deliberately with a smooth, visible transition. Avoid `scrollIntoViewIfNeeded()` as the visible movement because it may jump; make the target readable, then click it.
- Do not show retries, hover noise, loading time, unrelated scrolling, or cursor warps. Keep the cursor still while a result needs to be read.

## Route out-of-scope shots to screen capture

Do not use `showcase-capture-screen` as a generic fallback when browser control is unavailable or fails. If the planned proof point remains inside the page, report the blocked browser capability instead of silently changing the acquisition method.

Route to `showcase-capture-screen` only when the shot inherently requires browser chrome, a native authentication dialog, multiple windows, or another OS-owned state. Give it the URL/state, viewport, interaction sequence, and planned framing.

## Verify and hand off

Keep only the named final artifact; do not accumulate “final-v2” comparison files. Open or inspect the output. For video, use `ffprobe` to confirm duration and file size. For a still, confirm its pixel dimensions and format. Confirm the correct viewport and final state, readable text, intentional framing, and absence of secrets, personal data, or notifications.

Limit processing during capture to operations that preserve the represented state: crop, resize, padding, color-profile normalization, metadata removal, and export in the planned format. Do not add callouts, blur sensitive data, composite multiple images, or otherwise change represented product state. Re-capture a shot that exposes sensitive data or shows an unintended intermediate or stale state.

When the plan explicitly requires annotations, a comparison layout, compositing, or decorative framing, preserve a clean source artifact and delegate it with the exact edit specification to the tool-specific skill named by the plan: `showcase-cleanshot-annotate` or `showcase-figma-annotate`. Otherwise return the finished screenshot directly. Report paths, dimensions or duration, file size, format, and completed shots.
