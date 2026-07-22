---
name: showcase-capture-screen
description: Capture polished screenshots or video demonstrations from the visible screen when terminal- or browser-specific capture is not suitable. Use for native desktop apps, multi-window workflows, browser flows that need real chrome or cannot be automated, and any general screen recording or screenshot request. Prepare a controlled desktop, capture only the required region, and verify the result.
---

# General screen showcase capture

Use this skill for the capture surfaces that specialized terminal or browser tooling cannot handle. Prefer `showcase-capture-terminal` or `showcase-capture-browser` when their surface-specific output is sufficient.

## Prepare a controlled desktop

- Put every required window at its planned size and position; close or hide everything else.
- Disable or silence notifications, calendar popups, and messaging indicators. Check menus, dock/taskbar, wallpaper, account names, recent-file lists, and cursor position for sensitive or distracting material.
- Choose the smallest region that still explains the shot. Use a fixed display scale and do one rehearsal before recording.
- Start the application from a known reset point and use only representative, non-sensitive data.

## Capture the planned take

Use the operating system's accessible screenshot/screen-recording tool or an available screen-capture integration. Request needed permissions through the normal UI; do not bypass privacy or OS security controls.

- For a still, capture after the intended state is fully settled and verify the crop before saving.
- For video, start recording before the first visible action, execute only the scripted flow, hold on the outcome, then stop. Keep the cursor intentional and avoid unnecessary pointer movement.
- If a browser or terminal shot is clearer with its dedicated capture skill, return it there instead of recording the entire desktop.

## Verify and hand off

Review the saved file at the target size. Confirm framing, readability, audio only if requested, and that no notifications, credentials, personal data, or unrelated windows are visible. Re-take a flawed shot; do not rely on destructive editing of the source capture. Report output paths and any unavailable OS permission or tool limitation.
