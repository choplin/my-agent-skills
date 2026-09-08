# octa

Skills for running repository work through the local octa CLI.

| Skill | Description |
|---|---|
| `octa-base` | Operating model, setup, authoring standard, lifecycle, review, and completion policy |
| `octa-overview` | Read-only snapshot of active Projects and Project-unassigned work |
| `octa-capture-feedback` | Capture one reported concern or improvement idea as a Backlog Issue |
| `octa-start` | Pick up or resume one Issue, claim its lease, recover its workspace, and carry it into execution |
| `octa-groom` | Turn one Project's Backlog into self-complete Todo work |
| `octa-handoff` | Record resumable context on unfinished In Progress work |

Install the whole group because the workflow skills depend on `octa-base`.
Also install the `octa` product skill shipped by Octa; it owns CLI commands,
JSON, GraphQL, state, lease, scope, and storage behavior. The `octa` executable
is a separate runtime dependency. This group owns only the workflow policy and
the concrete queries used by its workflows.
