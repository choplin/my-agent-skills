# Bring an octa store to this operating convention

Apply this once per store, before its first lifecycle use. States and labels are
configured store-wide and govern every repository in it, so a rename or deletion
here moves or retires Issues everywhere. Inspect the current configuration in
`references/knowledge/workflow-configuration.md` before changing anything.

## 1. Configure the six Issue states

A store with no configured states is seeded with `open`, `in progress`,
`closed`, and `not planned`, one default per type. Seeding runs only when no
state is configured at all, so a customized store keeps exactly the states it
has. Rename the seeded states into the six this convention configures — Backlog,
Todo, In Progress, In Review, Done, and Canceled — rather than stacking
near-duplicates beside them:

```sh
octa config issue state set "open" --name Backlog          # renaming moves its Issues too
octa config issue state set "in progress" --name "In Progress"
octa config issue state set "closed" --name Done
octa config issue state set "not planned" --name Canceled
octa config issue state create Todo --type open
octa config issue state create "In Review" --type "in progress"
```

Renaming carries each type's existing default with it, so Backlog, In Progress,
and Done end up as the defaults without a further command.

For a store that already holds other states, rename where the target name is
free and delete with `--move-to` where it collides with a state the store
already has:

```sh
octa config issue state delete <old> --move-to <new>  # --move-to is required while Issues remain
```

The schema refuses to delete a state that still holds Issues without
`--move-to`, and deleting a state never deletes Issues.

## 2. Create the type labels

Inspect the store's existing labels first, then create the missing definitions:

```sh
octa config issue label-group create Type --selection single
octa config issue label create impl --group Type
octa config issue label create design --group Type
octa config issue label create research --group Type
```

The policy governing these labels — what not to create, and why `orchestration`
and priority stay out — is in `references/knowledge/workflow-configuration.md`.
