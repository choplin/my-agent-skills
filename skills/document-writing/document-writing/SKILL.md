---
name: document-writing
description: >-
  Plans, drafts, and revises substantial documents through a durable editorial
  workflow. Applies to books and chapters, technical documentation, academic
  writing, and general explanatory or argumentative documents when the work
  must establish the audience, governing idea, content model, and reader
  progression before polishing prose. Also applies when an existing draft
  needs developmental editing rather than sentence cleanup alone.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: trigger
---

# Document Writing

Treat writing as a sequence of editorial decisions, not as prose followed by a
large lens sweep. Establish what the document is trying to do and how the reader
will get there; only then draft and edit at progressively smaller scales.

Read [workflow.md](references/workflow.md) before starting. Read
[artifacts.md](references/artifacts.md) whenever the work will span files,
sessions, or agents. Select exactly one relevant plot template from `assets/`
after the earlier planning artifacts exist; a template is a prompt for thought,
not a form that must be filled completely.

When maintaining or evaluating this skill rather than using it for a document,
read [evaluation.md](references/evaluation.md). Do not load evaluation
expectations into the agent being forward-tested.

Use `document-writing-standards` according to the roles in its lens index.
Planning principles inform the brief, focus, content model, and plot. Editorial
heuristics support judgment during developmental and line editing. Local checks
belong near copyediting. A heuristic observation is not automatically a defect,
and a local finding does not authorize changing the document's argument.

## Choose the route

- **New document:** assignment → discovery → focus → content model → plot →
  draft → developmental edit → line edit → copyedit → proof and acceptance.
- **Existing document:** editorial assignment → diagnostic reading → reverse
  outline → editorial diagnosis → revised plot → substantive revision → line
  edit → copyedit → proof and acceptance.
- **Settled content and structure:** route wording-only work to
  `document-writing-prose`, detection-only work to `document-writing-audit`, or
  selected findings to `document-writing-apply`.

Combine adjacent planning stages for a short, low-risk document, but do not skip
their decisions. If the document's governing idea or reader progression is not
yet stable, prose editing is premature.

## 1. Establish the assignment

Record the audience, their relevant prior knowledge, use situation, intended
reader outcome, document kind, scope, constraints, sources, and unresolved
questions. For revision, also record the permitted degree of intervention and
what must be preserved.

Infer ordinary details where one interpretation is strongly supported. Ask only
when alternatives would materially change the document. Mark assumptions as
assumptions; do not silently promote them to facts.

The assignment is usable when a new editor can tell what success means without
recovering intent from conversation history.

## 2. Discover the material

Read the sources and existing draft before imposing an outline. Capture useful
facts, claims, examples, constraints, disagreements, gaps, and provenance.
Separate what the material establishes from what the author wants to argue.

For an existing draft, create a reverse outline: state the job of each section
or paragraph, its main claim, its support, and its relation to the whole. Record
the structure that actually exists, including repetition and missing bridges;
do not rewrite it into the structure you wish existed.

Stop for a source or scope decision only when the central argument cannot be
supported from the available material. Local uncertainty may remain visible.

## 3. Find the focus

Write a compact statement of:

- the governing question, problem, or reader task;
- the central answer, controlling idea, or intended change in the reader;
- why it matters to this audience;
- the tension, gap, or obstacle that makes the document necessary;
- the boundaries that keep the document from becoming a survey of everything.

This is not final prose. Revise it freely until it distinguishes the document
from a generic treatment of the topic. In the data-warehousing example, merely
defining a data warehouse would miss the focus; the load-bearing issue is the
centralized ownership or governance assumption and what follows from it.

## 4. Build the content model

Inventory the concepts, claims, evidence, examples, procedures, decisions, and
relationships the document needs. Rank concepts by argumentative centrality and
reader novelty:

- Assume established domain knowledge when the named audience can reasonably
  supply it.
- Develop a central unfamiliar concept from motivating context toward a usable
  definition.
