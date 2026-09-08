# Instruction patterns

Select a structure only after classifying the work it serves. These are options,
not required features of a good skill.

## For interpretive guidance

### Principles with rationale

State a small number of directions and explain why they matter. Let the model
apply them to cases not named in the skill.

```markdown
Prefer changes that preserve the reader's existing mental model, because a
locally elegant rewrite can make the surrounding document harder to navigate.
```

### Representative examples

Use one example to expose a distinction or quality of judgment. Say what the
example demonstrates; do not grow it into a case catalog.

### Gotchas

Keep an environment fact in `SKILL.md` when the model must know it before it
could recognize the condition that would trigger a reference.

```markdown
## Gotchas

- The `users` table uses soft deletes. Include `deleted_at IS NULL` in queries
  whose result should contain active users only.
```

## For coordinated workflows

### Compact procedure

Use a short numbered procedure when order matters. State why a gate or handoff
exists when the dependency is not obvious.

### Stage routing

Keep the shared order and handoff contract in `SKILL.md`. Load a stage's own
procedure reference only when that stage begins.

```markdown
1. Frame the decision and write `brief.md`.
2. Before research, read `references/procedures/research.md`; use `brief.md` as its scope.
3. Synthesize the decision from the research artifact.
```

### Persistent checklist

Use a checklist when work spans contexts or branches and losing progress would
cause a meaningful coordination failure. Do not duplicate an ordinary short
procedure as a checklist.

## For deterministic operations

### Bundled script

Bundle a script when an operation has stable inputs and outputs, deterministic
reliability matters, or the same implementation would otherwise be recreated.
Document the invocation and failure behavior; keep implementation detail out of
`SKILL.md` unless the model must modify the script.

### Schema or structured intermediate

Use a schema when a tool, protocol, or downstream consumer requires exact
structure. Do not use one merely to serialize the model's reasoning.

### Mechanical validation loop

Use do → validate → fix when a trustworthy checker exists for the property being
validated. Name that property and avoid claiming the checker proves qualities it
cannot observe.

```markdown
1. Generate the configuration.
2. Run `scripts/validate-config.sh <path>`; it checks the external schema.
3. Fix reported schema violations and rerun until it exits 0.
```

## For destructive or safety-critical operations

Use plan → verify against a source of truth → execute when a mistaken target or
order would cause material harm. Structure only the fields needed to validate or
execute the operation; the plan need not be machine-readable otherwise.

## For output shape

Provide a template when a real consumer expects a stable shape. For a
human-facing qualitative deliverable, a light outline or representative example
usually preserves more useful judgment than a mandatory field-by-field schema.
