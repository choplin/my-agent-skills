# git-helpers

Git helper skills for Claude Code.

## Skills

| Skill | Description |
|-------|-------------|
| `branch-commit` | Move uncommitted changes to a new branch and commit them |
| `draft-pr` | Push and create a draft PR |
| `explain-pr` | Generate and publish a reviewer-facing HTML explanation page for the current PR (delegates generation to `understanding-explain-diff`) |
| `pr-description` | Write a review-friendly PR description (purpose, design, design→code map) |
| `rebase-onto-rewritten` | Rebase onto force-pushed/squashed branches |
| `squash-merge` | Squash the current branch into one commit and fast-forward it onto the base (optionally rebase first, then remove the worktree) |

## When Skills Activate

- **branch-commit**: "branch-commit", "move changes to a new branch", "commit on a new branch"
- **draft-pr**: "create a draft PR", "open a draft PR", "draft pull request"
- **explain-pr**: "explain this PR", "PRの解説ページを作って", "attach an explanation page to the PR"
- **pr-description**: "write a PR description", "draft the PR body", or delegated from `draft-pr` for non-trivial PRs
- **rebase-onto-rewritten**: "rebase onto rewritten", "base branch was force pushed", "squash merged base"
- **squash-merge**: "squash-merge", "squash して main にマージ", "ブランチを1コミットにまとめて main へ", "squash then fast-forward merge"

## Use Cases

- Base branch was squash-merged
- Base branch was force-pushed
- Normal rebase fails due to history rewriting

The skill cherry-picks commits one-by-one for better handling of file moves and renames.

## Installation

Add to your `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/git-helpers"
  ]
}
```
