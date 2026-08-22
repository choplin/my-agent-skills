# Orchestration Toolkit

The Orchestration Toolkit carries one already-groomed tracker Issue through
implementation, verification, review, and integration.

Grooming is the entry condition. Once the Issue holds a settled work unit, the
question is no longer *what to build* but *how to carry it out*. The toolkit
keeps its run record on the Issue, durable design context in llm-wiki, and
implementation evidence in Git.

Work that is not yet groomed belongs in the selected provider's groom skill; an
unformed concept belongs in `inception`; an ad-hoc task with no tracker Issue
belongs in `exec-plan`.

## Skill

`orchestration-toolkit-execute` carries one groomed Issue to Done inline, with
no delegation or dependency-graph control plane. It records reversible
decisions in a Decision Log, parks one-way doors for one review pass, and uses
risk-based adversarial review before applying the selected provider's completion
procedure.

Several dependent Issues remain separate work units. Return to the selected
provider's groom skill or `planning-toolkit-plan` to identify the next
executable Issue; this group does not currently provide Project-wide graph
execution.

Independent review is not performed here. The executor calls
[`artifact-review-toolkit-adversarial`](../artifact-review-toolkit/README.md)
when its risk criteria require a separate pass, then owns the disposition of
the resulting findings.

## Installation

Install this group with its cross-group dependencies listed in the repository
README. The selected provider's start skill is the normal entry point because it
supplies the Issue, coordination handle, workspace, and completion procedure.
