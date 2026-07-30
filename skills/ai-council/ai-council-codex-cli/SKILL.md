---
name: ai-council-codex-cli
description: >-
  Command reference for the Codex CLI — subcommands, flags, sandbox and output
  modes, and how to read its results. Used to run a Codex consultation or code
  review from the terminal.
user-invocable: false
metadata:
  description-role: documentation
---

# Codex CLI Usage Guide

OpenAI Codex CLI is a command-line tool that provides AI-powered code assistance. This skill covers how to use Codex CLI effectively from Claude Code.

## Basic Commands

By default `codex` runs at its standard reasoning effort — fine for routine opinions. For high-stakes or contested questions (e.g. an adversarial panel), raise it per-invocation with `-c model_reasoning_effort="high"` rather than making every call slow.

### Non-interactive Mode (codex exec)

For getting quick opinions or executing prompts without interactive mode:

```bash
# Basic execution
codex exec "your prompt here"

# Read-only sandbox (safe for reviews)
codex exec -s read-only "Review this code and share your thoughts"

# Output to file
codex exec -o /tmp/codex-response.txt "your prompt"

# JSON output format
codex exec --json "your prompt"
```

### Code Review Mode (codex review)

For reviewing code changes:

```bash
# Review uncommitted changes
codex review --uncommitted

# Review changes against a base branch
codex review --base main

# Review specific files
codex review path/to/file.ts
```

## Running Codex from inside an agent

Two constraints apply whenever an agent — rather than a person at a shell —
invokes these commands.

**Pass `-s read-only` unless the run is meant to write.** Without it Codex may
modify files in the working tree. A consultation or review never needs write
access, so the flag is mandatory there, not merely advisable.

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

## Best Practices for Getting Opinions

1. **Be specific** in your prompts about what kind of feedback you want
2. **Provide context** about the codebase or design goals
3. **Capture output** using `-o` or `--json` for structured responses

## Example Prompts

### Code Review
```bash
# Codex can read files directly - just provide the path
codex exec -s read-only "Review src/utils/parser.ts for potential bugs and improvements"
```

### Design Discussion
```bash
codex exec -s read-only "What are the pros and cons of using Redux vs React Context for state management in a medium-sized React application?"
```

### Architecture Opinion
```bash
codex exec -s read-only "Review this API design and suggest improvements:

GET /users/{id}/posts
POST /users/{id}/posts
DELETE /posts/{id}

Should we restructure these endpoints?"
```

## Output Interpretation

Codex responses typically include:
- **Analysis**: Understanding of the code/problem
- **Suggestions**: Specific improvements or alternatives
- **Concerns**: Potential issues or risks identified
- **Code examples**: When applicable, concrete code suggestions

## Reference

For detailed Codex CLI documentation, see: [codex-reference.md](references/codex-reference.md)
