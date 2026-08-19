---
name: octa-import-linear
description: >-
  Imports the unfinished Linear Issues carrying the current repository's Repo
  label into octa, carrying Project, Milestone, state, Type, relations, and
  execution context, skipping what a previous run already imported. Use when
  moving a repository's work from Linear to octa.
metadata:
  description-role: trigger
---

# Import Linear work into octa

This skill exists only for the Linear-to-octa migration. It is safe to run
repeatedly during the migration, and it is meant to be deleted once no
repository still tracks work in Linear (see *Retiring this skill*).

Apply `octa-base` for state resolution, Type labels, the lease contract, and
the record model. Apply `linear-base` for the workspace conventions the import
reads, in particular its **Step A** repo-to-Repo-label resolution.

Import moves records; it does not groom them. A Linear body that falls short of
octa's Todo authoring standard is carried across as it is, and `octa-groom`
raises it afterwards.

## Scope

Only **unfinished** Linear Issues are imported: status types `backlog`,
`unstarted`, and `started`. Completed and canceled work stays in Linear as the
archive, because octa cannot reproduce its comment history, authorship, or
timestamps faithfully.

## Report octa gaps instead of working around them

octa is under active development and this import is dogfooding it. When octa
cannot represent or accept something the Linear record carries, do not force
the import through: no substitute field, no encoding the content into the body
or a comment, no dropping the part that does not fit.

Skip the affected record whole — a half-imported Issue is worse than an absent
one, and leaving no footer means a later run retries it once octa can take it.
Leave its Linear record untouched. If the gap blocks the run as a whole (a
required command or field does not exist at all), stop before writing anything.

Collect these as **feedback for octa**, separate from the ordinary import
report: what the Linear record needed, which octa command or field was tried,
the exact failure or missing capability, and how many records it affects.

This applies to capability gaps, not to the deliberate model differences in the
mapping below. A dropped `Repo` label, a dropped priority, an unused Cycle, and
comment history left in Linear are decisions of this migration; they are not
octa defects and do not belong in the feedback.

## Provenance and re-run safety

Every octa record this skill creates ends its body with one footer line:

```
Imported from Linear: ENG-123
```

Before creating anything, read the bodies of all octa Issues and the
descriptions of all octa Projects in the repository, collect their footers, and
skip every Linear record already present. An already-imported record is never
created again and never re-synced — report it as skipped and leave it alone.

The footer is the only Linear reference octa carries. Strip it if a body is
ever exported into a repository file, as `linear-base` requires.

## Flow

### 1. Confirm both sides

Confirm `octa` is available and the working directory is the target Git
repository. Resolve states with `octa config issue state list --json` and
inspect the `Type` label group. If the lifecycle states or Type labels are
missing, run `octa-base`'s `references/workflow-configuration.md` first; do not
import into a half-configured store.

Confirm a Linear MCP server is wired. If either side is unavailable, stop and
report which one.

### 2. Resolve the Repo label

Apply `linear-base` Step A to resolve the current repository to its Repo label
`R`. Ask the user when the match is absent or ambiguous; never guess.

### 3. Select what to import

List the Linear Issues labeled `R` whose status type is `backlog`, `unstarted`,
or `started`. Show the tally by status and by Project, then confirm before
writing anything. Let the user narrow the run to one Project or one status;
partial runs are expected and the footer check makes a later run additive.

### 4. Read the whole selection first

For each selected Issue read the description, labels, Project, Milestone,
parent, `blockedBy`/`blocks`/`relatedTo`, comments, and attachment links. Read
the owning Projects too. Resolve the mapping below and report what
will be dropped **before** the first write. Anything the mapping cannot place
is an octa gap, not a detail to improvise around: hold it for the feedback
report and leave the affected records out of the run.

### 5. Create Projects and Milestones

An active Linear Project that owns a selected Issue becomes an octa Project
with the same name, its description plus the footer, and an open state: create
it with `octa project create`, which resolves the `open` default on its own.
Create a Milestone only when the Linear Project actually has one, preserving
its order.

A completed or canceled Linear Project that still owns a selected Issue is not
recreated: leave the octa Issue Project-unassigned and report it, so the user
can decide where the leftover work belongs.

