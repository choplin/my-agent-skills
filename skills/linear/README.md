# linear

Skills for running work through Linear in this workspace: a solo, single-team
setup where the agent owns the whole issue lifecycle.

## Skills

| Skill | Description |
|-------|-------------|
| `linear-base` | The operating conventions — how Project, Milestone, Issue, Label, Status, and Priority are treated, the issue authoring standard, the lifecycle, and how a repository resolves to its active Projects |
| `linear` | Read-only snapshot of what is in flight for the current repository |
| `linear-start` | Pick up a Todo or Backlog issue, or resume one In Progress, and carry it into execution |
| `linear-groom` | Work the Backlog into ready Todo work, issue after issue |
| `linear-handoff` | Pause an unfinished issue so a different session can resume it |

`linear-base` is the foundation the other four build on, and it applies on its
own whenever issues are created, updated, or closed without one of the loops
running. It carries the routing between them.

## Installation

Install these skills through the repository's `skills add` workflow documented
in the root README.

