# Workflow adapter implementations

Provider-bound operation implementations, organized by provider:

- `llm-wiki/`: durable Markdown operations through llm-wiki
- `octa/`: tracker operations through octa
- `wtm/`: repository-worktree operations through wtm

Install this directory as one group together with `workflow-adapter` and the
provider skills used in the target environment. Provider selection rules live
in each operation implementation's `description`; there is no provider router
or monolithic implementation skill.
