#!/usr/bin/env bash
# init.sh — scaffold a skill-optimize run's state.json and directories.
set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || die "jq is required but not found"

RUN_DIR=""; SKILL=""; TRAIN=""; HOLDOUT=""; SIGNAL_KIND=""; SIGNAL_CMD=""; MAXIT=8; FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --run-dir)        RUN_DIR="$2"; shift 2;;
    --skill)          SKILL="$2"; shift 2;;
    --train)          TRAIN="$2"; shift 2;;
    --holdout)        HOLDOUT="$2"; shift 2;;
    --signal-kind)    SIGNAL_KIND="$2"; shift 2;;
    --signal-cmd)     SIGNAL_CMD="$2"; shift 2;;
    --max-iterations) MAXIT="$2"; shift 2;;
    --force)          FORCE=1; shift;;
    *) die "unknown arg: $1";;
  esac
done

[ -n "$RUN_DIR" ] || die "--run-dir required"
[ -n "$SKILL" ]   || die "--skill required"
[ -n "$TRAIN" ]   || die "--train required (comma-separated task ids)"
[ -n "$HOLDOUT" ] || die "--holdout required (comma-separated task ids)"
case "$SIGNAL_KIND" in oracle|anchor|self-criteria) ;; *) die "--signal-kind must be oracle|anchor|self-criteria";; esac
case "$MAXIT" in ''|*[!0-9]*) die "--max-iterations must be a positive integer";; esac

STATE="$RUN_DIR/state.json"
if [ -e "$STATE" ] && [ "$FORCE" -ne 1 ]; then
  die "$STATE exists (use --force to overwrite)"
fi
mkdir -p "$RUN_DIR/versions" "$RUN_DIR/traces" "$RUN_DIR/evals"

to_json_array() { printf '%s' "$1" | jq -R 'split(",") | map(gsub("^\\s+|\\s+$";"")) | map(select(length>0))'; }
TRAIN_J=$(to_json_array "$TRAIN")
HOLD_J=$(to_json_array "$HOLDOUT")

if [ -z "$SIGNAL_CMD" ]; then SIGCMD_J=null; else SIGCMD_J=$(printf '%s' "$SIGNAL_CMD" | jq -R .); fi

jq -n \
  --arg    skill  "$SKILL" \
  --arg    kind   "$SIGNAL_KIND" \
  --argjson sigcmd "$SIGCMD_J" \
  --argjson train  "$TRAIN_J" \
  --argjson hold   "$HOLD_J" \
  --argjson maxit  "$MAXIT" \
  '{
    target_skill: $skill,
    signal: {kind: $kind, command: $sigcmd},
    tasks: {train: $train, holdout: $hold},
    budget: {max_iterations: $maxit, iteration: 0, no_improve_streak: 0, no_improve_limit: 2},
    current: "v0",
    best: {version: "v0", holdout_score: null},
    scores: {v0: {train: null, holdout: null}},
    history: [],
    status: "init"
  }' > "$STATE.tmp"
mv "$STATE.tmp" "$STATE"

echo "initialized $STATE (train=$(echo "$TRAIN_J" | jq length), holdout=$(echo "$HOLD_J" | jq length))" >&2
echo "next: copy the target skill into $RUN_DIR/versions/v0/, then evaluate v0" >&2
cat "$STATE"
