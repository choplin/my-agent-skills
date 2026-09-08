# Loop script invocations

Apply these invocations to drive an optimization run. They are the only
supported way to write `state.json`; conform to
`references/contracts/state-schema.md` for what they record.

## init.sh — scaffold state

```bash
init.sh --run-dir <dir> --skill <name> \
        --train t1,t2,t3 --holdout h1,h2 \
        --signal-kind oracle|anchor \
        --signal-cmd '<checker command>' \
        [--max-iterations N] [--force]
```

Writes a fresh `state.json` (`v0` scores null, `best.holdout_score` null,
`status: init`) and creates `versions/ traces/ evals/`. Copy the target skill to
`versions/v0/` yourself after scaffolding.

## record.sh — record a version's results on a split

```bash
record.sh <run-dir> --version vN --split train|holdout \
          --results 't1::pass,t2::fail,t3::pass'
```

Computes `score = passes / total` for that split and stores it plus per-task
detail. Run it after evaluating a version on a split. Rejects results unless the
recorded task ids exactly match the declared split.

## gate.sh — set baseline, then accept/reject candidates

```bash
# once, after both v0 splits are recorded:
gate.sh <run-dir> --set-baseline

# per candidate, after both splits are recorded:
gate.sh <run-dir> --candidate vN [--reason 'text']
```

`--set-baseline` verifies that both v0 splits are complete, copies
`scores.v0.holdout` into `best.holdout_score`, and flips status to `running`.
Each candidate must also have complete train and holdout results. The gate then:

1. increments `budget.iteration`;
2. **accepts** iff `scores[vN].holdout` is *strictly greater* than
   `best.holdout_score` — then `current` and `best` move to `vN`, and
   `no_improve_streak` resets to 0;
3. otherwise **rejects** (revert stays on the current best) and increments
   `no_improve_streak`;
4. appends a `history` entry and recomputes `status`.

Ties are rejected on purpose: an edit must earn its place. The gate refuses to
run until the baseline and candidate contain complete results for both declared
splits.
