# Bring an octa store to this operating convention

Apply this once per store, before its first lifecycle use. Read
`references/knowledge/workflow-configuration.md` for the required states and
labels, and apply the external `octa` skill for configuration mechanics and
mutation safety. Inspect the global configuration before changing anything.

## 1. Configure the six Issue states

Inspect the store's Issue states, then map them to Backlog, Todo, In Progress,
In Review, Done, and Canceled with the types and defaults defined by the
workflow configuration. For the product's initial seed, rename the seeded
states rather than stacking near-duplicates beside them:

```sh
octa config issue state set "open" --name Backlog          # renaming moves its Issues too
octa config issue state set "in progress" --name "In Progress"
octa config issue state set "closed" --name Done
octa config issue state set "not planned" --name Canceled
octa config issue state create Todo --type open
octa config issue state create "In Review" --type "in progress"
```

For an existing custom configuration, preserve its Issues and make an explicit
mapping to the six required states. Do not guess at destructive state changes.

## 2. Create the type labels

Inspect the store's existing Issue labels first, then create the missing
definitions:

```sh
octa config issue label list --json
octa config issue label-group create Type --selection single
octa config issue label create impl --group Type
octa config issue label create design --group Type
octa config issue label create research --group Type
```

The policy governing these labels — what not to create, and why `orchestration`
and priority stay out — is in `references/knowledge/workflow-configuration.md`.
