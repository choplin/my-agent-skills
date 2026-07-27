# State Schema & State Contract

Single source of truth for dev-workflow state. Two things live here:

1. **`state.json` on-disk schema** — the machine-managed state of a work unit.
2. **State contract** — the state-category priority order, legacy-value mappings, and next-action dispatch that `scripts/workflow-state.py` implements and that consumer skills rely on.

No other file should restate the priority table or legacy mappings. Skills reference this document and run the script instead.

---

## 1. `state.json` on-disk schema

**Location**: one `state.json` per Story work unit:

- Story: `.claude/dev-workflow/story/{story-dir}/state.json`

`state.json` is the **local, offline source of truth for a Story's execution
state** (criteria/steps). It stays on disk so the implementation hot loop and
`workflow-state.py` never depend on network access. Authored content (the spec
prose, the plan design) lives in the Story's **Linear Issue**, not in local
`spec.md`/`plan.md` — see [Linear backing](#linear-backing-bootstrap-contract).

Epics do **not** use `state.json`: an Epic is a **Linear Project** and its
rollup (which Story next, how many done) is read from the Project's Issues at
session boundaries by the consumer skills — never by the offline script. Task-level
work runs outside dev-workflow (it has no `state.json`).

A Story work unit is defined by its `state.json` alone. There is no local
`spec.md`/`plan.md`/`epic.md` and no Markdown-derived fallback: a directory
without `state.json` is not a work unit.

**Principle — store only machine-managed, non-derived state.** Do not store values that can be computed from other fields (e.g., a "resolved 2/5" counter, or the derived state category). The script computes those at read time.

```json
{
  "schema": 1,
  "level": "story",
  "title": "state-foundation",
  "branch": "feat/state-foundation",
  "linear_issue_id": "ENG-123",
  "criteria": [
    { "id": 1, "name": "State evaluation unified", "verify": "python3 dev-workflow/scripts/workflow-state.py", "passes": false, "evidence": null }
  ],
  "steps": [
    { "id": 1, "name": "Prune plan-mode-context duplication", "done": false }
  ]
}
```

**Review state is not in `state.json`.** The review phase (`open`/`done`) and item
statuses (`open`/`resolved`/`skipped`/`postponed`) live in `review.md`, owned by the
`code-review-session` skill family (see `code-review-session-base` skill (`references/review-state.md`)).
`scripts/workflow-state.py` reads them by parsing `review.md`. dev-workflow's review
phase delegates to code-review-session (`code-review-session-import-ai`, `code-review-session-resolve`,
`code-review-session-report`), which never write to `state.json`.

### Field reference

| Field | Type | Meaning |
|-------|------|---------|
| `schema` | int | Schema version. Currently `1`. |
| `level` | string | `"story"`. |
| `title` | string | Human title (mirrors the Linear Issue title). |
| `branch` | string \| null | Git branch for this work unit (the Story branch). |
| `linear_issue_id` | string \| null | Identifier of the backing Linear Issue (e.g. `ENG-123`). The link the best-effort write-back and each session's authored-context read follow. `null` only for a Story not yet backed by an Issue. |
| `criteria` | array | Acceptance criteria. Authored in the Linear Issue by create-spec; the criterion name + `verify` are mirrored here at bootstrap. |
| `criteria[].id` | int | Stable id. |
| `criteria[].name` | string | Criterion name. |
| `criteria[].verify` | string \| null | Executable command that returns pass/fail, or `null` if not machine-verifiable (→ always human review). Populated by create-spec from the Issue's `Verify:` lines. |
| `criteria[].passes` | bool | **Initialized `false` (Default-FAIL).** May only become `true` with `evidence`. |
| `criteria[].evidence` | string \| null | What proves the pass (command output summary, file path, etc.). |
| `steps` | array | Implementation steps. Authored in the Linear Issue by create-plan; mirrored here at bootstrap. |
| `steps[].id` | int | Stable id. |
| `steps[].name` | string | Step name. |
| `steps[].done` | bool | Completion flag. Best-effort mirrored to the Linear Issue checklist on change. |

Review phase/mode/item fields are **not** part of `state.json` — they live in
`review.md` (see `code-review-session-base` skill (`references/review-state.md`)). The
evaluator parses `review.md` for the review phase and item statuses.

### Default-FAIL contract

`criteria[].passes` starts `false` and may only be set `true` together with a non-null `evidence`. Removing or weakening a criterion to make it pass is not allowed.

---

## Linear backing (bootstrap contract)

Authored content is externalized to Linear; local `state.json` holds only the
live execution state. The two are wired as:

- **Story ↔ Linear Issue** (`state.json.linear_issue_id`). The Issue description
  holds the spec (Why/What/Acceptance Criteria with `Verify:` lines/Out of Scope)
  and the plan design (Approach/Files to Change/Decision Log).
- **Epic ↔ Linear Project.** No local files; its Stories are the Project's Issues.

**`state.json` is sourced from Linear once, then owned locally.** Splitting the
"read Linear" moment by what it feeds is what keeps live progress safe:

1. **`state.json` itself** is built from the Issue **only when it does not yet
   exist locally** (first bootstrap of the work unit). If a `state.json` is
   present, load it — **never rebuild it from Linear**, which would overwrite the
   local `done`/`passes`/`evidence` and destroy progress.
2. **Authored context** (spec prose, plan design, Decision Log) is read from the
   Issue **at each session start**, read-only, so a resumed session recovers the
   "why". Reading it changes nothing on disk.

**The execution hot loop never reads Linear.** During implementation the only
source of truth is local `state.json` (and `review.md`). `workflow-state.py` is
offline and Linear-unaware.

**Write-back is best-effort and one-directional (local → Linear).** On a state
change (a step done, a criterion passing, review status moving) the owning skill
mirrors it to the Issue — checklist items, status — as fire-and-forget. A failed
or unauthenticated Linear call is logged and ignored; it never blocks the loop.
Linear-side edits are **not** read back.

**Bootstrap entry — parse vs adopt.** An Issue authored by dev-workflow
(`create-spec`/`create-epic`) is already structured, so bootstrap just **parses**
it into `state.json`. An arbitrary human-written Issue picked up via
`linear-start` → `dispatch-work` is unstructured; `create-spec` **adopt** mode
rewrites that same Issue (preserving its id/assignee/history) into the structured
form first, then bootstrap proceeds identically.

**Epic rollup is read at session boundaries, not by the script.**
`resume-work` reads the Project's Issues from Linear to compute which Story is
next and how many are done — the same infrequent, boundary-only reads as authored
context. The standalone repo-wide progress overview (which Projects/Issues are In
Progress/Todo/Backlog) is the **`linear`** skill's job, not a dev-workflow skill's.
When Linear is unavailable the Epic overview degrades (unavailable) but Story-level
work, driven entirely by local `state.json`, is unaffected.

The `linear` overview reports at **Issue granularity** only; it does not surface
`state.json` step-granularity progress (which step of a Story, which review phase).
That granularity is checked per-unit at resume time via `dev-workflow-resume-work`,
not from a standing overview.

---

## 2. State contract (implemented by `scripts/workflow-state.py`)

### State categories — priority order

Evaluated top-down; first match wins.

The script evaluates **Story** units only (an Epic is a Linear Project, resolved
by consumer skills — see [Linear backing](#linear-backing-bootstrap-contract)).

| Priority | State | Condition |
|----------|-------|-----------|
| 1 | `review_complete` | review present and `phase` = `LGTM` |
| 2 | `in_review` | review present and `phase` ≠ `LGTM` |
| 3 | `potentially_complete` | steps exist and all `done` |
| 4 | `in_progress` | steps exist and some (not all) `done` |
| 5 | `planned` | steps exist and none `done` |
| 6 | `spec_only` | `criteria` exist, no `steps` |
| 7 | `blocked` | implementation cannot proceed (declared, not auto-detected) |

### Next-action dispatch

| State | Action | Dispatch |
|-------|--------|----------|
| `spec_only` | Create implementation plan | `dev-workflow-create-plan` |
| `planned` | Begin implementation from step 1 | implementation handoff (no skill) |
| `in_progress` | Continue from first unchecked step | implementation handoff (no skill) |
| `potentially_complete` | Run self-review | `dev-workflow-self-review` |
| `in_review` | Resume user review | `dev-workflow-user-review` |
| `review_complete` | Run post-task | `dev-workflow-post-task` |
| `blocked` | Report blockers | (depends on blocker) |

### Legacy value mappings

The review phase/item statuses are read from `review.md` (owned by code-review-session).
The script normalizes these older values when parsing it:

| Legacy value | Normalized to |
|--------------|---------------|
| review phase `COLLECTING FEEDBACK` | `REVIEWING` |
| review phase `READY FOR IMPLEMENTATION` | `REVIEWING` |
| review phase `IMPLEMENTING` | `REVIEWING` |
| item status `APPROACH RECORDED` | `APPROACH PROPOSED` |

Criteria and steps come from `state.json` only — there is **no Markdown fallback**
for them. A Story directory without `state.json` is not a work unit.

---

## 3. Script output contract

`python3 dev-workflow/scripts/workflow-state.py` (run from repo root) prints one JSON object to stdout:

```json
{
  "current_branch": "feat/state-foundation",
  "active_path": ".claude/dev-workflow/story/2026-06-12-feat-state-foundation",
  "work_units": [
    {
      "path": ".claude/dev-workflow/story/2026-06-12-feat-state-foundation",
      "level": "story",
      "title": "state-foundation",
      "branch": "feat/state-foundation",
      "linear_issue_id": "ENG-123",
      "matches_current_branch": true,
      "active": true,
      "state": "in_progress",
      "progress": { "done": 2, "total": 7 },
      "review": { "phase": null, "items": {}, "resolved": "0/0" },
      "next_action": { "label": "Continue implementation", "skill": null }
    }
  ]
}
```

| Field | Meaning |
|-------|---------|
| `current_branch` | `git branch --show-current`. |
| `active_path` | Path of the unit bound to `--session` (or `null` when the session is unbound). See resolution rule below. |
| `work_units[]` | One entry per discovered **Story** (each a directory with `state.json`). Epics are not listed here — consumer skills resolve them from Linear. |
| `.linear_issue_id` | Backing Linear Issue id (or `null`). Passed through from `state.json`. |
| `.matches_current_branch` | `branch` equals `current_branch`. A display hint for interactive skills only; **not** used to select the active unit. |
| `.active` | `true` for the unit equal to `active_path`. **This is what consumers use to pick the unit to act on.** |
| `.state` | Derived category (priority table above). |
| `.progress` | `{done, total}` from steps. |
| `.review` | `{phase, items{status→count}, resolved "done/total"}` — `resolved` is derived, never stored. |
| `.next_action` | `{label, skill}` from the dispatch table; `skill` is `null` for implementation handoff. |

### Active-unit resolution

The active unit is **bound per session, never guessed**. Branch matching is unreliable (a repo may work entirely on `main`, or run several units on one branch), and "most recently modified" leaks a stale unit into every unrelated session in the repo. Instead:

- Each session records which unit it is working on in `root/active/<session_id>.json` (`{"unit": "<abspath>"}`). Skills write this the moment they know their target unit (see _Session binding_).
- `workflow-state.py --session <id>` resolves `active_path` to that pointer's unit (when the directory still exists); a session with **no pointer resolves to `null`** — so passive hooks stay silent in unrelated sessions.
- `matches_current_branch` is reported as a hint but does not select the active unit.

Pointer files are session-local and ephemeral. `--prune` (run on session start) drops pointers whose unit is gone or whose file has aged past 7 days; `dev-workflow-post-task` clears its own on completion.

### Session binding

The session id is the same value on both sides: hooks read `session_id` from their stdin payload (falling back to `$CLAUDE_CODE_SESSION_ID`), and skills read `$CLAUDE_CODE_SESSION_ID`. A skill binds or clears with a single command (no manual file writes):

```bash
# Bind this session to a unit (idempotent; run when the target unit is known)
python3 dev-workflow/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/{level}/{unit-dir}"

# Clear this session's binding (on task completion)
python3 dev-workflow/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --clear
```

Skills that operate on a specific unit (create-spec, create-plan, resume-work, self-review, user-review) **bind** at the point the unit is identified — normally at create-spec, when the Story directory is created. (The `code-review-session` skills that self-review/user-review delegate to do not bind; the dev-workflow wrapper binds before delegating.) `dev-workflow-post-task` **clears**. A unit left mid-flight is rebound by `dev-workflow-resume-work` in the next session (the SessionStart hook injects its summary so no prompt is carried across).

### Consumer rule

Skills that need state (resume-work, self-review) **run the script and read its output**, selecting the unit via `active` / `active_path`. They run the bind/clear command shown above where needed, but must not restate the priority table, legacy mappings, progress-counting rules, or the active-resolution rule — those live only here and in the script.
