# macOS screen capture

Use this procedure for native apps, OS-owned UI, browser chrome, and multi-window takes on macOS. Keep the capture plan's framing, output format, and privacy requirements unchanged when switching acquisition tools.

## Choose the acquisition path

1. Use CleanShot X when it is already installed and its URL scheme is enabled.
2. Use the macOS Screenshot toolbar when CleanShot is unavailable, disabled, or cannot perform the planned take.
3. Use the `screencapture` CLI for a native still or bounded recording only when its locally reported options cover the take and a predictable file path is useful.
4. Return a page-owned take to `showcase-capture-browser` or a terminal-renderable take to `showcase-capture-terminal`; tool failure alone does not change surface ownership.

Do not install CleanShot X or change its URL-scheme setting without approval. Before relying on a command, check the installed behavior: CleanShot parameters vary by version, while `screencapture` options vary by macOS release.

## Drive CleanShot X

CleanShot X exposes a URL scheme rather than a documented shell CLI. Launch a command with `open`:

```bash
open "cleanshot://capture-fullscreen?action=save"
open "cleanshot://capture-window?action=save"
open "cleanshot://capture-area?action=save"
open "cleanshot://record-screen"
```

CleanShot 4.7 or later can capture a known area immediately:

```bash
open "cleanshot://capture-area?x=100&y=120&width=1200&height=675&display=1&action=save"
open "cleanshot://record-screen?x=100&y=120&width=1200&height=675&display=1"
```

For CleanShot coordinates, `(0,0)` is the lower-left corner. `display=1` is the main display. Percent-encode any values that are not URL-safe.

Treat the URL scheme as an invocation API, not unattended capture orchestration:

- `capture-area` can take a screenshot immediately when all geometry parameters are present. Its `action` may be `copy`, `save`, `annotate`, `upload`, or `pin`.
- `capture-window` opens window selection; it does not identify a window by bundle ID or title.
- `record-screen` opens recording mode at an optional area. The documented URL API does not provide commands to start or stop recording, choose audio sources, force an output path, or return the saved artifact.
- The save destination, file name, screenshot format, recording format, cursor, microphone, and computer-audio behavior therefore remain CleanShot settings or UI choices. Inspect them before the take.

In CleanShot's recording settings, enable microphone or computer audio only when the capture plan requests it. Confirm the selected microphone, make a short rehearsal, and listen to the saved result; visible audio controls prove only that recording was requested, not that the intended source was captured.

CleanShot 3.5.1 or later provides these capture commands. Area geometry, `display`, and screenshot `action` require 4.7 or later. If the installed version or settings cannot satisfy the plan, retain the same shot specification and use the native fallback.

Reference: [CleanShot X URL scheme API](https://cleanshot.com/docs-api).

## Use the macOS-native fallback

Press Command-Shift-5 to open Screenshot. Choose capture entire screen, capture a window, capture a selected portion, record the entire screen, or record a selected portion. In Options, confirm the save location, timer, pointer or click behavior, and microphone or audio choices before starting. Stop a recording from the menu bar and confirm the resulting file at the configured destination.

For a native CLI path, first inspect the host's supported flags:

```bash
screencapture -h
```

Common bounded still paths include:

```bash
screencapture -x -m "shot.png"
screencapture -x -R100,120,1200,675 "shot.png"
screencapture -i "shot.png"
screencapture -W "window.png"
```

Use `-R<x,y,w,h>` only after rehearsing the coordinates on the active display arrangement. Use `-l<windowid>` only when the window ID has been obtained reliably; otherwise use interactive window selection. For recording, prefer the Screenshot toolbar unless the locally reported `screencapture` video, display or region, duration, and audio-input options match the plan exactly. Do not infer system-audio capture from an input-audio flag.

References: [Take screenshots or screen recordings on Mac](https://support.apple.com/guide/mac-help/mh26782/mac) and [Record your screen in QuickTime Player](https://support.apple.com/guide/quicktime-player/qtp97b08e666/mac).

## Handle permissions

Let CleanShot X, Screenshot, QuickTime Player, or the invoking terminal request access through the normal macOS dialog. If capture is blank, missing audio, or denied:

1. Stop rather than repeatedly retrying or changing security controls.
2. Tell the user which app needs access.
3. Direct them to System Settings > Privacy & Security > Screen & System Audio Recording. Microphone access is controlled separately under Microphone.
4. Continue only after the user grants access and any required app restart is complete.

Never bypass Transparency, Consent, and Control protections, edit their database, or silently broaden an app's permission. Treat a denied permission as a reported limitation, not permission to switch to another capture surface.

References: [Control access to screen and system audio recording](https://support.apple.com/guide/mac-help/mchld6aa7d23/mac) and [Allow use of the microphone and audio input](https://support.apple.com/guide/mac-help/mchl7fa8e3cc/mac).

## Verify the artifact

Open and inspect the final artifact at its target viewing size. Confirm framing, readable content, the intended application state, and the absence of notifications, credentials, personal data, unrelated windows, and unintended audio.

Check a still's format and dimensions:

```bash
file "shot.png"
sips -g pixelWidth -g pixelHeight -g format "shot.png"
```

Check a video's format, dimensions, duration, and bytes when FFprobe is available:

```bash
ffprobe -v error \
  -show_entries format=format_name,duration,size:stream=codec_name,width,height \
  -of default=noprint_wrappers=1 "recording.mp4"
stat -f %z "recording.mp4"
```

When FFprobe is unavailable, inspect native metadata and report that automated codec verification was limited:

```bash
mdls -name kMDItemContentType -name kMDItemPixelWidth \
  -name kMDItemPixelHeight -name kMDItemDuration -name kMDItemFSSize \
  "recording.mp4"
```

Replay the entire recording once. Confirm that the expected audio sources are present, private audio is absent, the beginning and end are intentional, and no permission prompt or recorder control obscures the proof point. Re-take an unsafe or incorrect capture instead of concealing it in post-processing.
