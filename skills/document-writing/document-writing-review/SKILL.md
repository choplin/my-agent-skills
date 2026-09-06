---
name: document-writing-review
description: >-
  Performs a holistic editorial review and revision of an existing document.
  Applies when the draft may have the wrong focus, conceptual emphasis,
  explanation depth, order, or reader progression—not merely awkward sentences.
  Builds an editorial assignment, reverse outline, diagnosis, and revised plot
  before substantive, line, and copy edits.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
metadata:
  description-role: trigger
---

# Document Review

Review from the whole document inward. Read
`../document-writing/references/workflow.md` and follow its existing-document
branch. If work will span sessions or files, also follow
`../document-writing/references/artifacts.md`.

## Workflow

1. Establish the editorial assignment: audience and prior knowledge, use,
   intended outcome, document kind, constraints, degree of intervention, and
   protected content.
2. Read diagnostically and make a reverse outline of what the draft actually
   does.
3. State the governing focus you can recover, conflicts within it, and any
   plausible alternatives. Distinguish unclear expression from an unsettled
   idea.
4. Build an editorial diagnosis covering substance, support, conceptual
   emphasis, order, proportion, representation, and reader movement.
5. Propose a free-form revised plot. Do not revise prose until the proposed
   progression is coherent. Ask only when competing plots would materially
   change the author's position or scope.
6. Revise substantively against the plot.
7. Apply a connected line edit and then local copyedit through
   `document-writing-base`.
8. Verify the result against the assignment, focus, plot, and protected content.

Use planning principles and editorial heuristics from
`document-writing-standards` in stages 2–6. They are aids to diagnosis and
judgment, not independent mandates. Use conformance checks only after the
document's substance and structure are stable.

## Review context

Any reviewer receives the relevant audience, focus, reverse outline, current
plot, sources, and intervention boundary. Reviewers may be blind to one
another's conclusions, but never blind to the context needed to judge why the
document exists.

## Routing findings

Name the earliest artifact that owns each issue. A missing premise, misplaced
definition, or inverted conceptual emphasis is a developmental issue even when
it appears in one sentence. Do not repair it through the smallest possible
local edit merely because the anchor is easy to locate.

If the user permits only content-preserving changes, return upstream issues as
observations and confine the revision to that boundary. If the task is truly
wording-only, use `document-writing-prose` instead.

## Deliverable

Lead with the revised document or link. Then give a concise account of the
recovered focus, principal plot changes, important content decisions, passes
completed, context limitations, and unresolved questions. Preserve intermediate
artifacts according to the artifact reference so the work can resume without
conversation history.
