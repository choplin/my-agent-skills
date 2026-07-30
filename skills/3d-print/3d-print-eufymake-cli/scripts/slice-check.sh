#!/usr/bin/env bash
#
# Slice an STL with eufyMake Studio's console build and report what the G-code
# says about bridges and overhangs.
#
# The GUI's slice-time notifications (long bridging extrusion, supports needed)
# are not written to the console, so this reads the toolpaths instead: every
# extruding move inside a ";TYPE:Bridge infill" region is measured, and the
# longest ones are reported with the layer height they sit at. That is the same
# evidence the GUI warning is derived from, and it is comparable between two
# revisions of a model.
#
# Usage: slice-check.sh <model.stl> [options]
#   --rotate-x DEG    rotate about X before slicing, as the GUI would (e.g. -90)
#   --rotate-y DEG    rotate about Y before slicing
#   --rotate DEG      rotate about Z before slicing
#   --config FILE     config .ini exported from the GUI (File > Export > Export
#                     Config). Without it the slicer's built-in defaults are
#                     used, which are NOT the printer's profile
#   --max-bridge MM   flag bridges longer than this (default 10)
#   --outdir DIR      where to write the G-code (default <model dir>/build/slice)
#   --keep            keep the G-code (default: keep; kept for symmetry)
#
# Prints one JSON report and exits 1 when a bridge exceeds --max-bridge.
set -uo pipefail

die() {
  echo "3d-print-eufymake-cli: $*" >&2
  exit 2
}

MODEL=""
ROT_X=""
ROT_Y=""
ROT_Z=""
CONFIG=""
MAX_BRIDGE=10
OUTDIR=""

while [ $# -gt 0 ]; do
  case "$1" in
  --rotate-x) ROT_X="$2" && shift 2 ;;
  --rotate-y) ROT_Y="$2" && shift 2 ;;
  --rotate) ROT_Z="$2" && shift 2 ;;
  --config) CONFIG="$2" && shift 2 ;;
  --max-bridge) MAX_BRIDGE="$2" && shift 2 ;;
  --outdir) OUTDIR="$2" && shift 2 ;;
  --keep) shift ;;
  -*) die "unknown option: $1" ;;
  *) MODEL="$1" && shift ;;
  esac
done

[ -n "$MODEL" ] || die "usage: slice-check.sh <model.stl> [--rotate-x DEG] [--config FILE]"
[ -f "$MODEL" ] || die "model not found: $MODEL"

# --- locate the console build -------------------------------------------------
# The GUI executable ignores CLI actions on Windows; only the -console build
# writes results to the terminal.
CONSOLE="${EUFYMAKE_STUDIO_CONSOLE:-}"
if [ -z "$CONSOLE" ]; then
  for c in \
    "$HOME/AppData/Local/eufyMake Studio/eufymake studio-console.exe" \
    "/mnt/c/Users/$USER/AppData/Local/eufyMake Studio/eufymake studio-console.exe" \
    "/mnt/c/Program Files/eufyMake Studio/eufymake studio-console.exe" \
    "/Applications/eufyMake Studio.app/Contents/MacOS/eufyMake Studio"; do
    [ -x "$c" ] && CONSOLE="$c" && break
  done
fi
[ -n "$CONSOLE" ] || die "eufyMake Studio console build not found — set EUFYMAKE_STUDIO_CONSOLE to its path"

# --- paths --------------------------------------------------------------------
# A Windows executable reached from WSL needs Windows paths for its arguments.
topath() {
  if command -v wslpath >/dev/null 2>&1 && case "$CONSOLE" in *.exe) true ;; *) false ;; esac; then
    wslpath -w "$1"
  else
    printf '%s' "$1"
  fi
}

MODEL_DIR="$(cd "$(dirname "$MODEL")" && pwd)"
BASE="$(basename "${MODEL%.*}")"
OUTDIR="${OUTDIR:-$MODEL_DIR/build/slice}"
mkdir -p "$OUTDIR" || die "cannot create $OUTDIR"
GCODE="$OUTDIR/$BASE.gcode"
LOG="$OUTDIR/$BASE.slicer.log"

ARGS=(--slice --loglevel 2 --dont-arrange)
[ -n "$ROT_X" ] && ARGS+=(--rotate-x "$ROT_X")
[ -n "$ROT_Y" ] && ARGS+=(--rotate-y "$ROT_Y")
[ -n "$ROT_Z" ] && ARGS+=(--rotate "$ROT_Z")
if [ -n "$CONFIG" ]; then
  [ -f "$CONFIG" ] || die "config not found: $CONFIG"
  ARGS+=(--load "$(topath "$(cd "$(dirname "$CONFIG")" && pwd)/$(basename "$CONFIG")")")
fi
ARGS+=(-o "$(topath "$GCODE")" "$(topath "$MODEL_DIR/$(basename "$MODEL")")")

"$CONSOLE" "${ARGS[@]}" >"$LOG" 2>&1
# The slicer writes <out>.tmp and renames it; the rename does not always survive
# a WSL-mounted target, so accept either name.
[ -f "$GCODE" ] || { [ -f "$GCODE.tmp" ] && mv "$GCODE.tmp" "$GCODE"; }
[ -f "$GCODE" ] || die "slicing produced no G-code — read $LOG"

# --- measure ------------------------------------------------------------------
# Bridge infill is extruded as straight moves; the length of one such move is
# the span the nozzle crosses unsupported.
awk -v maxb="$MAX_BRIDGE" -v gcode="$GCODE" -v logpath="$LOG" '
function abs(v) { return v < 0 ? -v : v }
/^;Z:/            { z = substr($0, 4) }
/^;TYPE:/         { type = substr($0, 7) }
/^G1 /            {
    e = ""; nx = x; ny = y
    for (i = 2; i <= NF; i++) {
        p = substr($i, 1, 1); v = substr($i, 2) + 0
        if (p == "X") nx = v
        else if (p == "Y") ny = v
        else if (p == "E") e = v
    }
    if (e != "" && e > 0 && (nx != x || ny != y)) {
        len = sqrt((nx - x) ^ 2 + (ny - y) ^ 2)
        if (type == "Bridge infill") {
            bn++; btot += len
            if (len > bmax) { bmax = len; bmaxz = z }
            if (len > maxb) { over++; if (len > 0) overlen[over] = len; overz[over] = z }
        } else if (type == "Overhang perimeter") {
            on++; ototal += len
        }
    }
    x = nx; y = ny
}
END {
    printf "{\n  \"gcode\": \"%s\",\n  \"log\": \"%s\",\n", gcode, logpath
    printf "  \"bridge_moves\": %d,\n  \"bridge_length_total_mm\": %.1f,\n", bn, btot
    printf "  \"bridge_longest_mm\": %.1f,\n  \"bridge_longest_at_z\": \"%s\",\n", bmax, bmaxz
    printf "  \"overhang_perimeter_moves\": %d,\n  \"overhang_perimeter_total_mm\": %.1f,\n", on, ototal
    printf "  \"max_bridge_mm\": %s,\n  \"over_threshold\": %d,\n", maxb, over + 0
    printf "  \"ok\": %s\n}\n", (over + 0 == 0 ? "true" : "false")
    exit (over + 0 == 0 ? 0 : 1)
}
' "$GCODE"
