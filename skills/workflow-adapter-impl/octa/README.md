# octa workflow adapter implementations

Operation-specific implementations of the tracker contracts through octa.

| Contract | Implementation |
|---|---|
| `workflow-adapter-tracker-resolve` | `workflow-adapter-impl-octa-resolve` |
| `workflow-adapter-tracker-list` | `workflow-adapter-impl-octa-list` |
| `workflow-adapter-tracker-read` | `workflow-adapter-impl-octa-read` |
| `workflow-adapter-tracker-create` | `workflow-adapter-impl-octa-create` |
| `workflow-adapter-tracker-update` | `workflow-adapter-impl-octa-update` |
| `workflow-adapter-tracker-comment` | `workflow-adapter-impl-octa-comment` |
| `workflow-adapter-tracker-relate` | `workflow-adapter-impl-octa-relate` |
| `workflow-adapter-tracker-transition` | `workflow-adapter-impl-octa-transition` |

Each implementation description declares both the neutral operation it handles
and the octa selection cues. Install this group with
`workflow-adapter-tracker` and `octa`.

Selection precedence lives in those descriptions: an explicit request provider
wins; with provider omitted, known locator provenance may select octa; only
without either cue may an explicit repository designation select it. An ID's
shape alone never identifies the provider.
