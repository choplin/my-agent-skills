#!/usr/bin/env bash
# build.sh — render, export, and mechanically check one OpenSCAD model.
#
# Runs OpenSCAD once for geometry (STL + summary JSON + echoed parameters), then
# once per view for the PNGs the agent reads. Applies the printer profile's
# thresholds and prints a single JSON report on stdout.
#
# The model file must follow the generation contract in SKILL.md:
#   - every dimension is a named parameter at the top of the file
#   - the geometry lives in `module main()`, which is called on the last line
#   - the smallest wall/feature thickness is reported with `echo(min_wall = <expr>);`
# `main()` is required because the section view imports the model with `use <>`,
# which takes module definitions only and ignores top-level geometry.
#
# Dependencies: bash + jq + openscad. OpenSCAD is expected to be installed the
# ordinary way for the platform — the skill needs the desktop application for
# its live-preview phase regardless, so a CLI-only provisioning path would not
# cover the skill anyway.
#
# Usage: build.sh <model.scad> [--profile <printer.json>]
#
# Output: JSON report on stdout. Exit 0 when every check passed, 1 when any
# check failed, 2 on usage/environment errors. A failed check is a normal
# outcome that the agent acts on — read the report either way.

set -uo pipefail

die() {
  printf '3d-print: %s\n' "$1" >&2
  exit 2
}

missing=()
command -v openscad >/dev/null 2>&1 || missing+=("openscad")
command -v jq >/dev/null 2>&1 || missing+=("jq")
if [ "${#missing[@]}" -gt 0 ]; then
  cat >&2 <<EOF
3d-print: required tools not found: ${missing[*]}
Install them, then re-run:
  macOS   -> brew install --cask openscad ; brew install jq
  Debian  -> apt-get install openscad jq
  Fedora  -> dnf install openscad jq
The OpenSCAD desktop application is wanted rather than a CLI-only build: the
skill's live-preview phase needs the GUI.
EOF
  exit 2
fi

MODEL=""
PROFILE="${XDG_CONFIG_HOME:-$HOME/.config}/3d-print/printer.json"
while [ $# -gt 0 ]; do
  case "$1" in
  --profile)
    [ $# -ge 2 ] || die "--profile needs a path"
    PROFILE="$2"
    shift 2
    ;;
  -*) die "unknown option: $1" ;;
  *)
    [ -z "$MODEL" ] || die "only one model file may be given"
    MODEL="$1"
    shift
    ;;
  esac
done

[ -n "$MODEL" ] || die "usage: build.sh <model.scad> [--profile <printer.json>]"
[ -f "$MODEL" ] || die "no such file: $MODEL"
[ -f "$PROFILE" ] || die "printer profile not found: $PROFILE (create it first — see SKILL.md)"

MODEL="$(cd "$(dirname "$MODEL")" && pwd)/$(basename "$MODEL")"
MODEL_DIR="$(dirname "$MODEL")"
STEM="$(basename "$MODEL" .scad)"
BUILD="$MODEL_DIR/build"
mkdir -p "$BUILD" || die "cannot create $BUILD"

NOZZLE="$(jq -r '.nozzle_diameter // empty' "$PROFILE")"
BED_X="$(jq -r '.bed.x // empty' "$PROFILE")"
BED_Y="$(jq -r '.bed.y // empty' "$PROFILE")"
BED_Z="$(jq -r '.bed.z // empty' "$PROFILE")"
for v in NOZZLE BED_X BED_Y BED_Z; do
  [ -n "${!v}" ] || die "printer profile is missing a required field (nozzle_diameter, bed.x/y/z): $PROFILE"
done

# --- geometry pass: STL + summary JSON + echoed parameters -------------------

STL="$MODEL_DIR/$STEM.stl"
SUMMARY="$BUILD/summary.json"
LOG="$BUILD/openscad.log"
rm -f "$SUMMARY" "$STL"

openscad -o "$STL" --export-format binstl \
  --summary all --summary-file "$SUMMARY" \
  "$MODEL" >"$LOG" 2>&1
GEOM_EXIT=$?

# OpenSCAD writes no summary and exits non-zero when the top-level object is
# empty, so an absent summary is the "nothing was produced" signal.
if [ "$GEOM_EXIT" -ne 0 ] || [ ! -f "$SUMMARY" ]; then
  jq -n \
    --arg model "$MODEL" \
    --arg log "$LOG" \
    --arg output "$(tr -d '\r' <"$LOG" | tail -20)" \
    '{model: $model, ok: false, fatal: "openscad produced no geometry",
      log: $log, output: $output, checks: [], views: []}'
  exit 1
fi

