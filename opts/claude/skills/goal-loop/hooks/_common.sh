#!/usr/bin/env bash
# Shared helpers for goal-loop hooks (shell + jq).
#
# All goal-loop hooks are best-effort: any failure must end with the session/turn
# proceeding normally. Goals live under "$CLAUDE_PROJECT_DIR/.agents/goals/"; the
# "active" goal is the most recently touched one whose status is "running".

goal_root() {
  printf '%s/.agents/goals' "${CLAUDE_PROJECT_DIR:-$PWD}"
}

# Portable mtime (BSD/macOS `stat -f %m`, GNU/Linux `stat -c %Y`).
_mtime() {
  stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0
}

# Print the goal dir of the most recent running goal, or nothing.
active_goal_dir() {
  command -v jq >/dev/null 2>&1 || return 1
  root=$(goal_root)
  [ -d "$root" ] || return 1
  newest=""
  newest_mt=-1
  for sp in "$root"/*/state.json; do
    [ -f "$sp" ] || continue
    st=$(jq -r '.status // empty' "$sp" 2>/dev/null) || continue
    [ "$st" = "running" ] || continue
    mt=$(_mtime "$sp")
    if [ "$mt" -ge "$newest_mt" ]; then
      newest_mt=$mt
      newest=$(dirname "$sp")
    fi
  done
  [ -n "$newest" ] || return 1
  printf '%s\n' "$newest"
}
