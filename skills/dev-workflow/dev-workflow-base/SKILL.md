---
name: dev-workflow-base
description: Shared resources for the dev-workflow skill family — the work-unit state schema, document templates (spec/plan/epic/review), plan-mode context template, review init guide, workflow concepts, and the workflow-state evaluator script. Other dev-workflow skills delegate to this skill to read a template or run the state evaluator. Use this skill when another dev-workflow skill asks to apply a template, follow the state schema, or evaluate work-unit state. Not typically invoked on its own.
---

# dev-workflow base resources

This skill owns the resources shared across the dev-workflow skill family. Other
dev-workflow skills **delegate to this skill by name** instead of referencing
plugin-root paths, so the same skills work whether installed flat by the skills
CLI or loaded as part of a plugin.

Other dev-workflow skills refer to resources here using two forms. In both,
resolve the path **relative to this skill's installed directory** (load this
skill, then read/run the named file from its own root):

- `` `dev-workflow-base` skill (`references/<file>`) `` → read `references/<file>` from this skill.
- `dev-workflow-base/scripts/workflow-state.py` → run this skill's state evaluator (see below).

## References

| Resource | File | Used for |
|----------|------|----------|
| State schema | `references/state-schema.md` | Work-unit state, Linear backing (bootstrap contract), legacy-value mappings, progress counting, active-unit resolution |
| Spec template | `references/spec-template.md` | Structure of a Story Issue's spec (its Linear Issue description) |
| Plan template | `references/plan-template.md` | Structure of the `## Plan` section appended to a Story Issue |
| Epic template | `references/epic-template.md` | Structure of an Epic's Linear Project description |
| Plan-mode context | `references/plan-mode-context.md` | The `## dev-workflow Context` block added to Claude Code plan files |
| Workflow concepts | `references/workflow-concepts.md` | Epic/Story/Task model and promotion flow |

> **Review resources moved.** `review.md` and its templates now live in the
> **`review-tools`** skill family (`review-tools-base` skill: `references/review-template.md`,
> `references/review-init-guide.md`, `references/review-state.md`). dev-workflow's
> review phase delegates to review-tools (`review-tools-ai-review` to record findings,
> `review-tools-resolve` to work them, `review-tools-report` to summarize). The state
> evaluator reads the review phase (`open`/`done`) and item statuses from `review.md` —
> there is no `review` block in `state.json`.

## State evaluator script

`scripts/workflow-state.py` is the single implementation of the state rules
documented in `references/state-schema.md`. Run it relative to this skill's root:

```bash
python3 scripts/workflow-state.py
```

It returns every work unit's derived `state`, `progress`, `review`, `active`,
and `next_action`, plus a top-level `active_path`. Do not restate or recompute
its rules elsewhere — delegate to it.

> The dev-workflow Claude Code add-on (`opts/claude/skills/dev-workflow/`) ships
> a copy of this script (a symlink to this one) so its SessionStart/Stop hooks
> can resolve it via `${CLAUDE_PLUGIN_ROOT}/scripts/workflow-state.py`.