### 6. Create Issues

Create Issues in a stable order (by Linear identifier) and keep the Linear
identifier to octa number map in session context for the relation pass.

1. Body: the Linear description verbatim, a blank line, then the footer. When
   the description is empty, the footer alone is the body.
2. Create with `octa issue open --title <title> --body <body> --json`. It
   resolves to the `open` default, Backlog. `--as` reaches another `open` state,
   so a Todo target can be set at creation with `--as Todo`; In Progress and In
   Review are a different type and are set in step 3.
3. Acquire `LEASE=$(octa issue lock <number>)` and apply the protected
   mutations with it: the single Type label, Project, Milestone, and the state
   when it was not set at creation. `octa issue set <number> --as <state>` is
   the move that reaches any type, so use it for In Progress and In Review
   rather than `issue start`, which cannot pick between the two.
4. Release with `octa issue unlock <number> --lease "$LEASE"` before moving to
   the next Issue. This skill never leaves a lease held, including on failure —
   an imported In Progress Issue must be claimable by whichever session resumes
   it. Never record the lease ID anywhere durable.

A Linear Issue with no Type label is imported without one; report it so
grooming can assign one.

### 7. Wire relations

Run this as a second pass, after every selected Issue exists, because octa
numbers are only known at creation.

Set parent/sub-issue links, then `--blocker` relations, then related links,
each with a lease on the Issue being changed. Both endpoints must have been
imported. When an endpoint is a completed Linear Issue, skip the relation and
record it in the migration comment: a blocker that is already Done imposes no
remaining order, but the reader should know it existed.

### 8. Write the migration comment

Post one comment per imported Issue, headed `## Imported from Linear`. Comments
need no lease. It carries:

- the source status, Project, and Milestone as they stood in Linear;
- the substance of the Linear comments that execution still needs — the newest
  handoff note, decisions and their rationale, rejected alternatives, and open
  questions — rewritten as one coherent section rather than transcribed comment
  by comment;
- branch, PR, and other attachment links;
- everything the import could not carry: dropped relations, dropped labels, an
  unmapped Project, a missing Type.

Drop chatter, status pings, and bot notifications. Keep anything a fresh
session would otherwise have to reconstruct.

### 9. Close the Linear side

Only after the octa Issue exists and its migration comment is posted:

1. Comment on the Linear Issue that the work has moved to octa in this
   repository and continues there. Do not write the octa Issue number — octa
   numbers are repository-local coordination references (`octa-base`).
2. Move the Linear Issue to the status whose type is `canceled`. State in the
   same comment that Canceled records the move, not abandonment, so the Linear
   history is not misread later.

If octa creation or the migration comment failed for an Issue, leave its Linear
record untouched so the next run retries it.

### 10. Report

Report imported counts by state, the Projects and Milestones created, records
skipped as already imported, failures with their reason, data deliberately
dropped, and what still remains under `R` in Linear. Point to `octa-overview`
for the resulting picture and `octa-groom` for bodies that do not yet meet the
Todo standard.

Close with the octa feedback report as its own section, even when it is empty.
It is the point of dogfooding the import, and it is the only place a capability
gap survives the run.

## Mapping

| Linear | octa |
|---|---|
| status type `backlog` | Backlog |
| status type `unstarted` | Todo |
| status type `started`, working | In Progress |
| status type `started`, review | In Review |
| status type `completed` / `canceled` | not imported |
| active Project | Project, left open |
| completed or canceled Project | not created; Issue left Project-unassigned |
| Milestone | Milestone |
| `Type` label | same `Type` member |
| `Repo` label | dropped — octa scopes records by repository |
| other Issue labels (e.g. `deep`) | dropped and reported, unless octa already defines the same label |
| priority | dropped — octa stores none; report it with the other dropped data |
| parent / sub-issue | parent / sub-issue |
| `blockedBy` | blocker relation |
| `relatedTo` | related relation |
| Cycle | unused in both models |
| comments | one migration comment |
| attachments and links | link list inside the migration comment |

## Retiring this skill

When no repository still tracks work in Linear, delete this skill directory and
its row in the group README. The footers may stay as provenance or be removed
from the octa bodies; nothing else in the octa group depends on them.
