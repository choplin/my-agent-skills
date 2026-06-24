#!/usr/bin/env bash
# PreToolUse hook: enforce the goal-loop Default-FAIL contract (shell + jq).
#
# Deny direct Write/Edit to a goal's state.json — that file may be written only
# by verify.sh (via Bash), which flips a predicate's `passes` to true only after
# its command has actually exited 0 and records the run as evidence. This makes
# "done" structural rather than a matter of the builder asserting it.
#
# Everything else is allowed. Best-effort: on any error, allow (never trap the
# user because the guard itself failed). Note this layers ON TOP of an
# already-safe core — verify.sh is the sole writer of predicate results
# regardless of this hook.

# Exit 0 with no JSON decision -> the tool call proceeds normally.
allow() { exit 0; }

input=$(cat 2>/dev/null) || allow
command -v jq >/dev/null 2>&1 || allow

fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || allow
fp=${fp//\\//}

case "$fp" in
  */.agents/goals/*/state.json)
    reason="goal-loop: state.json is managed by verify.sh and must not be edited directly (Default-FAIL contract). Implement the change that makes a predicate's command exit 0, then run verify.sh — it records evidence and flips \`passes\`. To change the goal itself, edit goal.md and re-scaffold state with init.sh, not the other way around."
    jq -nc --arg r "$reason" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $r
      }
    }'
    exit 0
    ;;
esac

allow
