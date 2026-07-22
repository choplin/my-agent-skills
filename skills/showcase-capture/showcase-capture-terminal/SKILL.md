---
name: showcase-capture-terminal
description: Capture polished screenshots or video demonstrations of a CLI, REPL, or text-based developer tool in a terminal. Use after a capture plan identifies a terminal surface, or when the user asks to record or screenshot command-line usage for documentation, a README, release notes, or a product demo. Prepare deterministic terminal state, execute the planned take, and verify the exported media.
---

# Terminal showcase capture

Capture a short, clean command-line story. Use `showcase-capture-plan` first when the story, audience, or shot list is not already clear.

## Prepare a repeatable take

- Use a disposable directory, stable fixtures, and commands that are safe to run repeatedly.
- Set a clean prompt and a readable fixed terminal size. Keep font size, theme, and width consistent within the deliverable.
- Hide unrelated panes, tabs, notifications, hostnames, paths, tokens, and personal/project-sensitive data.
- Pre-run slow setup and place the terminal at the exact reset point. Never fake command output; use real representative output.

## Capture

Use a terminal-aware capture or recording facility when one is available, because it preserves a clean terminal region and makes repeat takes easy. Capture only the terminal window/region and follow the plan's timing:

1. Start from the planned prompt and frame.
2. Type commands deliberately; avoid backspaces, accidental history, and dead time.
3. Pause briefly on the meaningful result so it can be read in a still or video frame.
4. Stop after the outcome; do not continue into cleanup or unrelated exploration.

If a terminal-aware facility cannot make the requested artifact, delegate the same shot to `showcase-capture-screen`; do not silently substitute a low-quality full-desktop capture.

## Verify and hand off

Inspect the saved artifact at its intended viewing size. Confirm that text is readable, the command/result pair fits in frame, no secrets or notifications appear, and the artifact matches the planned shot. Re-take rather than crop away essential context or hide a mistake with misleading edits.

Report the output path, the completed shot(s), and any remaining planned captures.