- Introduce a secondary unfamiliar concept briefly at the point of need.
- Avoid naming a minor abstraction when ordinary prose is clearer.
- Explain the particular property the argument depends on, even when the term
  itself is familiar.

Choose representations from the relationships in the material: prose for a
line of reasoning, steps for action, a table for repeated fields or comparison,
a diagram for topology or flow, and code for executable detail. These are
judgments, not mandatory transformations.

## 5. Make the plot

Choose the template that matches the document:

- [general plot](assets/plot-general.md)
- [book or chapter plot](assets/plot-book.md)
- [technical-document plot](assets/plot-technical.md)
- [academic plot](assets/plot-academic.md)

The plot is a free-form account of the reader's progression. It may contain
headings, scene or section cards, questions, diagrams, fragments, alternatives,
or notes to the writer. Preserve its axis: what each movement does, what it may
rely on, what changes for the reader, and how it advances the governing idea.
Do not turn the template into a required YAML schema or equate the plot with a
table of contents.

Test the plot as a whole:

- Does its sequence answer the governing question or enable the reader task?
- Does each movement earn its place and prepare what follows?
- Are central claims supported and limitations visible?
- Does conceptual emphasis match argumentative importance rather than ease of
  definition?
- Does the chosen document kind match the reader's use?

Resolve plot-level failures upstream. Do not ask a sentence lens to repair them.

## 6. Draft and edit from large scale to small scale

Draft against the accepted plot while preserving claim status and source
boundaries. A draft may discover a better focus or structure; when it does,
revise the upstream artifact first or alongside the draft so the durable intent
does not become false.

Run these passes in order:

1. **Developmental edit:** argument, coverage, order, section purpose,
   proportion, conceptual emphasis, and representation.
2. **Line or stylistic edit:** paragraph movement, continuity, emphasis,
   transitions, sentence shape, voice, and cadence in the target language.
3. **Copyedit:** terminology consistency, references, grammar, syntax, notation,
   and house style.
4. **Proof and acceptance:** final completeness, formatting, cross-references,
   rendering, and success against the assignment and plot.

Give reviewers the audience, focus, plot, and relevant sources. Independence
means they do not see one another's findings; it does not mean withholding the
context required to judge the document. Classify every issue by the earliest
artifact that can resolve it, then return it there:

- wrong promise or scope → assignment or focus;
- missing or misconceived substance → discovery or content model;
- wrong progression or emphasis → plot;
- paragraph or sentence realization → line edit;
- local correctness or consistency → copyedit.

After an upstream revision, inspect its downstream dependents before continuing.
Do not mechanically preserve text whose premise changed.

## 7. Accept the document

Acceptance asks whether the document works, not whether every heuristic fired:

- The intended reader can reach the promised understanding, decision, or task.
- Required scope is covered and excluded scope has not leaked in.
- Important claims retain support, qualification, and provenance.
- The reader progression realizes the plot's governing axis.
- Conceptual explanation is proportional to novelty and importance.
- Representations serve the relationships they were chosen for.
- Line and copyediting introduced no loss or contradiction.
- The delivered format is complete and usable.

Revise failures at their owning stage. If resolution requires new authority,
evidence, or a material scope choice, report it instead of hiding it with fluent
prose.

## Delivering the work

Lead with the finished document or its link. Then identify the latest durable
planning artifacts, the editorial passes completed, material deviations from
the plot, and unresolved decisions. Do not claim an independent review unless a
separate context actually performed it.

## Success criteria

- [ ] Audience knowledge and intended use shaped content and terminology.
- [ ] Discovery preceded commitment to a structure.
- [ ] A governing focus and content model existed before the plot.
- [ ] The plot preserved a discernible reader progression without becoming a
      rigid form.
- [ ] Developmental decisions preceded line and copy edits.
- [ ] Lens observations were interpreted in document context and routed to the
      stage that owned the problem.
- [ ] Durable artifacts make the work resumable without chat history.
- [ ] Acceptance was checked against the assignment and plot.
