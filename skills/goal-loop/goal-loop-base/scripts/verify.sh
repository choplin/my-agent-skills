#!/usr/bin/env bash
# verify.sh — goal-loop predicate evaluator (POSIX-ish shell + jq, no Python).
#
# Reads a goal directory's state.json, runs every predicate's command, records
# evidence, and recomputes status. This is the ONLY thing that writes predicate
# results: it enforces the Default-FAIL contract — a predicate's `passes` flips
# to true only after its command has actually exited 0, and the run is recorded
# as evidence. Nothing else (not the builder, not a prompt, not a human
# assertion) may set passes:true. (The loop driver may set a terminal `blocked`
# status when it hits its own round cap, but it never touches predicate results.)
#
# One invocation == one evaluation round:
#   1. iteration++
#   2. for EVERY predicate, run its command (passing ones are re-checked too, so
#      a regression that breaks an already-satisfied predicate flips it back to
#      false instead of staying latched true):
#        exit 0  -> passes=true, consecutive_failures=0, evidence recorded
#        exit !=0 -> passes set false, evidence recorded, and the failure
#                    SIGNATURE (exit code + output) is compared to the previous
#                    round: identical signature -> consecutive_failures++ (no
#                    progress); different signature -> reset to 1 (still failing,
#                    but the builder is moving, so do not penalise it).
#   3. recompute status:
#        all predicates pass THIS round  -> complete
#        any predicate stuck             -> blocked  (2-strike safeguard)
#        iteration >= max_iterations     -> blocked  (bounded-loop safeguard)
#        otherwise                       -> running
#
#      "stuck" == the same NON-EMPTY failure output repeated twice in a row. A
#      predicate with no output (a silent check like `test -f x`, or one with no
#      command) gives no progress signal, so it is NOT fast-failed — it is
#      bounded by max_iterations instead. This keeps the loop from killing a
#      builder that is genuinely converging but whose predicate prints nothing.
#
# Usage: verify.sh <goal-dir> [--timeout SECONDS] [--tail LINES]
# Exit:  0 when status == complete, 1 for running/blocked, 2 on usage/IO error.
set -uo pipefail

STRIKE_LIMIT=2
DEFAULT_TIMEOUT=600
DEFAULT_TAIL=40

die() { printf 'verify.sh: %s\n' "$1" >&2; exit 2; }
command -v jq >/dev/null 2>&1 || die "jq is required but not found on PATH"

TIMEOUT=$DEFAULT_TIMEOUT
TAIL=$DEFAULT_TAIL
GOAL_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --timeout) TIMEOUT="${2:?--timeout needs a value}"; shift 2;;
    --tail) TAIL="${2:?--tail needs a value}"; shift 2;;
    --) shift; break;;
    -*) die "unknown option: $1";;
    *) [ -z "$GOAL_DIR" ] || die "unexpected argument: $1"; GOAL_DIR="$1"; shift;;
  esac
done
[ -n "$GOAL_DIR" ] || die "usage: verify.sh <goal-dir> [--timeout SECONDS] [--tail LINES]"

STATE="$GOAL_DIR/state.json"
[ -f "$STATE" ] || die "state.json not found at $STATE"

state=$(cat "$STATE") || die "could not read $STATE"
printf '%s' "$state" | jq empty 2>/dev/null || die "$STATE is not valid JSON"

# 1. iteration++
state=$(printf '%s' "$state" | jq '.iteration = ((.iteration // 0) + 1)')

