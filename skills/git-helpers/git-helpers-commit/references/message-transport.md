# Commit message transport

Read this reference before executing a commit whose message contains bullets,
backticks, `$`, quotes, or other content that is awkward to quote safely in
shell arguments.

For ordinary paragraphs, pass one `-m` per paragraph. Git inserts the required
blank lines:

```bash
git commit -m "feat(scope): summarize the outcome" \
  -m "Why the change was necessary." \
  -m "How the final solution addresses it."
```

Use a message file (`git commit -F path`) for shell-sensitive or structured
content. Write actual newline characters to the file and inspect it before
committing. Do not use literal `\n` or `\n\n` as substitutes for newlines, and
do not rely on `echo -e` or a single `-m` argument with escaped newlines.

Never stage another file merely to make the message easier to pass.
