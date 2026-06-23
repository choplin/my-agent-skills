---
name: ai-council-gemini-cli
description: >-
  Use this skill when the user wants to consult Gemini AI as a second opinion
  on technical decisions, specifically when they want another AI perspective
  on code design, architecture choices, or implementation approaches. Triggers
  when user explicitly requests Gemini's input: "Geminiに聞いて", "Geminiの意見",
  "get Gemini's opinion on this design", "ask Gemini about this approach",
  "consult gemini". Should NOT trigger for: learning Gemini CLI syntax/commands
  (that's documentation reading), troubleshooting Gemini CLI errors, or casual
  mentions of Gemini without consultation intent.
---

# Gemini CLI Consultation Guide

This skill covers how to use Gemini CLI to get a second AI perspective on technical decisions from Claude Code.

## When to Use This Skill

Use this skill when you need a second AI perspective on technical decisions. This is valuable when:
- You want to validate Claude's recommendations with another AI
- You need alternative approaches to compare
- You want to identify blind spots in a design
- You want diverse viewpoints for better decision making

## How to Consult Gemini

### 1. Always Use Sandbox Mode

**Command**: `gemini -s "your prompt"`

**Why**: When Gemini CLI runs without sandbox mode, it has full file system access and can modify files based on its interpretation of the conversation. Since Claude Code already manages the workspace, allowing another AI to make direct file changes creates conflicting modifications. Sandbox mode restricts Gemini to read-only operations.

**When to make exceptions**: Never from Claude Code. Sandbox mode is mandatory.

### 2. Structure Your Prompts Clearly

**Pattern**: `gemini -s "Review [FILE/TOPIC] for [SPECIFIC_CONCERN]"`

**Why**: Gemini produces better responses when given specific scope and concrete questions. Vague prompts like "what do you think?" lead to generic responses that aren't actionable.

**Good example**: `gemini -s "Review src/auth.ts for security vulnerabilities in JWT handling"`
**Bad example**: `gemini -s "Review this code"` (too vague - Gemini won't know what to focus on)

### 3. Output Formats

```bash
# Text output (default, human-readable)
gemini -s "your prompt"

# JSON output (for structured parsing)
gemini -s -o json "your prompt"
```

**When to use JSON**: Use `-o json` when you need to parse specific fields from Gemini's response programmatically.

## Example Prompts

### Code Review
```bash
# Gemini can read files - provide paths in the prompt
gemini -s "Review src/utils/parser.ts for potential bugs and improvements"
```

### Design Discussion
```bash
gemini -s "What are the pros and cons of using Redux vs React Context for state management in a medium-sized React application?"
```

### Architecture Opinion
```bash
gemini -s "Review this API design and suggest improvements:

GET /users/{id}/posts
POST /users/{id}/posts
DELETE /posts/{id}

Should we restructure these endpoints?"
```

## Success Criteria

When consulting Gemini, verify:
- [ ] **Sandbox mode enabled**: Command includes `-s` flag
- [ ] **Specific question asked**: Prompt contains concrete question (not generic "what do you think?")
- [ ] **Context provided**: Prompt includes relevant file paths or describes the situation
- [ ] **Attribution clear**: Response indicates "Gemini suggests..." (not presented as your own analysis)

## Attribution Guidelines

When reporting Gemini's responses:
- **Always attribute** opinions to Gemini (e.g., "Gemini suggests...", "According to Gemini...")
- **Distinguish** between Gemini's analysis and Claude's observations
- **Note discrepancies** if Gemini's response conflicts with Claude's analysis or other information

**Why attribution matters**: The user needs to know which AI provided which perspective to make informed decisions and understand the source of different recommendations.

## Reference

For complete CLI syntax and options, see: [gemini-reference.md](references/gemini-reference.md)
