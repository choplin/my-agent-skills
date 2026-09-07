#!/usr/bin/env bash
# gate.sh — the sole writer of accept/reject decisions.
#   Set the v0 baseline, then accept a candidate iff it strictly beats the best
#   recorded held-out score (ties rejected). Advances the budget and status.
set -euo pipefail

die() { echo "error: $*" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || die "jq is required but not found"

RUN_DIR="${1:-}"; [ -n "$RUN_DIR" ] || die "usage: gate.sh <run-dir> (--set-baseline | --candidate vN [--reason TEXT])"
shift
CAND=""; REASON=""; SETBASE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --candidate)    CAND="$2"; shift 2;;
    --reason)       REASON="$2"; shift 2;;
    --set-baseline) SETBASE=1; shift;;
    *) die "unknown arg: $1";;
  esac
done

STATE="$RUN_DIR/state.json"
[ -f "$STATE" ] || die "no state.json in $RUN_DIR"
tmp="$STATE.tmp"

split_complete() {
  jq -e --arg v "$1" --arg s "$2" '
    (.tasks[$s] // []) as $declared
    | (.scores[$v] // {}) as $score
    | ($score[($s + "_detail")] // null) as $detail
    | if ($detail | type) != "object" or ($declared | length) == 0 then false
      else
        ($score[$s] | type) == "number"
        and (($detail | keys | sort) == ($declared | sort))
        and all($detail[]; . == "pass" or . == "fail")
        and ($score[$s] == ([$detail[] | select(. == "pass")] | length) / ($detail | length))
      end
  ' "$STATE" >/dev/null
}

if [ "$SETBASE" -eq 1 ]; then
  split_complete v0 train || die "v0 train results are missing or incomplete"
  split_complete v0 holdout || die "v0 holdout results are missing or incomplete"
  V0H=$(jq -r '.scores.v0.holdout' "$STATE")
  jq '.best = {version: "v0", holdout_score: .scores.v0.holdout} | .status = "running"' "$STATE" > "$tmp"
  mv "$tmp" "$STATE"
  echo "baseline set: v0 holdout=$V0H" >&2
  jq '{best, status}' "$STATE"
  exit 0
fi

[ -n "$CAND" ] || die "--candidate required (or use --set-baseline)"

BEST_H=$(jq -r '.best.holdout_score' "$STATE")
[ "$BEST_H" != "null" ] || die "baseline not set — run: gate.sh $RUN_DIR --set-baseline"
split_complete "$CAND" train || die "candidate $CAND train results are missing or incomplete"
split_complete "$CAND" holdout || die "candidate $CAND holdout results are missing or incomplete"
CAND_H=$(jq -r --arg v "$CAND" '.scores[$v].holdout' "$STATE")

jq --arg cand "$CAND" --arg reason "$REASON" '
  .budget.iteration += 1
  | (.scores[$cand].holdout) as $ch
  | (.best.holdout_score) as $bh
  | (.scores[$cand].train) as $ct
  | if $ch > $bh then
      .current = $cand
      | .best = {version: $cand, holdout_score: $ch}
      | .budget.no_improve_streak = 0
      | .history += [{iteration: .budget.iteration, candidate: $cand, train: $ct, holdout: $ch, accepted: true,
                      reason: (if $reason == "" then "holdout improved" else $reason end)}]
    else
      .budget.no_improve_streak += 1
      | .history += [{iteration: .budget.iteration, candidate: $cand, train: $ct, holdout: $ch, accepted: false,
                      reason: (if $reason == "" then "no holdout improvement (ties rejected)" else $reason end)}]
    end
  | .status = (
      if .budget.iteration >= .budget.max_iterations then "blocked"
      elif .budget.no_improve_streak >= .budget.no_improve_limit then "converged"
      else "running" end)
' "$STATE" > "$tmp"
mv "$tmp" "$STATE"

ACCEPTED=$(jq -r '.history[-1].accepted' "$STATE")
STATUS=$(jq -r '.status' "$STATE")
CURRENT=$(jq -r '.current' "$STATE")
echo "gate: candidate=$CAND holdout=$CAND_H best=$BEST_H accepted=$ACCEPTED -> current=$CURRENT status=$STATUS" >&2
jq '{current, best, budget, status, last: .history[-1]}' "$STATE"
