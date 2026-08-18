---
name: octa-start
description: >-
  Starts or resumes one octa Issue in the current Git repository: surfaces In
  Progress work before Todo and Backlog, confirms the selection, atomically
  claims it, prepares or recovers a workspace, reconstructs prior work, and
  carries it through the octa review and completion lifecycle. Use when picking
  up repository work managed in octa.
---

# Start or resume octa work

Apply `octa-base` throughout. The octa Issue and its comments are the durable
work record; Git is implementation reality.

## Flow

### 1. List candidates

Confirm the configured states with `octa config state list --json` — report any
of the six that is missing rather than substituting another one — then fetch
Issue candidate context in one read:

```graphql
{
  issues(filter: { stateType: ["open", "in progress"] }, limit: 100) {
    number
    title
    state
    stateType
    updatedAt
    leased
    project { id name }
    labels { name }
    blockedBy { number state stateType }
  }
}
```

The filter already excludes the `closed` type. Run it with `octa query`, inspect
the response `errors`, and paginate with `offset` when more than 100 Issues
exist. Exclude In Review Issues, then present two sections across every Project
and No Project:

1. **In flight** — In Progress Issues first, most recently updated first. These
   are resume candidates.
2. **Open** — Todo above Backlog, each ordered by Issue number, oldest first.
   octa records no priority; unblocked work and Milestone placement are the
   only ranking signals, so surface them rather than inventing an order.

Exclude In Review Issues: they await a response or integration rather than a
new execution session. If the user explicitly identifies an In Review Issue
to continue feedback, commit, or integration work, accept it as a completion
continuation rather than presenting it as a normal candidate; acquire or
recover its lease through step 3 and resume the implementation completion
procedure.

Show `#number`, title, state, Type, and Project. Type is the matching
`impl`, `design`, or `research` label; show an Issue as untyped rather than
inferring from its title. Let the user choose; do not require a Project
selection first.

### 2. Confirm the selected Issue

Read `octa issue show <number> --json`. Before changing state, lock, workspace,
or files, show the number/title and a short summary. Do not dump the record.

For a Backlog selection, apply the `octa-base` self-completeness gate. Groom it
in place before execution or route to `octa-groom`; never treat rough capture as
an implementation specification.

If any blocker outside the `closed` type remains, report it and do not start.

### 3. Claim ownership

Read `octa-base`'s CLI contract reference, then inspect the selected Issue's
`leased` boolean:

- false: acquire a new lease and retain its ID in the live session;
- true and this live session already retains the matching lease ID: resume
  without retrying the non-idempotent acquisition;
- true without the lease ID retained by this live session: stop and report
  contention. The CLI does not expose the holder or lease ID. Do not
  force-release it.

For an unleased Issue, capture the one-time lease ID:

    LEASE=$(octa issue lock <number>)

If acquisition races and fails, re-read the Issue and report that it is now
leased. On a new start, move the Issue to In Progress with
`octa issue start <number> --lease "$LEASE"`, which resolves to the
`in progress` default. A resume already in that state needs no transition.

The lease ID is a non-secret coordination handle and may appear in tool output
and command arguments. Never put it in an Issue comment, worktree note,
repository file, commit, or user-facing report.

### 4. Prepare or recover the workspace

Choose autonomously from the deliverable:

- `impl` or another repository change: use an isolated worktree when the
  installed `wtm-worktree` skill is available; otherwise use the current
  workspace and say so. Do not improvise one with a bare `git worktree add`:
  it leaves nowhere to record the Issue reference, and the current-workspace
  path already handles that case.
- design/research without repository changes: use the current workspace.

For a new worktree, use a descriptive branch name with no octa number. Put the
local reference in the worktree note, for example:

```text
octa:<repo>#<number> <title>
```

The note identifies the Issue only; it must not contain the lease ID.

On resume, search worktree notes before creating anything. If exactly one
matches, use it. With several, ask. With none, inspect current branch, status,
commits, octa PR records, and Issue comments; recover plausible existing work
before creating a replacement workspace.

