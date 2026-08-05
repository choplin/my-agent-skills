# git-helpers

Portable Git helper skills for coding agents.

## Skills

| Skill | Description |
|-------|-------------|
| `commit` | Create, amend, or draft review-friendly commits with consistent message granularity |
| `draft-pr` | Push and create a draft PR |
| `explain-pr` | Generate and publish a reviewer-facing HTML explanation page for the current PR (delegates page generation to the external `diff-explainer` skill) |
| `pr-description` | Write a review-friendly PR description (purpose, design, design→code map) |
| `rebase-onto-rewritten` | Rebase onto force-pushed/squashed branches |
| `squash-merge` | Squash the current branch into one commit and fast-forward it onto the base (optionally rebase first, then remove the worktree) |

## When Skills Activate

- **commit**: any `git commit`, amend, squash/rebase message, or commit-message draft
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

Install these skills through the repository's `skills add` workflow documented
in the root README. `git-helpers-explain-pr` additionally requires the external
`diff-explainer` skill from the `explainer-studio` repository and stops before
reading PR context when that dependency is unavailable.
