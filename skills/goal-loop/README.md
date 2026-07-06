# goal-loop

A self-managed, agent-agnostic, predicate-gated counterpart to Codex `/goal`:
once the user's **What** is clear and "done" can be checked by executable
predicates, hand the work to a bounded autonomous **implement → verify** loop and
review only the finished artifact. Unlike `/goal`, completion is gated on those
predicates rather than asserted by the model (see
[`docs/2026-06-24-goal-loop-design.md`](../../docs/2026-06-24-goal-loop-design.md) D2).

goal-loop is the loop-engineering counterpart to the spec-driven `dev-workflow`
group. Use it when the completion oracle lives **outside the user's head** (a test
suite, a build, a reference implementation, a benchmark). When "done" depends on
taste, UX, or product judgment, use `dev-workflow` instead — see
[`docs/2026-06-11-loop-engineering-research.md`](../../docs/2026-06-11-loop-engineering-research.md) §3.
The full design rationale (and the `/goal` divergence) is in
[`docs/2026-06-24-goal-loop-design.md`](../../docs/2026-06-24-goal-loop-design.md).

## When it activates

- "run this as a goal", "goal loop", "while-true loop", "let the agent finish this autonomously", "full-bet on the agent"
- porting / cloning / migration against tests or a reference implementation
- bug fixes whose done state is command-verifiable

**Not** for work whose right answer requires human judgment — route that to
`dev-workflow-kickoff` and the spec flow.

## Skills

| Skill | user-invocable | Role |
|-------|----------------|------|
| `goal-loop` | yes | Entry point. dig → oracle test → Goal Contract → run the loop → finish. |
| `goal-loop-base` | no | Shared resources: Goal Contract template, state schema, and the `init.sh` / `verify.sh` / `loop.sh` scripts. Delegated to by name. |

## How it works

1. **Clarify** the What with `discuss-toolkit-dig` (intent, oracle, boundaries, stop conditions).
2. **Oracle test** — proceed only if every completion criterion can be an executable command.
3. **Goal Contract** (`goal.md`) + `state.json` scaffolded by `init.sh`, every predicate `passes: false` (**Default-FAIL**).
4. **Loop** — each round runs a fresh-context builder pass, then `verify.sh` (the only writer of predicate results in `state.json`) re-evaluates **every** predicate and updates `status`. A regression in an already-passing predicate flips it back to `false` — passes are never latched.
5. **Bounded** — `verify.sh` forces `blocked` on `max_iterations` or a genuine stall (same error twice in a row); the loop driver also marks `blocked` if it hits its own `--max-rounds` cap. No infinite loops.
6. **Finish** — `complete` only when all predicates pass with recorded evidence; the human reviews the artifact, not an up-front plan.

State and goals live under `.agents/goals/{yyyy-mm-dd}-{slug}/`.

## Dependencies

- **`jq`** — the scripts are shell + `jq` only (no Python, no compiled binary). `jq` is the single external dependency; each script checks for it and exits with a clear message if it is missing. Supply it however you like (system package, `nix`, etc.) — the skill only requires it on `PATH`.
- **`discuss-toolkit-dig`** — `goal-loop` uses dig to clarify the What before writing the Goal Contract. If dig is unavailable, `goal-loop` runs the same interview inline using the host's user-input mechanism (graceful fallback).

## Claude Code add-on (opt-in)

The portable skill runs on any agent (with `loop.sh`, or the inline bounded
fallback) **without any hook**. For Claude Code, the `goal-loop-addon` opt-in plugin
under `opts/claude/skills/goal-loop-addon/` adds structural enforcement and convenience
*on top of* the already-safe core:

- `scripts/loop.sh` — a thin wrapper that defaults `--builder-cmd` to `claude -p` (fresh context) each round.
- `hooks/pretool-default-fail.sh` (PreToolUse) — denies direct edits to `state.json`, making the Default-FAIL contract structural.
- `hooks/session-start.sh` / `hooks/stop-gate.sh` — inject the active goal's state, and nudge when a loop is still running.

All hooks are shell + `jq` (no Python). Install the add-on:

```bash
scripts/install-opts.sh claude
```

If the add-on is absent, nothing breaks — `verify.sh` is still the only writer of
predicate results and `init.sh` the only scaffolder, so completion stays honest.

## Resources (owned by `goal-loop-base`)

- `references/goal-contract-template.md` — Goal Contract structure + how to scaffold `state.json`.
- `references/state-schema.md` — full `state.json` schema, Default-FAIL contract, stall detection, loop pseudocode, stop conditions.
- `scripts/init.sh` — scaffold a Default-FAIL `state.json`.
- `scripts/verify.sh` — predicate evaluator (the only sanctioned `state.json` writer).
- `scripts/loop.sh` — bounded fresh-context implement→verify loop driver.
