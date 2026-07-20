# discuss-toolkit

Skills for understanding user intent and pacing multi-point discussions.

## Skills

| Skill | Description |
|-------|-------------|
| `dig` | Base skill for deep intent clarification through structured interview |
| `one-point` | Handle multiple discussion points one at a time instead of dumping them all at once |

## Skill Hierarchy

```
dig (base skill - intent clarification)

one-point (independent - pacing of multi-point discussions)
```

## When Skills Activate

- **dig**: When AI needs to make assumptions, when intent is unclear, or `/dig` is called
- **one-point**: `/one-point`, "一つずつ", "一気に出さないで" — or the AI is about to raise two or more discussion points

## Core Principle

Never fill gaps with general best practices. When information is missing:
1. Ask the user via the host agent's user-input mechanism (dig skill — `AskUserQuestion` on Claude Code, the host's equivalent elsewhere)
2. Present hypotheses for user confirmation
3. Only proceed when intent is verified

**This applies to the entire workflow**—both clarification and any content created based on the result.

## Installation

Add to your `.claude/settings.json`:

```json
{
  "plugins": [
    "/path/to/discuss-toolkit"
  ]
}
```
