---
name: document-toolkit-distill
description: >-
  Distill an existing set of documents so it stays high-signal and does not
  bloat — consolidate overlapping documents into one keeper, refresh stale ones,
  split oversized ones, retire what no longer earns reach. The caller names the
  set and says what it is for; this skill judges which operation each document
  needs and carries it out, deleting the sources it folded in. Triggers on
  "distill these docs", "consolidate these notes", "these documents overlap",
  "tidy up this doc set", "ドキュメントを整理して", "重複したドキュメントをまとめて".
  Should NOT trigger for improving one document's writing (use
  document-toolkit-review), for verifying claims (use
  document-toolkit-fact-check), for stripping still-correct but no-longer-needed
  content out of documents that all stay (use document-toolkit-trim), or for
  producing a new short summary of a document while leaving the original in
  place — that is writing, not distilling.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
user-invocable: true
---

# Document Distill

Distill **reworks documents that already exist**. The deliverable is the changed
set — fewer, better documents — not a report about it and not a new summary
placed next to the originals. What keeps a set high-signal is this rework, run
whenever it is judged useful; there is no schedule and no maturity ladder.

This skill assumes nothing about the set's format: no index, no frontmatter
contract, no link convention. Everything it needs, it reads from the documents.

**The unit is the document.** Distill changes which documents exist and brings
their content back in line with what is true now. Content that is still true but
no longer needed — the route to a settled decision, a migration that completed,
background the reader has since learned — is not distill's to remove: that is
`document-toolkit-trim`, and whether it goes is the set owner's policy rather
than a judgment made here.

## What you are given, what you decide

The caller — another skill or the user — supplies:

| Input | Required | Notes |
|---|---|---|
| **Target set** | yes | A directory, a glob, or an explicit list of files |
| **Purpose and reader** | yes, as information | What the set is for and who reads it |
| **Retire destination** | no | Where retired documents go, if anywhere |

**You decide which documents to touch and which primitive to apply.** Do not
hand that judgment back by asking the caller to pick an operation — selecting
*what needs what* is the whole job.

If the purpose was not stated, infer it by reading the set, state it in one
sentence, and confirm it before the first destructive step. Without a purpose
there is no basis for deciding which of two overlapping documents is the keeper,
and the merge becomes arbitrary.

## Select what to rework — a judgment, not a flow

Read the set, then match signals to primitives. Selection strategies are inputs
to the same primitives, chosen from what the set actually shows:

| Signal | Primitive |
|---|---|
| Two or more documents cover the same thing | `consolidate` |
| One document carries several unrelated ideas, or is too long to hold | `split` |
| A document has gone stale, or contradicts what is known now | `refresh` |
| A document is inaccurate, superseded, or no longer worth reaching | retire |

**Passing over a document is a valid outcome.** A set where most documents are
fine is the normal case; touching everything is how a distill run destroys value.

Staleness — prefer git when the set is versioned, fall back to filesystem time:

```sh
git log -1 --format=%cs -- <path>          # last content change; survives copies and checkouts
find <set> -name '*.md' -mtime +180        # fallback bucket (POSIX find; avoids BSD/GNU stat differences)
```

Both are weak signals: a bulk reformat or a fresh clone resets mtime, and an old
date can simply mean the document is still correct. Treat a stale date as a
reason to **read** the document, never as a verdict.

Size and overlap come from the documents themselves:

```sh
wc -l <set>/*.md | sort -n                 # oversize candidates
rg -l '<recurring term>' <set>             # documents circling the same topic
```

## The primitives

### consolidate — merge what covers the same thing

1. Pick (or write) the keeper: the one that best serves the set's reader. Make
   it self-contained — one topic, or one decision plus the *why* behind it.
2. Fold the other documents' content in. Keep source citations where content
   came from research; drop restatements the keeper already makes better.
3. Repoint references to the folded documents (see Links), then delete them.

### refresh — bring a document back up to date

1. Reread it against what is known now — the code, the decisions, the rest of
   the set — and correct it, or confirm it unchanged.
2. Correcting includes deleting: a passage that is now plainly wrong and has
   nothing to be corrected *to* goes. What is still true stays, however dated it
   reads — dropping that is a policy call, not a correction (see the unit note
   above).
3. Confirming it unchanged is a real result. Say so; do not edit for the sake of
   showing work.
4. A document found inaccurate or superseded is not refreshed — retire it.

### split — break up a document carrying several ideas

1. Cut it into self-contained pieces, one topic each, in the same location.
2. Repoint references to the original at the right piece (see Links).
3. Delete the original.

## Links — not assumed, but never left broken

The set may use `[[wikilinks]]`, relative markdown links, or no links at all.
**Do not add links to satisfy a convention** — a document that links nowhere is
not a defect here.

But when consolidate or split removes or replaces a file, every reference to it
must land somewhere real. Detect the notation in use, and look outside the set
too — README files, code comments, and CI config link to documents:

```sh
rg -n '\[\[[^]]+\]\]|\]\([^)]*\.md[^)]*\)' <set>   # notation used inside the set
rg -n '<filename>' <repo-root>                     # inbound references from outside
```

## Deleting and retiring

Consolidate and split **delete their sources**. A source left beside its keeper
resurfaces as an overlap candidate on the next run, so the set never converges.

Before the first delete or move, establish whether the change is recoverable:

```sh
git -C <dir> rev-parse --is-inside-work-tree   # versioned?
git -C <dir> status --porcelain -- <paths>     # already committed?
```

- **Versioned and committed** → delete without asking; git holds the history.
- **Otherwise** (not a repository, or uncommitted edits would be lost) → list
  exactly which files will be deleted or moved, and get the user's confirmation
  before touching them.

**Retire** is for a document that no longer earns reach but is worth keeping on
request: move it to the destination the caller named. If no destination was
named, **propose the retirement and stop** — do not invent an archive directory
and do not silently delete instead.

## Report what changed

Close by reporting, so a calling skill can act on the outcome without re-reading
the set:

- Each document touched, the primitive applied, and one line of why.
- Files deleted, and files created or renamed.
- Anything proposed but not done: retirements with no destination, deletions the
  user declined, documents deliberately passed over.

A caller delegating here passes the target set, the purpose, and optionally a
retire destination, then consumes that report. It should not restate the
primitives in its own instructions.

## Success Criteria

- [ ] The purpose the judgments rest on was stated (given or inferred and
      confirmed), not left implicit.
- [ ] Every document in the set got a decision — reworked or deliberately
      passed over — and the untouched ones were left untouched.
- [ ] Consolidate/split sources were deleted, or explicitly kept by the user's
      decision; no source survives beside its keeper by default.
- [ ] References to removed or replaced files were repointed, inside the set and
      from the surrounding repository; no link was added merely to have one.
- [ ] Nothing irrecoverable was deleted or moved without confirmation.
- [ ] Retire moved a document only to a caller-named destination; otherwise it
      was proposed, not performed.
- [ ] The report lists what changed and what was proposed but not done.
