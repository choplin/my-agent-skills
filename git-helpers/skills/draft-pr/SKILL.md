---
name: draft-pr
description: Use this skill when the user wants to create a draft PR. Triggers on phrases like "draft PRを作って", "draft PRを作成", "ドラフトPRを開いて", "draft PR作って", or when the user wants to push and open a PR in draft mode.
allowed-tools: Bash(git *), Bash(gh *), Read, Glob
user-invocable: true
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

**If no template is found:**
- Use the default format described in the "Default PR Body Format" section below

### 3. Push

- Run `git push -u origin <branch>`
- Skip if already pushed and up to date

### 4. Create Draft PR

- Run `gh pr create --draft`
- Title: use conventional commit format `type(scope): description` (in English)
- Body: use the PR template if found (step 2), otherwise use default format
- **For non-trivial PRs** (3+ files with meaningful changes, multiple modules, new abstractions, or non-obvious motivation), delegate body authoring to the `pr-description` skill so the description covers purpose, design, and the design→code mapping. The template/default-format rules above still apply — `pr-description` shapes the *content of each section*.

### 5. Report Result

- Report the created PR URL

## Default PR Body Format

Use this format only when no PR template exists in the repository:

```
## Summary
<1-3 bullet points describing the changes>

## Test Plan
<How to verify the changes>
```
