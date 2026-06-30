---
name: exec-plan-record
description: >-
  Invoked explicitly by the user (e.g. /exec-plan-record); does not auto-activate. Write the current
  session out to a durable, self-contained plan file — reconstruct from the conversation so far what
  the goal is, which decisions are already made and why, what's done, and what's left — so the work
  can be referenced and resumed across later sessions. Use mid-work when a task is growing and you
  want one anchor document, for "write down where we've gotten to", "capture the goal and what's
  left", "save this so we can pick it up later". Writes the same plan file as exec-plan but does not
  drive anything. Not for agreeing a fresh goal and running it autonomously (use exec-plan), saving a
  pure design discussion for a future session (use discussion-continuity-continue-discussion), or
  snapshotting a dev-workflow work unit for /clear (use dev-workflow-handoff).
user-invocable: true
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Glob, Bash, Skill, AskUserQuestion
---

# Exec Plan — Record

Take the session as it stands and write it out as one self-contained plan file:
the goal, what's already been decided and why, what's done, and what's left. The
point is to have a single durable artifact you can reference and resume from in a
later session — not to start or drive any work.

This writes the **same** file format and location as `exec-plan` (defined in
`exec-plan-base`), so a recorded plan can later be handed to `exec-plan` to drive,
or just reread by a future session. The difference from `exec-plan` is direction
and scope: `exec-plan` agrees a goal up front and runs it autonomously; this skill
looks **backward** over the conversation and only captures — it never executes.

## Workflow

### 1. Reconstruct from the conversation

Read back over the session and pull out, from what was actually said and done:

- **Purpose / Big Picture** — what we're trying to achieve and why.
- **Decisions already made** — each with its rationale ("we chose X because Y").
- **Progress** — what's done versus what's still outstanding.
- **Open / remaining** — unresolved decisions and questions, and what they block.
- **Surprises & discoveries** — anything learned that a resumer would need.
- **Boundaries** — only if scope or out-of-scope lines actually came up.

Embed the knowledge each item needs, so the file stands on its own (see the
self-containment properties in `exec-plan-base`). Don't invent direction the
session didn't establish — if the goal or a decision is genuinely unsettled,
record it as open rather than guessing.

### 2. Align in one pass

Writing it down often surfaces a gap between your reconstruction and the user's
intent. Summarize what you captured — purpose, key decisions, progress, what's
left — and confirm it's right before saving. This is a single lightweight check,
not a verification loop; if it's off, correct and move on.

### 3. Write the file

Write the plan to the location and format from `exec-plan-base`. Map what you
reconstructed onto the template: settled calls go in **Decision Log**; open
questions and remaining decisions go in **Parking Lot**; done/outstanding steps go
in **Progress**. Use repo-relative paths and observable acceptance.

### 4. Hand off

Tell the user the file path, and that any later session can resume by reading it
alone. If they want it executed rather than just recorded, point them at
`exec-plan` to drive the same file.

## Gotchas

- **Record, don't drive.** This skill stops after writing. Don't start
  implementing the remaining steps — if the user wants autonomous execution, that's
  `exec-plan`.
- **Don't fabricate to fill the template.** Empty sections are fine. A purpose or
  decision the session never actually reached is recorded as open, not invented.
- **Self-contained or it's useless.** The value is cross-session resumability; if
  an entry only makes sense with this conversation in context, embed that context.

## Success criteria

- [ ] Purpose, decisions-so-far (with rationale), progress, and open items were reconstructed from the actual conversation.
- [ ] The reconstruction was confirmed with the user in one pass before saving.
- [ ] The file uses the `exec-plan-base` format and location and is self-contained — a fresh session could resume from it alone.
- [ ] Nothing was driven or implemented; the skill only wrote the file.

## When NOT to use

- You want to agree a goal and have it run autonomously → `exec-plan`.
- The work belongs in a dev-workflow unit and you're snapshotting it for `/clear` → `dev-workflow-handoff`.
- It's a pure design/requirements discussion to continue in a future session, needing rationale-verified capture → `discussion-continuity-continue-discussion`.
- The concept is still fuzzy and needs shaping, not recording → `inception`.