# `ECHO: name = value` lines -> a JSON object. One value per echo() statement.
ECHOES="$(
  grep '^ECHO: ' "$LOG" 2>/dev/null |
    sed 's/^ECHO: //' |
    jq -R -s '
      split("\n")
      | map(capture("^(?<k>[A-Za-z_][A-Za-z0-9_]*) *= *(?<v>.+)$") // empty)
      | map({key: .k, value: (.v | tonumber? // .)})
      | from_entries'
)"
[ -n "$ECHOES" ] || ECHOES='{}'

# --- view pass: the images the agent reads -----------------------------------

read -r MIN_X MIN_Y MIN_Z SIZE_X SIZE_Y SIZE_Z <<<"$(
  jq -r '.geometry.bounding_box | (.min + .size) | @tsv' "$SUMMARY" | tr '\t' ' '
)"

CUT="$BUILD/section.scad"
# Half-space cut through the middle of Y: the most readable single section.
awk -v m="$MODEL" -v x="$MIN_X" -v y="$MIN_Y" -v z="$MIN_Z" \
  -v sx="$SIZE_X" -v sy="$SIZE_Y" -v sz="$SIZE_Z" '
  BEGIN {
    printf "use <%s>\n", m
    printf "difference() {\n  main();\n"
    printf "  translate([%g, %g, %g]) cube([%g, %g, %g]);\n", x-1, y+sy/2, z-1, sx+2, sy/2+2, sz+2
    printf "}\n"
  }' >"$CUT"

# --view=edges is not cosmetic. Without it an orthographic view of a boxy part
# renders as one flat silhouette with no internal lines, which says nothing
# about wall thickness or feature placement; with it, every face boundary is
# drawn and the view becomes readable.
#
# `--render` is emitted first, before every other option, and never from the
# caller's argument list. Its argument is optional, so if it lands immediately
# before the positional .scad path it consumes that path as its own value and
# the whole run dies with a usage message and no PNG. Caller-supplied options
# are all `--flag=value` form and cannot swallow the path the same way.
render() { # render <name> <file> <full|preview> [--flag=value ...]
  local name="$1" file="$2" mode="$3"
  shift 3
  local mode_args=()
  [ "$mode" = full ] && mode_args=(--render)
  openscad ${mode_args[@]+"${mode_args[@]}"} \
    -o "$BUILD/$name.png" --imgsize=900,700 --colorscheme=Tomorrow \
    --viewall --autocenter --view=edges "$@" "$file" >>"$LOG" 2>&1
}

render iso "$MODEL" full
render front "$MODEL" full --projection=o --camera=0,0,0,90,0,0,0
render right "$MODEL" full --projection=o --camera=0,0,0,90,0,90,0
render top "$MODEL" full --projection=o --camera=0,0,0,0,0,0,0
# The section stays in preview mode on purpose: cut-open faces render in a
# contrasting colour there, which is what makes the interior readable. It is
# shot from the default isometric angle rather than square-on at the cut plane
# — square-on, the cavity behind the cut renders in that same contrasting
# colour and the section stops being distinguishable from what lies behind it.
render section "$CUT" preview

# A view that failed to render must never be reported as available: the report
# is the only thing standing between a silently missing image and an agent that
# believes it looked at one.
VIEW_NAMES=(iso front right top section)
MISSING_VIEWS=()
for v in "${VIEW_NAMES[@]}"; do
  [ -s "$BUILD/$v.png" ] || MISSING_VIEWS+=("$v")
done

# --- checks ------------------------------------------------------------------

REPORT="$(
  jq -n \
    --arg model "$MODEL" \
    --arg stl "$STL" \
    --arg build "$BUILD" \
    --argjson summary "$(cat "$SUMMARY")" \
    --argjson echoes "$ECHOES" \
    --argjson missing "$(printf '%s\n' ${MISSING_VIEWS[@]+"${MISSING_VIEWS[@]}"} | jq -R -s 'split("\n") | map(select(. != ""))')" \
    --argjson views "$(printf '%s\n' "${VIEW_NAMES[@]}" | jq -R -s 'split("\n") | map(select(. != ""))')" \
    --argjson nozzle "$NOZZLE" \
    --argjson bedx "$BED_X" --argjson bedy "$BED_Y" --argjson bedz "$BED_Z" '
    ($summary.geometry) as $g
    | ($g.bounding_box.size) as $s
    | ($nozzle * 2) as $min_wall_allowed
    | [
        {
          name: "geometry_is_3d",
          ok: ($g.dimensions == 3),
          detail: "dimensions = \($g.dimensions)",
          hint: "a 2D result means a 2D shape reached the top level un-extruded"
        },
        {
          name: "not_empty",
          ok: (($g.facets // 0) > 0),
          detail: "facets = \($g.facets // 0)",
          hint: "the booleans cancelled everything out"
        },
        {
          name: "fits_bed",
          ok: ((($s[0] <= $bedx and $s[1] <= $bedy)
                or ($s[0] <= $bedy and $s[1] <= $bedx))
               and $s[2] <= $bedz),
          detail: "model \($s[0])x\($s[1])x\($s[2]) mm vs bed \($bedx)x\($bedy)x\($bedz) mm",
          hint: "scale it down, or split it into parts printed separately"
        }
      ]
      + [
          {
            name: "views_rendered",
            ok: (($missing | length) == 0),
            detail: (if ($missing | length) == 0 then "all \($views | length) views rendered"
                     else "no image produced for: \($missing | join(", "))" end),
            hint: "read build/openscad.log — a failed view is an openscad invocation problem, not a model problem"
          }
        ]
      + (if ($echoes.min_wall | type) == "number" then
          [{
            name: "min_wall",
            ok: ($echoes.min_wall >= $min_wall_allowed),
            detail: "min_wall = \($echoes.min_wall) mm, needs >= \($min_wall_allowed) mm (nozzle x 2)",
            hint: "thin walls print as gaps — raise the parameter"
          }]
        else
          [{
            name: "min_wall",
            ok: false,
            detail: "the model did not echo min_wall",
            hint: "add echo(min_wall = <the thinnest wall expression>); so this can be checked"
          }]
        end)
    | {
        model: $model,
        stl: $stl,
        ok: (map(.ok) | all),
        bounding_box_mm: $s,
        parameters: $echoes,
        checks: .,
        views: ($views - $missing | map({name: ., path: "\($build)/\(.).png"})),
        views_missing: $missing
      }'
)" || die "failed to build the report"

printf '%s\n' "$REPORT"
jq -e '.ok' >/dev/null <<<"$REPORT" || exit 1
exit 0
