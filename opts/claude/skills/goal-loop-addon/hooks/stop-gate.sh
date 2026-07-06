#!/usr/bin/env bash
# Stop hook: remind that a goal-loop goal is still running (shell + jq).
#
# Blocks the stop when the active goal's status is `running` — at most twice in a
# row for the same goal, then yields. This is a reminder, not a loop engine. Any
# failure allows the stop (best-effort).

MAX_BLOCKS=2

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_common.sh"

allow() { exit 0; }

command -v jq >/dev/null 2>&1 || allow
gd=$(active_goal_dir) || allow
[ -n "$gd" ] || allow
sp="$gd/state.json"
[ -f "$sp" ] || allow

status=$(jq -r '.status // "running"' "$sp")
[ "$status" = "running" ] || allow

counter="$gd/.stop-gate"
count=0
[ -f "$counter" ] && count=$(jq -r '.count // 0' "$counter" 2>/dev/null || echo 0)

if [ "$count" -ge "$MAX_BLOCKS" ]; then
  rm -f "$counter"
  allow
fi

printf '{"count": %s}\n' "$((count + 1))" > "$counter" 2>/dev/null || true

total=$(jq -r '.predicates | length' "$sp")
passed=$(jq -r '[.predicates[] | select(.passes)] | length' "$sp")
name=$(basename "$gd")
reason="goal-loop goal '${name}' is still running (${passed}/${total} predicates pass). Run the next builder -> verify round (or loop.sh) to converge, or stop again to override and hand it back."

jq -nc --arg r "$reason" '{decision: "block", reason: $r}'
exit 0
