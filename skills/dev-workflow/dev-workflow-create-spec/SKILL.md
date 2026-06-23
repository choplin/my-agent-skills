---
name: dev-workflow-create-spec
description: This skill is invoked ONLY from kickoff when Story-level work is identified. Should NOT be invoked directly by user or auto-triggered by AI. Creates spec document with requirements and acceptance criteria.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion, Bash
user-invocable: false
---

# Create Spec Document

Create a specification document that captures requirements and acceptance criteria for Story-level work.

## Tool Usage Constraints

- **Bash**: ONLY for git branch operations (`git checkout -b`, `git branch`, `git status --porcelain`). No other use.

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

The `Verify:` value is mirrored into `state.json` `criteria[].verify` (the command, or `null` for `human`). Prefer machine-verifiable criteria — the more pass/fail is a command, the more self-review closes on its own (see `docs/2026-06-11-loop-engineering-research.md` §3).

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

#### 5b. Create Spec File

Create `.claude/dev-workflow/story/{story-dir}/spec.md` where `{story-dir}` is the directory name from step 5a:

```markdown
# Spec: {title}

## Branch

- **Name**: `{prefix}/{story-name}`
- **Base**: `main`

## Related Files

- **Workflow concepts**: `dev-workflow-base/references/workflow-concepts.md`
- **Epic**: `.claude/dev-workflow/epic/{epic-dir}/epic.md` (if part of an Epic)

## Why
{Background, motivation, problem being solved - from kickoff interview}

## What
{User Needs to satisfy - from kickoff interview}

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

#### 5c. Create state.json

Create `.claude/dev-workflow/story/{story-dir}/state.json` next to spec.md. See `dev-workflow-base` skill (`references/state-schema.md`) for the full schema. Initialize:

- `level`: `"story"`, `title`, `branch` (from step 5a)
- `criteria`: one entry per Acceptance Criteria scenario. For each, set `name`, decide `verify` (an executable pass/fail command if the criterion is machine-verifiable, else `null`), and initialize `passes: false`, `evidence: null` (**Default-FAIL** — see schema).
- `steps`: `[]` (filled by create-plan)
- `review`: `null` (filled when review starts)

This is the machine-managed mirror of the spec. Do **not** store derived values (counters, state category).

#### 5d. Bind this session to the Story

Now that the unit directory exists, bind this session so dev-workflow hooks track only this work (see `dev-workflow-base` skill (`references/state-schema.md`) § Session binding):

```bash
python3 dev-workflow-base/scripts/workflow-state.py --session "$CLAUDE_CODE_SESSION_ID" --set ".claude/dev-workflow/story/{story-dir}"
```

### 6. User Review

Present spec to user for approval before proceeding.

### 7. Create Branch

After user approves the spec, create the git branch:

1. **Check uncommitted changes**: Run `git status --porcelain`
   - If there are uncommitted changes, **stop** and inform the user to commit or stash first
2. **Check existing branch**: Run `git branch --list {branch-name}`
   - If the branch already exists, ask user whether to use the existing branch or choose a different name
3. **Create and switch**: Run `git checkout -b {branch-name}`
4. **Report success**: Confirm branch creation to the user

## Success Criteria

- [ ] Why/What from kickoff is captured
- [ ] Requirements are MECE relative to User Needs (see Purpose for what spec is NOT)
- [ ] Acceptance criteria are in Gherkin format
- [ ] Acceptance criteria are few and focused (prefer 3-5 over 10+)
- [ ] Each criterion is verifiable by AI: Can identify specific file(s) or code section(s) to check for PASS/FAIL. If no verification target can be named, the criterion is not verifiable.
- [ ] Out of Scope is explicitly stated
- [ ] User has approved the spec
- [ ] Branch is created and checked out (or user opted to skip)
- [ ] Directory name matches `{yyyy-mm-dd}-{prefix}-{story-name}` format

## Next Session

After spec is approved and branch is created:

**Reference**: `.claude/dev-workflow/story/{story-dir}/spec.md` (where `{story-dir}` = `{yyyy-mm-dd}-{prefix}-{story-name}`)
**Branch**: `{prefix}/{story-name}` (checkout if not already on it)
**Next phase**: `dev-workflow-create-plan`

Read the spec file and invoke `dev-workflow-create-plan` skill to create implementation plan.
