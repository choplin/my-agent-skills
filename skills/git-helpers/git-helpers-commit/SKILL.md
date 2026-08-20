---
name: git-helpers-commit
description: >-
  Creates, amends, or drafts review-friendly Git commits and commit messages
  at a consistent level of detail. Applies whenever a commit is created or
  rewritten, a commit message is proposed, a squash commit is prepared, or
  commits are combined during an interactive rebase.
user-invocable: false
metadata:
  description-role: trigger
---

# Create Review-Friendly Git Commits

Describe one coherent change at the level a future reader needs: a concise
outcome in the subject, plus only the non-obvious motivation, approach, or
consequences in the body. Repository and user instructions take precedence.

## 1. Confirm the operation and scope

Distinguish drafting a message, creating a normal commit, amending, and writing
the final message for a squash or rebase. Do not stage, unstage, split, amend,
squash, or rewrite history without authorization for that specific operation;
authorization for a normal commit does not authorize a history rewrite.

For a normal commit, inspect at least:

```bash
git status --short
git diff --cached --stat
git diff --cached
```

The staged diff is the sole description scope. Use unstaged and untracked
changes only to detect omissions or accidental scope. Stop if the staged scope
is empty. If it contains independent concerns that cannot be truthfully
summarized as one outcome, explain the split and ask how to proceed.

For an amend, squash, or rebase, read
`references/history-rewrites.md` before inspecting the effective change or
writing the message.

## 2. Match the repository convention

Apply conventions in this order:

1. explicit repository or user instructions;
2. global agent instructions;
3. stable patterns in recent commit history; and
4. Conventional Commits as the fallback.

Inspect enough recent history to identify established scopes, vocabulary, and
message granularity. When no more specific rule exists, use an imperative
`type(scope): description` subject with `feat`, `fix`, `refactor`, `build`,
`docs`, `test`, or `chore`; omit the scope when none covers the whole change.

## 3. Write only what future readers need

Before drafting, identify the outcome and any non-obvious motivation, approach,
or consequence supported by the diff, repository context, or user intent. Ask
when a necessary motivation is unknown; do not invent it.

The subject describes the central outcome, not edited files or work performed.
It covers only the final state, does not join independent outcomes, and marks
breaking changes when the repository requires it.

Add a body only when the subject and diff do not preserve an important reason,
design decision, coordinated approach, behavioral consequence, constraint, or
non-goal. A one-line message is sufficient for a genuinely trivial change.
When a body is useful, normally write:

```text
<Why the change was necessary.>

<How the final solution addresses it and any important consequence.>
```

Do not pad it with file lists, diff narration, a work diary, abandoned
approaches, conversational context, or unverified claims.

## 4. Check and execute

Drafting a message alone requires no test run. Before an executed commit or
rewrite, run the repository-required relevant checks. Report any check that
cannot run; do not imply it passed.

Show the message when the user requested a draft or when missing context, mixed
scope, or a rewrite decision requires input. Otherwise, after authorization and
checks, execute without another confirmation and without changing the staged
scope.

Use one `git commit -m` argument per paragraph. If the message contains bullets,
backticks, `$`, quotes, or other shell-sensitive content, read
`references/message-transport.md` before executing. Never encode newlines as
literal `\n` or `\n\n` in a commit-message argument or file.

## 5. Verify the recorded result

After committing, inspect:

```bash
git log -1 --format=%B
git show --stat --oneline HEAD
git status --short
```

Confirm that the message is exact, the commit contains the intended scope, and
remaining changes are reported accurately. If creation failed, report the
failure rather than presenting a draft as committed.

When called from a broader workflow, return control after verification; a
commit request does not cancel the caller's remaining steps unless the user
requested commit-only behavior.
