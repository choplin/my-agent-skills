---
name: linear-handoff
description: Record an in-progress Linear issue's context as a Handoff note comment so a DIFFERENT session can pick the issue up where this one stopped. Use when work on an issue spans sessions — you are pausing an issue that is still In Progress (not finished) and want the background, discussion, decisions, and next step preserved on the issue itself. Triggers on "hand off this issue", "pause here, save it so I can continue later", "record where we are on this issue", "この issue を引き継げるように残して", "ここで中断、続きは別セッションで", "作業の経緯を issue に残して". Should NOT trigger for finishing an issue (the completion note fires at In Review/Done — see `linear-base`), for continuing a discussion that is not yet a Linear issue (turn it into an issue first — see below), for snapshotting local execution state (that is read back on resume, not written here), or for non-Linear trackers (Jira → jira-cli; GitHub Issues → github tools).
user-invocable: true
---

# Hand off an in-progress Linear issue

Leave a **Handoff note** on a Linear issue that is still **In Progress**, so a fresh session — with no memory of this one — can resume the *same* issue without re-deriving what already happened. This is the mid-work counterpart to `linear-base`'s **completion note**: the completion note records how an issue *finished*; the handoff note records where it *paused*.

It builds on the `linear-base` skill for all status/label/issue semantics and owns the **Handoff note** concept there — read that skill's *Handoff note* subsection for what belongs in the note and what does not. Use whichever Linear MCP server is wired.

## When this applies (and when it does not)

- **Applies:** the issue is In Progress, the work is not done, and the session is ending (or you are switching away) before it finishes. The issue **stays In Progress** — a handoff note is not a status transition.
- **Finished, not paused** → this is a *completion* note, not a handoff. Leave it per `linear-base` at the In Review / Done transition instead.
- **No issue yet** → a discussion worth carrying across sessions belongs in an issue. If the work spanning sessions is not yet a Linear issue, that is itself the thing to fix: create the issue first (via `linear-base`), then hand it off. There is no local-file fallback — the issue is the anchor.

## Flow

### 1. Identify the issue being handed off

Resolve which In Progress issue this session was working, using `linear-base`'s local-side link (in priority order):

- the **worktree note** (`wtm notes show`) if in a worktree started via `linear-start` (it holds the issue identifier),
- otherwise **session context** — the issue named earlier this session.

If none resolves, **ask** the user which issue. Do not guess.

### 2. Align on what happened — before writing anything

Writing the note surfaces mismatches between your account and the user's. Summarize back, and confirm with the user:

- **Goal** — what this issue is trying to achieve (as understood now, which may be sharper than the groomed description).
- **Decisions made while working** — each with its rationale, and alternatives rejected.
- **Open questions** — what is still undecided.
- **Current state** — where the work actually stands right now, and the concrete **next step** a resumer should take first.

If the user corrects any of it, realign before drafting. An aligned account is the whole value of the note.

### 3. Draft the Handoff note

Write the note in the issue's own terms, following the *Handoff note* content standard in `linear-base`. In short — record **what a fresh reader cannot reconstruct from git and the tracked artifacts**:

- the **why / 経緯 / discussion** that led here, the **decisions** (with rationale and rejected alternatives), the **open questions**, and the **next step**.

Do **not** re-describe the diff (git holds it) or transcribe local execution state — `state.json`, plan files, loop artifacts are read directly on resume (see step 5). The note carries the judgement those files cannot.

Keep it proportional to how far the work diverged from the groomed plan: a clean pause needs a few lines; a session full of pivots needs the decisions spelled out.

### 4. Verify the note is self-complete

The note has to stand on its own for a session that knows only the issue ID. Hand the **drafted note text alone** (not this conversation) to a subagent (Task tool) and ask it to reconstruct, from that text only:

1. the **goal** of the work,
2. the **decisions** made and **why** each was made,
3. the **open questions**,
4. the **current state** and the **next step**.

**Pass** = the subagent answers all four consistently with your understanding. **Fail** (revise and re-verify) = it cannot state the goal, lists a decision but cannot explain why, misses an open question, or says it lacks information. Fix the gap in the note, not in a side channel.

### 5. Post the note and report

- Post the verified note as a **comment on the issue** (the issue stays In Progress — do not transition it).
- Per `linear-base`'s *Linear references stay internal*, the note lives on the issue only; do not copy it into commits, branch names, or PR text.
- Tell the user it is recorded, and how the next session resumes: `linear-start` (pick the In Progress issue) reconstructs from this note plus git and the execution artifacts. The resumer does not need a pasted prompt — the issue carries the context.

## Success criteria

- [ ] The correct In Progress issue is identified (not guessed).
- [ ] The account was aligned with the user before drafting.
- [ ] The note records why/decisions/open/next — not a diff or a local-state dump.
- [ ] A subagent reconstructed goal, decisions+rationale, open questions, and next step from the note alone.
- [ ] The note is posted as an issue comment; the issue remains In Progress.
