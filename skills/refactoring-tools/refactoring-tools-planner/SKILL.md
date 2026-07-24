---
name: refactoring-tools-planner
description: Analyze a repository and produce an evidence-based, implementation-ready refactor-instructions.md without changing production code. Use when the user wants a refactoring assessment, technical-debt map, safe phased refactor plan, or a handoff document for another coding agent. Prioritize behavior preservation, repository-specific validation, bounded changes, and explicit stop-and-ask gates. Do not use when the primary request is to implement the refactor now, add features, migrate schemas, or intentionally change public behavior.
---

# Refactoring Tools Planner

Create a self-contained execution contract for a fresh implementation agent.
Inspect the repository deeply enough to make the contract specific, but do not
perform the refactor.

Default the deliverable to
`.agents/refactoring-tools/refactor-instructions.md` under the repository root.
Create `.agents/refactoring-tools/` when it does not exist. Honor a different
filename, path, or scope when the user supplies one.

## Hard boundaries

- Do not edit production code, tests, schemas, configuration, or generated
  artifacts. The only permitted repository change is the requested instruction
  document.
- Do not treat age, file size, style preference, or unfamiliarity as evidence of
  technical debt.
- Do not silently turn a refactor into a feature, bug fix, migration, dependency
  upgrade, performance rewrite, or public-contract change.
- Do not claim behavior, test coverage, or command success that was not observed.
- Do not prescribe a repository-wide rewrite. Convert findings into bounded,
  independently verifiable slices.
- Make the document portable: the implementation agent must not need this skill
  or hidden conversation context to execute it.

## Workflow

### 1. Establish scope and repository rules

Read the applicable instruction hierarchy before exploring: `AGENTS.md`,
`CLAUDE.md`, README files, and repository- or directory-specific guidance.
Inspect `git status` first. Preserve all pre-existing changes and never attribute
them to the refactor plan.

Use the scope named by the user. If the request says only “this repository,” map
the whole system at low resolution, then select a small number of high-value
refactor slices. State what was inspected and what was not; breadth of discovery
does not authorize breadth of change.

### 2. Build an evidence-based project model

Inspect applicable sources rather than mechanically requiring every category:

- manifests, dependencies, build, lint, test, typecheck, CI, and release setup;
- docs, specifications, design notes, operational scripts, and runbooks;
- entry points, primary workflows, major modules, and ownership boundaries;
- tests, fixtures, snapshots, schemas, migrations, and generated artifacts;
- authentication, authorization, billing, notifications, external APIs, jobs,
  queues, concurrency, storage, and observability boundaries.

Trace representative paths end to end. Identify:

- what the product does and its important user-visible workflows;
- entry points and external contracts;
- module responsibilities and dependency direction;
- data, control, error, and transaction flow;
- persisted and generated representations;
- existing validation commands and required environment assumptions;
- behavior that must remain unchanged.

Prefer repository-native search and inspection tools. Use history only when it
clarifies intent that current code and documentation cannot establish. Do not
use network research unless the task explicitly requires it.

Keep three categories distinct throughout:

1. **Observed** — directly supported by code, configuration, tests, docs, or
   command output.
2. **Inferred** — a reasoned interpretation with its evidence and confidence.
3. **Unknown** — a decision that cannot be made safely from repository evidence.

Record evidence as repository-relative paths plus symbols or line numbers where
practical. A filename alone is not enough when the relevant location is narrow.

### 3. Establish the validation baseline

Discover commands from repository configuration; do not invent conventional
commands. Record for each command:

- exact command and working directory;
- what it validates;
- prerequisites or services;
- whether it was run during analysis;
- observed result, or a clear reason it was not run.

Run only cheap, safe checks when their result materially improves the plan.
Expensive, destructive, credentialed, or environment-dependent commands belong
in the implementation instructions with their prerequisites. Never describe an
unrun command as a passing baseline.

### 4. Build and rank the debt map

Look for root causes, not a cosmetic smell inventory:

