# AI Council Plugin

Ask other AI agents for opinions during code review and discussions.

## Overview

This plugin enables Claude Code to consult other AI agents (OpenAI Codex CLI and Google Gemini CLI) for alternative perspectives on code, design decisions, and technical questions.

## Components

| Component | Name | Purpose |
|-----------|------|---------|
| Skill | codex-cli | Learn how to use Codex CLI |
| Agent | codex-advisor | Autonomously query Codex for opinions |
| Reference | codex-reference.md | Detailed Codex CLI documentation |
| Skill | gemini-cli | Learn how to use Gemini CLI |
| Agent | gemini-advisor | Autonomously query Gemini for opinions |
| Reference | gemini-reference.md | Detailed Gemini CLI documentation |

## Prerequisites

1. **Install Codex CLI**
   ```bash
   npm install -g @openai/codex
   ```

2. **Configure authentication**
   ```bash
   codex login
   ```
   or set environment variable:
   ```bash
   export OPENAI_API_KEY="your-api-key"
   ```

### Gemini CLI

1. **Install Gemini CLI**
   ```bash
   npm install -g @google/gemini-cli
   ```

2. **Configure authentication**
   ```bash
   gcloud auth application-default login
   ```
   or set environment variable:
   ```bash
   export GOOGLE_API_KEY="your-api-key"
   ```

### Additional Setup

3. **Configure codex-xhigh alias** (recommended)
   ```bash
   # Add to your shell config (.bashrc, .zshrc, etc.)
   alias codex-xhigh='codex --config model_reasoning_effort="xhigh"'
   ```

4. **Claude Code sandbox settings** (macOS only)

   Codex CLI requires access to macOS SystemConfiguration API, which is blocked by Claude Code's default sandbox. Add the following to `~/.claude/settings.json`:

   ```json
   {
     "sandbox": {
       "enabled": true,
       "allowUnsandboxedCommands": true,
       "excludedCommands": ["codex", "codex-xhigh"]
     }
   }
   ```

   See: [sandbox-runtime#30](https://github.com/anthropic-experimental/sandbox-runtime/issues/30) for details on this limitation.

## Usage

### Ask Codex for an opinion

```
Codexにこのコードをレビューしてもらって
```

```
Ask Codex what it thinks about this design
```

### Ask Gemini for an opinion

```
Geminiにこのアーキテクチャについて聞いて
```

```
Get Gemini's opinion on this implementation
```

### Get CLI usage help

```
Codexの使い方を教えて
```

```
Geminiの使い方を教えて
```

## Example Interactions

### Code Review
> User: この関数についてCodexの意見を聞いて
>
> Claude: [Uses codex-advisor agent to get Codex's review and presents the findings]

### Design Discussion
> User: このアーキテクチャについて他のAIの視点が欲しい
>
> Claude: [Queries Codex and provides a comparison of perspectives]

## Safety

### Two Layers of Sandboxing

This plugin involves two separate sandbox mechanisms:

1. **Codex CLI sandbox** (`-s read-only`): Prevents Codex from modifying files on your system. All queries use this mode.

2. **Claude Code sandbox**: Restricts what commands Claude can execute. Due to a [macOS limitation](https://github.com/anthropic-experimental/sandbox-runtime/issues/30), Codex CLI requires `allowUnsandboxedCommands: true` to access SystemConfiguration API.

### Security Notes

- The agent **never makes code changes** based on Codex's suggestions - only reports findings
- Responses are clearly attributed to distinguish Codex's opinions from Claude's
- Code sent to Codex is transmitted to OpenAI's API - avoid sending sensitive credentials or PII

## Future Plans

- Add support for other AI agents
- Enable multi-agent discussions for complex decisions
