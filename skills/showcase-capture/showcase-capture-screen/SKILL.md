---
name: showcase-capture-screen
description: Capture polished screenshots or video demonstrations from the visible screen when terminal- or browser-specific capture is not suitable. Use for native desktop apps, multi-window workflows, browser flows that need real chrome or cannot be automated, and any general screen recording or screenshot request. Prepare a controlled desktop, capture only the required region, and verify the result.
metadata:
  description-role: documentation
---

# General screen showcase capture

Use this skill for the capture surfaces that specialized terminal or browser tooling cannot handle. Prefer `showcase-capture-terminal` or `showcase-capture-browser` when their surface-specific output is sufficient.

Own visible-screen state preparation, acquisition, state-preserving crop/resize/padding/export, and verification for both screenshots and video. Do not route by media type: use this skill for stills as well as video when the surface is a native app, OS UI, multi-window workflow, or another general screen. Treat the capture plan as the owner of the proof point, composition, target dimensions/format, and annotation intent.

## Prepare a controlled desktop

- Put every required window at its planned size and position; close or hide everything else.
- Disable or silence notifications, calendar popups, and messaging indicators. Check menus, dock/taskbar, wallpaper, account names, recent-file lists, and cursor position for sensitive or distracting material.
- Choose the smallest region that still explains the shot. Use a fixed display scale and do one rehearsal before recording.
- Start the application from a known reset point and use only representative, non-sensitive data. Seeded data may be artificial, but exercise the real application path rather than showing stub responses or prewritten activity.

## Capture the planned take

On macOS, read `references/macos-capture.md` before choosing an acquisition path. Prefer CleanShot X when it is already installed and enabled; use its URL scheme for the operations it exposes, then fall back to macOS-native capture when CleanShot is unavailable or cannot satisfy the planned take. Do not install or enable a capture tool without approval.

Use the operating system's accessible screenshot/screen-recording tool or an available screen-capture integration. Request needed permissions through the normal UI; do not bypass privacy or OS security controls.

- For a still, capture after the intended state is fully settled and verify the crop before saving.
- For video, start recording before the first visible action, execute only the scripted flow, hold on the outcome, then stop. Keep the cursor intentional and avoid unnecessary pointer movement.
- If a browser or terminal shot is clearer with its dedicated capture skill, return it there instead of recording the entire desktop.

## Verify and hand off

Review the saved file at the target size. Confirm pixel dimensions and format for a still, or duration and file size for video. Confirm framing, readability, audio only if requested, and that no notifications, credentials, personal data, or unrelated windows are visible.

Treat the rehearsal as a lightweight acceptance test. If the real application cannot produce the documented or planned state, stop and report the action, expected behavior, and observed behavior. Do not change the fixture or framing to conceal the discrepancy.

Limit processing during capture to operations that preserve the represented state: crop, resize, padding, color-profile normalization, metadata removal, and export in the planned format. Do not add callouts, blur sensitive data, composite multiple images, or otherwise change represented product state. Re-take a flawed or unsafe shot instead of repairing it with a misleading edit.

When the plan explicitly requires annotations, a comparison layout, compositing, or decorative framing, preserve a clean source artifact and delegate it with the exact edit specification to the tool-specific skill named by the plan: `showcase-cleanshot-annotate`, `showcase-figma-annotate`, or `showcase-pen-annotate`. Otherwise return the finished screenshot directly. CleanShot acquisition does not imply a CleanShot annotation handoff; use the path selected in the plan. Report output paths and any unavailable OS permission or tool limitation. Keep and report the capture recipe, fixture/setup instructions, fixed display settings, and final media filenames as the reproduction bundle.
