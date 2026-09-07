---
name: skill-quality-improve
description: >-
  Produces one improvement step for a skill under optimization: reads the
  labeled failure traces, proposes edits that address failures recurring
  across several train trajectories, applies them at a controlled magnitude,
  and emits a candidate version for the held-out gate to judge.
user-invocable: false
metadata:
  description-role: documentation
---

# skill-quality-improve: one improvement step

Given a scored version and its **train** failure traces, produce the next
candidate version. This is the gradient + parameter-update step of the training
loop (`skill-quality-base`). It does **not** decide whether the edit survives —
that is the held-out gate (`gate.sh`).

> Load `skill-quality-base` for the run layout and laws. Load
> `skill-quality-standard` for the normative requirements applied to every
> candidate. This step decides *which* edits to make; the standard governs how
> to write them well.

## Inputs

- The current best version `versions/<current>/SKILL.md`.
- Its **train** traces `traces/<current>/train/*.md` with per-task failure
  reasons. (Never read holdout traces here — base law 2.)

## Procedure

### 1. Cluster failures across train trajectories

Group the train failures by root cause. For each cluster, count **how many
distinct train tasks** exhibit it.

- **Adopt** a fix only for clusters that recur across **≥2 train tasks** — that is
  evidence of a property common to the task domain, not a fluke (base law 3,
  Trace2Skill regularization).
- **Discard** single-trajectory corrections. A one-off failure does not become a
  rule — if the same failure is real, it will recur as a ≥2-task cluster in a
  future train split and get adopted then.

### 2. Turn each adopted cluster into a minimal edit

For each surviving cluster, write the smallest edit that would have prevented the
failure, while keeping the candidate conformant with `skill-quality-standard`:

- Classify the affected part as interpretive, coordinated, or deterministic
  before choosing the edit.
- For an interpretive failure, adjust the smallest relevant principle, rationale,
  example, or gotcha. For a coordination failure, adjust the sequence, handoff,
  invariant, or stop condition. For a deterministic failure, adjust the existing
  operation or its real input/output contract; use a script or schema only when
  that boundary is genuinely mechanical.
- Keep `SKILL.md` economical: if the fix is bulky reference material, move it to
  `references/` with an explicit load trigger, not into the always-loaded body.
- Prefer correcting, deleting, or generalizing existing content before adding a
  new rule. Do not rewrite working sections; touch only what a failure cluster
  points at.

Apply the standard's common requirement to every changed passage: state the
resulting current behavior directly.
Remove former-state or rejected-alternative framing introduced by the edit. Retain
compatibility language only when the failure cluster identifies a current
interoperability, migration, deprecation, or versioned schema/protocol requirement;
name that requirement in the candidate.

### 3. Respect the edit-magnitude budget

Read `budget.iteration` / `max_iterations` from `state.json`:

- **Early** (first iterations): larger structural edits are allowed — reorder,
  add a section, change the default approach. They are cheap to revert: the gate
  always compares against the same current best, so a bad early edit just fails
  and reverts.
- **Late** (as scores plateau): shrink to targeted, surgical edits. Wholesale
  rewrites late in a run overwrite hard-won gains and confuse the gate about what
  caused a change.

A single step should change **one coherent thing** (or a few tightly-related
clusters), so the held-out gate attributes the score delta to a known cause.

### 4. Emit the candidate

Write the edited skill to `versions/v<next>/` (copy the current best, apply the
edits). Record a one-line changelog of what changed and which failure clusters it
targets — the orchestrator uses this when reporting, and it becomes the `--reason`
passed to `gate.sh`.

Then run the standard's loadability preflight on the candidate — **mandatory whenever the
edit touched the frontmatter**, since an edit to `description` is the likeliest way
to break it:

```
skill-quality-standard/scripts/lint-frontmatter.sh versions/v<next>/
```

It must exit 0. Fix and re-run until it does; never hand a failing candidate to the
gate. The trap is a `: ` (colon + space) written into an unquoted `description` —
YAML reads it as a nested key, the file stops parsing, and the skill silently does
not load. The gate would then score the candidate at whatever a *missing* skill
scores and reject it as a bad edit, so the loop learns the wrong lesson from a
one-character typo.

Before handing back, confirm: (1) every edit traces to a ≥2-task cluster adopted
in step 1; (2) any new gotcha landed in `SKILL.md`, not `references/`; (3) the
changelog names the specific clusters addressed; (4) the lint exited 0. A malformed
candidate caught here costs nothing; caught by the gate it wastes a held-out
evaluation round; and (5) changed passages describe the current contract directly,
with every compatibility exception tied to an explicit current requirement.

## Output

The path `versions/v<next>/` and the changelog. Do **not** score it or accept it
— hand back to the orchestrator, which evaluates the candidate on held-out and
runs `gate.sh`.
