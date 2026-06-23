---
name: git-helpers-branch-commit
description: This skill should be used when the user wants to move current changes to a new branch and commit them. Triggers on phrases like "branch-commit", "ブランチを作ってコミット", "変更をブランチに切り出し", "新しいブランチにコミット", "この変更を別ブランチに", or when the user wants to create a branch from uncommitted changes. Should NOT trigger when: committing to current branch (use /commit), creating empty branch, or switching branches without changes.
allowed-tools: Bash(git *)
user-invocable: true
---

# Branch & Commit

Move current uncommitted changes to a new branch and commit them.

## Process

1. **Check for changes**
   - Run `git status` to verify uncommitted changes exist
   - If no changes (staged or unstaged), stop with error: "No uncommitted changes found. Nothing to commit."

2. **Determine branch name**
   - If user provided branch name: use it directly
   - If not provided:
     - Analyze the changes (modified files, diff content)
     - Suggest a branch name based on the changes
     - Ask user to confirm or provide alternative name
     - Do NOT proceed until user confirms

3. **Create branch and commit**
   - `git checkout -b <branch-name>`
   - Determine target files from conversation context
   - If unclear which files to include, ask user
   - Stage only the target files
   - Create commit with message describing the changes

4. **Report result**
   - Show created branch name
   - Show commit hash and message

## Success Criteria

- [ ] Branch created (verified by `git branch --list`)
- [ ] All changes committed (verified by `git status` showing clean working tree)
- [ ] User confirmed branch name before creation
