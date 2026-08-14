# octa

Skills for running repository work through the local octa CLI with the same
solo lifecycle used by the Linear skill group.

| Skill | Description |
|---|---|
| `octa-base` | Operating model, setup, authoring standard, lifecycle, review, completion, and CLI contract |
| `octa-overview` | Read-only snapshot of active Projects and Project-unassigned work |
| `octa-start` | Pick up or resume one Issue, claim its lease, recover its workspace, and carry it into execution |
| `octa-groom` | Turn one Project's Backlog into self-complete Todo work |
| `octa-handoff` | Record resumable context on unfinished In Progress work |

Install the whole group because the four workflow skills depend on
`octa-base`. The `octa` CLI must be installed separately. These skills keep
workflow policy here while treating the CLI's lease, query, and filter behavior
as a product contract.
