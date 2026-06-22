# State Schema & State Contract

Single source of truth for dev-workflow state. Two things live here:

1. **`state.json` on-disk schema** — the machine-managed state of a work unit.
2. **State contract** — the state-category priority order, legacy-value mappings, and next-action dispatch that `scripts/workflow-state.py` implements and that consumer skills rely on.

No other file should restate the priority table or legacy mappings. Skills reference this document and run the script instead.

---

## 1. `state.json` on-disk schema

**Location**: one `state.json` per Story or Task work unit, alongside its other documents:

- Story: `.claude/dev-workflow/story/{story-dir}/state.json`
- Task: `.claude/dev-workflow/task/{task-dir}/state.json`

Epics do **not** use `state.json`. Epic status is derived from the `## Stories` table in `epic.md`.

**Principle — store only machine-managed, non-derived state.** Do not store values that can be computed from other fields (e.g., a "resolved 2/5" counter, or the derived state category). The script computes those at read time.

```json
{
  "schema": 1,
  "level": "story",
  "title": "state-foundation",
  "branch": "feat/state-foundation",
  "criteria": [
    { "id": 1, "name": "State evaluation unified", "verify": "python3 dev-workflow/scripts/workflow-state.py", "passes": false, "evidence": null }
  ],
  "steps": [
    { "id": 1, "name": "Prune plan-mode-context duplication", "done": false }
  ],
  "review": {
    "phase": "REVIEWING",
    "mode": "ITERATIVE",
    "items": [
      { "id": 1, "status": "OPEN", "classification": "Minor", "source": null }
    ]
  }
}
```

### Field reference

| Field | Type | Meaning |
|-------|------|---------|
| `schema` | int | Schema version. Currently `1`. |
| `level` | string | `"story"` or `"task"`. |
| `title` | string | Human title (mirrors the `# Spec:`/`# Plan:` title). |
| `branch` | string \| null | Git branch for this work unit. `null` for Task (no plan) without a dedicated branch. |
| `criteria` | array | Acceptance criteria (Story) / completion criteria (Task). Owned by spec/plan. |
| `criteria[].id` | int | Stable id. |
| `criteria[].name` | string | Criterion name. |
| `criteria[].verify` | string \| null | Executable command that returns pass/fail, or `null` if not machine-verifiable (→ always human review). Populated by create-spec; **execution is out of scope until Story #3**. |
| `criteria[].passes` | bool | **Initialized `false` (Default-FAIL).** May only become `true` with `evidence`. |
| `criteria[].evidence` | string \| null | What proves the pass (command output summary, file path, etc.). |
| `steps` | array | Implementation steps. Owned by plan. |
| `steps[].id` | int | Stable id. |
| `steps[].name` | string | Step name. |
| `steps[].done` | bool | Completion flag. Mirrors plan.md `## Progress`. |
| `review` | object \| null | Review state. `null` until review starts. |
| `review.phase` | string | `"REVIEWING"` or `"LGTM"`. |
| `review.mode` | string | `"ITERATIVE"` or `"BATCH"`. |
| `review.items[]` | array | Review items. |
| `review.items[].id` | int | Stable id. |
| `review.items[].status` | string | See item-status enum below. |
| `review.items[].classification` | string | `"Minor"`, `"Complex"`, or `"Design Change"`. |
| `review.items[].source` | string \| null | Origin (e.g. `"PR #42 comment:123 (inline)"`) or `null` for direct user feedback. |

### Enums

- **review.phase**: `REVIEWING`, `LGTM`
- **review.items[].status**: `OPEN`, `APPROACH PROPOSED`, `APPROACH AGREED`, `IMPLEMENTING`, `RESOLVED`, `SKIPPED`
- **review.items[].classification**: `Minor`, `Complex`, `Design Change`

### Default-FAIL contract

