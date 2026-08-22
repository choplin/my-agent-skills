---
name: octa-capture-feedback
description: >-
  Captures one user-reported concern, friction point, bug observation, or
  improvement idea as one repository-scoped octa Backlog Issue, asking only
  for information that is necessary to preserve the report faithfully. Use
  when a user notices something while using a product or tool and wants it
  recorded in octa for later investigation or grooming.
---

# Capture one feedback Issue

Apply `octa-base` for repository scope, record structure, lifecycle states, and
CLI behavior. Handle exactly one concern per invocation. Treat several details
about one underlying concern as context for one Issue; if the input contains
separate concerns, ask the user to choose one and leave the others for later
invocations.

This is a capture workflow, not diagnosis or grooming. Create the Issue in
Backlog even when the report already contains substantial detail. Do not turn
it into Todo, prescribe a solution, or begin implementation.

## Flow

### 1. Establish the capture target

Confirm that `octa` is available and that the working directory is the target
Git repository. Use the current repository when the user has not named another
one. If the intended repository is genuinely ambiguous, ask before writing;
never place the report in a guessed repository.

Do not require a Project. Leave the Issue Project-unassigned unless the user
explicitly names an active finite Project and the concern clearly belongs to
its outcome. Do not invent a permanent feedback Project or a repository label.

### 2. Build a faithful report

Use the user's account as the primary evidence. Inspect relevant repository
code, documentation, configuration, and existing Issues only when doing so can
clarify terminology, locate the affected surface, or detect an existing report
without changing the meaning of what the user said.

Separate these kinds of information in the draft:

- **Observation** — what the user noticed or wants changed;
- **Context** — where, when, and under what conditions it occurred;
- **Impact** — why it matters to the user or workflow;
- **Evidence** — reproduction details, messages, links, screenshots, or
  repository locations, when available;
- **Unresolved** — relevant facts that remain unknown but do not prevent rough
  capture.

Omit empty sections. Label repository-derived conclusions as inference. Never
invent a root cause, frequency, severity, expected behavior, or desired
solution.

The report has enough information for Backlog capture when all of the following
are true:

- it identifies one coherent concern;
- a later reader can recognize the affected product, feature, command, or
  workflow;
- the title and body can be written without choosing between materially
  different interpretations of the user's meaning.

Do not demand Todo-level acceptance criteria, exact files, a proposed fix, a
root cause, or complete reproduction steps. When the capture bar is not met,
ask the smallest set of concrete questions that closes the material gaps, then
wait. Combine related questions into one turn.

### 3. Check for an existing report

Read existing Issues, including closed ones, with JSON output and compare both
titles and bodies. An exact existing report satisfies the capture request:
report its number and state instead of creating a duplicate. When a candidate
is only plausibly the same concern and choosing incorrectly would merge distinct
work, ask the user whether it is the same report.

Do not add a comment to an existing Issue unless the user's account contributes
new durable information and the user confirms it is the same concern.

### 4. Create one Backlog Issue

Write a concise, outcome-neutral title describing the concern, not a guessed
implementation. Compose a proportional body from the known sections above.
Preserve concrete user language where it prevents loss of meaning, while
removing conversational filler.

Create the Issue with:

```sh
octa issue open --title <title> --body <body> --json
```

The command resolves to Backlog, the configured `open` default. Do not pass
`--as Todo`. Add `--project <project>` only when the placement rule in step 1
is satisfied. Issue creation needs no lease.

Leave the Issue without a Type label by default. `impl`, `design`, and
`research` classify an executable deliverable, and assigning one belongs to
grooming unless the user explicitly supplied a settled deliverable type. Do
not infer a Type merely from words such as “bug,” “idea,” or “feedback.”

### 5. Report the result

Return the new or existing Issue number, title, state, and Project placement.
Briefly state which unknowns were intentionally left for grooming. Point to
`octa-groom` only when the user wants the captured report turned into
self-complete Todo work.
