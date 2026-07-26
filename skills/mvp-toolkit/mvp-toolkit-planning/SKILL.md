---
name: mvp-toolkit-planning
description: >-
  Define a deliberately small MVP and turn it into autonomous-ready delivery
  work. Use when a PRD, design notes, decision logs, or rough actions already
  exist, but the MVP boundary, deferred roadmap, blocking research/design,
  milestones, or atomic Linear issues still need shaping. Includes guided
  dialogue to establish the MVP hypothesis and scope; persists durable product
  decisions to llm-wiki and, after explicit approval, creates or updates the
  finite MVP Project, Milestones, Issues, and dependencies in Linear. Not for
  shaping a still-unformed product concept, resolving the planned research or
  decisions, or orchestrating implementation.
---

# MVP Planning

Shape an existing product direction into the smallest credible MVP and a
delivery graph that a context-free orchestrator can drive.

The output is not merely a detailed backlog. It is an explicit scope cut, an
inventory of remaining uncertainty, and ordered work whose inputs and completion
conditions are visible.

## Responsibility boundary

Own:

- defining the MVP hypothesis through dialogue when it is not yet explicit;
- separating MVP scope from deferred roadmap;
- identifying the few unknowns that must be resolved before implementation;
- arranging those unknowns before implementation work;
- defining outcome-oriented milestones and atomic deliverables;
- persisting durable product knowledge to llm-wiki;
- proposing, then creating or updating, the corresponding Linear structure.

Do not:

- reopen the whole product concept when its direction is already established;
- execute research or settle design decisions planned for later resolution;
- implement code, choose agents, branches, commits, or PR topology;
- insert routine human-review gates into the dependency graph;
- create executable Linear issues for speculative future work.

If the product concept itself is still unformed, use `inception`. If a request is
unclear rather than conceptually open, use `discuss-toolkit-dig`.

## Required integrations and degradation

- Use `discuss-toolkit-dig` for the MVP-defining dialogue. Ask only questions
  that can change the scope cut, unknown classification, or delivery structure.
- Use the installed llm-wiki skills to retrieve and persist durable knowledge.
  Apply `llm-wiki-base` for setup, scope, and note-model rules. If llm-wiki or
  `zk` is unavailable, stop before pretending the durable record exists and ask
  where the user wants it persisted.
- Use `linear-base` for Linear model, labels, issue lifecycle, and repository
  resolution. If Linear is unavailable, finish a concrete proposal but report
  that registration remains incomplete.

Read [references/output-contract.md](references/output-contract.md) before
drafting the proposal or writing either system.

## Workflow

### 1. Establish the planning surface

Retrieve the relevant PRD, design notes, decision records, and prior scope notes
from llm-wiki. Read the selected Linear Project and rough actions when they
already exist. Inspect the repository only where current implementation facts
materially constrain the plan.

Build a source map:

- established product direction and target user;
- explicit decisions and rejected alternatives;
- rough requested capabilities and actions;
- known technical or operational constraints;
- unresolved questions;
- contradictions or stale assumptions.

Do not invent a source-precedence rule. When two sources conflict and the answer
would change scope or sequencing, surface the conflict and resolve it with the
user.

### 2. Define the MVP contract through dialogue

Use `discuss-toolkit-dig` to establish:

- **Target user and problem** — whose situation changes;
- **Smallest value loop** — the shortest end-to-end use that delivers real value;
- **Hypothesis** — what the MVP is intended to prove or disprove;
- **Evidence** — what observable result would count as learning or success;
- **Constraints** — safety, legal, operational, integration, or timing limits;
- **Non-goals** — what this MVP deliberately does not establish.

The MVP contract has converged when target user, problem, value loop, hypothesis,
evidence, constraints, and non-goals are specific enough to decide whether a
candidate capability belongs in the MVP.

Do not require every product question to be closed. Close only those that change
the MVP boundary or make the delivery graph ambiguous.

### 3. Cut scope against the value loop

Classify every proposed capability:

- **MVP** — required for the smallest value loop, its evidence, safe operation,
  or a constraint that would make later reversal disproportionately expensive;
- **Deferred** — potentially valuable, but unnecessary for the current
  hypothesis and safely addable after learning;
- **Rejected** — inconsistent with the direction, duplicated, or no longer
  justified.

Require a concrete reason for every MVP inclusion. Challenge:

- abstractions with only one current implementation;
- flexibility for hypothetical future variants;
- optimization for unobserved scale;
- completeness that does not change the MVP evidence;
- infrastructure whose only benefit is making later work cleaner;
- feature parity beyond the smallest value loop.

Prefer a temporary manual step or narrow implementation when it can test the
same hypothesis without unacceptable risk.

Keep Deferred items in llm-wiki with their exclusion rationale. Do not turn them
into executable Linear issues. If a later phase is already a committed finite
outcome, propose a separate future Project rather than mixing it into the MVP
Project.

### 4. Classify remaining unknowns

Classify each uncertainty by what must happen next:

1. **Scope-defining decision** — resolve it with the user now. Do not hide a
   product-direction choice inside a later issue.
2. **Blocking research or design** — plan it before implementation because its
   outcome can invalidate the MVP route, change a material contract, or prevent
   downstream issues from being self-complete.
3. **Reversible implementation choice** — leave it to the executor. Do not create
   an issue merely to decide a low-impact detail.

Front-load only genuine blockers. A question needed solely by a later milestone,
or answerable safely while implementing one issue, is not pre-implementation
work.

For category 2:

- a `research` issue produces evidence, constraints, or evaluated options;
- a `design` issue consumes evidence and produces one binding decision, including
  rejected alternatives, rationale, and affected downstream work;
