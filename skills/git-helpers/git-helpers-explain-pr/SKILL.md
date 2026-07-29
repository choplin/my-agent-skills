---
name: git-helpers-explain-pr
description: This skill should be used when the user wants to generate and publish a reviewer-facing HTML explanation page for the current branch's PR. Triggers on "explain this PR", "PRの解説ページを作って", "レビュアー向けの解説を公開して", "attach an explanation page to the PR". Gathers PR context, delegates HTML generation to understanding-explain-diff, publishes to gh-pages (public repos) or a pr-docs branch (private repos), and links it from a PR comment. Should NOT trigger for writing the PR description itself (git-helpers-pr-description) or for a local-only diff explanation without publishing (understanding-explain-diff).
allowed-tools: Bash(git *), Bash(gh *), Read, Write, Glob
metadata:
  description-role: documentation
---

# Explain PR

Generate an HTML explanation page for the current branch's PR and publish it so
reviewers can open it from a PR comment. Content generation is delegated to the
`understanding-explain-diff` skill; this skill owns PR context gathering,
publishing, and the PR comment.

Invocation is deliberately manual — the human decides which PRs deserve an
explanation page, so there is no triviality heuristic here.

## Preconditions

Stop with a clear message if any fails:

1. Working tree is clean (`git status --porcelain` is empty) — publishing
   temporarily checks out another branch in this worktree.
2. The current branch has an open PR (`gh pr view` succeeds). If not, suggest
   `git-helpers-draft-pr` first.

## Process

### 1. Gather PR context

- `gh pr view --json number,title,body,url,baseRefName` for the PR itself.
- `git fetch origin <base>` then `git log --format='%h %s%n%b' origin/<base>..HEAD`
  for commit messages.
- For each issue referenced in the PR body (`#N`, `Fixes ...`, full URL), fetch
  its title/body with `gh issue view N --json title,body` when it is in the same
  repo; skip silently on failure.

### 2. Decide the publish target from repo visibility

`gh repo view --json visibility` →

| Visibility | Publish branch | Reviewer access |
|-----------|----------------|-----------------|
| `PUBLIC` | `gh-pages` | GitHub Pages URL |
| anything else | `pr-docs` | local one-liner (below) |

**Never publish a private repo's explanation to GitHub Pages.** On Free/Team
plans a Pages site is world-readable even when its repository is private
(access-controlled Pages is Enterprise Cloud only), and the explanation embeds
diff content — publishing it is equivalent to publishing the code.

### 3. Generate the HTML

Delegate to the `understanding-explain-diff` skill with:

- Diff: `origin/<base>...HEAD`
- Context material: PR title/body, commit messages, linked issue bodies
- Output path: a temp file **outside the repository** (e.g.
  `${TMPDIR:-/tmp}/explain-pr-<number>/index.html`)

Generating outside the repo is mandatory: the branch switch in step 4 removes
the current branch's tracked files from the worktree, and an in-repo output
would either vanish or pollute the publish branch commit.

### 4. Publish

Let `<pub>` be the publish branch, `<n>` the PR number, `<orig>` the current
branch. Run exactly this sequence — see Gotchas for why it must be exact and
how to recover from a mid-sequence failure:

```bash
git fetch origin
# existing publish branch → track/update it; otherwise create it empty
if git show-ref --verify --quiet refs/remotes/origin/<pub>; then
  git switch <pub> 2>/dev/null || git switch -c <pub> --track origin/<pub>
  git pull --ff-only
else
  git switch --orphan <pub>
fi
mkdir -p pr/<n>
cp "<temp output>" pr/<n>/index.html
git add pr/<n>/index.html
git commit -m "docs: explanation page for PR #<n>"
git push -u origin <pub>
git switch <orig>
```

Re-running for the same PR overwrites `pr/<n>/index.html` — one page per PR,
updated in place. Old pages are kept forever, like the PRs they document.

**Public repos, first publish only**: if `gh api "repos/{owner}/{repo}/pages"`
returns 404, enable Pages with
`gh api -X POST "repos/{owner}/{repo}/pages" -f "source[branch]=gh-pages" -f "source[path]=/"`.

### 5. Comment on the PR

Post with `gh pr comment <n> --body ...`, starting the body with the marker
`<!-- explain-pr -->`. If a comment containing that marker already exists,
update it with `gh api` (PATCH the comment) instead of posting a duplicate.

- **Public**: link `https://<owner>.github.io/<repo>/pr/<n>/` and note that the
  first deployment may take about a minute to go live.
- **Private**: give the copy-paste viewer command:

  ```bash
  git fetch origin pr-docs && git show origin/pr-docs:pr/<n>/index.html > "${TMPDIR:-/tmp}/pr-<n>.html" && open "${TMPDIR:-/tmp}/pr-<n>.html"
  ```

  (`git show` needs no checkout, so reviewers' worktrees are untouched.)

### 6. Report

Report the page URL (or viewer command) and the comment URL.

## Success criteria

Verify each before reporting completion; on any No, fix it first (see Gotchas
for mid-publish recovery):

- [ ] `git push` for the publish branch succeeded, and
      `git show origin/<pub>:pr/<n>/index.html` returns the new content.
- [ ] The PR comment exists exactly once with the `<!-- explain-pr -->` marker
      (`gh pr view --json comments`), and its body matches this repo's
      visibility: Pages URL for public, viewer one-liner for private.
- [ ] `git branch --show-current` prints `<orig>` and `git status --porcelain`
      is empty — verified by running the commands, not assumed.

## Gotchas

- `git switch --orphan` empties the index and removes tracked files from the
  worktree but leaves untracked files alone — hence the clean-tree precondition
  and the out-of-repo temp output. Commit only `pr/<n>/index.html`; never
  `git add -A` on the publish branch.
- If anything fails mid-publish, first return to `<orig>` (`git switch <orig>`,
  using `git switch -f` only if the failure left the publish branch's files
  staged), then report — do not leave the worktree on the publish branch.
- The Pages build lags the push by ~30–60s; do not try to verify the URL
  responds. The HTML was already verifiable locally before publishing.
