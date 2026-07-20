---
name: project-notes-distill
description: Distill project knowledge into a typed long-term note in the Project Notes Obsidian vault (the durable Notes layer), organized per repository. Use when the user wants to record a decision and its rationale, a reusable concept, a proposal draft, or a durable handoff — shaping it into something readable months later. Triggers on "蒸留して残して", "ちゃんとまとめて残して", "この決定を記録", "distill this into a note", "record this decision/concept". Should NOT trigger for quick raw capture without shaping (use project-notes-capture); saving transient state to resume the SAME session shortly (keep it in session); updating in-repo docs, README, or code comments (this targets the external Obsidian vault only); TODO lists; or committing code.
allowed-tools: Read, Write, Glob, Bash, AskUserQuestion
user-invocable: true
---

# Project Notes: Distill Long-term Note

Shape project knowledge into a durable, typed note in the vault's **Notes** layer.

Read `project-notes-base` and run its "Resolving the Anchor" step first — it is
mandatory and gives you `<anchor>` (the in-repo symlink into the vault). This
skill only handles the distillation half.

## Note Types (filename prefix in `Notes/`)

| Prefix        | Use for |
|---------------|---------|
| `Concept - `  | A reusable analytical lens or concept |
| `Decision - ` | A decision with its rationale (decision record) |
| `Proposal - ` | A draft proposal / pitch |
| `Handoff - `  | Durable handoff across environments / people / days |
| `PRD - `      | A foundational PRD — what this is and why, as a long-term anchor. Usually written by `inception-finalize` (the inception family's exit), not shaped here by hand. |

- **When a note spans several types, `Decision` and `Proposal` outrank `Concept`
  and `Handoff`** (the decision or proposal is the actionable payload). Use
  AskUserQuestion only when none clearly fits better.
- **Handoff vs a transient pause**: a `Handoff - ` note is a *durable* record
  for another environment, another person, or resuming after days. If the user
  just wants to pause and resume the *same* work shortly, that is not a note at
  all — keep it in session; a Linear issue that genuinely spans sessions records
  its pickup context on the issue via `linear-handoff`.

## Workflow

1. Resolve the anchor (see `project-notes-base`, MUST run first).
2. Pick the note type (prefix) using the precedence rule above.
3. Write `<anchor>/Notes/<Prefix> - <concise title>.md` with light frontmatter
   (below), meeting the success criteria.
4. Add `[[Note name]]` links to related existing notes (Glob `<anchor>/Notes/`
   to find them) to weave the knowledge.
5. If distilling from `Inbox/`, tell the user which raw notes are now redundant
   and can be deleted (do not delete them yourself unless asked).

## Frontmatter (keep it light)

```markdown
---
repo: <repo-name>
type: concept | decision | proposal | handoff | prd
created: YYYY-MM-DD
---
```

Get `created` from `date +%F` (do not guess it).

## Success Criteria

Before presenting a distilled note, verify:

- [ ] **Self-contained**: readable months later without the session context.
- [ ] **Rationale present** (for `Decision`): states the decision AND *why*,
      including alternatives rejected. "Chose X because Y, not Z because W."
- [ ] **Reusable** (for `Concept`): describes when the lens applies, not just a
      one-off observation.
- [ ] **Actionable** (for `Handoff`): states current state, the next action, and
      where to resume.
- [ ] **Concrete**, not generic. Good: "Sync API blocks rendering because the
      main thread handles both UI and network." Bad: "Performance matters."
- [ ] **Linked**: references related notes with `[[...]]` where relevant.
- [ ] **Correct location & prefix**: under `<anchor>/Notes/` with a valid prefix.
