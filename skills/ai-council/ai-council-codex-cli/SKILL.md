---
name: ai-council-codex-cli
description: >-
  Use this skill when the user asks about Codex CLI, wants to get another AI's
  opinion, or needs guidance on using Codex for code review. Triggers on phrases
  like "Codexに聞いて", "Codexの意見", "他のAIに聞いて", "ask codex", "codex opinion",
  "get another perspective", or "how to use codex".
---

# Codex CLI Usage Guide

OpenAI Codex CLI is a command-line tool that provides AI-powered code assistance. This skill covers how to use Codex CLI effectively from Claude Code.

## Basic Commands

**Important**: Always use `codex-xhigh` alias which has `model_reasoning_effort="xhigh"` configured for better reasoning quality.

### Non-interactive Mode (codex-xhigh exec)

For getting quick opinions or executing prompts without interactive mode:

```bash
# Basic execution
codex-xhigh exec "your prompt here"

# Read-only sandbox (safe for reviews)
codex-xhigh exec -s read-only "Review this code and share your thoughts"

# Output to file
codex-xhigh exec -o /tmp/codex-response.txt "your prompt"

# JSON output format
codex-xhigh exec --json "your prompt"
```

### Code Review Mode (codex-xhigh review)

For reviewing code changes:

```bash
# Review uncommitted changes
codex-xhigh review --uncommitted

# Review changes against a base branch
codex-xhigh review --base main

# Review specific files
codex-xhigh review path/to/file.ts
```

## Best Practices for Getting Opinions

1. **Use read-only sandbox** for safety: `-s read-only`
2. **Be specific** in your prompts about what kind of feedback you want
3. **Provide context** about the codebase or design goals
4. **Capture output** using `-o` or `--json` for structured responses

## Example Prompts

### Code Review
```bash
# Codex can read files directly - just provide the path
codex-xhigh exec -s read-only "Review src/utils/parser.ts for potential bugs and improvements"
```

### Design Discussion
```bash
codex-xhigh exec -s read-only "What are the pros and cons of using Redux vs React Context for state management in a medium-sized React application?"
```

### Architecture Opinion
```bash
codex-xhigh exec -s read-only "Review this API design and suggest improvements:

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
