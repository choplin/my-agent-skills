# English Rhythm Lens

This is an editorial heuristic for continuously read prose, not an independent
local conformance test. Use it to realize the cognitive movement in the plot;
do not impose a fixed sentence-length waveform.

## `en.cadence`

```yaml
lens: en.cadence
language: en
layer: rhythm
packing_group: english-rhythm
objective: Find continuously read English prose whose sentence and paragraph
  cadence gives every idea the same rhetorical weight.
checks:
  - Repeated declarative sentences with the same length and syntactic movement.
  - Dense paragraphs running together without a short footing or stop.
  - Short sentences repeated mechanically rather than used for emphasis.
  - A fixed viewpoint distance held across a whole passage.
non_goals:
  - Do not vary syntax for ornament alone.
  - Do not manufacture disagreement, suspense, or a reader belief.
content_impact: none
```

Use short footing and stops deliberately, vary clause movement by logical role,
and alternate density only where the subject matter supplies a real transition.