- duplication and dead or unreachable code;
- mixed responsibilities and unclear ownership;
- abstractions that conceal behavior or fail to protect a real boundary;
- reversed dependencies or leaking transport, persistence, and framework types;
- ambiguous types, schemas, contracts, or state transitions;
- missing characterization coverage and brittle tests;
- inconsistent error handling, logging, configuration, and environment behavior;
- unsafe asynchronous, concurrent, transactional, or lifecycle behavior;
- evidenced performance risks;
- security-sensitive trust boundaries;
- misleading names or placement that causes ownership mistakes.

For every retained finding, provide:

- stable ID and concise title;
- evidence;
- current behavior and why the structure impedes a concrete change or raises a
  concrete risk;
- affected contracts and blast radius;
- confidence and change risk;
- recommended bounded intervention;
- verification method;
- disposition: **implement**, **characterize first**, **proposal only**, or
  **out of scope**.

Consolidate symptoms that share one cause. Drop findings that are only taste.
Rank work by expected maintenance benefit, risk reduction, confidence, and
prerequisites—not by visual cleanliness.

### 5. Apply the question gate

Exhaust repository evidence before asking the user. Ask only when the answer
changes the safe implementation plan, including:

- code, tests, and documentation disagree on correct behavior;
- deletion safety or reachability cannot be established;
- public APIs, schemas, persisted data, or compatibility may change;
- authentication, authorization, billing, notifications, or external
  integrations may change;
- multiple viable designs require a product or architecture decision.

Separate uncertainties into:

- **Blocking questions** — an answer changes scope, preserved behavior, phase
  order, or a one-way decision. Ask these before finalizing the instruction
  document. Do not bury unresolved choices in an apparently executable plan.
- **Non-blocking uncertainties** — exclude the dependent change, record a
  stop-and-ask condition or proposal-only item, and continue.

If blocking questions exist, return only the smallest sufficient question set
and wait. After answers arrive, verify the affected evidence and then write the
document.

### 6. Design executable phases

Read [the instruction template](references/refactor-instructions-template.md)
before drafting. Tailor every section to the repository; remove template
prompts and placeholders.

Order phases by dependency and reversibility:

1. Reconfirm worktree state and baseline.
2. Add characterization tests or reproducible checks where important behavior
   lacks a safety net.
3. Perform high-confidence mechanical cleanup only when it enables later work.
4. Separate one responsibility or ownership boundary at a time.
5. Clarify interfaces, types, schemas, and dependency direction without changing
   external contracts.
6. Improve test seams and remove duplication made obsolete by earlier phases.
7. Leave high-risk redesigns as proposals unless separately approved.

Each phase must specify:

- objective and linked debt IDs;
- concrete files, symbols, or boundaries in scope;
- ordered implementation steps;
- behavior and contracts to preserve;
- validation commands or manual checks;
- phase-specific stop conditions;
- observable exit criteria;
- dependencies on earlier phases.

Do not over-prescribe implementation details unsupported by the repository.
Specify constraints and outcomes precisely while leaving reversible local coding
choices to the implementation agent.

### 7. Write and audit the deliverable

Write the finalized document to the agreed path. Audit it before returning:

- every material claim has traceable evidence;
- every phase resolves named debt and has an observable exit;
- commands, paths, and symbols exist or are explicitly marked conditional;
- preservation requirements cover public, persistence, security, concurrency,
  ordering, error, and operational contracts that are relevant;
- the implementation agent knows when to stop rather than guess;
- baseline failures are distinguished from regressions;
- out-of-scope work prevents opportunistic expansion;
- no unresolved blocking question or placeholder remains.

The instruction document must require the implementation agent to:

- inspect `git status` before editing and preserve unrelated changes;
- record baseline results before changing code;
- make small, reversible, reviewable changes;
- avoid unrelated formatting and opportunistic refactors;
- verify after every phase and stop on unexplained regression;
- report the final diff scope, commands run, results, limitations, and follow-ups.

## Return to the user

After writing the document, report:

- the output path;
- the selected refactor scope and number of implementation phases;
- any proposal-only or excluded high-risk items;
- analysis checks actually run and their results.

Do not paste the entire document unless the user requests it. If the question
gate paused the workflow, ask the blocking questions instead and do not claim the
document is final.
