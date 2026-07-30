---
name: 3d-print-eufymake-cli
description: >-
  Slices a model from the command line with eufyMake Studio's console build,
  then attributes its print warnings to the geometry that causes them by
  measuring the G-code — because the GUI's slice-time warning reaches the
  console only as an untranslated key with the detail stripped. Applies when a
  slicer warning has to be reproduced, traced back to a feature of the model,
  or confirmed gone after an edit, on eufyMake or AnkerMake printers.
allowed-tools: Read, Bash, Glob
metadata:
  description-role: trigger
---

# Slicing with the eufyMake Studio CLI

eufyMake Studio is a PrusaSlicer fork, so it carries the whole Slic3r
command-line interface. Its own banner says so:

```
eufyMake Studio-1.5.26 based on Slic3r (with GUI support)
https://github.com/prusa/AnkerStudio
```

That makes a slice reproducible from a shell — which is what turns a slicer
warning from something the user reports into something you can measure, bisect
against an edit, and prove gone.

**This never touches the printer.** Slicing writes G-code to disk; nothing is
uploaded and no print is started. There is no CLI action that would.

## The console build

On Windows the GUI executable swallows CLI actions. Only the `-console` build
writes results to the terminal:

```
%LOCALAPPDATA%\eufyMake Studio\eufymake studio-console.exe
```

`scripts/slice-check.sh` probes that path and a few others, and honours
`EUFYMAKE_STUDIO_CONSOLE` when the install is somewhere else.

## Running it from WSL

Two things always apply, and neither is optional:

- **The Bash sandbox blocks it.** Launching a Windows `.exe` needs the WSL
  interop socket, which the sandbox denies — the failure is
  `WSL (4 - ) ERROR: UtilConnectUnix:526: socket failed 1`. Re-run with
  `dangerouslyDisableSandbox: true`. Nothing else about the call needs widening.
- **Arguments need Windows paths.** Convert every path with `wslpath -w`; the
  script does this for you.

And one consequence to expect: launched from WSL, the slicer leaves its output
as `<out>.gcode.tmp` and never performs the final rename. Verified on every run.
The script renames it; a hand-written invocation must look for the `.tmp`.

## Configuration is the part that bites

The datadir is PrusaSlicer-shaped —
`%APPDATA%\eufyMake Studio Profile\{print,printer,filament,vendor}` — but you
cannot select a preset by name from the CLI, and:

- `printer/` and `filament/` are typically **empty**, because the printer's real
  settings are system presets inside `vendor/Anker.ini`.
- `--load vendor/Anker.ini` **fails**: `Error while reading config file […]:
  duplicate key name`. A vendor bundle holds many presets, and `--load` takes a
  flat config.

So do this once, in the GUI: **File → Export → Export Config**, and keep the
`.ini` next to the model (`build/eufymake-config.ini` is a good home). Pass it
with `--config`.

Without `--config` the slicer runs on its built-in defaults, which are not the
printer's profile. A comparison between two revisions of the same model still
holds — both sides are wrong the same way — but any absolute claim about print
time, filament, or whether *this printer* will bridge cleanly does not. Say
which of the two you did.

## What the console tells you, and what it withholds

The CLI does emit print warnings, as raw i18n keys:

```
print warning: common_slicepopup_stabilityissue
```

That key is `Detected print stability issues:\n%1%`
(「プリントの安定性に関する問題が検出されました」) — and **`%1%`, the line that
says which issue, is not printed**. The GUI fills it from these:

| Key suffix | GUI text | Japanese |
|---|---|---|
| `…stabilityissue1` | Floating object part | オブジェクトの浮いている部分 |
| `…stabilityissue2` | **Long bridging extrusions** | **長いブリッジの押し出し** |
| `…stabilityissue3` | Floating bridge anchors | 浮いているブリッジの支え |
| `…stabilityissue4` | Collapsing overhang | オーバーハングの崩壊 |
| `…stabilityissue5` | Loose extrusions | 緩い押し出し |
| `…stabilityissue6` | Low bed adhesion | ベッドの粘着力低下 |
| `…stabilityissue7` | Thin and fragile part | 薄くてもろい部分 |
| `…stabilityissue8` | Consider enabling supports. | サポートの有効化を検討してください。 |

(From `resources/localization/{en,ja}/eufyMake Studio_*.po` in the install —
grep that file when a key appears that is not in this table.)

So the console answers *whether* the model warns; the G-code answers *which*
issue and *where*. You need both.

## Measuring the toolpaths

```bash
scripts/slice-check.sh model.stl --rotate-x -90 --config build/eufymake-config.ini
```

- `--rotate-x / --rotate-y / --rotate` must reproduce the orientation the user
  actually prints in. `--dont-arrange` is passed, and `--ensure-on-bed` is on by
  default, so a rotated part is dropped onto the bed exactly as the GUI does it.
- Every extruding move inside a `;TYPE:Bridge infill` region is measured — that
  length is the span the nozzle crosses unsupported — and `;TYPE:Overhang
  perimeter` is totalled alongside it.
- Exit 1 when a bridge exceeds `--max-bridge` (default 10 mm). That threshold is
  a working heuristic for "longer than anything a small part should need to
  bridge", not the slicer's own trigger, which is not exposed.

A real before/after, on an under-keyboard mount printed rear-face-down, where a
square front lip presented a 141 mm horizontal face in the build direction:

```
before                                  after (lip ramped to 45 deg)
"bridge_longest_mm": 143.0              "bridge_longest_mm": 4.4
"bridge_longest_at_z": "119.45"         "bridge_longest_at_z": "23.15"
"bridge_length_total_mm": 992.4         "bridge_length_total_mm": 276.7
"overhang_perimeter_total_mm": 486.3    "overhang_perimeter_total_mm": 62.6
"over_threshold": 5                     "over_threshold": 0
print warning: common_slice…issue       (no warning line)
```

The 4.4 mm that remains is a 3 mm strap slot closing over itself, plus one
extrusion width — a bridge the design intends.

## Attributing a long bridge to the model

`bridge_longest_at_z` is the whole diagnosis. Take that Z back to the model:

- **One bridge nearly as wide as the part, at a single Z** is a flat face that
  closes in the build direction — a square step, an un-tapered window end, a
  lid over a cavity. Fix it in the model (taper the face to 45°), not in the
  slicer.
- **Many short bridges spread over many Z values** are holes and slots closing.
  Normal.
- **A bridge where you expected none** usually means the print orientation you
  passed is not the one the model was designed for. Check the `.scad` header
  before touching the geometry.

For OpenSCAD models, the geometric counterpart of this check — reading downward
face normals straight off the mesh, with no slicer involved — belongs to the
`3d-print` skill's own build report. Use that while iterating on the shape, and
this skill to confirm against the real slicer once the shape is settled.

## What this does not do

- **It does not print, upload, or talk to the printer.**
- **It does not reproduce the GUI's notification text**, only the key. Anything
  more specific has to come from the G-code.
- **It does not check supports, adhesion, or the other stability issues.** Only
  bridges and overhang perimeters are measured. A `stabilityissue` warning with
  no long bridge in the report means one of the other seven, and identifying it
  needs the GUI.
- **It does not validate the printer profile.** With `--config` it trusts the
  exported `.ini`; without one it silently uses defaults.