- express ordering with `blocked by`: research → design → affected implementation;
- say whether AI may decide, AI must recommend for a human decision, or an
  external input is required.

The later `mvp-toolkit-resolution` skill is expected to complete this lane,
apply its outcomes to affected implementation issues, and leave the Project
ready to implement. Planning only prepares that work.

### 5. Assign readiness

Assign exactly one state:

- **READY** — no blocking unknown remains; the first implementation issue is
  self-complete and executable.
- **READY_AFTER_RESOLUTION** — the resolution lane is executable, but
  implementation is not. List every blocker and the chain that resolves it.
- **BLOCKED** — no useful autonomous work can begin without missing human or
  external input. Name the input and owner.

Do not label a plan READY merely because all unknowns have issues. READY means
implementation itself may start.

### 6. Design delivery milestones

Define milestones as observable increments within the finite MVP outcome. A
milestone must produce a state that can be demonstrated, inspected, or tested.
Prefer a thin vertical value slice before breadth or hardening.

Do not organize milestones as technical layers such as "database", "API", then
"UI" when no usable behavior appears until the end.

For each milestone define:

- outcome available at completion;
- included and excluded scope;
- observable acceptance or demo;
- hypothesis, risk, or decision that becomes assessable;
- constituent issues and necessary dependencies.

When resolution work exists, place it before implementation milestones. It is a
pre-implementation lane, not a license to design every later detail up front.

Make milestones reviewable, but do not create review issues or block later
milestones merely to enforce a human pause. Review cadence belongs to the
execution policy. A genuinely unresolved binding decision remains a real
dependency and is modeled as such.

### 7. Decompose atomic issues

Create the smallest meaningful deliverables, not mechanical file edits.

Every issue must:

- express one coherent outcome in one sentence;
- be feasible in one focused executor session;
- be independently verifiable;
- declare all inputs that cannot be reconstructed from the repository;
- name completed blocker outcomes it consumes;
- contain no unresolved scope or product-direction choice;
- state what is explicitly out of scope;
- provide observable acceptance and a verification method.

Use `impl`, `research`, and `design` according to the deliverable produced. Git
packaging is not part of planning: an issue is an atomic deliverable, while the
execution workflow decides how issues map to commits, branches, and PRs.

If an implementation issue still depends on unresolved blocker results, create
it in Backlog with the dependency and enough provisional intent to show the
delivery shape. Do not promote it to Todo until resolution has made its inputs
and acceptance self-complete. READY plans may place unblocked self-complete
issues in Todo.

### 8. Preview before external writes

Present one proposal containing:

- MVP contract;
- MVP / Deferred / Rejected scope table;
- unknown register and readiness;
- milestones, issues, and dependency graph;
- planned llm-wiki changes;
- planned Linear Project, Milestones, Issues, statuses, and relations;
- contradictions, assumptions, and remaining human choices.

Get explicit user approval before creating or mutating Linear or committing the
scope cut to llm-wiki. Incorporate corrections into the proposal first.

### 9. Persist knowledge and executable work

After approval:

1. Persist the MVP contract, scope cut, Deferred rationale, and product decisions
   in the current repository scope in llm-wiki. Update an existing authoritative
   note when one clearly owns the subject; otherwise create a linked MVP planning
   note. Do not duplicate complete PRD or design content.
2. Create or update one finite Linear Project for the MVP outcome, following
   `linear-base`. Summarize Goal, Scope, Out of Scope, evidence, and readiness in
   its description.
3. Create Milestones only when the outcome has distinct observable stages.
4. Create issues with Type and Repo labels, status, milestone, and `blocked by`
   relations. Do not create Deferred roadmap issues.
5. Re-read the resulting Project and compare it to the approved proposal. Repair
   omissions or mismatched dependencies before declaring completion.

### 10. Hand off

Report:

- the final readiness state;
- the first unblocked work;
- every unresolved blocker and who may settle it;
- the llm-wiki note and Linear Project updated;
- the appropriate next route.

For READY_AFTER_RESOLUTION, hand off to `mvp-toolkit-resolution` when installed.
For READY, hand off to `mvp-toolkit-orchestration` when installed. If the
destination skill does not yet exist, name the missing capability without
silently substituting implementation in this session.

## Gotchas

- **Detailed is not ready.** More subtasks do not compensate for an unsettled MVP
  boundary or missing acceptance.
- **Do not manufacture discovery.** Research that cannot change scope, contract,
  feasibility, or sequencing is probably implementation detail.
- **Do not freeze provisional implementation issues.** Resolution may update,
  split, or cancel them before implementation.
- **Do not confuse reviewability with a review gate.** Expose observable
  increments; let execution decide when to pause.
- **Do not turn the Deferred list into a shadow backlog.** Preserve rationale,
  not ready-to-run tickets.
- **Do not silently overwrite durable knowledge.** Resolve conflicting notes and
  preserve decision rationale.

## Success criteria

- [ ] The MVP contract is explicit and confirmed by the user.
- [ ] Every included capability is justified by the value loop, evidence,
      constraints, or disproportionate reversal cost.
- [ ] Deferred scope and its rationale are durable but absent from executable
      MVP issues.
- [ ] Every pre-implementation research/design item is a genuine blocker with a
      concrete deliverable and dependency chain.
- [ ] Milestones are observable increments rather than technical layers.
- [ ] Issues are atomic, verifiable, and sized for one focused session.
- [ ] The readiness state matches what may actually start.
- [ ] llm-wiki and Linear match the user-approved proposal.
- [ ] A context-free orchestrator can identify the next work and every blocker
      without relying on this conversation.
