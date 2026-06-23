# Gemini CLI Reference

## Installation

```bash
npm install -g @google/gemini-cli
```

Or via Homebrew:
```bash
brew install gemini-cli
```

## Authentication

Gemini CLI uses Google Cloud authentication. Ensure you have authenticated:

```bash
gcloud auth login
gcloud auth application-default login
```

Or set the API key:
```bash
export GOOGLE_API_KEY="your-api-key"
```

## Commands

### gemini (Default Command)

Launch an interactive CLI or execute a one-shot prompt:

```bash
# Interactive mode
gemini

# One-shot with positional prompt
gemini "your prompt here"
```

### Positional Arguments

| Argument | Description |
|----------|-------------|
| `query` | Positional prompt. Defaults to one-shot; use `-i` for interactive continuation |

### Options

| Option | Description |
|--------|-------------|
| `-d, --debug` | Run in debug mode (default: false) |
| `-m, --model <model>` | Specify the model |
| `-p, --prompt <text>` | **Deprecated**: Use positional prompt instead |
| `-i, --prompt-interactive <text>` | Execute prompt and continue in interactive mode |
| `-s, --sandbox` | Run in sandbox mode (boolean) |
| `-y, --yolo` | Auto-approve all actions (default: false) |
| `--approval-mode <mode>` | Set approval mode: `default`, `auto_edit`, `yolo` |
| `--allowed-tools <tools>` | Tools allowed without confirmation (array) |
| `-e, --extensions <list>` | Extensions to use |
| `-l, --list-extensions` | List available extensions and exit |
| `-r, --resume <session>` | Resume previous session (use "latest" or index) |
| `--list-sessions` | List available sessions |
| `--delete-session <index>` | Delete a session by index |
| `--include-directories <dirs>` | Additional workspace directories |
| `--screen-reader` | Enable screen reader mode |
| `-o, --output-format <format>` | Output format: `text`, `json`, `stream-json` |
| `-v, --version` | Show version number |
| `-h, --help` | Show help |

### MCP Commands

```bash
gemini mcp          # Manage MCP servers
```

### Extension Commands

```bash
gemini extensions <command>   # Manage extensions
gemini extension <command>    # Alias for extensions
```

## Sandbox Mode

The `-s, --sandbox` flag enables sandbox mode for safer execution:

```bash
# Enable sandbox
gemini -s "Review this code"
```

When sandbox is enabled:
- File modifications may be restricted
- Network access may be limited
- Shell commands may require approval

## Approval Modes

| Mode | Description |
|------|-------------|
| `default` | Prompt for approval on all actions |
| `auto_edit` | Auto-approve edit tools only |
| `yolo` | Auto-approve all tools (use with caution) |

```bash
# Set approval mode
gemini --approval-mode auto_edit "your prompt"
```

## Output Formats

| Format | Description |
|--------|-------------|
| `text` | Human-readable text output (default) |
| `json` | Structured JSON output |
| `stream-json` | Streaming JSON output |

```bash
# JSON output
gemini -o json "your prompt"

# Stream JSON
gemini -o stream-json "your prompt"
```

## Session Management

Resume previous sessions or manage session history:

```bash
# Resume latest session
gemini -r latest

# Resume specific session
gemini -r 5

# List sessions
gemini --list-sessions

# Delete a session
gemini --delete-session 3
```

## Examples

### Get a quick opinion
```bash
gemini -s "What do you think about using monorepos for microservices?"
```

### Review code in sandbox mode
```bash
gemini -s "Review src/components/Button.tsx for accessibility issues"
```

### Get JSON output
```bash
gemini -s -o json "List 5 best practices for React hooks"
```

### Interactive session after initial prompt
```bash
gemini -i "Let's discuss the architecture of this project"
```

### Specify model
```bash
gemini -m gemini-2.0-flash "Explain this error message"
```
