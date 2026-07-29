---
name: showcase-capture-terminal
description: Capture polished screenshots or video demonstrations of a CLI, REPL, or text-based developer tool in a terminal. Use after a capture plan identifies a terminal surface, or when the user asks to record or screenshot command-line usage for documentation, a README, release notes, or a product demo. Prepare deterministic terminal state, execute the planned take, and verify the exported media.
metadata:
  description-role: documentation
---

# Terminal showcase capture

Capture a short, clean command-line story. Use `showcase-capture-plan` first when the story, audience, or shot list is not already clear.

Own terminal-specific state preparation, acquisition, state-preserving crop/resize/padding/export, and verification for both screenshots and video. Do not hand off merely because the requested artifact is a still. Treat the capture plan as the owner of the proof point, composition, target dimensions/format, and annotation intent.

## Choose the acquisition path

Choose by destination and playback behavior:

1. **README still → VHS PNG screenshot.**
2. **README motion → VHS GIF.** Keep it to a short silent loop; for a longer story, use a still preview that links to the Web demo or video.
3. **Fixed Web video → VHS MP4 or WebM.** Default to MP4 for broad playback compatibility. Add WebM when the destination supports it and wants an alternate source. A tape may declare both outputs so one take produces matching encodes.
4. **Interactive Web terminal → asciinema.** Use a `.cast` with asciinema player when viewers should pause, search, copy text, or resize the terminal playback. Use `agg` when the same recording must also supply a GIF.
5. **Real terminal window or unsupported interaction → `showcase-capture-screen`.** Delegate when the shot must show native window chrome, tabs, mouse interaction, several windows, the exact local renderer, audio, or a format the available terminal-aware tools cannot produce. Do not install software or substitute a full-desktop capture without user approval.

VHS produces rendered pixels; asciinema records terminal events. Do not treat them as interchangeable fallbacks when the required behavior would be lost. If VHS is unavailable for a README GIF, asciinema plus `agg` is acceptable when text-event rendering is faithful enough. If asciinema is unavailable for an interactive Web embed, a VHS video is only a non-interactive fallback and that loss must be reported.

Always retain the `.tape` or `.cast` as the source artifact through handoff and report its path with the rendered media. Publishing or committing that source is a separate decision owned by the capture plan. Inspect it for commands, output, paths, and environment values before it leaves the local workspace; a rendered image may look safe while a text-readable cast still contains sensitive data.

## Prepare a repeatable take

- Use a disposable directory, stable fixtures, and commands that are safe to run repeatedly.
- Fixtures may be artificial, but exercise the real product path. Use real initialization, indexing, commands, search, selection, and previews against representative seeded data; never substitute stub output or prewritten logs.
- Set a clean prompt and a readable fixed terminal size. Record the shell, font family and size, theme, width, and height with the capture recipe; use the same values for every shot in one deliverable.
- Hide unrelated panes, tabs, notifications, hostnames, paths, tokens, and personal/project-sensitive data.
- Pre-run slow setup and place the terminal at the exact reset point. Never fake command output; use real representative output.

Record and fix every visible environment input that applies:

- shell, `PS1`, prompt hooks such as Bash `PROMPT_COMMAND`, and the working directory shown in the prompt;
- `PAGER`, `FZF_DEFAULT_OPTS`, `XDG_DATA_HOME`, and `XDG_CONFIG_HOME`;
- terminal width and height, font family and size, theme, and renderer;
- TUI-specific layout and colors, including fzf layout and color options.

Use isolated XDG directories when the demonstrated tool reads mutable user state. Disable a pager or alternate screen explicitly, for example with `PAGER=cat`, when the previous result must remain visible for the next action. Do not clear between related operations by default; retain the prior result and add spacing before the next prompt when that continuity explains the exploration.

Assign color to information roles rather than decoration. Make the command start, query match, current selection, result count, and available actions distinguishable when those states appear in the story.

Verify fonts with a rendered rehearsal frame, not only by checking that the font name exists. Include letters, digits, punctuation, a Nerd Font glyph when used, and a long line; reject a font whose glyphs or cell widths misalign in the actual VHS/xterm.js output.

Before choosing a native terminal-aware path, check its commands without changing the environment:

```bash
command -v vhs ttyd ffmpeg ffprobe
command -v asciinema agg
```

VHS supports macOS and Linux, but a native installation depends on `ttyd` and FFmpeg; its official container includes those dependencies when an existing Docker or Podman runtime is acceptable. Asciinema supports both operating systems; `agg` is a separate renderer needed for GIF export. Ask before installing any missing dependency.

## Capture with VHS

Create a `.tape` file for every repeatable take. Keep requirements, outputs, and all appearance settings before the interaction commands. Adapt this representative recipe to the planned command and expected output:

```text
Require demo-cli
Output "demo.gif"
Output "demo.mp4"
Output "demo.webm"

Set Shell bash
Set FontFamily "JetBrains Mono"
Set FontSize 20
Set Width 1200
Set Height 675
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 50ms
Set CursorBlink false

Type "demo-cli run"
Enter
Wait+Screen /Result ID:/
Sleep 2s
Screenshot "demo.png"
```

