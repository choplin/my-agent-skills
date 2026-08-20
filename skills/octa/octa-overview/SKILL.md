---
name: octa-overview
description: Gives a read-only snapshot of the current Git repository's octa work as a Markdown section per active Project plus Project-unassigned Issues, with open, in progress, and closed counts and a list of the unfinished Issues by most recent update. Use when deciding what is active or next without changing tracker state.
metadata:
  description-role: documentation
---

# Overview current octa work

Apply `octa-base`. This skill reads and reports only; never create, edit, lock,
or transition a record.

The point of this skill is the report, not the reading. Its goal is that a
reader takes in the whole state of the repository's work at a glance, at the
lowest cognitive load the medium allows — which Project is moving, what is
ready to pick up, what is stuck. Every rule in `## Report` exists to serve
that, and the layout is load-bearing rather than cosmetic: a change that makes
the output flatter, longer, or more uniform defeats the skill even when every
fact in it stays correct. When a formatting decision is open, resolve it
towards what the eye can separate without reading.

## Flow

### 1. Read everything in one query

The overview always needs the same fields, so it is one fixed read. Run this
document verbatim. Do not consult `octa query --schema`, do not probe the CLI
for available fields, and do not assemble a different document — the shape
below is the contract this skill is written against.

```
octa query <<'GRAPHQL'
{
  projects(limit: 100) { id name summary state stateType }
  unfinished: issues(filter: { stateType: ["open", "in progress"] }, limit: 100) {
    number title state stateType updatedAt leased
    project { id }
    labels { name }
    blockedBy { number stateType }
  }
  closed: issues(filter: { stateType: "closed" }, limit: 100) {
    number
    project { id }
  }
}
GRAPHQL
```

One response covers the whole report. `state` and `stateType` arrive together
on every Issue, so no separate read of the state configuration is needed to
turn a state into a count column; and the closed Issues arrive carrying their
Project id, so no Project tally is needed either.

Inspect the response `errors` before consuming `data`; the process can exit
successfully on a failed operation. When a list comes back holding exactly 100
entries, re-run that one list with `offset` until it returns fewer, and merge —
`projects` and `closed` are the ones that realistically overflow.

If `octa` is not on PATH, or the command fails because the working directory is
not a Git repository octa knows, report that and stop rather than falling back
to another command.

### 2. Partition and count

Discard Projects whose `stateType` is `closed` before building the report.
Never render a section for a closed Project, including when it has unfinished
Issues. Do not move those Issues into **No Project**; they remain assigned to
the closed Project and are outside this overview of current work.

Partition the remaining `unfinished` Issues into their active Project or
**No Project**, matching on `project.id` against the `projects` result.

Count each block from the same response: `open` and `in progress` from the
`unfinished` Issues by `stateType`, and `closed` from the `closed` Issues,
grouped by `project.id`, with the null-Project ones forming the **No Project**
count. If `closed` was too large to paginate through, omit the closed count and
say it was not counted; do not substitute a repository-wide number for it.

An active Project's `summary` is the purpose line. An active Project with no
Issue in any of the three counts is still current work; report it with its zero
row.

## Report

Write Markdown. Active Project is the top axis, so each active Project is its
own `##` section and the Issues inside it are a list. Do not write the report
as prose, and do not use tables: the pipes and header rows are overhead the
reader does not need. Do not split a Project into per-state subsections either
— the extra headings stretch the block down the screen without adding a
distinction the state note already carries.

Order the sections by activity: a Project with `in progress` work outranks one
sitting entirely in `open`. Keep the **No Project** section last, and keep it
even when its only content is a zero row.

### What the renderer gives you

The report is read in a terminal, where only a narrow set of Markdown carries
visual weight. The layout below is built on exactly that set, so do not
substitute equivalents:

- Headings render bold. Heading level changes neither size nor colour, so a
  deeper heading buys nothing.
- Inline code is the only colour channel available to text; emoji carry their
  own colour.
- `---` is not drawn as a rule. Use a run of `─` (U+2500), which is a literal
  character and therefore always appears.
- Leading spaces inside a list item are collapsed, so a column cannot be built
  out of plain spaces. Spaces inside an inline code span do survive, which is
  the only way to align a text column.
- Private-use codepoints are stripped, so Nerd Font glyphs render as nothing.
  Never emit them.

### Section shape

