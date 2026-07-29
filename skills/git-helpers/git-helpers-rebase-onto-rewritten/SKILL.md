---
name: git-helpers-rebase-onto-rewritten
description: Use this skill when the user needs to rebase onto a branch with rewritten history. Triggers on phrases like "rebase onto rewritten", "base branch was force pushed", "squash merged base", "cherry-pick my commits", or when normal rebase fails due to history rewriting.
allowed-tools: Bash(git *)
user-invocable: false
metadata:
  description-role: trigger
---

# Rebase onto Rewritten History

Help rebase the current branch onto a base branch that has rewritten its history (e.g., through squash-and-merge or force-push).

## Required Information

1. The first (oldest) commit to cherry-pick from the branch (required)
2. The base branch to rebase onto (optional, default: main)

## Process

1. **Analyze the situation**:
   - Show current branch commits to help identify the first commit
   - Show base branch recent history
   - Prepare to cherry-pick from the specified commit to HEAD

2. **Create a backup**:
   - Create a backup branch (e.g., `<branch>-backup-<timestamp>`)

3. **Prepare for rebase**:
   - Create a temporary branch from the latest base branch
   - Use the range from the specified commit to HEAD

4. **Cherry-pick commits**:
   - **Apply commits ONE AT A TIME** (not as a range)
   - This is critical for commits involving directory restructuring or file moves
   - Git can better track changes when applied incrementally
   - If conflicts arise, stop and show the conflicting files
   - Wait for instructions on how to resolve conflicts
   - Show progress during the process

5. **Finalize**:
   - Before renaming, record the original branch's upstream (`git config branch.<name>.remote` and `branch.<name>.merge`)
   - Rename branches to preserve the original branch name
   - Restore the upstream tracking to match the original branch (`git branch --set-upstream-to=<original-upstream>`)
   - Delete temporary branch
   - Show final status

## Why One-by-One?

When cherry-picking multiple commits at once (e.g., `git cherry-pick A..B`), Git may fail to properly track directory renames and file moves across commits, causing unnecessary conflicts. Applying commits individually allows Git to correctly recognize and apply each structural change sequentially.

## When to Use

- Base branch was squash-merged
- Base branch was force-pushed
- Normal rebase fails due to history rewriting
