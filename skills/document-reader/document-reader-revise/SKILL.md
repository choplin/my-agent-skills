---
name: document-reader-revise
description: >-
  Works a reader review's findings into the document, deciding with the author
  what each stumble, objection, and takeaway divergence should change. Handles
  findings that cannot be applied mechanically because closing them adds content
  the document does not yet contain — a missing premise, an unanswered
  objection, an undisclosed cost. Applies after document-reader-review, or
  whenever reader feedback names a gap in what a document says rather than in
  how it says it.
allowed-tools: Read, Write, Edit, Grep, Glob, AskUserQuestion
metadata:
  description-role: trigger
---

# Reader Revise

Turn reader findings into a revised document.

The findings from `document-reader-review` cannot be applied the way writing
findings are. A stumble is closed by supplying knowledge the document does not
hold, and an objection is closed by conceding, answering, or narrowing a claim.
**Every one of those is a decision about what the document asserts, and that
decision belongs to the author.** This skill's work is to put each decision
cleanly, not to guess it.

## Responsibility boundary

Own:

- classifying each finding by what closing it requires;
- resolving the ones that need nothing from the author;
- putting the rest to the author as one decision each, with the reader's reaction
  as the evidence;
- applying the resolutions and reporting what changed and what was declined.

Do not:

- invent a fact, a rationale, a measurement, or a trade-off to close a gap;
- close an objection by softening the claim without the author choosing that;
- re-review the document, or generate findings of your own;
- polish the writing — that is `document-writing-review` on the revised draft.

## 1. Take the findings

Take a `document-reader-review` report, or reader feedback the caller supplies
directly. Reader feedback given in conversation is a finding like any other; it
needs an anchor before it can be worked.

Re-anchor every finding in the current document before doing anything. A finding
whose anchor no longer matches is stale — report it, do not guess where it moved.

## 2. Classify by what closing it requires

| Class | Closing it requires | Route |
|-------|--------------------|-------|
| `author-knowledge` | A fact, a reason, a number, or a history only the author holds | Ask |
| `assertion-change` | Conceding, narrowing, or dropping a claim | Ask |
| `scope-call` | Deciding this reader is out of audience, so the gap is correct | Ask |
| `arrangement` | Moving existing content earlier, or surfacing what is already written | Apply |
| `writing` | The document already says it; the reader missed it through phrasing | Route to `document-writing-review` |

Order matters: work `takeaway_divergence` first. A divergence usually has one
cause upstream of many individual stumbles, and fixing it can close them.

## 3. Put the decisions

Batch the `author-knowledge`, `assertion-change`, and `scope-call` findings and
put them to the author in one pass, ordered by weight. For each, give:

- the reader's reaction verbatim, and which persona had it;
- the anchor;
- what the document would have to gain or give up to close it;
- the option of declining, with what stays open if it is declined.

**Do not offer drafted content as one of the options.** Supplying a plausible
sentence for the author to approve is how an invented rationale reaches a
document: approval is cheaper than authorship, and the author will take it. Ask
what is true, then write it.

A finding the author declines is closed as declined, not silently dropped.

## 4. Apply

Apply `arrangement` findings and the author's resolutions together, in one pass
over the document.

Constraints:

- Add only what the author supplied. Where a resolution leaves a hole, leave the
  hole and report it rather than filling it.
- Keep the document's existing shape unless a resolution requires otherwise. This
  skill changes what the document says, not how it is organized.
- Do not restate the reader's objection in the document. The reader is evidence,
  not an audience the text addresses.

## 5. Report

```yaml
document:
findings_in: <count>

resolved:
  - finding: <id and observation>
    class:
    resolution: <what the author decided>
    change: <what the document now says>

declined:
  - finding:
    why:
    still_open: <what the reader will still hit>

routed_out:
  - finding:
    to: document-writing-review | document-toolkit-fact-check

stale:
  - finding:
    anchor_not_found: <the anchor as given>

unfilled:
  - finding:
    what_is_missing: <what the author would still need to supply>
```

## Success criteria

- [ ] No fact, rationale, or figure in the revised document originated here.
- [ ] Every `assertion-change` was decided by the author, not by the revision.
- [ ] Declined findings are reported with what stays open.
- [ ] Stale anchors are reported, not relocated by guess.
- [ ] Writing-level findings were routed out rather than applied here.
