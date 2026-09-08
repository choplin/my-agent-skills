# state.json schema, run layout, and stop conditions

`state.json` is the single source of truth for an optimization run. The scripts
own it; do not hand-edit accept decisions. It survives `/clear` and lets a run
resume in a fresh session. Every skill that reads or writes a run conforms to
the layout and fields below; apply `references/procedures/loop-scripts.md` to
invoke the scripts that maintain them.

## Run directory layout

```
<run-dir>/
  state.json              # this file
  signal.md               # the verification signal, written by evaluate
  versions/
    v0/SKILL.md           # baseline: verbatim copy of the target skill
    v1/SKILL.md           # candidate produced by improve
    ...
  traces/
    v0/train/<taskid>.md  # execution trace + pass/fail rationale
    v0/holdout/<taskid>.md
    v1/holdout/<taskid>.md
    ...
  evals/                  # optional human-readable score dumps
```

Convention for `<run-dir>`: `.skill-quality/<skill-name>/` under the repo, or a
scratchpad path when outside a repo. One directory per skill under optimization.

## state.json fields

```json
{
  "target_skill": "skill-name-or-path",
  "signal": { "kind": "oracle|anchor", "command": "<checker command>" },
  "tasks": {
    "train":   ["t1", "t2", "t3"],
    "holdout": ["h1", "h2"]
  },
  "budget": {
    "max_iterations": 8,
    "iteration": 0,
    "no_improve_streak": 0,
    "no_improve_limit": 2
  },
  "current": "v0",
  "best": { "version": "v0", "holdout_score": null },
  "scores": {
    "v0": { "train": null, "holdout": null }
  },
  "history": [],
  "status": "init"
}
```

- **signal.kind** — which verification-signal design is in use (see
  `references/verification-signals.md`). `command` is the required mechanical
  checker for the `oracle` or `anchor`.
- **tasks** — the fixed, non-empty split. Task ids are unique within each split
  and cannot appear in both. `train` feeds edit proposal; `holdout` decides
  accept/reject and is never used to derive edits.
- **budget** — `max_iterations` bounds the loop; `no_improve_limit` consecutive
  rejects mean the loop has converged (or the verifier is too weak to make
  progress).
- **current** — the accepted best version so far (what a reject reverts to).
- **best** — the version + held-out score the gate compares candidates against.
- **scores[v][split]** — pass fraction in `[0,1]`; `record.sh` also stores a
  `<split>_detail` object of per-task `pass|fail`.
- **status** — `init` → `running` → terminal `converged` (plateaued) or
  `blocked` (budget exhausted).

## Stop conditions

The orchestrator stops the loop when `status` becomes terminal:

- **converged** — `no_improve_streak >= no_improve_limit`. Either the skill is as
  good as this signal can make it, or (law 1) the signal is too weak to
  discriminate further. Spot-check a few held-out deliverables by hand before
  trusting the result.
- **blocked** — `budget.iteration >= max_iterations`. Budget exhausted; report
  the best version and its held-out score.

On any terminal status, the deliverable is `versions/<best.version>/`.
