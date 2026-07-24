# discuss-toolkit

Skills for clarifying intent, stress-testing candidate directions, and pacing
multi-point discussions.

## Skills

| Skill | Description |
|-------|-------------|
| `dig` | Base skill for deep intent clarification through structured interview |
| `grill-me` | Stress-test a candidate direction through one-question-at-a-time interviewing |
| `one-point` | Handle multiple discussion points one at a time instead of dumping them all at once |

## Skill Hierarchy

```
dig (base skill - intent clarification)

grill-me (independent - candidate robustness; delegates to dig when no test object is clear)

one-point (independent - pacing of multi-point discussions)
```

`grill-me` intentionally keeps its upstream name instead of taking the
`discuss-toolkit-` prefix.

## When Skills Activate

- **dig**: When AI needs to make assumptions, when intent is unclear, or `/dig` is called
- **grill-me**: When the user has a candidate direction and asks to challenge assumptions, poke holes, or be grilled
- **one-point**: `/one-point`, "一つずつ", "一気に出さないで" — or the AI is about to raise two or more discussion points

## Routing

- Use **dig** to improve fidelity: make the agent's understanding match the
  user's intent.
- Use **grill-me** to improve robustness: make a candidate direction
  withstand challenge.
- Use **one-point** to improve pacing: keep multiple known discussion points
  navigable.

The same rough idea can fit either `dig` or `grill-me`. Route by the requested
outcome: clarify what the user means with `dig`; challenge whether their
candidate direction holds with `grill-me`. If no test object can be identified
without guessing, let `dig` establish only that object, then return to
`grill-me`.

## Intent-Clarification Principle

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