### 5. Reconstruct a resume

Before touching files, read:

- the newest Handoff note, then earlier Issue comments;
- Git status, commits against the target branch, staged/unstaged changes;
- linked octa PR records and their comments;
- the in-flight execution artifact left by whichever mode was running:
  - `orchestration-toolkit-execute` — its run record, kept as checkpoint
    comments on this Issue; there is no local file;
  - `exec-plan` — a plan file under `.agents/exec-plans/`;
  - host-native `/goal` — active goal state, when the host exposes it to this
    session; there is no repository artifact to search;
  - none of these — the work ran in-session with no execution skill.

Also confirm that the current live session still retains the lease ID. If the
Issue is leased but the ID is unavailable, stop instead of guessing or
force-releasing it.

Report what is done, in progress, and next. Do not re-derive the Issue from
scratch or contradict recorded decisions.

### 6. Execute

Preserve the Issue's What and Acceptance; decide implementation details without
rewriting requirements. Keep durable checkpoints as Issue comments when the run
crosses meaningful boundaries or must pause.

**Starting.** The Issue is the work unit, so the destination follows from what
it asks for. Do not run a mode questionnaire:

| The selected Issue | Hand off to |
|---|---|
| Entails repository changes toward a commit (normally `impl`) | `orchestration-toolkit-execute` |
| Produces a non-repository deliverable — analysis, design, research (normally `design`/`research`) | Ordinary in-session work; record the deliverable on the Issue |
| Is a trivial, self-evident change | Implement it directly; for a repository change, satisfy `octa-base`'s implementation completion gate before closing it |

State the choice in one line and proceed. If dependencies on sibling Issues
surface while working, that is the signal to stop and route the Project-sized
dependency graph back to grooming/planning instead of widening this run.

**Resuming.** The execution mode has usually already been chosen — continue it
rather than re-picking one. Route by the artifact found at step 5:

| Artifact found at step 5 | Hand off to |
|---|---|
| Checkpoint comments from `orchestration-toolkit-execute` | `orchestration-toolkit-execute` (continue the existing run record; do not open a new one) |
| Plan file under `.agents/exec-plans/` | `exec-plan` (drive the existing plan; do not write a new one) |
| Active host-native `/goal` | Continue the existing goal through the host |
| None | Apply the Starting table above, but frame the remaining work from step 5 as the task, not the whole Issue |

For an `impl` change, implement and verify without committing, pass the selected
Issue's full record and retained lease into the execution flow, then read and
apply `octa-base`'s `references/implementation-completion.md` from pre-commit
review through its closing outcome. That procedure owns the review brief,
status transitions, feedback cycle, commit handoff, integration, completion
comment, lease release, and cleanup; do not reproduce those branches here.
Comments and reads need no lease, but every protected Issue mutation and
Issue–PR link change does. When the procedure returns Done, continue with step
8. Otherwise report the exact unresolved gate or explicit commit-only outcome
it returned.

Design/research work records its result and acceptance evidence in the Issue.
Close it to Done with `octa issue close <number> --lease "$LEASE"` after
acceptance, then release the lease normally.

### 7. Finish or pause

For design/research completion, post the required completion comment, close to
Done with the lease, release it normally, and apply the safe worktree cleanup
procedure when relevant. `impl` completion is already owned by the centralized
procedure in step 6.

If the session ends before review with unfinished work, use `octa-handoff`,
keep the Issue In Progress, and release the lease when another session should
be able to resume. A review or integration stop remains In Review and follows
the centralized procedure's lease-release rule; it is not an In Progress
handoff.

### 8. Show what follows

After Done, show the containing Project tally when present. Suggest related
Todo/Backlog Issues in this order:

1. newly unblocked Issues;
2. same Milestone;
3. explicit related or parent/sub-issues;
4. other unblocked Todo work in the repository, oldest first.

Let the user choose or stop. If they choose, loop back to confirmation before
claiming the next Issue.
