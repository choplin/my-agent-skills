---
name: 3d-print
description: >-
  Models a small object for 3D printing, interactively and parametrically.
  Writes it as OpenSCAD, checks its own work by reading rendered views and a
  mechanical geometry report, settles the dimensions that have to be measured
  off a real object, and hands over a parametric .scad file the user tunes in
  OpenSCAD's live preview. Applies when someone wants a printable model made —
  a holder, a bracket, a stand, a tray, a case, an insert — rather than an
  existing model found, a mesh repaired, or a print sliced.
allowed-tools: Read, Write, Edit, Bash, Glob, AskUserQuestion
metadata:
  description-role: trigger
---

# 3D Print Modeling

Make a printable model **by writing OpenSCAD**, not by describing one. The `.scad`
file is the deliverable and the source of truth; the STL is a by-product that is
regenerated whenever a parameter changes.

The work splits across three phases with different people in the loop. Phase 1
is yours alone — you generate and check your own geometry by reading renders.
Phase 2 hands one specific job to the user, measuring a real object, and only
happens when the model has to fit something. Phase 3 hands the file over: the
user watches OpenSCAD's live preview and says what to change, and you only edit.

## What it produces

Everything lands in **a directory named after the model, under the current
working directory** — so the user gets the files where they asked for them, and
one directory can be deleted to undo the whole thing.

```
<model-name>/
  model.scad        # the deliverable — parametric, hand-editable
  model.stl         # regenerated on every build; hand this to a slicer
  build/            # working output: renders, summary.json, section.scad, openscad.log
```

## Prerequisites

**OpenSCAD and `jq`, installed on the system.** `scripts/build.sh` probes for
both and stops with per-platform install commands if either is missing; relay
that message rather than trying to work around it.

OpenSCAD is expected to be the **desktop application**, not a CLI-only build:
Phase 3 hands the file to its live preview, and one install covers both the GUI
and the `openscad` command the scripts call. On macOS that is
`brew install --cask openscad`.

This skill therefore treats OpenSCAD as a plain external dependency and bundles
no nix dev shell, departing from the repository's usual runtime policy. The
reason is that the nix path would provide only the CLI, which cannot serve
Phase 3 — so it would be an alternative that does not actually substitute for
the real dependency. If only a CLI is present, Phases 1 and 2 still run in full:
say plainly that live preview is unavailable and keep iterating by render.

## Printer profile

The printer does not change between models, so it is asked once and read
silently ever after, from
`${XDG_CONFIG_HOME:-$HOME/.config}/3d-print/printer.json`:

```json
{
  "nozzle_diameter": 0.4,
  "bed": { "x": 220, "y": 220, "z": 250 },
  "layer_height": 0.2,
  "fit_clearance": 0.2,
  "material": "PLA"
}
```

| Field | What it decides |
|---|---|
| `nozzle_diameter` | The minimum wall: anything thinner than **two nozzle widths** prints as a gap. |
| `bed` | Whether the model fits at all, in mm. |
| `layer_height` | The smallest vertical detail worth modelling. Detail below one layer disappears. |
| `fit_clearance` | How much slack a measured dimension gets before a mating part will actually go in. Printer- and material-specific, so it is measured once and reused — never re-derived per model. |
| `material` | The shrinkage and overhang assumptions behind the shape. |

**If the file does not exist, this is the one time you interrupt to ask.** Ask
for all five at once, write the file, and never ask again. If it exists, read it
and say nothing about it.

## The three phases

| Phase | Who is in the loop | Ends when |
|---|---|---|
| **1 — Generate** | You alone | The geometry checks pass and the renders show no obvious break, or three rounds are spent |
| **2 — Measure** | The user, with calipers | The measured values are in the file (skipped entirely when nothing has to fit) |
| **3 — Tune** | The user, watching live preview | The user is satisfied |

## Phase 1 — generate, then check your own work

**Ask nothing before generating.** Every dimension the request leaves open gets a
plausible placeholder, because a rendered guess is a far better prompt for the
user than a question is. The one exception — a value that can only come off a
real object with calipers — is not asked here either; it is Phase 2's job, and
Phase 2 deliberately runs *after* the shape is agreed, since measuring before
the shape is settled measures the wrong things.

1. **Write `<model-name>/model.scad`** to the generation contract below.
2. **Build it.** `scripts/build.sh <model.scad>` exports the STL, renders five
   views, and prints one JSON report. Exit 1 means a check failed — a normal
   outcome to act on, not an error to report.
3. **Read the report, then read the images.** Both, every round. They answer
   different questions and neither substitutes for the other.
4. **Fix and rebuild.** At most three rounds.
5. **Show the user the isometric view and the section**, state the overall
   dimensions, and say which numbers are placeholders.

| Read this | To answer |
|---|---|
| `iso.png` | Is this recognisably the thing that was asked for? |
| `front.png`, `right.png`, `top.png` | Are the holes, cutouts, and protrusions in the right places, at the right proportions? |
| `section.png` | Is the inside what you intended — hollow where it should be hollow, walls where it should have walls? Cut-open faces are shown in a contrasting colour. |
| `checks[]` in the report | Is it 3D at all, non-empty, on the bed, and thicker than the nozzle can print? |
| `parameters` in the report | Did the values you meant to set actually reach the geometry? |

**Stop after three rounds even if you are not satisfied.** Then say what is still
wrong and hand over anyway. The user is about to look at it in live preview,
where a bad shape is obvious in a second — burning rounds on a judgment they are
better equipped to make is the more expensive mistake.

Stop *earlier* than three rounds when the checks pass and the renders look
right. There is no credit for extra polish before the user has seen it.

