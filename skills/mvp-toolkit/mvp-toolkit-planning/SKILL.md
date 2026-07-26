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

- Load `mvp-toolkit-base` first and apply its
  `references/mvp-delivery-model.md`. It owns the MVP Contract, classifications,
  readiness, persistence boundary, Linear mapping, issue contract, and handoff
  payload used below.
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

Use `discuss-toolkit-dig` to complete and confirm the MVP Contract defined by
`mvp-toolkit-base`. Apply the base convergence condition rather than accepting a
generic product summary.

Do not require every product question to be closed. Close only those that change
the MVP boundary or make the delivery graph ambiguous.

### 3. Cut scope against the value loop

Apply the base Scope Disposition to every proposed capability. Record a concrete
rationale for each disposition. Only MVP capabilities may become executable
work in the current Project.

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

Apply the base Unknown Class and Decision Authority. Resolve scope-defining
unknowns with the user now. Plan blocking research/design before implementation,
and leave reversible implementation choices to their executor.

Front-load only genuine blockers. A question needed solely by a later milestone,
or answerable safely while implementing one issue, is not pre-implementation
work.

For blocking research/design:

- a `research` issue produces evidence, constraints, or evaluated options;
- a `design` issue consumes evidence and produces one binding decision, including
  rejected alternatives, rationale, and affected downstream work;
- express ordering with `blocked by`: research → design → affected implementation;
- say whether AI may decide, AI must recommend for a human decision, or an
  external input is required.

The `mvp-toolkit-resolution` skill completes this lane, applies its outcomes to
affected implementation issues, and leaves the Project ready to implement.
Planning only prepares that work.

### 5. Assign readiness

Assign exactly one readiness state using the base state machine and record its
required blocker or handoff summary.

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

Apply the base Issue execution contract. Additionally require that the outcome
fits in one sentence, one focused executor session, and one independently
verifiable deliverable.

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
   under the base durable-ownership rules. Update an existing authoritative note
   when one clearly owns the subject; otherwise create a linked MVP planning
   note. Do not duplicate complete PRD or design content.
2. Create or update one finite Linear Project for the MVP outcome, following
   the base MVP mapping and `linear-base` mechanics.
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

For READY_AFTER_RESOLUTION, hand off to `mvp-toolkit-resolution`.
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
