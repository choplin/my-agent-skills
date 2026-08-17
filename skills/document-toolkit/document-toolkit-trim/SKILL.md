---
name: document-toolkit-trim
description: >-
  Strips information a set of documents no longer needs while it is still
  correct, so the set stops carrying its own history. Sorts the content along
  time, topic, granularity, and authority, shows the regions it found, and
  asks the set's owner for a keep-or-drop policy on each axis.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
metadata:
  description-role: documentation
---

# Document Trim

Trim removes information **from inside documents that stay**. A document set
accumulates its own history: the route to a decision that is now just the
decision, the migration that has since completed, the background written for a
reader who has since learned it. None of that is wrong, so nothing flags it — it
only makes the set longer to read every year.

Every document survives a trim. Merging, splitting, and retiring whole documents
belong to `document-toolkit-distill`, and so does anything that has become
**incorrect**.

## Wrong and unneeded are different problems

Two questions decide whether a passage is even yours to touch:

1. **Is it still true?** No → not trim's job. `document-toolkit-distill`'s
   `refresh` corrects it, or deletes it when there is nothing to correct it to.
2. **Still true — is it still needed?** No → trim.

A section describing a feature that no longer exists fails question 1; it is a
distill job, not a trim job. A section describing a migration that completed
successfully passes question 1 and fails question 2 — that is trim.

Keeping these apart matters because they need different evidence. Wrongness is
settled against the world: read the code, the decision, the current behaviour.
Necessity is not settled against anything you can read.

## You do not decide what is needed

Necessity is the owner's policy, not a property of the text. Two teams with
identical documents will disagree about whether the route to a decision is dead
weight or the most valuable thing in the set, and both are right for their own
set. A skill that decides this on its own will delete plausibly — and the loss is
not recoverable from the document.

So the work splits in two, and only the first half is yours:

- **Yours:** sort the content into regions, so that a policy can be stated at all.
- **The owner's:** say which regions go.

This is why trim classifies before it cuts. Judging passage by passage as you
read would drift — the same kind of content gets kept in one document and cut in
the next, because the standard was never written down. One policy, stated once,
applies across the whole set.

## What you are given

| Input | Required | Notes |
|---|---|---|
| **Target set** | yes | A directory, a glob, or an explicit list of files |
| **Purpose and reader** | yes, as information | What the set is for and who reads it |
| **Policy** | no | If the caller states one, skip the asking step and apply it |

Nothing about where the documents came from is an input. A set that a distill run
just consolidated and a set nobody has touched in a year are trimmed the same
way — if provenance seemed to matter, the thing that actually mattered belongs in
the policy.

If the purpose was not stated, infer it by reading the set and state it in one
sentence. Region boundaries depend on it: "central topic" and "supporting detail"
mean nothing without knowing what the set is for.

## The four axes

Read the set, then sort what you find. Each axis exists because owners
genuinely split on it — that is the test for carrying an axis at all.

| Axis | Poles | The policy question |
|---|---|---|
| **Time** | the current state / the route to it | Keep how the set arrived here — superseded steps, completed migrations, the history of a decision — or keep only where it arrived? |
| **Topic** | central / adjacent | Keep subjects that drifted in alongside the set's own, or cut to the set's subject? |
| **Granularity** | the claim / its specifics | Keep procedures, parameters, sample output and worked examples, or keep the claim and let the reader go to the source? |
| **Authority** | original here / restated from elsewhere | Keep content whose real home is another document, the code, or general knowledge — or cut it to a pointer? |

The axes are close enough to be confused, so test each passage against the axis
you are placing it on:

- Still-true history is **Time**, even when it is detailed. Detail that describes
  the current state is **Granularity**.
- A passage is **Authority**-restated only if some other place is the source of
  truth for it. Being long is not restating.
- General background — how a well-known tool works, what a standard term means —
  is **Authority**, not Topic: it is on-topic, it is just not this set's to own.
  This is the region that grows fastest in machine-written documents.

Present only regions that actually have content in this set. An empty region
gives the owner nothing to decide and makes the real ones harder to see.

Four axes give sixteen combinations, which is already more than anyone can hold.
Do not multiply them further for symmetry: add a fifth axis only if this set
shows a dimension the four cannot express *and* a policy would plausibly split on
it. If every owner would answer the same way, it is not an axis — it is a
default.

**One default needs no asking:** text carrying no information at all — filler
transitions, preambles announcing what the section will say, closing paragraphs
restating it. There is no policy split to find, so drop it. Rewriting text that
*does* carry information into fewer words is a different job and belongs to
`document-writing-review`.

## Ask for the policy

Show what you found and ask per axis — one question each, with the region's real
content behind it, so the answer is about this set and not about documentation in
the abstract. Name what would go: how much, from which documents, and one
example passage. An owner cannot price "drop the route to decisions" without
seeing that it means the whole rationale section of three files.

Some regions are load-bearing in ways the axis alone does not show — rejected
alternatives look like pure history until someone reopens the decision. When you
see one, say so alongside the question rather than resolving it yourself.

The answers **are** the retention contract: record them, because that is what
makes this run's cuts reviewable and the next run's consistent.

## Cut

Establish first that the change is recoverable:

```sh
git -C <dir> rev-parse --is-inside-work-tree   # versioned?
git -C <dir> status --porcelain -- <paths>     # already committed?
```

- **Versioned and committed** → cut without further confirmation; git holds it.
- **Otherwise** → say which files you are about to edit and get confirmation
  first. Trimmed text is gone from the document; if it is also gone from history,
  the owner's policy answer was a guess they cannot revisit.

Then apply the policy across the whole set, not document by document — the same
region gets the same treatment everywhere, which is the point of having a policy.

What is left has to still read as a document. Cutting the route to a decision
leaves a heading with one line under it; cutting a restated explanation leaves a
dangling "as described above". Repair the seams, and repoint references that
aimed into a removed section:

```sh
rg -n '#[a-z0-9-]+\)' <set>          # links into section anchors, inside the set
rg -n '<filename>#' <repo-root>      # inbound anchor links from outside
```

Repairing a seam is not a licence to rewrite. If a section needs real rewriting
to survive its cut, that is `document-writing-review`'s work — say so in the
report.

## Report

- The policy, axis by axis, as the owner set it.
- What was dropped: which regions, from which documents, roughly how much.
- What was kept against expectation, and why — a region the policy would have
  dropped but you left, because it turned out to be load-bearing.
- Anything sent elsewhere: passages that were wrong rather than unneeded
  (distill), sections whose seams need real rewriting (review).

## Success Criteria

- [ ] Nothing was cut for being wrong; those passages were reported for distill
      instead.
- [ ] The policy came from the owner (or the caller), not from your own judgment
      of what mattered.
- [ ] The owner saw what each answer would cost — content, not axis names —
      before answering.
- [ ] Only regions with real content in this set were presented.
- [ ] The policy was applied uniformly across the set; no document was trimmed to
      a different standard.
- [ ] Every document in the set still exists; none was merged, split, or retired.
- [ ] Nothing irrecoverable was cut without confirmation.
- [ ] Seams left by cuts were repaired, and references into removed sections
      repointed.
- [ ] The report states the policy, so the next run can start from it.
