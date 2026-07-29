---
name: git-helpers-squash-merge
description: This skill should be used when the user wants to collapse the current feature branch into a single commit and fast-forward it onto the base branch (default main). Triggers on phrases like "squash-merge", "squash して main にマージ", "ブランチを1コミットにまとめて main へ", "squash then fast-forward merge", "1コミットにして main に着地させる", or when the user wants one clean commit on main from a branch. Rebases onto the base first when needed (backup ref created, no confirmation) and removes the worktree afterward (with confirmation). Should NOT trigger for normal merges that preserve branch history, PR/remote-side merges, or moving uncommitted changes to a new branch (use `git switch -c` then `/commit`).
allowed-tools: Bash(git *), Bash(wtm *)
user-invocable: false
metadata:
  description-role: trigger
---

# Squash & Fast-Forward Merge

Collapse the current feature branch into a single commit and fast-forward it onto
the base branch, so the base gains exactly **one** commit for the whole branch.
Rebases onto the base first when the base has advanced (a backup ref is created
first; no confirmation), then removes the branch (and, if asked, the worktree).

This skill is **explicit-invocation only** — never run it proactively.

## Inputs

- **Base branch** (optional, default: `main`)
- Runs against the **current branch** (the feature branch)

## Preconditions (stop with a clear error if any fail)

- Current branch is **not** the base branch (`git rev-parse --abbrev-ref HEAD` ≠ base).
- Working tree is **clean** (`git status --porcelain` empty). If dirty, stop and
  ask the user to commit or stash first — do not stash silently.
- Base branch exists (`git rev-parse --verify <base>`).
- Branch has at least one commit beyond base
  (`git rev-list --count <base>..HEAD` > 0). If 0, stop: "Nothing to merge."

## Process

1. **Gather context**
   - `BRANCH=$(git rev-parse --abbrev-ref HEAD)`, `BASE` = arg or `main`.
   - Show `git log --oneline <base>..HEAD` so the user sees what will be squashed.
   - Detect where the base is checked out (empty = nowhere):
     ```
     BASE_WT=$(git worktree list --porcelain | awk -v b="refs/heads/$BASE" '
       /^worktree /{wt=$2} $0=="branch "b{print wt}')
     ```

2. **Rebase onto base if needed — automatic, backup ref first**
   - If base is **not** an ancestor of HEAD
     (`git merge-base --is-ancestor <base> HEAD` fails), the base has advanced.
   - A rebase is unavoidable here: the skill's goal is a fast-forward landing, so
     there is no alternative path. Do it **without asking** — but always create a
     backup ref first so it stays reversible.
   - Report how far base moved (`git log --oneline HEAD..<base>`), create the backup
     `git branch "$BRANCH-backup-$(date +%Y%m%d-%H%M%S)"`, then `git rebase <base>`.
   - If conflicts arise, **stop** and show the conflicting files. Wait for the user
     to resolve; do not auto-resolve.

3. **Squash into one commit**
   - `COUNT=$(git rev-list --count <base>..HEAD)`.
   - If `COUNT == 1`: already a single commit — skip to step 4.
   - If `COUNT > 1`:
     - Apply the `git-helpers-commit` skill to compose the final message from
       the combined diff and complete commit range. Use the original subjects
       (`git log --reverse --format='- %s' <base>..HEAD`) as evidence, but
       describe the final outcome and its why/how instead of copying the
       implementation history into the body.
       If that skill is unavailable, apply the same rule inline: summarize the
       final outcome in the subject and explain non-obvious motivation,
       approach, constraints, or consequences in the body.
     - Show the proposed message and let the user confirm or edit it.
     - `git reset --soft <base>` then `git commit` with the agreed message.
     - Verify the tree is unchanged: `git diff --quiet <base>..HEAD` content-wise
       must equal the pre-squash tree (the squash must not alter files).

4. **Fast-forward merge into base** (base is guaranteed an ancestor now)
   - If `BASE_WT` is non-empty (base checked out in a worktree):
     `git -C "$BASE_WT" merge --ff-only "$BRANCH"`
   - Else (base checked out nowhere): `git branch -f <base> "$BRANCH"`
   - Never force a non-fast-forward. If `merge --ff-only` fails, stop and report.

5. **Delete the feature branch** (it is now fully merged)
   - If deleting the worktree too (step 6), do that **first**, then
     `git -C "$BASE_WT" branch -d "$BRANCH"` (a checked-out branch can't be deleted).
   - Otherwise: `git switch <base>` (if you are on the feature branch), then
     `git branch -d "$BRANCH"` (`-d`, not `-D`; it is merged).
   - Do **not** push. The base is updated locally only.

6. **Worktree removal — only if in a linked worktree, and CONFIRM FIRST**
   - Detect a linked worktree: `git rev-parse --git-dir` ≠ `git rev-parse --git-common-dir`.
   - If linked, **ask the user** whether to remove this worktree. If they decline, stop
     here after reporting the merge result.
   - If they approve, hand off to the project's **worktree-management workflow**:
     - If the repo uses `wtm` (e.g. `git worktree list` paths contain `wtm-worktrees`,
       or `wtm` is on PATH), delegate to the `wtm-worktree` skill / `wtm remove`.
     - Otherwise: `git worktree remove <path>`.
   - Caveat: you are removing the worktree you are standing in — run the removal and
     all following commands from the base worktree (`git -C "$BASE_WT" …` or `cd "$BASE_WT"`),
     since the current directory disappears.

## Success Criteria

- [ ] Base advanced by exactly **one** new commit (`git rev-list --count <base>@{1}..<base>` == 1, or verified via reflog)
- [ ] That commit's tree equals the feature branch tip (no content lost in the squash)
- [ ] Merge was a true fast-forward (no merge commit)
- [ ] Feature branch deleted with `-d` (merged), unless the user opted to keep it
- [ ] Worktree removed only after explicit user confirmation, via the worktree-management workflow
- [ ] Nothing pushed to any remote