Confirm the named font and theme with an actual rendered frame, remove any `Output` lines the plan does not require, then run `vhs demo.tape`. Use `Require` for the demonstrated program so the take fails early instead of recording a missing-command error. Use `Sleep` only for deliberate typing and reading holds. A VHS `Screenshot` writes the current frame as PNG, while `Output` supports GIF, MP4, WebM, or a PNG frame sequence.

### Synchronize each VHS operation

`Wait+Screen` searches visible screen content, including commands and text left by an earlier step. Wait for a string that can first appear after the current operation completes; a repeated result term is not a completion signal. Make a setup helper print a unique sentinel when the program has no suitable final state. The sentinel must not appear in the typed command itself:

```text
Type "./prepare-demo"
Enter
Wait+Screen /__CAPTURE_SETUP_DONE__/
```

Use a different sentinel for every step. Prefer a meaningful state that appears only after the operation, such as a detail field rendered only by the final view, when a visible sentinel would distract from the story. `Enter` only submits input; it does not prove completion. Use `Wait+Line` only for a unique state that remains on the final line.

### Keep VHS and shell quoting separate

Parse the tape string and the command passed to the shell as two distinct quoting layers:

- Prefer single quotes for string literals inside `Type "..."`; escaped double quotes can fail to parse in VHS 0.11.0.
- Move multi-command setup or complex quoting into a reviewed helper script and type only the helper invocation.
- Do not assume `\n` remains two literal characters inside a VHS string; it may become an actual newline.
- Rehearse the exact tape with the installed VHS version instead of validating only the extracted shell command.

Quote every output path and use paths relative to the directory where VHS runs. VHS tape syntax can parse an unquoted absolute path such as `/tmp/demo.mp4` as commands instead of one path, and VHS 0.11.0 on macOS may log an unquoted relative `Screenshot` without preserving the PNG. Run from the intended output directory rather than relying on an absolute destination.

## Capture a text session with asciinema

Fix the real terminal to the planned columns and rows before recording, use a clean shell, and record locally:

```bash
asciinema rec demo.cast
asciinema play demo.cast
agg --cols 100 --rows 30 --font-size 20 --theme dracula demo.cast demo.gif
```

Use `asciinema rec -c '<command>' demo.cast` when one command owns the complete session. Review the cast locally before rendering because commands and output remain recoverable as text. Never upload a cast to asciinema.org or another service unless the user explicitly requests publishing. `agg` can override font, theme, rows, and columns, but reflowing a recording can change long lines and full-screen TUIs; re-record at the target geometry when that matters.

## Execute the take

Capture only the terminal window or rendered terminal frame and follow the plan's timing:

1. Start from the planned prompt and frame.
2. Type commands deliberately; avoid backspaces, accidental history, and dead time.
3. Pause briefly on the meaningful result so it can be read in a still or video frame.
4. Stop after the outcome; do not continue into cleanup or unrelated exploration.

Use the take as a lightweight acceptance test. If a real command cannot produce the documented or planned demonstration, stop and report the command, expected behavior, and observed behavior. Do not alter the fixture or edit the capture to hide the discrepancy.

For an OS-level fallback, preserve the same shot specification and delegate it to `showcase-capture-screen`. On macOS, screen capture may require Screen & System Audio Recording permission. On Linux, window/monitor capture depends on the active desktop and may use the XDG ScreenCast portal. Request access through normal UI and never bypass the platform security model.

## Verify and hand off

Inspect the saved artifact at its intended viewing size. Confirm its machine-readable properties before judging the content:

```bash
# Still: codec/format and pixel dimensions
ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height \
  -of default=noprint_wrappers=1 demo.png

# Video or GIF: format, duration, dimensions, and bytes
ffprobe -v error -select_streams v:0 \
  -show_entries format=format_name,duration:stream=codec_name,width,height \
  -of default=noprint_wrappers=1 demo.mp4
wc -c demo.mp4
```

Use the real artifact path and compare the reported values with the capture plan. When `ffprobe` is unavailable on an OS-capture fallback, use that platform's metadata inspector and report the missing automated check.

Confirm that text is readable, the command/result pair fits in frame, no secrets or notifications appear, and the artifact matches the planned shot. Replay the whole video or cast once to catch truncation, timing gaps, cursor noise, font or cell-width errors, and secret-bearing intermediate frames.

Limit processing during capture to operations that preserve the represented state: crop, resize, padding, color-profile normalization, metadata removal, and export in the planned format. Do not add callouts, blur sensitive data, composite multiple images, or otherwise change represented terminal state. Re-take rather than crop away essential context or hide a mistake with misleading edits.

When the plan explicitly requires annotations, a comparison layout, compositing, or decorative framing, preserve a clean source artifact and delegate it with the exact edit specification to the tool-specific skill named by the plan: `showcase-cleanshot-annotate`, `showcase-figma-annotate`, or `showcase-pen-annotate`. Otherwise return the finished screenshot directly.

Report the output path, the completed shot(s), and any remaining planned captures. Keep and report the reproduction bundle: the `.tape` or `.cast`, fixture, setup helper, fixed visible-environment settings, and final media filenames.
