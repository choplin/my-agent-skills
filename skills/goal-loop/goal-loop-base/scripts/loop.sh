#!/usr/bin/env bash
# loop.sh — bounded, fresh-context implement->verify loop (host-agnostic core).
#
# Each round re-launches the builder as a FRESH process (so it never praises its
# own prior work) to make one failing predicate pass, then runs verify.sh to
# evaluate progress and decide whether to continue. verify.sh is the only thing
# that flips a predicate to passing (the Default-FAIL contract); this driver
# never touches predicate results — it only reads status and, on its own
# round cap, records a terminal `blocked`. The loop stops when status is
# complete or blocked.
#
# The builder is host-supplied via --builder-cmd, so this core runs on ANY host
# (claude -p, codex exec, a make target, a shell function...). Claude Code users
# get a thin wrapper that defaults --builder-cmd to `claude -p` (see the goal-loop
# opt-in add-on); nothing here depends on a specific agent.
#
# Bounds (defence in depth against runaway loops):
#   - verify.sh enforces max_iterations and the 2-strike rule inside state.json;
#   - this script also caps total rounds via --max-rounds / GOAL_LOOP_MAX_ROUNDS,
#     and marks the goal blocked (not left "running") if that cap is hit.
#
# Each command (builder, predicates via verify.sh, evaluator) receives:
#   GOAL_DIR GOAL_FILE GOAL_STATE NEXT_FINDINGS GOAL_ITERATION
#
# Usage:
#   loop.sh --goal-dir DIR --builder-cmd '<cmd>' [--evaluator-cmd '<cmd>']
#           [--max-rounds N] [--cwd DIR]
set -uo pipefail

die() { printf 'loop.sh: %s\n' "$1" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || die "jq is required but not found on PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERIFY="$SCRIPT_DIR/verify.sh"
[ -x "$VERIFY" ] || [ -f "$VERIFY" ] || die "verify.sh not found next to loop.sh ($VERIFY)"

GOAL_DIR=""
BUILDER_CMD=""
EVALUATOR_CMD=""
CWD="."
MAX_ROUNDS="${GOAL_LOOP_MAX_ROUNDS:-50}"

while [ $# -gt 0 ]; do
  case "$1" in
    --goal-dir) GOAL_DIR="${2:?--goal-dir needs a value}"; shift 2;;
    --builder-cmd) BUILDER_CMD="${2:?--builder-cmd needs a value}"; shift 2;;
    --evaluator-cmd) EVALUATOR_CMD="${2:?--evaluator-cmd needs a value}"; shift 2;;
    --max-rounds) MAX_ROUNDS="${2:?--max-rounds needs a value}"; shift 2;;
    --cwd) CWD="${2:?--cwd needs a value}"; shift 2;;
    --) shift; break;;
    -*) die "unknown option: $1";;
    *) [ -z "$GOAL_DIR" ] || die "unexpected argument: $1"; GOAL_DIR="$1"; shift;;
  esac
done

[ -n "$GOAL_DIR" ] || die "usage: loop.sh --goal-dir DIR --builder-cmd '<cmd>' [--evaluator-cmd '<cmd>']"
STATE="$GOAL_DIR/state.json"
[ -f "$STATE" ] || die "state.json not found at $STATE (run init.sh first)"

status() { jq -r '.status // "running"' "$STATE"; }

export GOAL_DIR
export GOAL_FILE="$GOAL_DIR/goal.md"
export GOAL_STATE="$STATE"
export NEXT_FINDINGS="$GOAL_DIR/NEXT_FINDINGS.md"

write_next_findings() {
  {
    printf '# NEXT_FINDINGS\n\n'
    printf -- '- round: %s\n' "$1"
    printf -- '- status: %s\n\n' "$(status)"
    printf '## Failing predicates\n\n'
    jq -r '
      .predicates[] | select(.passes | not) |
      "### \(.id)\n\n- command: `\(.command // "")`\n- exit_code: \(.evidence.exit_code // "n/a")\n\n```\n\(.evidence.output // .evidence.summary // "")\n```\n"
    ' "$STATE"
  } > "$NEXT_FINDINGS"
}

round=0
while [ "$(status)" = "running" ]; do
  if [ "$round" -ge "$MAX_ROUNDS" ]; then
    printf 'loop.sh: hit max rounds (%s); marking blocked\n' "$MAX_ROUNDS" >&2
    # Driver-level backstop. Record a terminal status so the goal is not left
    # looking "running" (resumable) to session hooks. Predicate results are
    # untouched — only the overall status/reason are set.
    jq --argjson n "$MAX_ROUNDS" \
      '.status = "blocked" | .blocked_reason = "loop driver hit max-rounds (\($n)) before converging"' \
      "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
    break
  fi
  round=$((round + 1))
  export GOAL_ITERATION="$round"
  printf -- '── round %s ──\n' "$round" >&2

  # Fresh-context builder pass. A builder failure never aborts the loop;
  # verify.sh decides progress. Builder chatter goes to stderr so this script's
  # only stdout is the final state JSON.
  if [ -n "$BUILDER_CMD" ]; then
    ( cd "$CWD" && sh -c "$BUILDER_CMD" ) >&2 || true
  fi

  # Verify pass: the only sanctioned state writer. Its status line goes to stderr.
  ( cd "$CWD" && bash "$VERIFY" "$GOAL_DIR" ) >&2 || true

  st=$(status)
  if [ "$st" = "complete" ]; then
    rm -f "$NEXT_FINDINGS"
    # Optional independent evaluator after predicates pass.
    if [ -n "$EVALUATOR_CMD" ]; then
      if eout=$( cd "$CWD" && sh -c "$EVALUATOR_CMD" 2>&1 ); then
        : # evaluator accepts the artifact
      else
        printf '%s\n' "$eout" | tail -n 40 > "$NEXT_FINDINGS"
        # Reopen the loop: predicates passed but the evaluator rejected.
        jq '.status = "running" | .blocked_reason = null' "$STATE" > "$STATE.tmp" && mv "$STATE.tmp" "$STATE"
      fi
    fi
  else
    write_next_findings "$round"
  fi
done

printf 'loop finished: status=%s\n' "$(status)" >&2
cat "$STATE"
[ "$(status)" = "complete" ]
