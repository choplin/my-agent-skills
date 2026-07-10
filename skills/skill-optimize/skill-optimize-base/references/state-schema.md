# state.json schema, run layout, and stop conditions

`state.json` is the single source of truth for an optimization run. The scripts
own it; do not hand-edit accept decisions. It survives `/clear` and lets a run
resume in a fresh session.

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

Convention for `<run-dir>`: `.skill-optimize/<skill-name>/` under the repo, or a
scratchpad path when outside a repo. One directory per skill under optimization.

## state.json fields

```json
{
  "target_skill": "skill-name-or-path",
  "signal": { "kind": "oracle|anchor|self-criteria", "command": null },
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
  `references/verification-signals.md`). `command` is the mechanical checker when
  the signal is an `oracle` or `anchor`; `null` for agent-judged `self-criteria`.
- **tasks** — the fixed split. `train` feeds edit proposal; `holdout` decides
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

## Script invocations

### init.sh — scaffold state

```bash
init.sh --run-dir <dir> --skill <name> \
        --train t1,t2,t3 --holdout h1,h2 \
        --signal-kind oracle|anchor|self-criteria \
        [--signal-cmd '<checker command>'] \
        [--max-iterations N] [--force]
```

Writes a fresh `state.json` (`v0` scores null, `best.holdout_score` null,
`status: init`) and creates `versions/ traces/ evals/`. Copy the target skill to
`versions/v0/` yourself after scaffolding.

### record.sh — record a version's results on a split

```bash
record.sh <run-dir> --version vN --split train|holdout \
          --results 't1::pass,t2::fail,t3::pass'
```

Computes `score = passes / total` for that split and stores it plus per-task
detail. Run it after evaluating a version on a split. Warns if the recorded task
ids differ from the declared split.

### gate.sh — set baseline, then accept/reject candidates

```bash
# once, after v0's holdout is recorded:
gate.sh <run-dir> --set-baseline

# per candidate, after its holdout is recorded:
gate.sh <run-dir> --candidate vN [--reason 'text']
```

`--set-baseline` copies `scores.v0.holdout` into `best.holdout_score` and flips
status to `running`. Per candidate, the gate:

1. increments `budget.iteration`;
2. **accepts** iff `scores[vN].holdout` is *strictly greater* than
   `best.holdout_score` — then `current` and `best` move to `vN`, and
   `no_improve_streak` resets to 0;
3. otherwise **rejects** (revert stays on the current best) and increments
   `no_improve_streak`;
4. appends a `history` entry and recomputes `status`.

Ties are rejected on purpose: an edit must earn its place. The gate refuses to
run until a baseline held-out score exists and the candidate's held-out score is
recorded.

## Stop conditions

The orchestrator stops the loop when `status` becomes terminal:

- **converged** — `no_improve_streak >= no_improve_limit`. Either the skill is as
  good as this signal can make it, or (law 1) the signal is too weak to
  discriminate further. Spot-check a few held-out deliverables by hand before
  trusting the result.
- **blocked** — `budget.iteration >= max_iterations`. Budget exhausted; report
  the best version and its held-out score.

On any terminal status, the deliverable is `versions/<best.version>/`.
