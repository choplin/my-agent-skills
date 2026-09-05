# Japanese Rhythm Lens

## `ja.cadence`

```yaml
lens: ja.cadence
language: ja
layer: rhythm
packing_group: japanese-rhythm
objective: Find continuously read Japanese prose whose repeated sentence and
  paragraph movement makes distinct ideas sound mechanically equal.
checks:
  - A run of bare assertions ending with the same grammatical weight.
  - Every sentence carrying one fact and stopping, despite unequal logical roles.
  - Repeated dense paragraphs with no sentence or paragraph that fixes a point.
  - Short sentences used uniformly rather than as deliberate footing or emphasis.
non_goals:
  - Do not vary endings or sentence length for variety alone.
  - Do not manufacture hesitation, tension, or a reader belief.
  - Do not join sentences before their arguments and hierarchy are recoverable.
content_impact: none
```

Vary movement by function: establish a point, develop it through a clause,
pause, or change viewpoint distance. Sentence length is evidence only when the
boundaries repeatedly give unequal propositions the same rhetorical weight.
