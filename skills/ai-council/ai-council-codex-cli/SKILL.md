---
name: ai-council-codex-cli
description: >-
  The operating constraints for driving the Codex CLI as a consultation
  panelist: read-only invocation, the host sandbox it needs, and the fact that
  the files it reads leave the machine. Applied when seating Codex on a panel.
user-invocable: false
metadata:
  description-role: documentation
---

# Driving Codex as a Panelist

OpenAI's Codex CLI answers from a command line, which makes it usable as a
panelist that shares neither the host model's training nor its context. This
skill covers what has to be right when an agent — rather than a person at a
shell — invokes it.

## The calls this skill prescribes

Two shapes cover almost every consultation. Both are non-interactive, and both
pin the sandbox to read-only for the reason given below.

```bash
# An opinion on a question, with the files named in the prompt
codex exec -s read-only "Review src/utils/parser.ts for correctness and error handling"

# A review of a diff — note that `review` takes no sandbox flag
codex review --uncommitted
codex review --base main
codex review --commit <SHA>
```

`-s` is an `exec` flag. Passing it to `review` is an error
(`unexpected argument '-s' found`), so the read-only rule below is about `exec`.

Capture the answer to a file when it feeds a synthesis rather than the
conversation, and raise the effort for a question worth the wait:

```bash
codex exec -s read-only -o /tmp/codex-opinion.txt "<the brief>"
codex exec -s read-only -c model_reasoning_effort="high" "<the brief>"
```

Verified against `codex-cli 0.145.0`.

## Anything beyond these, ask the CLI

`codex --help`, `codex exec --help`, and `codex review --help` are authoritative
and describe the version actually installed. Read them for anything this skill
does not already prescribe.

What is written above is the set of calls this skill tells you to make. What is
deliberately *not* written is a catalog of everything Codex can do — a copy of a
third-party CLI's interface rots silently, going on looking like documentation
long after the tool has moved. This file previously claimed `codex review
path/to/file.ts` reviewed a named file; that positional is read as review
instructions, so the command succeeded and reviewed something else. A prescribed
call gets exercised and stays honest. A copied catalog does not.

## Constraints

**On `codex exec`, `-s read-only` is mandatory, not advisable.** Without it
Codex may modify files in the working tree. A consultation never needs write
access, and a panelist that edits the tree has exceeded its mandate. The other
modes (`workspace-write`, `danger-full-access`) have no place here.

**Codex needs network access the host may deny.** Under Claude Code's Bash
sandbox on macOS the call fails, because Codex reaches for the
SystemConfiguration API that the sandbox blocks
([sandbox-runtime#30](https://github.com/anthropic-experimental/sandbox-runtime/issues/30)).
Invoke it with `dangerouslyDisableSandbox: true`. On a host with no such
sandbox, nothing extra is required. If the call fails for a reason other than
that block, report it rather than widening permissions further.

**Codex reads the files you name, and they leave the machine.** Before pointing
it at a path that may hold credentials, keys, or customer data, confirm with the
user. This is a third-party service, and the prompt plus the file contents go to
it.

**Raise the reasoning effort per invocation, not globally.** The default is fine
for a routine opinion. For a high-stakes or contested question — an adversarial
panel, an architectural call that is expensive to reverse — raise it for that
call alone (`-c model_reasoning_effort="high"`) instead of making every
consultation slow.

## Getting a usable opinion

Codex answers what it is asked, so the brief carries the weight.

- **Name the target.** Give file paths; Codex reads them directly. "Review the
  parser" returns a generic answer where `src/utils/parser.ts` returns a
  specific one.
- **State the decision.** What choice is open, and what would change the answer.
- **Say what to weigh.** Security, performance, maintainability — an unfocused
  request returns an unfocused survey.
- **Capture the output** when the answer feeds a synthesis rather than the
  conversation — `-o <file>` writes the final message; `--json` streams the
  events instead, which you rarely want for an opinion.

An answer worth putting in a council report states a position, gives the
observations behind it with file and line, and names at least one trade-off it
would not choose.
