# octa

Skills for running repository work through the local octa CLI.

| Skill | Description |
|---|---|
| `octa-base` | Operating model, setup, authoring standard, lifecycle, review, completion, and CLI contract |
| `octa-overview` | Read-only snapshot of active Projects and Project-unassigned work |
| `octa-capture-feedback` | Capture one reported concern or improvement idea as a Backlog Issue |
| `octa-start` | Pick up or resume one Issue, claim its lease, recover its workspace, and carry it into execution |
| `octa-groom` | Turn one Project's Backlog into self-complete Todo work |
| `octa-handoff` | Record resumable context on unfinished In Progress work |

Install the whole group because the workflow skills depend on
`octa-base`. The `octa` CLI must be installed separately. These skills keep
workflow policy here while treating the CLI's lease, query, and filter behavior
as a product contract.
