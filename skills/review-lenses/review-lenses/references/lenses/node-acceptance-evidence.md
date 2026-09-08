# `node.acceptance-evidence`

## Objective

Falsify the claim that an issue's stated acceptance is satisfied by the supplied
artifact and evidence.

## Required inputs

- stated acceptance criteria
- the artifact and producer-supplied evidence
- reproduction instructions or checks relevant to those criteria

## Checks

- Map each criterion to artifact evidence or a reproducible check.
- Exercise relevant failure behavior and boundary inputs.
- Separate checked facts from producer assertions.
- Identify criteria that are subjective, indirect, or not observable from the
  supplied evidence.

## Non-goals

- Do not broaden the issue's acceptance.
- Do not invent criteria when none were defined.

## Severity guidance

A demonstrably unmet binding criterion is blocker. Missing or inadequate evidence
for a material criterion is major unless another reproducible check resolves it.
