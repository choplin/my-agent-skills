# Goal Contract template

A Goal Contract is the compact, user-confirmed agreement that an autonomous loop
runs against. Write it to `goal.md` in the goal directory before any
implementation file is touched. Every line must trace to a user answer from the
dig interview — no AI filling.

```markdown
# Goal: {short title}

## Why
{user-confirmed motivation — the problem this solves, in the user's own words}

## Target
{one paragraph describing the finished state — what is true when this is done}

## Boundaries
- In scope: {files, modules, behavior the loop may change}
- Out of scope: {explicit non-goals}
- Must not change: {tests, public contracts, generated files, ...}

## Predicates
Each predicate is an executable command whose exit 0 proves a completion
criterion. If a criterion cannot be written as a command, this task is NOT
eligible for goal-loop — route it to the spec workflow instead.

1. `{command}` -> proves {criterion}
2. `{command}` -> proves {criterion}

## Stop Conditions
- Complete: every predicate exits 0 with recorded evidence.
- Blocked: the same predicate fails twice with the same error, an external
  oracle turns out to be missing, or implementation reveals a decision that needs
  human judgment.
```

## Deriving state.json

Do **not** hand-write `state.json`. Scaffold it from the Predicates section with
`init.sh`, which guarantees the Default-FAIL start state (every predicate
`passes: false`) and avoids the bootstrap trap where a host hook that protects
`state.json` would block a hand-written first copy:

```bash
# run init.sh from this skill's scripts/ directory
init.sh --goal-dir .agents/goals/{yyyy-mm-dd}-{slug} \
  --predicate 'tests::npm test' \
  --predicate 'lint::npm run lint' \
  --max-iterations 20
```

The resulting `state.json`:

```json
{
  "status": "running",
  "iteration": 0,
  "max_iterations": 20,
  "predicates": [
    {"id": "tests", "command": "npm test", "passes": false, "evidence": null, "consecutive_failures": 0, "failure_signature": null}
  ],
  "blocked_reason": null
}
```

Set `--max-iterations` to a bound proportional to task size (default 20). It is a
safety net, not a target.
