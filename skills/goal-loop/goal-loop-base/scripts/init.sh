#!/usr/bin/env bash
# init.sh — scaffold a Default-FAIL state.json for a goal loop (shell + jq).
#
# Writing state.json from a script (not by hand, and not via the agent's
# Write/Edit tool) is what guarantees the Default-FAIL contract from the start:
# every predicate begins passes:false, and only verify.sh may ever flip it true.
# It also avoids the bootstrap trap where a PreToolUse guard that denies edits to
# state.json would otherwise block the very first creation.
#
# Usage:
#   init.sh --goal-dir DIR --predicate id::command [--predicate id::command ...]
#           [--max-iterations N] [--force]
set -uo pipefail

MAX_ITER=20
FORCE=0
GOAL_DIR=""
preds=()

die() { printf 'init.sh: %s\n' "$1" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || die "jq is required but not found on PATH"

while [ $# -gt 0 ]; do
  case "$1" in
    --goal-dir) GOAL_DIR="${2:?--goal-dir needs a value}"; shift 2;;
    --predicate) preds+=("${2:?--predicate needs id::command}"); shift 2;;
    --max-iterations) MAX_ITER="${2:?--max-iterations needs a value}"; shift 2;;
    --force) FORCE=1; shift;;
    *) die "unknown argument: $1";;
  esac
done

[ -n "$GOAL_DIR" ] || die "usage: init.sh --goal-dir DIR --predicate id::command [...]"
[ "${#preds[@]}" -gt 0 ] || die "at least one --predicate id::command is required"

mkdir -p "$GOAL_DIR"
STATE="$GOAL_DIR/state.json"
if [ -f "$STATE" ] && [ "$FORCE" -ne 1 ]; then
  die "state.json already exists at $STATE (use --force to overwrite)"
fi

arr='[]'
for p in "${preds[@]}"; do
  case "$p" in
    *::*) : ;;
    *) die "--predicate must be in id::command form, got: $p";;
  esac
  id="${p%%::*}"
  cmd="${p#*::}"
  [ -n "$id" ] && [ -n "$cmd" ] || die "--predicate needs non-empty id and command"
  arr=$(printf '%s' "$arr" | jq --arg id "$id" --arg cmd "$cmd" \
    '. += [{id: $id, command: $cmd, passes: false, evidence: null, consecutive_failures: 0}]')
done

jq -n --argjson preds "$arr" --argjson max "$MAX_ITER" '{
  status: "running",
  iteration: 0,
  max_iterations: $max,
  predicates: $preds,
  blocked_reason: null
}' > "$STATE" || die "could not write $STATE"

printf 'initialized %s\n' "$STATE"
