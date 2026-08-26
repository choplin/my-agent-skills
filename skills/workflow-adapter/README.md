# Workflow adapter contracts

Provider-neutral operation contracts, organized by record family:

- `markdown/`: durable Markdown resolve, find, read, create, and update
- `tracker/`: tracker resolve, list, read, create, update, comment, relate, and transition
- `worktree/`: repository-worktree resolve, list, read, create, and remove

Install this directory as one group. Each operation delegates directly to one
matching implementation skill; there is no family router skill.
