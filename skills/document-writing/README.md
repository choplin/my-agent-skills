# document-writing

This family treats document writing and revision as an editorial workflow. It
establishes the assignment, learns the material, finds the governing focus,
models the content, and creates a flexible genre-specific plot before drafting
or substantive revision. Developmental editing comes before line editing,
copyediting, and proof.

Intermediate artifacts can be stored as immutable Markdown revisions with
explicit lineage. There is no mutable state file or separate event log; current
heads and upstream changes are derived from revision files and their digests.

## Choose by task

| Task | Skill | Result |
|---|---|---|
| Create or substantially rebuild a document | `document-writing` | Durable planning artifacts, a drafted and edited document, and acceptance against audience and plot |
| Holistically revise an existing draft | `review` | Reverse outline, editorial diagnosis, revised plot, and revised document |
| Write inside an already settled plan | `standards` | Relevant planning, editorial, and language guidance used during composition |
| Improve prose without changing content or structure | `prose` | A connected line edit |
| Inspect stable prose without changing it | `audit` | Local conformance findings only |
| Apply approved local findings | `apply` | Content-preserving edits with stale-anchor and preservation checks |

`base` is internal machinery for the line, copyedit, audit, and apply lanes.

## Workflow

For a new document:

```text
assignment → discovery → focus → content model → plot → draft
           → developmental edit → line edit → copyedit → proof/acceptance
```

For an existing document:

```text
editorial assignment → diagnostic reading → reverse outline
                     → editorial diagnosis → revised plot
                     → substantive revision → line/copy/proof
```

Adjacent planning artifacts may be combined for small documents, but their
decisions are not skipped. A plot is a free-form account of reader progression,
not a mandatory data schema. Templates are supplied for general documents,
books or chapters, technical documents, and academic work.

## Lens placement

`document-writing-standards` classifies guidance by use:

- planning principles inform focus, concept treatment, document kind,
  representation, argument, and plot;
- editorial heuristics support contextual judgment during developmental and
  line editing;
- conformance checks detect local correctness and consistency defects after the
  larger decisions are stable.

Only the third category flows directly through `audit` and `apply`. Reviewers
receive the relevant audience and plot context; “blind” means independent of
other reviewers' conclusions, not deprived of document intent.

## Durable artifacts

For multi-session work, store artifacts beside the target in a
`<document>.writing/` directory unless the project defines another location.
Each artifact revision records its kind, revision number, predecessor, and the
paths and SHA-256 digests of upstream artifacts. Revisions are immutable. A
changed upstream digest triggers downstream review and a new revision, not a
central status mutation.

## References

### Editorial workflow

- [Editors Canada: Professional Editorial Standards](https://editors.ca/publications/professional-editorial-standards/) and [The Fundamentals of Editing](https://editors.ca/publications/professional-editorial-standards/fundamentals-editing/)
- [CIEP: About proofreading and editing](https://www.ciep.uk/resource/about-proofreading-and-editing.html), [Editorial glossary](https://www.ciep.uk/resource/editorial-glossary.html), [The publishing workflow](https://www.ciep.uk/learn-and-develop/the-ciep-competency-framework/the-publishing-workflow.html), and [What is an editorial brief?](https://www.ciep.uk/resource/what-is-an-editorial-brief-and-how-does-it-help-both-authors-and-editorial-professionals.html)
- [Purdue OWL: Genre analysis and reverse outlining](https://owl.purdue.edu/owl/graduate_writing/introduction_to_writing/documents/drafting-your-document/handouts/genre-analysis-activity.pdf)

### Technical writing

- Google Technical Writing on [audience](https://developers.google.com/tech-writing/one/audience), [document scope and organization](https://developers.google.com/tech-writing/one/documents), and [large-document outlines](https://developers.google.com/tech-writing/two/large-docs)
- [Diátaxis](https://diataxis.fr/start-here/) and its [workflow guidance](https://www.diataxis.fr/how-to-use-diataxis/)

### Academic writing

- [ICMJE: Preparing a Manuscript for Submission](https://icmje.org/recommendations/browse/manuscript-preparation/preparing-for-submission.html)
- [EQUATOR Network](https://www.equator-network.org/)
- [Taylor & Francis: Writing your paper](https://authorservices.taylorandfrancis.com/wp-content/uploads/2021/03/Writing_your_paper_ebook.pdf)

### Original lens sources

- [`japanese-tech-writing`](https://gist.github.com/k16shikano/fd287c3133457c4fd8f5601d34aa817d): Japanese technical prose, argument, reader load, voice, and notation
- [`cognitive-rhythm-writing`](https://gist.github.com/k16shikano/eb2929f13ed19c97188393d297be8432): cognitive pacing and Japanese cadence
- [`writing-clearly-and-concisely`](https://github.com/obra/the-elements-of-style/tree/05fc4f0d2b97b7c042dd9949ad658568e4a1324e/skills/writing-clearly-and-concisely): English mechanics, composition, and concision

## Skills

| Skill | Responsibility |
|---|---|
| `document-writing` | End-to-end new-document and substantial-rebuild workflow |
| `standards` | Planning principles, editorial heuristics, local checks, and Japanese/English profiles |
| `base` | Shared context-aware line/copy/audit/apply machinery |
| `review` | Existing-document developmental review and revision |
| `prose` | Content-preserving line edit |
| `audit` | Local conformance findings without edits |
| `apply` | Application of selected local findings |
