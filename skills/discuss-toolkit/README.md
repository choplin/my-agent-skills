# discuss-toolkit

Skills for guided exploration, stress-testing candidate directions, and pacing
multi-point discussions.

## Skills

| Skill | Description |
|-------|-------------|
| `dig` | Guided exploration that clarifies or broadens intent while tracking the whole discussion |
| `discuss-toolkit-grill-me` | Stress-test a candidate direction through one-question-at-a-time interviewing |
| `one-point` | Handle multiple discussion points one at a time instead of dumping them all at once |

## Skill Hierarchy

```
dig (base skill - guided exploration)

discuss-toolkit-grill-me (independent - candidate robustness; delegates to dig when no test object is clear)

one-point (independent - pacing of multi-point discussions)
```

`discuss-toolkit-grill-me` keeps the upstream phrase while following the
repository's group-prefix convention.

## When Skills Activate

- **dig**: When intent is unclear, the user wants to broaden their thinking, or `/discuss-toolkit-dig` is called
- **discuss-toolkit-grill-me**: When the user has a candidate direction and asks to challenge assumptions, poke holes, or be grilled, or `/discuss-toolkit-grill-me` is called
- **one-point**: `/discuss-toolkit-one-point`, "一つずつ", "一気に出さないで" — or the AI is about to raise two or more discussion points

## Routing

- Use **dig** to improve exploration: clarify or broaden the user's thinking
  while tracking the whole discussion.
- Use **discuss-toolkit-grill-me** to improve robustness: make a candidate direction
  withstand challenge.
- Use **one-point** to improve pacing: keep multiple known discussion points
  navigable.

The same rough idea can fit either `dig` or `discuss-toolkit-grill-me`. Route by the requested
outcome: clarify or broaden the user's thinking with `dig`; challenge whether
their candidate direction holds with `discuss-toolkit-grill-me`. If no test object can be
identified without guessing, let `dig` establish only that object, then return
to `discuss-toolkit-grill-me`.

## Guided-Exploration Principle

Maintain a provisional map of the whole discussion. Ask a question only when its
answer can update that map or affect a downstream decision. State consequential
assumptions; leave low-impact gaps unresolved instead of interrupting the
discussion. Concrete examples are optional tools, not completion requirements.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.
