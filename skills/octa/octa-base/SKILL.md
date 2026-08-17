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
| Repository | The Git common directory is the scope of Issues, Projects, PRs, and Wiki pages. Worktrees of one repository share octa data. Do not add Repo labels. |
| Project | A finite outcome that can complete, never a permanent repository bucket. A Project carries a free-form state name plus a terminal flag that decides whether it is still active. |
| Milestone | An ordered phase within a Project. Add only when the outcome has distinct stages. |
| Issue | One atomic deliverable: one coherent code change, one decision, or one research result. It may exist without a Project. |
| Parent/sub-issue | Use only for a small effort containing a few atomic deliverables. Do not use hierarchy for execution order. |
| Relations | Use `blocked by` for required order and `related` for non-ordering context. |
| Pull Request | A local branch-associated discussion record. Git remains authoritative for commits, diffs, and forge integration. PR use is optional; integration evidence is not. |
| Label | Opaque classification defined once for the whole octa store, not per repository. Use the `Type` single-select group described below; do not build repo identity into labels. |
| Ordering | octa stores no priority and no state ordinal. Rank work by resolved blockers, Project and Milestone placement, and Issue number as creation order. |
| Lease | Non-expiring coordination handle that atomically claims an Issue for one active session. It is not a security credential or a status. |

## CLI contract

Read [cli-contract.md](references/cli-contract.md) before using Issue leases,
GraphQL queries, or Issue list state selectors. It records product mechanics
only; this skill owns the lifecycle policy built on them.

## Required workflow configuration

Read [workflow-configuration.md](references/workflow-configuration.md) before
first lifecycle use. States and labels are configured once for the whole octa
store and govern every repository in it, so the six states — Backlog, Todo, In
Progress, In Review, Done, and Canceled — are the same everywhere and are named
directly. States carry no ordering; nothing about a state is derived from where
it appears in `config state list`.

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

One Issue label group `Type` with single selection governs the whole store and
holds these labels:

- `impl` — repository change intended for commit or integration.
- `design` — a decision or ADR.
- `research` — findings or an investigation result.

Every Todo Issue has exactly one of these three Types. A documentation change committed to a
repository is `impl`; an independent findings document is `research`.

Do not create `Type/orchestration` until an installed execution workflow has an
octa-backed control-record contract. Current planning and orchestration skills
may be Linear-specific; advertising an unroutable Type would strand work.

## Lifecycle

| State | Flags | Meaning |
|---|---|---|
| Backlog | starting | Captured, not groomed. New Issues enter here. |
| Todo | — | Groomed and executable. |
| In Progress | — | Actively owned and being worked. |
| In Review | — | Awaiting human review or integration. |
| Done | terminal | Accepted and integrated/shipped when applicable. |
| Canceled | terminal | Dropped or superseded. |

A state carries exactly two classifications, `is_starting` and `is_terminal`,
and octa models no gradation between them. `issue list` selects by
`--open`/`--closed`/`--all` on the terminal flag or by `--state <name>` on the
exact name; the four are mutually exclusive and nothing else distinguishes
Backlog from Todo or In Progress from In Review. If the store is missing one of
these six states, report that instead of substituting another one. Apply
transitions:

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
octa issue list --state Backlog --project <project> --json
octa issue list --unblocked --json
octa issue show <number> --json
octa issue create --title <title> --body <body> --state <state> --json
octa issue comment <number> --body <text>
LEASE=$(octa issue lock <number>)
octa issue set <number> --body <body> --project <project> --lease "$LEASE"
octa issue add <number> --label <label> --lease "$LEASE"
octa issue add <number> --blocker <blocker-number> --lease "$LEASE"
octa issue set-state <number> <state> --lease "$LEASE"
octa issue unlock <number> --lease "$LEASE"
```

Never scrape human-readable tables when JSON is available. Inspect before
mutating, and keep record updates scoped to the current repository. `octa
config` is the exception: it edits the store-wide configuration and rejects
`--repo` and `--all-repos`, so a rename or deletion there reaches every
repository's Issues.
