# Codex CLI Reference

## Installation

```bash
npm install -g @openai/codex
```

## Recommended Alias

For better reasoning quality, use the `codex-xhigh` alias which sets `model_reasoning_effort="xhigh"`:

```bash
# Add to your shell config (.bashrc, .zshrc, etc.)
alias codex-xhigh='codex --config model_reasoning_effort="xhigh"'
```

**All examples in this document use `codex-xhigh` for optimal results.**

## Authentication

### Option 1: Login command
```bash
codex login
```

### Option 2: Environment variable
```bash
export OPENAI_API_KEY="your-api-key"
```

## Commands

### codex (Interactive Mode)

Start an interactive session with Codex:

```bash
codex
```

Options:
- `-m, --model <model>`: Specify the model (default: codex)
- `-s, --sandbox <mode>`: Sandbox mode: `none`, `read-only`, `full` (default: full)
- `--no-sandbox`: Disable sandbox entirely

### codex exec

Execute a single prompt non-interactively:

```bash
codex exec [options] "prompt"
```

Options:
- `-s, --sandbox <mode>`: Sandbox mode
- `-o, --output <file>`: Write response to file
- `--json`: Output in JSON format
- `-m, --model <model>`: Specify the model
- `--timeout <seconds>`: Set execution timeout

### codex review

Review code changes:

```bash
codex review [options] [paths...]
```

Options:
- `--uncommitted`: Review uncommitted changes
- `--base <branch>`: Compare against a base branch
- `--staged`: Review only staged changes
- `-o, --output <file>`: Write review to file

### codex config

Manage configuration:

```bash
codex config get <key>
codex config set <key> <value>
codex config list
```

## Sandbox Modes

| Mode | File Read | File Write | Network | Shell |
|------|-----------|------------|---------|-------|
| `full` | Yes | Yes | Yes | Yes |
| `read-only` | Yes | No | No | Limited |
| `none` | No | No | No | No |

## Configuration Options

Use `-c, --config <key=value>` to override configuration values.

### model_reasoning_effort

Controls how much reasoning effort the model applies.

| Value | Description |
|-------|-------------|
| `low` | Minimal reasoning |
| `medium` | Balanced reasoning |
| `high` | More thorough reasoning |
| `xhigh` | Maximum reasoning effort (recommended for reviews) |

Example:
```bash
codex exec -c model_reasoning_effort="xhigh" "Review this code"
```

### model_reasoning_summary

Controls the detail level of reasoning summaries in output.

| Value | Description |
|-------|-------------|
| `auto` | Automatic (default) - shows summaries based on task complexity |
| `concise` | Brief reasoning summaries |
| `detailed` | Full reasoning summaries |
| `none` | Hide reasoning summaries entirely |

Example:
```bash
codex exec -c model_reasoning_summary="detailed" "Analyze this architecture"
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key for authentication |
| `CODEX_MODEL` | Default model to use |
| `CODEX_SANDBOX` | Default sandbox mode |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Authentication error |
| 3 | Network error |
| 4 | Timeout |

## Examples

### Get a quick opinion
```bash
codex-xhigh exec -s read-only "What do you think about using monorepos for microservices?"
```

### Review PR changes
```bash
codex-xhigh review --base main --output /tmp/review.md
```

### Generate code with specific model
```bash
codex-xhigh exec -m gpt-4 "Write a Python function to parse JSON safely"
```

### Batch review multiple files
```bash
codex-xhigh review src/components/*.tsx
```
