---
name: artifact-review-toolkit-quick
description: >-
  Runs a one-off AI code review of a change and returns the findings directly
  in the conversation. Applies when someone asks to review a diff, code-review
  the changes, or get an AI read on what was just written, and the findings
  themselves are the deliverable.
allowed-tools: Read, Glob, Grep, Bash, Skill, Task
metadata:
  description-role: trigger
---

# Quick Review

Get an ordinary AI code review of a change, using the best reviewer the host
already has. This skill is a **redirect**, not a review procedure: it decides who
reviews and normalizes what comes back.

## Input

- `scope` — the change to review (default: current branch diff).
- `reviewer` — optional; a specific reviewer to use. Honor it when given.

## Process

### 1. Select the reviewer

Use the caller's `reviewer` when one is named. Otherwise pick the first that the
host actually provides:

1. the host's own code-review command (e.g. `/code-review`);
2. a code-review subagent the host exposes (e.g. `feature-dev:code-reviewer`);
3. a code-review capability from another CLI available on this machine (e.g.
   `codex:review`);
4. failing all of those, review the diff inline.

Do not invent a capability the host does not have. Name the one you used in the
report — the choice is meant to be swappable, and the caller needs to know which
reviewer produced the findings.

### 2. Run the review over `scope`

Ask the selected reviewer for **discrete findings**. Each finding must carry:

- a one-line summary;
- the location (file and, where it applies, line);
- the detail — what is wrong and why it matters;
- a severity, if the reviewer offers one (optional metadata; this skill does not
  gate on it).

### 3. Return the findings

Report the findings directly, grouped by location, with the reviewer named. Do not
create a review record, do not fix anything, and do not gate.

When there are findings a caller may want to track, say so and point at
`code-review-session-import-ai` — but do not create the record here.

## When something heavier is needed

Escalate to `artifact-review-toolkit-adversarial` when the change carries broad
blast radius, low reversibility, weak executable evidence, or a completion claim
that must be falsified against explicit acceptance criteria. That skill selects
review lenses and runs independent reviewers; this one does not.

## Success Criteria

- [ ] The reviewer used is a capability the host actually provides, and is named in
      the report
- [ ] Findings are discrete, each with summary, location, and detail
- [ ] Nothing is fixed, recorded, or gated
- [ ] Heavier review needs are redirected to `artifact-review-toolkit-adversarial`
      rather than approximated here
