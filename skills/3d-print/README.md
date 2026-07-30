# 3d-print

## Skills

| Skill | Description |
|-------|-------------|
| `3d-print` | Model a small printable object interactively in OpenSCAD — generate and self-verify from rendered views, settle the dimensions that need measuring, then hand over a parametric `.scad` for live-preview tuning |
| `3d-print-eufymake-cli` | Slice from the command line with eufyMake Studio's console build, and trace a print warning back to the geometry that causes it by measuring the G-code |

Aimed at small objects: holders, brackets, stands, trays, cases, inserts. It
writes OpenSCAD rather than meshes, so the deliverable stays parametric and
hand-editable. It does not find existing models or repair meshes.

Modelling and slicing stay separate skills. `3d-print` ends at a `.scad` and an
`.stl` and judges printability from the mesh; `3d-print-eufymake-cli` is the
after-the-fact check against the real slicer, for when a warning has to be
reproduced or proven gone.

## Prerequisites

OpenSCAD and `jq` on the system. OpenSCAD should be the **desktop application**
(macOS: `brew install --cask openscad`) — the live-preview phase needs the GUI,
and the same install provides the `openscad` command the scripts call. No nix
dev shell is bundled, because a CLI-only provisioning path cannot serve that
phase.

The printer profile lives at `~/.config/3d-print/printer.json` and is collected
once, on first use.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
