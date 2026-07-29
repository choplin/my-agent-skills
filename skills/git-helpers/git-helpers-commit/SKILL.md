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
outcome in the subject, plus the non-obvious motivation and solution in the
body. Treat repository and user instructions as authoritative; use this
workflow to apply them consistently.

## 1. Establish the operation and authority

Determine whether the task is:

- drafting a message only;
- creating a commit from the index;
- amending an existing commit; or
- composing the final message for a squash or rebase.

Do not stage, unstage, split, amend, squash, or otherwise rewrite history unless
the user has authorized that operation. Authorization to create a normal commit
does not imply authorization to amend or squash.

## 2. Inspect the exact commit scope

For a normal commit, inspect at least:

```bash
git status --short
git diff --cached --stat
git diff --cached
```

Use the staged diff as the sole description scope. Consult unstaged and
untracked changes only to detect omissions or accidental scope; do not describe
them as committed work.

For an amend, also inspect the current commit message and the effective change
against its first parent. For a squash or rebase, inspect the complete commit
range and the final combined diff against the base. Treat intermediate commit
subjects as evidence, not as text to copy into the final body.

If the scope is empty, stop. If it contains independent concerns that cannot be
truthfully summarized as one outcome, explain the split and ask the user how to
proceed; do not conceal the mismatch with a vague subject.

## 3. Resolve the repository convention

Apply conventions in this order:

1. explicit repository or user instructions;
2. global agent instructions;
3. stable patterns in recent commit history;
4. Conventional Commits as the fallback.

Inspect recent history for established scope names, domain vocabulary, and
message granularity. Do not let inconsistent history override an explicit rule.

When no more specific rule exists, use:

```text
type(scope): imperative description
```

Use `feat`, `fix`, `refactor`, `build`, `docs`, `test`, or `chore`. Omit the
scope when the change is not limited to one clear area.

## 4. Model the change before writing

State these facts privately before drafting:

- **Outcome:** what the repository gains or changes.
- **Motivation:** why the change is necessary now.
- **Approach:** how the final implementation solves the problem.
- **Consequences:** important behavior, compatibility, migration, security,
  performance, constraints, or deliberate exclusions.

Use only facts supported by the diff, repository context, or the user's stated
intent. If a load-bearing motivation cannot be established, ask rather than
inventing it.

## 5. Write the subject

Summarize the central outcome, not the edited files or the work performed.

Prefer:

```text
feat(git-helpers): add consistent commit message guidance
```

Avoid:

```text
docs(git-helpers): update SKILL.md and README
```

Keep the subject concise and:

- use the repository-required grammatical mood;
- describe only the final state, never intermediate work;
- avoid joining independent outcomes with `and`;
- use a scope only when one name accurately covers the whole change; and
- mark breaking changes according to the repository's Conventional Commit
  policy when applicable.

## 6. Decide whether the body carries useful information

Write a body when any of these is true:

- the motivation is not obvious from the subject and diff;
- multiple files or layers implement one coordinated design;
- the change embodies a design decision or meaningful trade-off;
- behavior, compatibility, migration, security, or performance changes;
- a constraint or deliberate non-goal would otherwise be lost;
- a small diff has a non-obvious reason; or
- a squash combines several implementation steps into one final outcome.

Allow a one-line message only when the subject fully explains a genuinely
trivial change, such as a typo, semantics-preserving wording edit, or mechanical
formatting. Judge semantic weight, not line or file count.

Structure a typical body as:

```text
<Why the change was necessary.>

<How the final solution addresses it, including important constraints or
consequences.>
```

Use bullets only for several independently reviewable consequences. Do not pad
the body with file lists, diff narration, a work diary, abandoned intermediate
approaches, conversational context, or claims that were not verified.

## 7. Satisfy pre-commit checks

For an executed create, amend, squash, or rebase commit, run the
repository-required relevant tests and checks before committing. If a required
check cannot run, report the gap and do not imply that it passed. Drafting a
message alone does not require running checks.

Treat verification as a commit precondition, not routine body content. Mention
it in the message only when the verification method or limitation is important
to understanding the change or a repository rule requires it.

## 8. Execute without changing the agreed scope

Show the proposed message when the user requested a draft or when missing
context, mixed scope, or history rewriting requires a decision. Otherwise, once
the user has authorized the commit and the scope is coherent, create it without
adding an unnecessary confirmation step.

Pass the commit message so the shell never has to interpret newline escapes.

Default to one `-m` per paragraph. Git joins multiple `-m` values with a blank
line, which is the correct way to structure subject and body:

```bash
git commit -m "feat(scope): summarize the outcome" \
  -m "Why the change was necessary." \
  -m "How the final solution addresses it."
```

Use a message file (`git commit -F path`) only when the body needs bullets,
backticks, `$`, quotes, or other content that is awkward to quote safely in
shell arguments. Write the file with real newlines; do not encode them as
escape sequences.

Never put literal `\n` or `\n\n` inside a `-m` argument, a heredoc, or a
message file in place of an actual newline. Never rely on a single `-m` plus
escaped newlines, or on `echo -e` / similar, to assemble a multi-paragraph
message. Never stage additional files merely to make the message more
complete.

## 9. Verify the recorded result

After committing, inspect:

```bash
git log -1 --format=%B
git show --stat --oneline HEAD
git status --short
```

Confirm that the recorded message is exact, the commit contains the intended
scope, and remaining working-tree changes are reported accurately. If commit
creation failed, stop and report the failure rather than presenting the draft
message as committed.
