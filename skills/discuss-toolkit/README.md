# discuss-toolkit

Skills for understanding user intent and providing feedback.

## Skills

| Skill | Description |
|-------|-------------|
| `dig` | Base skill for deep intent clarification through structured interview |
| `quick-chat` | Fast, honest feedback when context is clear |
| `name-project` | Project naming with intent clarification and conflict checking |

## Skill Hierarchy

```
dig (base skill - intent clarification)
 └── name-project (specialized skill, uses dig first)

quick-chat (independent - for quick decisions)
```

## When Skills Activate

- **dig**: When AI needs to make assumptions, when intent is unclear, or `/dig` is called
- **quick-chat**: "what do you think", "A vs B", "which is better" (when context is clear)
- **name-project**: "name this project", "suggest a name"

## Core Principle

Never fill gaps with general best practices. When information is missing:
1. Ask using AskUserQuestion (dig skill)
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
