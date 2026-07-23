---
name: codebase-structure-refactor
description: Safely refactor an initial or AI-generated implementation toward the codebase-structure skill while preserving external behavior. Use when responsibilities, handlers, SQL, and business rules are mixed and the code needs incremental restructuring with contract, transaction, generated-artifact, and regression checks. Do not use for a primarily feature, schema, or externally visible contract change.
---

# Codebase Structure Refactor

Use `$codebase-structure` as the target design. This skill defines the safe migration
process: preserve external behavior while moving existing code toward clear
concept, type, ownership, module, and layer boundaries.

Do not combine feature work, schema migrations, or UX changes with this
refactor: doing so makes a behavior regression impossible to attribute to either
the structural move or the intentional change. If the target requires one,
isolate it and get direction separately.

## Workflow

### 1. Establish the refactor boundary

State the behavior to preserve and explicitly list excluded changes. Inspect
repository instructions, the current diff, public entry points, build/test
commands, schema metadata, and generated SQL artifacts before editing.

Read `$codebase-structure`, then use its concept-model template to inventory the
relevant concepts. Read [the contract and invariant checklist](references/contract-invariant-checklist.md)
before choosing extraction order.

### 2. Model the current code against the target style

For each important concept, identify its meaningful states, invariants,
permitted transitions, owned rules, relationships, and domain/external/
persistence representations. Distinguish concept-owned behavior from
orchestration before moving code.

For example, parsing a body into links and calculating a link-set difference are
domain behavior; loading an entity, applying that difference, and committing
both writes is coordination. SQL query text and database-row conversion belong
at the external adapter boundary.

### 3. Refactor in verifiable slices

Move one concept or coherent transition at a time. Start with independent value
objects and pure transformations, then isolate reads and mappings, and lastly
refactor coordinated writes.

After each slice, format and run the smallest relevant static check and test.
Review the diff for accidental contract changes before the next slice. Do not
declare success after mechanically splitting files that still contain a large
procedural blob.

### 4. Protect persistence and atomicity

For changes that touch storage, follow `$codebase-structure`'s external-adapter
boundary and apply `lang-reference-sql` for SQL query style when SQL changes.

Put every write necessary to preserve one invariant in the same transaction.
Review failure paths so a failed operation cannot leave an observable
intermediate state. Include SQL caches, offline metadata, and generated query
artifacts in the same change when the project uses them.

### 5. Review by failure mode, then verify

Independently inspect the final change for:

- ownership or module boundaries that remain procedural or ambiguous;
- dependencies from concept code outward into coordination, persistence, or transport;
- rows, SQL, or database-access APIs leaking beyond external adapters;
- multi-write invariants without an atomic transaction;
- regressions in CLI/API/JSON behavior, error text, sort order, filters, scope,
  empty results, optional states, idempotence, and all-scope restrictions;
- stale generated SQL metadata or query caches.

Run the repository's applicable formatter, static checks, offline build if
supported, integration tests, and a final diff check. Green tests are evidence,
not proof that every external contract remained unchanged.

Complete the refactor only when every relevant item in the contract and invariant
checklist has recorded evidence of preservation or an explicit limitation, and
when every coupled write has an identified atomicity boundary. Record unresolved
items as follow-up risk rather than implying they passed.

## Record the outcome

Leave a concise decision record in the project's established location. Include
concept-boundary decisions, verification performed, deliberate exceptions,
unresolved risks, and follow-up work. Do not claim a contract is preserved beyond
what was inspected or tested.
