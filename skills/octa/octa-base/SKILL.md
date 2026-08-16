---
name: octa-base
description: >-
  Defines the complete repository-work lifecycle for the local octa CLI using
  finite Projects and atomic Issues. Use when structuring or managing octa work
  from capture and grooming through ownership, review, integration, handoff,
  and completion.
---

# Octa operating conventions

Use octa as the durable, repository-scoped work record for solo development
across agents and sessions. octa stores coordination data locally; Git stores
code and diffs. Run commands inside the target Git repository and prefer
`--json` for machine-readable output.

Before using an unfamiliar command, run `octa --help` and the relevant nested
`--help`. If `octa` is unavailable, stop and report that the CLI must be
installed; do not silently fall back to another tracker or a local markdown
task list.

## Route recurring work

| Work | Skill |
|---|---|
| Survey current work | `octa-overview` |
| Pick up or resume one Issue | `octa-start` |
| Turn Backlog into ready Todo work | `octa-groom` |
| Pause unfinished work for another session | `octa-handoff` |
| Create, comment, transition, or close one record | Follow this skill directly |

## Model

| Primitive | Treatment |
|---|---|
| Repository | The Git common directory is the scope. Worktrees of one repository share octa data. Do not add Repo labels. |
| Project | A finite outcome that can complete, never a permanent repository bucket. Project state and `status_type` describe the outcome lifecycle. |
| Milestone | An ordered phase within a Project. Add only when the outcome has distinct stages. |
| Issue | One atomic deliverable: one coherent code change, one decision, or one research result. It may exist without a Project. |
| Parent/sub-issue | Use only for a small effort containing a few atomic deliverables. Do not use hierarchy for execution order. |
| Relations | Use `blocked by` for required order and `related` for non-ordering context. |
| Pull Request | A local branch-associated discussion record. Git remains authoritative for commits, diffs, and forge integration. PR use is optional; integration evidence is not. |
| Label | Repository-defined opaque classification. Use the `Type` single-select group described below; do not build repo identity into labels. |
| Priority | `1` Urgent, `2` High, `3` Medium, `4` Low, `0` None. |
| Lease | Non-expiring coordination handle that atomically claims an Issue for one active session. It is not a security credential or a status. |

## CLI contract

Read [cli-contract.md](references/cli-contract.md) before using Issue leases,
GraphQL queries, or Issue list state selectors. It records product mechanics
only; this skill owns the lifecycle policy built on them.

## Required repository setup

Read [repository-setup.md](references/repository-setup.md) before first use in a
repository. Every repository uses the same six states — Backlog, Todo, In
Progress, In Review, Done, and Canceled — so name them directly. States carry
no ordering; nothing about a state is derived from where it appears in
`config state list`.

## Todo authoring standard

A Todo Issue must be executable by a fresh agent with no conversation history.
Its body must contain:

- **What & why** — requested change and reason.
- **Where** — concrete repository areas, files, or entry points.
- **Inputs** — completed blocker outcomes, decisions, or external artifacts it
  must consume. Omit only when the repository and Issue contain everything.
- **Acceptance** — observable completion behavior and relevant checks.
- **Constraints** — scope exclusions and choices that must not be guessed.

Before moving an Issue from Backlog to Todo, ask: can a fresh agent produce the
deliverable from this Issue and its explicitly named completed inputs without
asking for missing requirements? If not, leave it in Backlog.

Backlog is rough capture and has no self-completeness bar.

## Grouping and ordering

Decide grouping and order independently:

- One deliverable: one Issue.
- A few deliverables in one small effort: parent Issue plus atomic sub-issues.
- A finite outcome: Project, optionally with Milestones.
- When B needs A's completed outcome, add A as B's blocker. Hierarchy alone
  never implies order.

If grooming reveals a Project-sized outcome, create the Project and constituent
Issues. Reuse the original as one constituent when useful; otherwise mark it
Canceled after recording what superseded it. Never mark unperformed work Done.

## Type labels

Create an Issue label group `Type` with single selection and these labels:

- `impl` — repository change intended for commit or integration.
- `design` — a decision or ADR.
- `research` — findings or an investigation result.