# 2. run every predicate (re-checking passing ones catches regressions)
count=$(printf '%s' "$state" | jq '.predicates | length')
i=0
while [ "$i" -lt "$count" ]; do
  # Re-run EVERY predicate each round, including ones already passing, so a
  # regression flips passes back to false instead of staying latched true.
  cmd=$(printf '%s' "$state" | jq -r ".predicates[$i].command // empty")
  if [ -z "$cmd" ]; then
    # No command can never be machine-verified: no output, so (like a silent
    # predicate) it is bounded by max_iterations, not the 2-strike rule.
    prev_sig=$(printf '%s' "$state" | jq -r ".predicates[$i].failure_signature // empty")
    if [ "$prev_sig" = "no-command" ]; then cf_new=$(($(printf '%s' "$state" | jq -r ".predicates[$i].consecutive_failures // 0") + 1)); else cf_new=1; fi
    state=$(printf '%s' "$state" | jq --argjson cf "$cf_new" "
      .predicates[$i].passes = false
      | .predicates[$i].consecutive_failures = \$cf
      | .predicates[$i].failure_signature = \"no-command\"
      | .predicates[$i].evidence = {error: \"predicate has no command; not machine-verifiable\"}")
    i=$((i + 1)); continue
  fi

  if command -v timeout >/dev/null 2>&1; then
    out=$(timeout "$TIMEOUT" sh -c "$cmd" 2>&1); code=$?
  else
    out=$(sh -c "$cmd" 2>&1); code=$?
  fi
  tail_out=$(printf '%s\n' "$out" | tail -n "$TAIL")

  if [ "$code" -eq 0 ]; then
    state=$(printf '%s' "$state" | jq --arg cmd "$cmd" --arg out "$tail_out" "
      .predicates[$i].passes = true
      | .predicates[$i].consecutive_failures = 0
      | .predicates[$i].failure_signature = null
      | .predicates[$i].evidence = {command: \$cmd, exit_code: 0, summary: \$out}")
  else
    # Signature of THIS failure; same signature twice in a row == no progress.
    sig=$(printf '%s\n%s\n' "$code" "$tail_out" | cksum | awk '{print $1 "-" $2}')
    prev_sig=$(printf '%s' "$state" | jq -r ".predicates[$i].failure_signature // empty")
    if [ "$sig" = "$prev_sig" ]; then
      cf_new=$(($(printf '%s' "$state" | jq -r ".predicates[$i].consecutive_failures // 0") + 1))
    else
      cf_new=1
    fi
    state=$(printf '%s' "$state" | jq --arg cmd "$cmd" --arg out "$tail_out" --argjson code "$code" --arg sig "$sig" --argjson cf "$cf_new" "
      .predicates[$i].passes = false
      | .predicates[$i].consecutive_failures = \$cf
      | .predicates[$i].failure_signature = \$sig
      | .predicates[$i].evidence = {command: \$cmd, exit_code: \$code, output: \$out}")
  fi
  i=$((i + 1))
done

# 3. recompute status
state=$(printf '%s' "$state" | jq --argjson strike "$STRIKE_LIMIT" '
  (.predicates | length) as $n
  | ([.predicates[] | select(.passes)] | length) as $passed
  | ([.predicates[]
       | select((.consecutive_failures // 0) >= $strike
                and ((.evidence.output // "") | length) > 0)]) as $stuck
  | if $n > 0 and $passed == $n then
      .status = "complete" | .blocked_reason = null
    elif ($stuck | length) > 0 then
      .status = "blocked"
      | .blocked_reason = ($stuck[0]
          | "predicate \(.id // "?") failed \($strike) times in a row "
            + "(exit \(.evidence.exit_code // "?")); human input needed")
    elif (.iteration >= (.max_iterations // 20)) then
      .status = "blocked"
      | .blocked_reason = "max_iterations (\(.max_iterations // 20)) reached"
    else
      .status = "running" | .blocked_reason = null
    end')

# 4. atomic write — verify.sh is the only thing that flips a predicate to
#    passing (the driver may set a terminal status, but never predicate results)
tmp="$GOAL_DIR/.state.json.tmp"
printf '%s\n' "$state" > "$tmp" || die "could not write $tmp"
mv "$tmp" "$STATE"

status=$(printf '%s' "$state" | jq -r '.status')
printf '%s\n' "$status"
[ "$status" = "complete" ]
