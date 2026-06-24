#!/usr/bin/env bash
# SessionStart hook: inject the active goal-loop goal's state, if any (shell + jq).
#
# Best-effort: if there is no active goal, or anything fails, emit nothing and
# exit 0 so session start is never disrupted.

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

command -v jq >/dev/null 2>&1 || exit 0
gd=$(active_goal_dir) || exit 0
[ -n "$gd" ] || exit 0
sp="$gd/state.json"
[ -f "$sp" ] || exit 0

name=$(basename "$gd")
status=$(jq -r '.status // "running"' "$sp")
iteration=$(jq -r '.iteration // 0' "$sp")
total=$(jq -r '.predicates | length' "$sp")
passed=$(jq -r '[.predicates[] | select(.passes)] | length' "$sp")

ctx="Active goal-loop goal: ${name} (status=${status}, iteration=${iteration}). Predicates passing: ${passed}/${total}."
if [ "$status" = "running" ]; then
  ctx="${ctx} Resume with the goal-loop skill: run the next builder -> verify round (or loop.sh against the goal dir). Do not edit state.json directly — verify.sh owns it."
fi

jq -nc --arg c "$ctx" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $c
  }
}'
exit 0
