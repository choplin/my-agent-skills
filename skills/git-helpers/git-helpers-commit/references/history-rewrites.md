# History rewrites

Read this reference only when amending a commit or composing the final message
for a squash or rebase.

Confirm that the user authorized the exact rewrite operation. Permission to
create a normal commit does not authorize an amend, squash, rebase, or other
history rewrite.

For an amend:

- inspect the current commit message; and
- inspect the effective change against the commit's first parent, including
  staged changes that the amend will add.

For a squash or rebase:

- inspect the complete commit range;
- inspect the final combined diff against the base; and
- treat intermediate subjects as evidence, not text to copy into the final
  message.

Write about the final combined outcome, not the sequence of intermediate
commits. If the effective scope contains independent concerns, surface that
mismatch before rewriting history.
