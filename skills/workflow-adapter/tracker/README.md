# Tracker workflow adapter contracts

Provider-neutral contracts for tracker work-record operations. Invoke the
matching operation skill directly:

- `workflow-adapter-tracker-resolve`
- `workflow-adapter-tracker-list`
- `workflow-adapter-tracker-read`
- `workflow-adapter-tracker-create`
- `workflow-adapter-tracker-update`
- `workflow-adapter-tracker-comment`
- `workflow-adapter-tracker-relate`
- `workflow-adapter-tracker-transition`

Each skill owns its request, result, failure reasons, and invariants. It
delegates only to an installed operation implementation whose skill description
names that exact contract and whose provider trigger matches the request or
repository context. There is no family router skill.
