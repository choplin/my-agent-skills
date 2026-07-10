#!/usr/bin/env bash
# record.sh — record a version's pass/fail results on a split and compute its score.
set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || die "jq is required but not found"

RUN_DIR="${1:-}"; [ -n "$RUN_DIR" ] || die "usage: record.sh <run-dir> --version vN --split train|holdout --results 't1::pass,t2::fail'"
shift
VERSION=""; SPLIT=""; RESULTS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --version) VERSION="$2"; shift 2;;
    --split)   SPLIT="$2"; shift 2;;
    --results) RESULTS="$2"; shift 2;;
    *) die "unknown arg: $1";;
  esac
done

STATE="$RUN_DIR/state.json"
[ -f "$STATE" ] || die "no state.json in $RUN_DIR (run init.sh first)"
[ -n "$VERSION" ] || die "--version required"
case "$SPLIT" in train|holdout) ;; *) die "--split must be train|holdout";; esac
[ -n "$RESULTS" ] || die "--results required (e.g. t1::pass,t2::fail)"

RESULTS_J=$(printf '%s' "$RESULTS" | jq -R '
  split(",") | map(gsub("^\\s+|\\s+$";"")) | map(select(length>0))
  | map(split("::") | {key: .[0], value: (.[1] // "fail")})
  | from_entries')

echo "$RESULTS_J" | jq -e 'length > 0 and all(.[]; . == "pass" or . == "fail")' >/dev/null \
  || die "results must be non-empty and every value must be pass|fail"

DECLARED=$(jq --arg s "$SPLIT" '.tasks[$s]' "$STATE")
MISMATCH=$(jq -n --argjson got "$RESULTS_J" --argjson decl "$DECLARED" \
  '(($got|keys) - $decl) + ($decl - ($got|keys)) | length')
[ "$MISMATCH" = "0" ] || echo "warning: recorded tasks differ from declared $SPLIT split" >&2

SCORE=$(echo "$RESULTS_J" | jq 'to_entries | (map(select(.value=="pass"))|length) as $p | ($p / length)')

tmp="$STATE.tmp"
jq --arg v "$VERSION" --arg s "$SPLIT" --argjson score "$SCORE" --argjson results "$RESULTS_J" '
  .scores[$v] = (.scores[$v] // {train: null, holdout: null})
  | .scores[$v][$s] = $score
  | .scores[$v][($s + "_detail")] = $results
' "$STATE" > "$tmp"
mv "$tmp" "$STATE"

echo "recorded $VERSION $SPLIT score=$SCORE" >&2
jq --arg v "$VERSION" '.scores[$v]' "$STATE"
