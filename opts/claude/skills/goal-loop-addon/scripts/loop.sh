#!/usr/bin/env bash
# loop.sh (Claude Code wrapper) — run the goal-loop with `claude -p` as the
# fresh-context builder by default. Thin convenience over the host-agnostic core
# (goal-loop-base scripts/loop.sh, available here as loop-core.sh). Everything the
# core does is unchanged; this only supplies a standard builder command so a
# Claude Code user can start a loop with just a goal dir.
#
# Usage: loop.sh <goal-dir> [--max-rounds N] [extra core args...]
#   Override the builder by passing your own --builder-cmd (forwarded to core).
set -uo pipefail

die() { printf 'loop.sh: %s\n' "$1" >&2; exit 2; }
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE="$SCRIPT_DIR/loop-core.sh"
[ -f "$CORE" ] || die "core loop driver not found ($CORE); is goal-loop-base installed?"

GOAL_DIR="${1:?usage: loop.sh <goal-dir> [--max-rounds N]}"
shift

# Default fresh-context builder: a new `claude -p` each round. The core re-runs
# this as a fresh process per round, so the builder never reviews its own work.
BUILDER_PROMPT='You are the builder inside a goal-loop. Read $GOAL_FILE and $GOAL_STATE (and $NEXT_FINDINGS if it exists). Pick one predicate whose "passes" is false and implement the smallest change set that can make its command exit 0. Rules: do NOT edit $GOAL_STATE directly (verify.sh owns it; a hook will block writes to it); do NOT delete, weaken, or skip predicates or tests, and do not change anything listed under "Must not change" in the goal; stay within the goal Boundaries; if the predicate needs human judgment, stop and explain instead of guessing. Stop when this round'\''s change set is implemented.'

# Allow the caller to override --builder-cmd; otherwise inject the default.
has_builder=0
for a in "$@"; do
  case "$a" in --builder-cmd) has_builder=1;; esac
done

if [ "$has_builder" -eq 1 ]; then
  exec bash "$CORE" --goal-dir "$GOAL_DIR" "$@"
else
  exec bash "$CORE" --goal-dir "$GOAL_DIR" \
    --builder-cmd "claude -p \"$BUILDER_PROMPT\" --permission-mode acceptEdits" \
    "$@"
fi
