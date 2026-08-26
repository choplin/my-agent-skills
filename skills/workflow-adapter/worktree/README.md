# Worktree workflow adapter contracts

Provider-neutral contracts for repository-worktree operations. Invoke the
matching operation skill directly:

- `workflow-adapter-worktree-resolve`
- `workflow-adapter-worktree-list`
- `workflow-adapter-worktree-read`
- `workflow-adapter-worktree-create`
- `workflow-adapter-worktree-remove`

Each skill owns its request, result, failure reasons, and invariants. It
delegates only to an installed operation implementation whose skill description
names that exact contract and whose provider trigger matches the request or
repository context. There is no family router skill.