Every Todo Issue has exactly one of these three Types. A documentation change committed to a
repository is `impl`; an independent findings document is `research`.

Do not create `Type/orchestration` until an installed execution workflow has an
octa-backed control-record contract. Current planning and orchestration skills
may be Linear-specific; advertising an unroutable Type would strand work.

## Lifecycle

| State | Status type | Meaning |
|---|---|---|
| Backlog | `backlog` | Captured, not groomed. |
| Todo | `unstarted` | Groomed and executable. |
| In Progress | `started` | Actively owned and being worked. |
| In Review | `started` | Awaiting human review or integration. |
| Done | `completed` | Accepted and integrated/shipped when applicable. |
| Canceled | `canceled` | Dropped or superseded. |

`status_type` is the coarse classification used by filters such as
`issue list --status-type`; it does not identify a state. In Progress and In
Review both carry `started`, so only the name distinguishes them. If a
repository is missing one of these six states, report that instead of
substituting another one. Apply transitions:

- Capture into Backlog.
- Groom Backlog to Todo only after the authoring gate passes.
- On start, acquire the Issue lease and move Todo/Backlog to In Progress with
  that lease ID.
- Move In Progress to In Review when presenting an implementation for human
  review or when an integration PR is open.
- Keep an `impl` Issue In Review through feedback, corrections, approval,
  commit, and integration. Return it to In Progress only when the user
  explicitly sends it back.
- Move to Done only when the deliverable is accepted and an implementation is
  integrated, unless the user explicitly accepts an unintegrated exception.
- Keep unfinished cross-session work In Progress and use `octa-handoff`.
- Release the lease after Done or Canceled. Do not force-release a lease merely
  because its holder is unknown.

### Implementation completion procedure

For every `impl` Issue, read and apply
[implementation-completion.md](references/implementation-completion.md) from
pre-commit review through its terminal outcome. It is the single source of
truth for the review brief, feedback cycle, commit-only exception, nested
commit handoff, integration evidence, lease release, final status, and cleanup.
Caller skills must invoke that procedure, not restate it.

### Completion comment

When a completed deliverable enters final integration review, or goes directly
to Done, add an Issue comment recording:

- decisions made during execution and why;
- what changed or was concluded;
- acceptance evidence and checks;
- for `impl`, target branch and integration evidence, or the explicit exception.

Keep it proportional. If execution followed the groomed plan exactly, say so.
Do not paste diffs or raw test logs; Git and CI hold those.

### Handoff comment

When a session ends with an Issue still In Progress, record the goal, decisions
and rationale, rejected alternatives, open questions, current state, and next
concrete step. Keep the lease only while the same live session will continue
imminently; otherwise release it after posting the handoff so another session
can claim the Issue. Never put the lease ID in an Issue, worktree note, Git
artifact, or user-facing report. Use `octa-handoff` for the full flow.

### Cleanup

After Done, read [worktree-cleanup.md](references/worktree-cleanup.md). Remove an
isolated worktree and local work branch only after verifying integration,
cleanliness, and identity.

## Octa references stay local

Issue numbers are repository-local coordination references. Keep them in octa
comments, local session context, and worktree notes. Do not put octa Issue or PR
numbers into commits, branch names, repository files, or forge PR text. If a
forge PR is used, record its URL in an octa Issue or PR comment so the durable
link points from the local tracker to the external artifact.

## Core CLI mapping

Use exact help as the source of truth. Common operations are:

```sh
octa project list --active --json
octa project show <project> --json
octa issue list --all --json
octa issue list --status-type backlog --project <project> --json
octa issue list --unblocked --json
octa issue show <number> --json
octa issue create --title <title> --body <body> --state <state> --json
octa issue comment <number> --body <text>
LEASE=$(octa issue lock <number>)
octa issue set <number> --body <body> --priority <0-4> --project <project> --lease "$LEASE"
octa issue add <number> --label <label> --lease "$LEASE"
octa issue add <number> --blocker <blocker-number> --lease "$LEASE"
octa issue set-state <number> <state> --lease "$LEASE"
octa issue unlock <number> --lease "$LEASE"
```

Never scrape human-readable tables when JSON is available. Inspect before
mutating, and keep updates scoped to the current repository.