`criteria[].passes` starts `false` and may only be set `true` together with a non-null `evidence`. Removing or weakening a criterion to make it pass is not allowed. (Enforcement of execution lands in Story #3; this Story only establishes the field and the rule.)

---

## 2. State contract (implemented by `scripts/workflow-state.py`)

### State categories — priority order

Evaluated top-down; first match wins.

| Priority | State | Condition |
|----------|-------|-----------|
| 1 | `review_complete` | review present and `phase` = `LGTM` |
| 2 | `in_review` | review present and `phase` ≠ `LGTM` |
| 3 | `potentially_complete` | steps exist and all `done` |
| 4 | `in_progress` | steps exist and some (not all) `done` |
| 5 | `planned` | plan/steps exist and none `done` |
| 6 | `spec_only` | spec exists, no plan/steps |
| 7 | `epic_next_story` | epic with one or more `Not Started` stories |
| 8 | `blocked` | implementation cannot proceed (declared, not auto-detected) |

**Epic state derivation** (the `## Stories` table Status column is located by header name, tolerating both `| # | Story | Status | Dependencies |` and `| Story | Status | Spec | Plan |` layouts):

- no stories → `blocked`
- any `Not Started` → `epic_next_story`
- all `Done` → `review_complete`
- otherwise (some past `Not Started`, not all `Done`) → `in_progress`

### Next-action dispatch

| State | Action | Dispatch |
|-------|--------|----------|
| `spec_only` | Create implementation plan | `create-plan` |
| `planned` | Begin implementation from step 1 | implementation handoff (no skill) |
| `in_progress` | Continue from first unchecked step | implementation handoff (no skill) |
| `potentially_complete` | Run self-review | `self-review` |
| `in_review` | Resume user review | `user-review` |
| `review_complete` | Run post-task | `post-task` |
| `epic_next_story` | Start next Story | `create-spec` |
| `blocked` | Report blockers | (depends on blocker) |

### Legacy value mappings (backward compatibility)

The script normalizes these when reading older Markdown or `state.json`:

| Legacy value | Normalized to |
|--------------|---------------|
| review phase `COLLECTING FEEDBACK` | `REVIEWING` |
| review phase `READY FOR IMPLEMENTATION` | `REVIEWING` |
| review phase `IMPLEMENTING` | `REVIEWING` |
| item status `APPROACH RECORDED` | `APPROACH PROPOSED` |

### Markdown fallback (no `state.json`)

When a work unit has no `state.json`, the script derives the same fields from existing Markdown:

- **review.phase**: from `review.md` line `- **Phase**: {value}` (apply legacy mapping).
- **steps / progress**: from `plan.md` `## Progress` — count `- [x]` (done) and `- [ ]` (pending).
- **criteria**: from `spec.md` `## Acceptance Criteria` scenarios (names only; `verify`/`passes` unknown → `verify: null`, `passes: false`).
- **epic stories**: from `epic.md` `## Stories` table Status column.

A one-time migration is **not** performed; fallback keeps existing work units readable.

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
      "matches_current_branch": true,
      "active": true,
      "state": "in_progress",
      "progress": { "done": 2, "total": 7 },
      "review": { "phase": null, "items": {}, "resolved": "0/0" },
      "next_action": { "label": "Continue implementation", "skill": null },
      "source": "state_json"
    }
  ]
}
```

| Field | Meaning |
|-------|---------|
| `current_branch` | `git branch --show-current`. |
| `active_path` | Path of the unit bound to `--session` (or `null` when the session is unbound). See resolution rule below. |
| `work_units[]` | One entry per discovered epic/story/task. |
| `.matches_current_branch` | `branch` equals `current_branch`. A display hint for interactive skills only; **not** used to select the active unit. |
| `.active` | `true` for the unit equal to `active_path`. **This is what consumers use to pick the unit to act on.** |
| `.state` | Derived category (priority table above). |
| `.progress` | `{done, total}` from steps. |
| `.review` | `{phase, items{status→count}, resolved "done/total"}` — `resolved` is derived, never stored. |
| `.next_action` | `{label, skill}` from the dispatch table; `skill` is `null` for implementation handoff. |
| `.source` | `"state_json"` or `"markdown_fallback"`. |

### Active-unit resolution

The active unit is **bound per session, never guessed**. Branch matching is unreliable (a repo may work entirely on `main`, or run several units on one branch), and "most recently modified" leaks a stale unit into every unrelated session in the repo. Instead:

- Each session records which unit it is working on in `root/active/<session_id>.json` (`{"unit": "<abspath>"}`). Skills write this the moment they know their target unit (see _Session binding_).
- `workflow-state.py --session <id>` resolves `active_path` to that pointer's unit (when the directory still exists); a session with **no pointer resolves to `null`** — so passive hooks stay silent in unrelated sessions.
- `matches_current_branch` is reported as a hint but does not select the active unit.

Pointer files are session-local and ephemeral. `--prune` (run on session start) drops pointers whose unit is gone or whose file has aged past 7 days; `post-task` clears its own on completion.

### Session binding

The session id is the same value on both sides: hooks read `session_id` from their stdin payload (falling back to `$CLAUDE_CODE_SESSION_ID`), and skills read `$CLAUDE_CODE_SESSION_ID`. A skill binds or clears with a single command (no manual file writes):

```bash
# Bind this session to a unit (idempotent; run when the target unit is known)
python3 dev-workflow/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/{level}/{unit-dir}"

# Clear this session's binding (on task completion)
python3 dev-workflow/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --clear
```

Skills that operate on a specific unit (create-spec, create-plan, resume-work, self-review, user-review, import-pr-comments, reply-to-pr-comments) **bind** at the point the unit is identified. A Task has no directory until self-review creates one, so a Task session is first bound there. `post-task` **clears**. Read-only overviews (workflow-status) and `handoff` do not bind; a handed-off unit is rebound by `resume-work` in the next session.

### Consumer rule

Skills that need state (resume-work, handoff, workflow-status, self-review) **run the script and read its output**, selecting the unit via `active` / `active_path`. They run the bind/clear command shown above where needed, but must not restate the priority table, legacy mappings, progress-counting rules, or the active-resolution rule — those live only here and in the script.
