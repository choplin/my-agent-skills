---
name: dev-workflow-create-spec
description: This skill is invoked ONLY from kickoff (or, in adopt mode, from linear-start → dispatch-work) for one human-gated deliverable. In dev-workflow every single deliverable is a Story regardless of size. Should NOT be invoked directly by user or auto-triggered by AI. Authors the spec into a Story's Linear Issue and creates its local state.json.
user-invocable: false
---

# Create Spec

Capture the requirements and acceptance criteria for one human-gated Story. Here
Story means a single independently reviewable deliverable, not a size threshold.
The spec's
**authored content lives in the Story's Linear Issue**; a local `state.json` holds
only the machine-managed execution state. There is no local `spec.md`.

A **Story maps to a Linear Issue** (an Epic maps to a Linear Project — see
`dev-workflow-create-epic`). All Linear mechanics — resolving the repo's Project,
Repo/Type labels, status transitions, the issue authoring standard — are owned by
the **`linear-base` skill**; read it and follow its conventions rather than restating
them here.

## Tool Usage Constraints

- **Bash**: ONLY for git branch operations (`git checkout -b`, `git branch`, `git status --porcelain`) and the session-bind command. No other use.
- **Linear**: use whichever Linear MCP server is wired, per the `linear-base` skill.

## Two entry modes

- **create** (default, entered from kickoff): no Issue exists yet. Create a new
  Issue in the repo's Project, then author the structured spec as its description.
- **adopt** (entered via `linear-start` → `dispatch-work`): an Issue was already
  picked and moved to In Progress. **Do not create a new Issue** — structure that
  same Issue in place (preserving its id/assignee/history). Use its original
  description as interview material; move the raw original into a comment for
  provenance before replacing the description with the structured spec. `git`
  workspace is already set up by `linear-start` in this path (see step 7).

## Purpose

Create a spec document that captures What and Why for Story-level work.

### What Spec Is NOT

Spec is **NOT** an exhaustive specification. It does not aim for:
- Complete coverage of all edge cases
- Trivial validation checks
- Rare corner case handling

These are implementation details to be addressed during the implementation phase.

### What Spec IS

Spec aims to **keep focus on task purpose**. It captures:
- **Why**: The motivation and problem being solved
- **What**: User Needs expressed as MECE requirements
- **Criteria**: Verifiable acceptance criteria (few, focused)

The spec survives /clear as the sole source of truth for the next session.

## Critical Rule: Fewer Criteria is Better

**Problem from experience**: When AI generates acceptance criteria, it tends to create many items. This leads to:
1. Review cost increases
2. User skips review due to volume
3. Implementation proceeds with criteria that don't reflect user intent

**Rule**: Requirements and Criteria should be as few as possible while still covering User Needs.
- Ask: "Is this criterion essential to verify the User Need is met?"
- If not essential, don't include it
- Prefer 3-5 focused criteria over 10+ comprehensive ones

## Input

This skill receives Why/What context from kickoff interview via session history.

## Process

### 1. Confirm Why/What from kickoff

Review the interview results:
- **Why**: Background, motivation, problem being solved
- **What**: User Needs to satisfy

If unclear, ask for clarification.

### 2. Organize Requirements

Expand User Needs into specific Requirements:
- What the system must do (functional)
- Constraints it must satisfy (non-functional)

Keep requirements minimal. Only include what's necessary for User Needs.

### 3. Define Acceptance Criteria (Gherkin)

**Why Gherkin?**: Adopting a well-established format eliminates ambiguity about methodology and clarifies expectations.

Write each criterion in Given-When-Then format:

```gherkin
Scenario: {Criterion name}
  Given {Preconditions - what exists/is prepared}
  When {Action - specific action to perform}
  Then {Verifiable result - confirmable in code or files}
```

**Example**:
```gherkin
Scenario: Successful login
  Given user is on the login page
  When user enters valid credentials and clicks login
  Then user is redirected to dashboard with username displayed
```

Each criterion must be:
- **Verifiable**: AI can determine PASS/FAIL by checking code or files
- **User-confirmed**: Traceable to user statement
- **Essential**: Necessary to verify User Need is met

#### Predicate-ize each criterion

For every criterion, decide **how it will be verified** and record it on a `Verify:` line right after the scenario:

- **Machine-verifiable** → write an executable command that exits 0 on PASS, non-zero on FAIL (a test invocation, build, `rg -q ...`, a script). This becomes the criterion's predicate; self-review runs it deterministically before any LLM review.
- **Not machine-verifiable** (UX, subjective quality, judgment) → write `Verify: human` — the criterion is routed to human review from the start, never guessed by an LLM.

```gherkin
Scenario: Login redirects to dashboard
  Given a registered user on the login page
  When valid credentials are submitted
  Then the response redirects to /dashboard
  Verify: npm test -- auth/login.redirect
```

```gherkin
Scenario: Error copy reads clearly
  ...
  Verify: human
```

The `Verify:` value is mirrored into `state.json` `criteria[].verify` (the command, or `null` for `human`). Prefer machine-verifiable criteria — the more pass/fail is a command, the more self-review closes on its own.

### 4. Define Out of Scope

Explicitly state what this spec does NOT include. This prevents scope creep during implementation.

### 5. Create Spec Document

#### 5a. Determine Branch Name and Directory Name

**Branch name**: Determine the prefix from the Why/What content:

