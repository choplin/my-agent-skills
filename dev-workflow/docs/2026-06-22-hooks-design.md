---
title: "dev-workflow Hooks Design — SessionStart injection & Stop gate"
date: 2026-06-22
status: accepted
type: design-note
tags:
  - dev-workflow
  - hooks
  - loop-engineering
summary: >
  Concrete "What" for Story #2 (workflow-hooks): a SessionStart hook that
  injects active work-unit state, and a Stop hook that gates on missing
  self-review. Only the What is decidable up front; behavior is verified by
  running the hook scripts (the harness contract is discovered empirically).
---

# dev-workflow Hooks Design

Story #2 of the v1 improvement roadmap (see `2026-06-11-loop-engineering-research.md` §6 B-1/B-2). This note records the **What** only — the behavior to build. Hook runtime behavior in the Claude Code harness is verified by running the scripts and observing a live session, not by an up-front spec.

## Why

Workflow adherence today rests on prompt instructions ("MUST run self-review", "resume with /resume-work"). Prompts are probabilistic. The two highest-leverage gaps:

- After a `/clear` or a new session, the model does not know there is in-progress dev-workflow work unless the user re-says so (the handoff copy-paste ritual exists to patch this).
- The model can finish implementing and stop without running self-review (workflow-concepts.md admits this).

Move both from "ask the model nicely" to "the mechanism handles it."

## Shared foundation

Both hooks are **command hooks** (deterministic) that shell out to the already-built state evaluator:

```
python3 "$CLAUDE_PLUGIN_ROOT/scripts/workflow-state.py" --root "$CLAUDE_PROJECT_DIR/.claude/dev-workflow"
```

They read `active_path` and the matching unit's `state`, `progress`, `next_action`. The evaluator already resolves the active unit branch-independently (unique branch match, else most-recently-modified). All state logic stays in the script; the hooks only format/act on its output.

**Invariants for both hooks:**
- Fast and silent when there is no dev-workflow work (`active_path` is null) → exit 0, no output.
- Never break the session: any error (python missing, bad JSON, no git) → exit 0, no output. The hooks are best-effort, not load-bearing.
- No third-party deps beyond python3 + jq-free parsing (parse JSON in python, or pass a `--format` from the script).

## Hook 1 — SessionStart: inject active work state

**Event**: `SessionStart`, matcher `*`.

**Behavior**: on session start, run the evaluator. If there is an active unit with a non-terminal next action, emit a short context block so the model starts already knowing where it is.

Injected context (example):

```
dev-workflow: resuming active work.
- Unit: 2026-06-12-feat-state-foundation (story)
- State: in_review (2/7 steps, review REVIEWING)
- Next: resume user review → run /dev-workflow:resume-work
```

**Rules:**
- Emit only when `active_path` is non-null AND `state` is not a finished state. (Finished = nothing to do. `review_complete` still has `post-task` pending, so it is surfaced; a fully-done unit with no next action is not.)
- Keep it to a few lines: title, level, state, progress, and the `next_action` (label + skill to invoke).
- Output via the SessionStart context mechanism (stdout / `systemMessage` / `hookSpecificOutput.additionalContext` — pick whichever the harness actually surfaces; verify empirically).

**Effect**: replaces the handoff copy-paste ritual for the common case. `handoff` remains only for explicitly capturing session notes.

## Hook 2 — Stop: gate on missing self-review

**Event**: `Stop`, matcher `*`.

**Behavior**: when the session tries to end while the active unit is `potentially_complete` (all plan steps done, no review started), block once with a reminder to run self-review. Cap at **2 consecutive blocks** for the same unit, then allow the stop (a reminder, not a trap).

**Rules:**
- Block condition: `active_path` non-null AND that unit's `state == "potentially_complete"`.
- Block output: `{"decision": "block", "reason": "..."}` — reason tells the model to run `/dev-workflow:self-review` (or to stop again to override).
- **2-strike cap**: maintain a small transient counter keyed by the active unit. Increment each time we block for it; once it would exceed 2, allow the stop and reset. Reset the counter whenever the gate condition does not hold (state moved on, e.g. review started). Honor `stop_hook_active` if the harness provides it.
- Any other state → allow stop (exit 0, no decision).
- This is **not** a loop engine. It does not force completion; it prevents the single most common silent skip, twice, then yields.

**Counter location**: a transient file outside the committed tree, e.g. `$CLAUDE_PROJECT_DIR/.claude/dev-workflow/.stop-gate` (gitignored area). It holds the unit path + count. It is disposable; losing it only resets the strike count.

## Out of scope (this Story)

- Turning the Stop hook into a loop engine / forcing self-review to pass (cap is 2, deliberately).
- PostToolUse hook for Plan Mode Context (research §1 issue 1c) — later if needed.
- Replacing/retiring the `handoff` skill (only its everyday role shrinks; the skill stays).
- The `/goal` integration and oracle routing (Story #5).

## Verification approach (predicate, not spec)

Because hooks load at session start and cannot be hot-tested in the authoring session, verification is in two layers:

1. **Script-level (automatable now)**: pipe fixture stdin JSON to each hook script with fixture `.claude/dev-workflow` trees, assert the output:
   - SessionStart: active unit present → context block contains the title/state/next; no active unit → empty output, exit 0.
   - Stop: active unit `potentially_complete` → `decision: block` on strikes 1-2 → allow on strike 3; non-`potentially_complete` → no block; missing/broken state → allow.
2. **Live (requires restart)**: after install, restart Claude Code; confirm SessionStart context appears and the Stop gate fires once on a `potentially_complete` unit. This step is the user's, since hook changes need a restart.
