---
name: exec-plan-base
description: >-
  Shared resources for the exec-plan skill — the self-contained ExecPlan-style plan file
  format, its on-disk location convention, and the principles that keep a plan restartable on its
  own. exec-plan delegates here for the file it drives. Use this skill when exec-plan asks to apply
  the plan file format or follow the location convention. Not typically invoked on its own.
user-invocable: false
allowed-tools: Read, Write, Edit, Glob, Bash
---

# Exec Plan — Base

The shared plan artifact for the exec-plan skill. Keeping the file format and
location here — separate from the skill that drives the file — is what lets a
plan written in one session be picked up in a later one: the format is the
stable contract a fresh reader resumes from. `exec-plan` writes and drives this
file.

This format adapts OpenAI's ExecPlan / PLANS.md — self-contained, self-driving
plans (https://developers.openai.com/cookbook/articles/codex_exec_plans).

## What makes the file work

These properties are the point of the format — preserve them however the file is
written:

- **Single living document.** One Markdown file is the whole plan. Update it in
  place as things change; don't scatter state across notes.
- **Self-contained.** No external references — embed the knowledge each step
  needs, so a fresh reader (a later session, or a different skill) can resume from
  the file alone. This is what makes it referenceable across sessions.
- **Observable acceptance.** Acceptance is behavior a human can see, not internal
  code properties.
- **Repo-relative paths.** So the file survives being read from anywhere.

## Location

Persist at `.agents/exec-plans/{yyyy-mm-dd}-{slug}.md`. Ensure `.agents/` is
git-ignored (add it if missing). The file lives on disk across sessions even
though it isn't committed, which is what allows later sessions to reference it.

## Plan file template

```markdown
# {Goal title}

## Purpose / Big Picture
{What we want and why — the agreed direction. What a human sees when it works.}

## Boundaries
- Free to decide: {scope that may be resolved without asking}
- Defer / park: {kinds of calls to leave open for the user}
- Out of scope: {what not to touch}

## Acceptance
- {Observable behavior a human can verify.}

## Progress
- [ ] {step}
- [x] (YYYY-MM-DDThh:mmZ) {done step}
- [ ] {step} — blocked by: {which open item}

## Decision Log
- (YYYY-MM-DD) {decision} — {why}.

## Parking Lot
- [ ] {open decision} — {why it's open}; blocks {which Progress steps};
      options: {A / B}; leaning: {if any}.

## Surprises & Discoveries
- {unexpected behavior + evidence}
```

## Section semantics

The sections are stable so the file stays interoperable, but the invoking skill
gives them their workflow meaning:

- **Decision Log** — decisions already settled, each with its rationale. `exec-plan`
  fills this live with reversible two-way-door calls it made while driving.
- **Parking Lot** — decisions still open. `exec-plan` parks high-impact / one-way-door
  calls here for a single batch review at the end.

`exec-plan` reads the format and location from here rather than restating the
template. The surrounding workflow (how the file gets filled, and whether it is
then driven) belongs to the invoking skill, not to this base.