| Pattern | Prefix |
|---------|--------|
| New feature | `feat/` |
| Bug fix | `fix/` |
| Refactoring | `refactor/` |
| Documentation | `docs/` |
| Test | `test/` |
| Build/CI/tooling | `chore/` |
| Performance | `perf/` |

Branch name: `{prefix}/{story-name}` (e.g., `feat/add-auth`)

**Directory name**: Derived from branch name with date prefix:

1. Take the branch name `{prefix}/{story-name}` (e.g., `feat/add-auth`)
2. Replace `/` with `-` (e.g., `feat-add-auth`)
3. Prepend today's date as `{yyyy-mm-dd}-` (e.g., `2026-04-22-feat-add-auth`)

Result: `.claude/dev-workflow/story/{yyyy-mm-dd}-{prefix}-{story-name}/`

#### 5b. Author the spec into the Story's Linear Issue

The spec content becomes the Issue **description**. Follow the `linear-base` skill for
placement (repo's Project, Repo/Type labels, In Progress status, authoring
standard).

- **create mode**: create a new Issue in the repo's active Project (resolve it per
  `linear-base`/`linear-start`), set Type = `impl` (or `design`/`research` as fits),
  move it to In Progress, and write the description below. Note its identifier as
  `{issue-id}`.
- **adopt mode**: the Issue already exists and is In Progress. Copy its current raw
  description into a comment (`provenance: original issue text`), then replace the
  description with the structured spec below. `{issue-id}` is that issue.

Issue **title**: `{title}`. Issue **description**:

```markdown
## Branch
- **Name**: `{prefix}/{story-name}`
- **Base**: `main`

## Why
{Background, motivation, problem being solved — from kickoff interview}

## What
{User Needs to satisfy — from kickoff interview}

## Requirements
{Specific requirements derived from User Needs}

## Acceptance Criteria

### Scenario: {name}
- Given: {preconditions}
- When: {action}
- Then: {verifiable result}
- Verify: {executable command that exits 0 on PASS, or `human`}

## Out of Scope
{What this spec explicitly does NOT include}

## TBD
{Items that need clarification later, if any}
```

The Issue is the single source of truth for authored spec content; it is read
back only at session boundaries (never in the implementation hot loop). See
`dev-workflow-base` skill (`references/state-schema.md`) § Linear backing.

#### 5c. Create state.json

Create `.claude/dev-workflow/story/{story-dir}/state.json` where `{story-dir}` is the directory name from step 5a. See `dev-workflow-base` skill (`references/state-schema.md`) for the full schema. Initialize:

- `level`: `"story"`, `title`, `branch` (from step 5a)
- `linear_issue_id`: `{issue-id}` from step 5b (the backing Issue)
- `criteria`: one entry per Acceptance Criteria scenario. For each, set `name`, decide `verify` (an executable pass/fail command if the criterion is machine-verifiable, else `null`), and initialize `passes: false`, `evidence: null` (**Default-FAIL** — see schema).
- `steps`: `[]` (filled by create-plan)

`state.json` is the local, offline execution state and the link (`linear_issue_id`)
back to the Issue. Do **not** store derived values (counters, state category), and
do **not** duplicate the authored prose here — that lives in the Issue.

#### 5d. Bind this session to the Story

Now that the unit directory exists, bind this session so dev-workflow hooks track only this work (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

```bash
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/story/{story-dir}"
```

### 6. User Review

Present spec to user for approval before proceeding.

### 7. Set up the branch (conditional)

The Story maps to one git branch. **Who creates it depends on the entry path:**

- **adopt mode / already on a dedicated work branch or worktree** (the
  `linear-start` path already set up the workspace): **do not create a branch.**
  Use the current one. If its name differs from `{prefix}/{story-name}`, that is
  fine — record the actual branch in `state.json.branch`.
- **create mode on a base branch** (`main`/`master`, entered from kickoff with no
  workspace set up yet): create the branch now:
  1. **Check uncommitted changes**: `git status --porcelain` — if dirty, **stop** and ask the user to commit or stash first.
  2. **Check existing branch**: `git branch --list {branch-name}` — if it exists, ask whether to reuse it or pick another name.
  3. **Create and switch**: `git checkout -b {branch-name}`.
  4. **Report success** and make sure `state.json.branch` matches.

## Success Criteria

- [ ] Why/What from kickoff is captured
- [ ] Requirements are MECE relative to User Needs (see Purpose for what spec is NOT)
- [ ] Acceptance criteria are in Gherkin format
- [ ] Acceptance criteria are few and focused (prefer 3-5 over 10+)
- [ ] Each criterion is verifiable by AI: Can identify specific file(s) or code section(s) to check for PASS/FAIL. If no verification target can be named, the criterion is not verifiable.
- [ ] Out of Scope is explicitly stated
- [ ] Spec authored into the Linear Issue (created or adopted); `linear_issue_id` recorded in `state.json`
- [ ] User has approved the spec
- [ ] Branch is set up (created, or the existing linear-start workspace reused); `state.json.branch` matches the actual branch
- [ ] Directory name matches `{yyyy-mm-dd}-{prefix}-{story-name}` format

## Next Session

After the spec is approved and the branch is set up:

**Reference**: the Story's Linear Issue `{issue-id}` (authored spec) + `.claude/dev-workflow/story/{story-dir}/state.json` (execution state, where `{story-dir}` = `{yyyy-mm-dd}-{prefix}-{story-name}`)
**Branch**: the Story branch (checkout if not already on it)
**Next phase**: `dev-workflow-create-plan`

Read the Issue and invoke `dev-workflow-create-plan` to create the implementation plan.
