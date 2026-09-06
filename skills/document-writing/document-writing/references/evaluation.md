# Workflow evaluation

Use these cases when changing the workflow or the role of a lens. They test
editorial behavior, not exact wording. Do not load this file during ordinary
writing or reveal its expectations to a forward-test agent.

## Method

Give a fresh agent only the task, source material, audience/use information that
a real request would contain, and the installed skill. Inspect the intermediate
reasoning artifacts and final document. A polished final paragraph is not enough
evidence if the workflow cannot show how it chose the governing axis.

The run passes only when it:

- identifies audience knowledge and intended use;
- recovers or chooses a specific governing focus before line editing;
- distinguishes a content or plot problem from a local prose defect;
- explains concepts in proportion to novelty and argumentative centrality;
- treats lens heuristics as inputs to judgment rather than independent commands;
- records any added substantive premise with its source or editorial status;
- produces a coherent whole whose emphasis follows the plot;
- preserves enough artifacts to resume the work in a fresh context.

Fail the run when it begins with a list of located lens findings and merely
applies them, requires the smallest local remediation for a developmental
problem, defines every technical term without regard to audience, or withholds
the plot and audience from editorial reviewers in the name of blindness.

## Regression case: centralized data management

Use the original passage that contrasts centralized data warehousing with
department-led data management for an audience of data-platform practitioners.

Expected editorial behavior:

- Treat data warehousing as familiar domain knowledge; do not spend the passage
  on a generic definition.
- Inspect the implicit equation of centralized storage or processing with
  centralized knowledge, authority, and responsibility.
- Make the document's comparison axis explicit before revising individual
  sentences.
- Decide whether product names contribute evidence or distract from the axis.
- Resolve or deliberately preserve the final forward reference according to
  whether the following comparison is in scope.
- Surface new premises such as shared governance mechanisms instead of smuggling
  them into fluent prose.

No exact revised wording is required. A revision may preserve the original
two-way contrast or show that infrastructure and governance can vary
independently, provided the choice is explicit and consistent with the author's
scope.

## Coverage cases

Maintain at least one forward test for each plot family:

- **Book or chapter:** the run identifies both the work-level promise and the
  chapter's contribution rather than treating chapter headings as the plot.
- **Technical document:** the run chooses tutorial, how-to, reference,
  explanation, or another justified kind from reader use, without creating
  empty taxonomy sections.
- **Academic document:** the run selects a structure from research question,
  contribution, study/article type, venue, and reporting constraints rather
  than imposing IMRAD universally.
- **Existing draft:** the run records the actual reverse outline before proposing
  a revised plot.

## Lineage case

Create two revisions of an upstream focus or content-model artifact. A
downstream plot based on the first revision must be recognized as needing review
because a newer revision exists or its recorded digest differs. The workflow
must create a new downstream revision even when the review concludes that its
body can remain unchanged. No mutable state file or event log may be required.
