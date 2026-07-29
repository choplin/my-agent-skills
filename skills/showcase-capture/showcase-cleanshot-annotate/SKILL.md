---
name: showcase-cleanshot-annotate
description: Hand a clean showcase screenshot to a person for annotation in CleanShot X, then recover and verify the saved result. Use on macOS when a planned still needs arrows, labels, highlights, a background, or another small visual edit that is faster for a person to perform in CleanShot Annotate than for an agent to reproduce programmatically. Preserves the clean source and uses an explicit edit brief and final path.
user-invocable: false
metadata:
  description-role: documentation
---

# Annotate a showcase still in CleanShot X

Use CleanShot X as a human-operated editor. Own the preparation, edit brief, Annotate launch, completion handoff, result recovery, and verification; do not claim that CleanShot's URL scheme can place or return annotations.

## Establish the handoff

Require:

- an existing PNG or JPEG clean source and the proof point that must remain visible;
- a numbered edit brief naming every arrow, label, highlight, crop, background, or framing change;
- the final path, dimensions or aspect ratio, and format.

Inspect the source before launch. If it contains a preventable secret, personal data, notification, wrong state, or other capture defect, return it to the originating capture skill. Do not prescribe blur or masking as a repair.

Keep the clean source immutable. Create a separate working copy and reserve a distinct final path. Do not guess a save destination from CleanShot settings or overwrite the only source.

## Open CleanShot Annotate

Confirm that CleanShot X is already installed and that its URL scheme is enabled. Do not install it or change that setting without approval. Percent-encode the absolute working-copy path, then open:

```bash
open "cleanshot://open-annotate?filepath=/absolute/path/to/working.png"
```

Request authorization before launching a GUI when the environment requires it. If the URL scheme is unavailable, report the limitation rather than silently substituting another editor.

Present the human editor with:

1. the numbered edit brief;
2. the visual proof that must not be covered or changed;
3. the exact final path and format;
4. a request to save there and reply when editing is complete.

Pause at this handoff. Do not attempt pointer-level CleanShot editing by default, poll unrelated folders, or infer completion from the newest screenshot.

## Recover and verify

After the user reports completion, resolve the exact final path and confirm that it exists. Inspect the final image at its intended viewing size and compare it with the clean source. Confirm:

- the proof point is unchanged, visible, and readable;
- every requested edit appears and no unrequested edit appears;
- annotations do not cover the state they explain;
- dimensions, aspect ratio, and format match the brief;
- no secret, personal data, misleading reconstruction, or generative fill appears.

If the file is missing or ambiguous, ask the user to save to the agreed path; do not recover a different recent image by guesswork. If a visual requirement is missed, give a short correction brief and reopen the same working artifact for another human edit pass.

Return the final image to the session for review and report the source path, final path, dimensions, format, and edits verified.
