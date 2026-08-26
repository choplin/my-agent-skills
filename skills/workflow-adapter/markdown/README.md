# Markdown workflow adapter contracts

Provider-neutral contracts for durable Markdown operations. Invoke the matching
operation skill directly:

- `workflow-adapter-markdown-resolve`
- `workflow-adapter-markdown-find`
- `workflow-adapter-markdown-read`
- `workflow-adapter-markdown-create`
- `workflow-adapter-markdown-update`

Each skill owns its request, result, failure reasons, and invariants. It
delegates only to an installed operation implementation whose skill description
names that exact contract and whose provider trigger matches the request or
repository context. There is no family router skill.