1. A `##` heading carrying the Project name, then ` — `, then the counts as
   `N open · N wip · N closed`. The counts share the heading line rather than
   taking one of their own. Do not add a total; it is the sum of the three.
2. The Project's purpose on the next line, only when the name does not already
   convey it.
3. One list of that block's `open` and `in progress` Issues, most recently
   updated first, up to **10 items**. Both types share one list so the ordering
   is a single activity axis; the state note keeps the six states apart.
4. When items were omitted, a line saying how many: `+N more open Issues`.
5. A `────────────────────` rule closing the section, the last section
   included. This rule is the only strong signal that a Project ended, because
   the heading below it is merely bold.

### Issue line

One line per Issue: `- <#N> <title> — <updated> · <notes>`.

The number opens the line in its own inline code span, so it takes the code
colour and the row is addressable at a glance. Right-pad it inside the span to
the widest number displayed in that block — `#3 ` beside `#54` — so a
one-digit number does not shift every title after it.

The title follows as plain text. It is the only unstyled run on the row, which
is what makes the eye land there.

The state is the first note in the trailing metadata, written lower case:
`wip`, `review`, `todo`, `backlog`. The two-word states are written short. Do
not move the state ahead of the title and do not turn it into a leading column:
it is the field the reader consults after finding a row that interests them,
not the one they scan for, and a state column pushes every title to the right
by its own width.

Never substitute an emoji marker for the state word — colour reads poorly
against a dark terminal, and a glyph has to be learned before the row can be
read at all.

The state names the state and nothing more. A Todo carrying a blocker still
reads `todo`; whether it can actually be picked up is read from its
`blocked by` note.

Updated is the `updatedAt` date as `MM-DD`, prefixed with the year when the
Issue was last updated in an earlier year. Show the date only; never add a
time, however close together the timestamps are. Order on the full timestamp
all the same.

Do not annotate the ordering. No line observing that a block's dates coincide,
that the Issues arrived in one bulk import, or that the sequence therefore
carries no activity signal. The dates are on the rows and the reader can see
them; a sentence restating them is exactly the flat prose this report exists to
keep out.

Notes carry what changes pickability and nothing else, each in its own inline
code span, in a fixed order: the state, then the Type label (`impl`, `design`,
`research`) when it is set, then `leased` when the Issue is claimed, then the
blockers outside the `closed` type. The order is fixed so the trailing run
reads as columns even though it is ragged.

Blockers are one note, not one per blocker: `blocked by #11, #19`. Cap the
numbers at three and append ` +N`, so one heavily blocked Issue does not crowd
out the rest of the list. Read `octa issue show <n> --json` for a displayed
Issue only when blocker status materially affects whether it can be picked up.

No label repeats inside a row. Any field that can hold several values is
written once and its values listed after it — the label is the expensive part
of a note, and repeating it turns the one field the reader most needs to skim
into the longest thing on the line.

```markdown
## Replace the cache path — 6 open · 2 wip · 11 closed
Swap the cache path for the new resolver

- `#12` Point the resolver at the new cache root — 08-17 · `wip` `impl` `leased`
- `#18` Add cache diagnostics — 08-16 · `review` `impl`
- `#14` Remove the compatibility layer — 08-15 · `todo` `impl` `blocked by #12, #18`
- `#21` Decide the invalidation contract — 08-11 · `backlog` `design`

+4 more open Issues

────────────────────

## No Project — 1 open · 0 wip · 3 closed

- `#30` Refresh the contributor guide — 08-09 · `backlog`

────────────────────
```

If neither an active Project nor a Project-unassigned unfinished Issue exists,
say that no current work was found in this repository rather than printing
empty sections. Closed Projects do not prevent this empty result.

Close with a short evidence-based interpretation: what is changing, what is
ready next, and any blocker or concentration of risk. Write it as a plain
paragraph after the final rule, with no heading — `##` means Project here, and
a closing section wearing one reads as another Project until the reader has
parsed it. Ground it in the shown Issues rather than restating the counts. In
Progress and In Review rows are the resume candidates; Todo rows are the
pickable ones.

Then route without acting:

- start/resume → `octa-start`;
- groom a Project Backlog → `octa-groom`;
- groom a **No Project** Backlog Issue → pick it through `octa-start`, which
  applies the single-Issue grooming gate before execution;
- pause active work → `octa-handoff`.
