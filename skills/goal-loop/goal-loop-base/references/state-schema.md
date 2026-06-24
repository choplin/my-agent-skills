# goal-loop state schema

`state.json` is the machine-managed state of one autonomous goal loop. It lives
next to `goal.md` in a goal directory (`.agents/goals/{yyyy-mm-dd}-{slug}/`).
Humans read `goal.md`; the loop reads and writes `state.json`. Only `verify.sh`
ever writes predicate results (a predicate's `passes`/`evidence`); the loop
driver may additionally set a terminal `blocked` status when it hits its own
round cap, but it never touches predicate results.

## Schema

```json
{
  "status": "running",
  "iteration": 0,
  "max_iterations": 20,
  "predicates": [
    {
      "id": "tests",
      "command": "npm test",
      "passes": false,
      "evidence": null,
      "consecutive_failures": 0,
      "failure_signature": null
    }
  ],
  "blocked_reason": null
}
```

| Field | Meaning |
|-------|---------|
| `status` | `running` \| `complete` \| `blocked`. Owned by `verify.sh`; never hand-edit. |
| `iteration` | Number of evaluation rounds run so far. Incremented by `verify.sh`. |
| `max_iterations` | Hard upper bound. Reaching it forces `blocked` (bounded-loop safeguard). |
| `predicates[]` | The executable completion criteria. The loop is done when all pass. |
| `predicates[].id` | Stable short identifier. |
| `predicates[].command` | Shell command whose exit 0 proves the criterion. Required. |
| `predicates[].passes` | Default-FAIL: starts `false`; only `verify.sh` writes it. Re-evaluated every round, so a regression flips it back to `false` — it is never latched. |
| `predicates[].evidence` | The proof from the last run (command, exit code, output tail). |
| `predicates[].consecutive_failures` | Length of the current run of *identical* failures (see Stall detection). Resets to 0 on pass. |
| `predicates[].failure_signature` | Signature of the last failure (exit code + output). Used to tell a stuck predicate from a converging one. |
| `blocked_reason` | Human-readable reason when `status == blocked`, else `null`. |

## Default-FAIL contract

Every predicate starts with `passes: false`. A predicate may flip to `true`
**only** through `verify.sh`, which requires the command to have actually run and
exited 0, and records the run as `evidence`. Nothing else — not the builder, not
a prompt, not a human assertion — may set `passes: true`.

This holds **without any host integration**: `verify.sh` is the single writer of
predicate results by construction, and `init.sh` scaffolds the file so a human
never hand-writes it.
Where a host offers hooks (e.g. Claude Code), a PreToolUse guard additionally
denies direct edits to `state.json`, making the contract structural on top of the
already-safe core. The hook is an optimization, never a prerequisite.

Why: "asking politely in a prompt does not reliably prevent false 'done'
reports. The harness makes 'done' structural"
(see `docs/2026-06-11-loop-engineering-research.md` §2).

## Stall detection (why a converging loop is not killed)

A naive "failed twice in a row → blocked" rule kills any predicate that takes
more than two rounds to satisfy, even while the builder is genuinely making
progress. Instead, `verify.sh` blocks only when it sees **no progress**:

- On each failure it computes a `failure_signature` from the exit code and output.
- If the new signature equals the previous one, `consecutive_failures` increments
  (the builder changed nothing observable). If it differs, the counter resets to 1
  (progress — give the builder another round).
- A predicate is **stuck** only when `consecutive_failures >= 2` **and** its
  failure output is non-empty. A silent predicate (no output, e.g. `test -f x`)
  carries no progress signal, so it is *not* fast-failed — it is bounded by
  `max_iterations` instead.

So: an informative command (a test runner whose output shrinks as failures are
fixed) fast-fails on a genuinely repeating error, while a slowly-converging or
silent predicate runs until it passes or `max_iterations` is hit.

## Loop pseudocode

One round = one builder pass followed by one `verify.sh` evaluation.

```
load state.json            # status starts "running", all predicates passes:false
while status == running:
    builder pass:          # FRESH process each round (claude -p / codex exec / a make target)
        read goal.md + state.json + NEXT_FINDINGS.md
        implement the smallest change set that can make a failing predicate pass
        do NOT edit `passes` directly; do NOT delete or weaken predicates
    verify.sh <goal-dir>:  # the only sanctioned state writer
        iteration++
        run EVERY predicate's command (re-check passing ones too), record evidence + signature
        recompute status:
            all pass THIS round      -> complete
            stuck (same error twice) -> blocked
            iteration >= max         -> blocked
            else                     -> running
present artifact for human review   # human reviews the result, not an up-front plan
```

## Stop conditions

- **complete** — every predicate passes with recorded evidence.
- **blocked** — a predicate is stuck on an identical failure, or `max_iterations`
  was reached. `blocked_reason` names which. A `blocked` loop is handed back to a
  human; it is not an error, it is the loop refusing to fake completion.
