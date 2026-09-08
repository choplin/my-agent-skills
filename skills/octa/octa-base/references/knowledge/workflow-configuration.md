# Workflow configuration

Read this before first lifecycle use of an octa store. The external `octa`
product skill owns configuration commands, global scope, defaults, and mutation
safety. This reference defines only the configuration required by this
workflow. Apply `references/procedures/store-setup.md` to bring the store to the
convention described here.

## Issue states

### The lifecycle this convention configures

This operating convention splits capture from grooming and execution from
review, so it requires six Issue states:

| State | Type | Default | Notes |
|---|---|---|---|
| Backlog | open | yes | new Issues enter here |
| Todo | open | | |
| In Progress | in progress | yes | |
| In Review | in progress | | |
| Done | closed | yes | |
| Canceled | closed | | |

The paired states are intentional. Their shared type gives the coarse lifecycle
phase; their names distinguish captured from groomed work, active work from
review, and completed from canceled work. State list order carries no workflow
meaning. If any required state is missing, report it instead of substituting
another state.

## Project states

This operating convention prescribes no particular Project state set. A Project
is a finite outcome that is either still open or finished with, while active
work is read from its Issue tally. Retain the product defaults unless the
repository needs a named distinction such as Planned versus In Progress; the
workflow does not depend on either name.

## Type labels

The Type group carries `impl`, `design`, and `research`. Apply
`references/procedures/store-setup.md` to create them in a store that lacks
them.

Do not create Repo labels; repository scope already carries that identity. Do
not reserve any taxonomy beyond this operating convention in product code.

Do not add `orchestration` by default. Introduce it only together with an
octa-aware planning/orchestration workflow that defines how its control Issue
is created, resumed, and completed.

Priority is not part of this operating convention. Introduce a separate
single-select classification only when there is a durable need to record it.
