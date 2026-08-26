# llm-wiki workflow adapter implementations

Operation-specific implementations of the durable Markdown contracts through
llm-wiki.

| Contract | Implementation |
|---|---|
| `workflow-adapter-markdown-resolve` | `workflow-adapter-impl-llm-wiki-resolve` |
| `workflow-adapter-markdown-find` | `workflow-adapter-impl-llm-wiki-find` |
| `workflow-adapter-markdown-read` | `workflow-adapter-impl-llm-wiki-read` |
| `workflow-adapter-markdown-create` | `workflow-adapter-impl-llm-wiki-create` |
| `workflow-adapter-markdown-update` | `workflow-adapter-impl-llm-wiki-update` |

Each implementation description declares both the neutral operation it handles
and the llm-wiki selection cues. Install this group with
`workflow-adapter-markdown` and the required llm-wiki skills.

Selection precedence lives in those descriptions: an explicit request provider
wins; with provider omitted, known locator provenance may select llm-wiki; only
without either cue may an explicit repository designation select it. A path's
shape alone never identifies the provider.
