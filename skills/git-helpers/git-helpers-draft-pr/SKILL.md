---
name: git-helpers-draft-pr
description: >-
  Pushes the current branch and opens a pull request in draft mode. Applies
  when a PR should go up for early visibility rather than for merge — opening
  a draft PR, putting a branch up before it is finished, or pushing and
  creating a PR that is not ready yet.
allowed-tools: Bash(git *), Bash(gh *), Read, Glob
user-invocable: false
metadata:
  description-role: trigger
---

# Draft PR Creation

Push the current branch and create a PR in draft mode.

## Language

- PR title and body MUST be written in **English** by default
- Only use a different language if the user explicitly requests it

## Process

### 1. Branch Check

- Verify the current branch is NOT main/master
- If on main/master, stop with an error

### 2. PR Template Check (MANDATORY - DO NOT SKIP)

Search for the PR template in this order:

1. `.github/pull_request_template.md`
2. `.github/PULL_REQUEST_TEMPLATE.md`
3. `docs/pull_request_template.md`
4. `pull_request_template.md`

Also check for multiple templates in `.github/PULL_REQUEST_TEMPLATE/` directory.

**If a template is found:**
- Read its full content
- You MUST use it as the structure for the PR body
- Fill in every section of the template — do NOT skip, remove, or reorder any sections
- If a section is not applicable, write "N/A" instead of omitting it
- In the first section that describes the PR, begin with a standalone `This PR <what>.` sentence, then explain the background and motivation in a new paragraph

**If no template is found:**
- Use the default format described in the "Default PR Body Format" section below

### 3. Push

- Run `git push -u origin <branch>`
- Skip if already pushed and up to date

### 4. Create Draft PR

- Run `gh pr create --draft`
- Title: use conventional commit format `type(scope): description` (in English)
- Body: use the PR template if found (step 2), otherwise use default format
- **For non-trivial PRs** (3+ files with meaningful changes, multiple modules, new abstractions, or non-obvious motivation), delegate body authoring to the `git-helpers-pr-description` skill so the description covers purpose, design, and the design→code mapping. The template/default-format rules above still apply — `git-helpers-pr-description` shapes the *content of each section*.

### 5. Report Result

- Report the created PR URL

## Default PR Body Format

Use this format only when no PR template exists in the repository:

```
## Summary
This PR <states what the PR does in one sentence>.

<Explain the background and why the change is needed.>

## Test Plan
<How to verify the changes>
```