## Phase 2 — settle the measurements

**Only when the model has to fit a real object.** A tray, a stand, a figure base,
a cable clip — nothing to fit, so skip this phase and say nothing about it.

Run it **after the shape is agreed**, never before. The shape determines which
dimensions matter; asking first produces measurements of the wrong features.

Give the user a numbered list, and hold it to these three rules:

- **Each item names one dimension unambiguously.** "The distance from the left
  edge of the mounting face to the centre of the hole" — not "the hole
  position". If a view makes it clearer, say which of the rendered views to look
  at and where on it.
- **Ask for the raw measurement, never an adjusted one.** Clearance comes from
  the printer profile and is added by you. A user who helpfully adds slack
  themselves makes it double.
- **Ask only for what changes the geometry.** "Measure this too, just in case" is
  the most expensive line in the list, because measuring is the one part of this
  whole process nobody can automate.

Then substitute the values, rebuild, and show the result. If real numbers break
the shape — proportions that no longer work, a feature that no longer fits —
say so and re-agree the shape before moving on.

## Phase 3 — hand over to live preview

Tell the user to open `<model-name>/model.scad` in the OpenSCAD desktop
application. It reloads on file change, so every edit you make appears in their
window immediately, and they can rotate and zoom to judge it themselves.

From here:

- **Edit, do not re-render.** They are looking at the model. Producing your own
  renders duplicates what they can already see.
- **Absorb changes through the parameters at the top of the file.** By now they
  may have tuned values themselves; restructuring the geometry throws that work
  away. When a request genuinely cannot be met by a parameter change, say that
  the structure has to change before changing it.

## The generation contract

Every model file follows this shape. It is not style — Phase 3 and the section
view both break without it.

```scad
// Cable clip for a 6 mm cable, mounted on a desk edge.
// Print orientation: flat on the back face, no supports needed.
// Longest unsupported span: 8 mm bridge over the cable channel.

/* [Main] */
cable_diameter = 6;     // measured
wall            = 2.4;
clip_opening    = 4.5;  // less than cable_diameter, so it snaps
mount_length    = 25;

/* [Hidden] */
$fn = 64;

echo(min_wall = wall);

module main() {
    // ... geometry ...
}

main();
```

| Rule | Why |
|---|---|
| **Every dimension is a named parameter at the top.** No bare numbers inside the geometry, except structural constants like `2` in a halving. | Phase 3 is entirely parameter edits, by you and by the user. A hardcoded number is a dimension neither of you can reach. OpenSCAD's Customizer also picks up this layout, so the user gets sliders for free. |
| **Derive, do not restate.** An inner dimension is `outer - 2 * wall`, never its own literal. | Otherwise one parameter change silently desynchronises the model, and the break shows up as a bad print rather than a bad render. |
| **The geometry lives in `module main()`, called on the last line.** | The section view imports the file with `use <>`, which takes module definitions and ignores top-level geometry. Without `main()` the section renders nothing. |
| **`echo(min_wall = <the thinnest wall expression>);`** as an expression over the parameters, not a literal. | This is the only way the wall-thickness check can see the value. Omitting it fails that check by design, rather than passing it silently. |
| **A header comment stating the print orientation, whether supports are needed, and the longest unsupported span.** | Overhang is not checked mechanically (see below), so it has to be a stated design decision. Writing it down forces the decision to be made while the shape is still being chosen. |
| **Placeholder values carry a `// placeholder` or `// measured` comment.** | Phase 2 has to find them again, and so does the user. |

## What is checked, and what is not

`build.sh` checks five things, all cheaply and all reliably:

| Check | Fails when |
|---|---|
| `geometry_is_3d` | A 2D shape reached the top level un-extruded |
| `not_empty` | The booleans cancelled everything out — a very common way to render nothing |
| `fits_bed` | The bounding box exceeds the bed, in either XY orientation |
| `views_rendered` | A view produced no image. `views` lists only images that exist, and `views_missing` names the rest |
| `min_wall` | The echoed thinnest wall is under two nozzle widths, or was never echoed |

**Read only the views the report lists.** A view that failed to render is
reported as missing rather than omitted silently, so treat `views_missing` as a
build problem to fix — never assume an image is there because it usually is.

**Four things are deliberately not checked.** Do not claim them, and do not
imply them by silence:

- **Manifoldness.** OpenSCAD's summary reports `simple: true` even for geometry
  meeting at a single edge and for fully disjoint bodies, so that flag cannot
  carry the claim. In practice OpenSCAD's CSG primitives and booleans — what a
  model like this is built from — produce manifold output anyway.
- **Disjoint bodies.** A part that floats free of the rest is not detected.
  Catch it in the renders instead.
- **Overhang angles and support.** Not measured. This is why orientation and
  supports are a stated decision in the header comment.
- **Whether it prints.** No slicer is run: no print time, no filament estimate,
  no confirmation that a slicer accepts the file. Say so rather than implying
  the model is print-verified.

## Gotchas

- **Do not ask before the first render.** A rendered guess moves the
  conversation further than a question does, and the shape is one edit away for
  as long as everything is a parameter.
- **Do not measure early.** Measurements taken before the shape settles measure
  features that may not survive it. That ordering is the whole reason Phase 2
  sits where it does.
- **Do not restructure after Phase 3 begins.** By then the user has invested
  their own judgment in the parameter values; a rewrite discards it. If a
  restructure is genuinely needed, say so and get agreement first.
- **Do not treat a failed check as an error to report.** It is the loop working.
  Fix it and rebuild.
- **Do not print, and do not slice.** This skill ends at a `.scad` and an
  `.stl`. Handing those over is the finish line.
