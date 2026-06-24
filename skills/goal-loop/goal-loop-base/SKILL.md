---
name: goal-loop-base
description: Shared resources for the goal-loop skill family — the goal-loop state schema, the Goal Contract template, and the agent-agnostic shell scripts (init.sh, verify.sh, loop.sh) that scaffold, evaluate, and drive a bounded autonomous loop. The goal-loop skill delegates to this skill to read a template or run a script. Use this skill when goal-loop asks to apply the Goal Contract template, follow the state schema, scaffold state.json, evaluate predicates, or run the loop. Not typically invoked on its own.
user-invocable: false
---

# goal-loop base resources

This skill owns the resources shared across the goal-loop skill family. Other
goal-loop skills **delegate to this skill by name** instead of referencing
plugin-root paths, so the same skills work whether installed flat by the skills
CLI or loaded as part of a plugin.

References here are addressed in two forms. In both, resolve the path **relative
to this skill's installed directory** (load this skill, then read/run the named
file from its own root):

- `` `goal-loop-base` skill (`references/<file>`) `` → read `references/<file>` from this skill.
- `goal-loop-base/scripts/<name>.sh` → run this skill's script (see below).

## Resources

- `references/goal-contract-template.md` — the Goal Contract structure to write to `goal.md`, plus how to scaffold `state.json`.
- `references/state-schema.md` — the full `state.json` schema, the Default-FAIL contract, the stall-detection rule, the loop pseudocode, and the stop conditions.
- `scripts/init.sh` — scaffold a Default-FAIL `state.json` from predicates.
- `scripts/verify.sh` — the predicate evaluator (the only sanctioned `state.json` writer).
- `scripts/loop.sh` — the bounded, fresh-context implement→verify loop driver.

## Why shell + jq (not Python)

The scripts are POSIX-ish `bash` and depend only on **`jq`** (plus standard
utilities: `tail`, `awk`, `cksum`). There is no Python, no compiled binary, and
no per-host runtime to install. `jq` is the single external dependency; every
script checks for it up front and exits with a clear message if it is missing.
This keeps the harness runnable anywhere a shell and `jq` exist, rather than
assuming a language runtime is present.

## Scripts

All three are agent-agnostic and run from any host's loop runner or by hand.

### init.sh — scaffold state

```bash
init.sh --goal-dir <dir> --predicate id::command [--predicate id::command ...] \
        [--max-iterations N] [--force]
```

Writes a Default-FAIL `state.json` (every predicate `passes: false`). Scaffolding
from a script — never by hand and never via the agent's file-write tool — is what
guarantees the contract from the first byte.

### verify.sh — evaluate predicates (sole writer of predicate results)

```bash
verify.sh <goal-dir> [--timeout SECONDS] [--tail LINES]
```

One invocation = one evaluation round: increments `iteration`, runs every
predicate (re-checking already-passing ones so a regression is caught, not
latched), records evidence, updates each predicate's failure signature, and
recomputes `status` (`complete` / `blocked` / `running`). It is
**the only thing that flips a predicate's `passes` to `true`**, and only after
the command actually exits 0 (the loop driver may set a terminal `blocked` on its
own round cap, but never writes predicate results). Exit code is 0 when
`complete`, else 1.

### loop.sh — drive the bounded loop

```bash
loop.sh --goal-dir <dir> --builder-cmd '<cmd>' [--evaluator-cmd '<cmd>'] \
        [--max-rounds N] [--cwd DIR]
```

Each round runs `--builder-cmd` as a **fresh process** (so it never praises its
own prior work), then `verify.sh`. It writes `NEXT_FINDINGS.md` with the failing
predicates' evidence for the next builder pass, and stops when `status` becomes
`complete` or `blocked`. The builder is host-supplied, so the same driver runs on
any host (`claude -p`, `codex exec`, a make target, a shell function). Each
command receives `GOAL_DIR`, `GOAL_FILE`, `GOAL_STATE`, `NEXT_FINDINGS`, and
`GOAL_ITERATION` in the environment.

`loop.sh`'s only stdout is the final `state.json`; all progress chatter goes to
stderr, so it composes cleanly in a pipeline.

## Graceful fallback

If this base skill is unavailable, the caller should inline the same behavior:
write the Goal Contract from the template, scaffold `state.json` with every
predicate `passes: false`, run each predicate command yourself between builder
passes, and only mark a predicate satisfied after its command has actually exited
0 with the run recorded as evidence — never edit `passes` by hand.
