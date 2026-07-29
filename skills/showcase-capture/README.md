# showcase-capture

Skills for producing presentation media of a product — screenshots and short
demo videos for documentation, release notes, or a demo — and for handing a
finished still to a person for annotation.

## Skills

| Skill | Description |
|-------|-------------|
| `showcase-capture-plan` | Decide what to capture before capturing it: a video script and a still-image shot list, each shot routed to a surface |
| `showcase-capture-terminal` | Capture a CLI, REPL, or text UI in a terminal |
| `showcase-capture-browser` | Capture a web application in a browser, driving page-owned states through browser control |
| `showcase-capture-screen` | Capture from the visible screen — native apps, multi-window flows, and browser flows needing real chrome |
| `showcase-cleanshot-annotate` | Hand a still to a person for a quick local edit in CleanShot X on macOS |
| `showcase-figma-annotate` | Hand a still to a person as an editable Figma composition |
| `showcase-pen-annotate` | Hand a still to a person as a local pen.dev `.pen` file, edited through Pencil MCP tools |

## How the pieces fit

```
plan ──> one capture surface per shot ──> annotation handoff, only if the shot needs one
```

**Choosing a capture surface.** Match the surface that owns the content. A
terminal shot belongs to the terminal skill and a page-owned browser state to the
browser skill, because each can drive its own surface deterministically. Screen
capture is for what neither owns: native desktop apps, several windows at once,
real browser chrome, and OS-level dialogs. It is not a fallback for browser
automation that failed — a browser shot that cannot be automated is still a
browser shot, and the reason it failed is worth fixing.

**Choosing an annotation handoff.** All three preserve the clean source and hand
the edit to a person; they differ in where the editable artifact lives. CleanShot
is a one-off local edit on macOS. Figma keeps reusable layers and allows shared
review. Pen keeps an agent-writable file next to the repository, under version
control. Most stills need none of them.

A shot list is worth producing first whenever the claim to prove, the states, or
the framing are not already settled. Capturing without one tends to produce
incidental recordings rather than a story.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
