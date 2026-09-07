# Family review mode

Use this mode for an explicitly named cooperating skill family or repository
scope. It extends static review to defects that no one `SKILL.md` owns visibly.
Run it before making B1–B6 judgments so those judgments use the complete path
evidence. It remains advisory: path findings are not a gate, score, automatic
edit, or optimization signal.

## Bound the family and reconstruct paths

Start from the explicitly named family or repository scope. Identify entry points
from concrete evidence: a user-facing trigger, a standing caller, or another
skill that names the entry point. Do not infer a dependency from similar names or
directory adjacency alone.

Search the bounded repository for exact entry-point names and paths to find
reverse callers, then follow every explicit delegate edge forward. Read those
callers and delegates, every in-scope skill's `references/` files (including
files with no visible trigger), output schemas/templates, the repository
documentation that defines the path, and consumers of the produced fields.
Reconstruct each observable path as:

```text
entry point -> caller -> delegate -> reference -> deliverable/consumer
```

For every edge, record its evidence as one of:

- **explicit** — a skill names the callee, reference, command, schema, or output;
- **repository inference** — an exact field, artifact, or command connects a
  producer and consumer, but no declaration owns the edge;
- **unresolved dynamic edge** — dispatch depends on an installed role, runtime
  choice, or external component that the repository cannot resolve statically.

Stop at external boundaries. Put unresolved dynamic edges and excluded areas in
Coverage; a partial reconstruction must not read as a complete family audit.

Run the B0 preflight against every in-scope skill directory before applying the
standard. If it fails anywhere, use the existing B0 stop rule and identify the
affected path in Coverage.

## Build ownership and use inventories

Build two compact evidence tables before judging duplication:

| Executable item | Kind | Defined/produced by | Used/enforced by | Paths that load it |
|-----------------|------|---------------------|------------------|--------------------|
| `<exact name or quote>` | rule / schema field / metadata / acceptance gate | `<file:section>` | `<consumer sites, or none>` | `<paths>` |

| Reference | Loaded from | Load condition | Lens needed | Loading unit |
|-----------|-------------|----------------|-------------|--------------|
| `<file>` | `<caller>` | `<exact trigger, or none>` | `<needed section>` | `<whole file/section>` |

Search exact schema and metadata field names across the bounded scope with `rg`
or the repository's equivalent. A declaration is not a consumer: record where a
value is produced, where behavior reads it, and where it only passes through.
Mark a produced value with no behavioral consumer as **unused contract data**;
mark a behaviorally significant field with no shared contract owner as **missing
ownership**.

For every executable rule, schema, or acceptance gate, identify the file that
claims authority. Several authoritative copies are **competing ownership** even
when their current text agrees, because they can drift independently.

## Judge path-level context and ownership

Apply B1–B6 to each local skill, then use the path inventories for cross-skill
findings:

- Flag the same rule or reference loaded more than once on one execution path;
  copies on mutually exclusive paths are not duplicate context for one run.
- Distinguish authoritative restatement from independent enforcement. Preserve a
  caller/callee guard when each side can reject the violation at its own boundary
  and removing either copy would permit an invalid handoff. State that reason in
  Strengths or the relevant finding rather than silently deduplicating it.
- Flag a reference that lacks an explicit load condition. Also flag a reference
  whose condition selects one narrow lens but whose loading unit forces unrelated
  material into context; a trigger can be correct while the unit is still too
  broad.
- Describe the current contract directly and judge historical residue from the
  current tree. Former-state wording (for example, `previously`, `no longer`,
  `legacy`) is already sufficient evidence of residue; its origin does not need
  reconstruction. Consult version history only when an explicit migration,
  deprecation, interoperability, or versioned external contract is itself in
  scope and the current artifacts cannot verify it.

Classify every family finding as exactly one primary kind:

- **local content quality** — a B1–B6 defect within one skill or reference;
- **cross-skill duplication** — redundant content loaded on the same path;
- **missing or competing ownership** — no authority, or several authorities,
  for one executable contract;
- **unused contract data** — produced schema or metadata with no behavioral
  consumer;
- **historical residue** — former-state language or structure that no longer
  describes the current contract.

Use secondary standard requirements where helpful, but do not blur the primary kind.

## Calibration fixture

For a bounded path containing (a) a produced schema field with no consumer, (b)
two authoritative copies of one workflow, (c) the same handoff guard enforced by
both caller and callee, and (d) a reference whose one needed lens requires loading
several unrelated sections:

- report (a) as **unused contract data**;
- report (b) as **cross-skill duplication** with **competing ownership** noted in
  the evidence;
- retain (c), explaining that both boundaries independently prevent an invalid
  handoff; and
- report (d) as **local content quality** under B1.

If the evidence does not establish independent enforcement for (c), report the
uncertainty instead of assuming the duplication is intentional.
