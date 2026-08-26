# wtm workflow adapter implementations

Operation-specific implementations of the repository-worktree contracts through
wtm.

| Contract | Implementation |
|---|---|
| `workflow-adapter-worktree-resolve` | `workflow-adapter-impl-wtm-resolve` |
| `workflow-adapter-worktree-list` | `workflow-adapter-impl-wtm-list` |
| `workflow-adapter-worktree-read` | `workflow-adapter-impl-wtm-read` |
| `workflow-adapter-worktree-create` | `workflow-adapter-impl-wtm-create` |
| `workflow-adapter-worktree-remove` | `workflow-adapter-impl-wtm-remove` |

Each implementation description declares both the neutral operation it handles
and the wtm selection cues. Install this group with
`workflow-adapter-worktree` and `wtm`.

Selection precedence lives in those descriptions: an explicit request provider
wins; with provider omitted, known locator provenance may select wtm; only
without either cue may an explicit repository designation select it. A name's
shape alone never identifies the provider.
