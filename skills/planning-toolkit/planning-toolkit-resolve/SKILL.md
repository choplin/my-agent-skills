---
name: planning-toolkit-resolve
description: >-
  Resolve a Project's pre-implementation research and design blockers and leave
  its implementation work autonomous-ready. Use when planning-toolkit-plan
  marked a Linear Project READY_AFTER_RESOLUTION, or when explicit
  research/design issues block the implementation lane. Executes research,
  settles decisions according to recorded AI/human/external authority, persists
  evidence and rationale to llm-wiki and Linear, applies outcomes to affected
  implementation issues, and promotes self-complete work to Todo before marking
  the Project READY, which is where it stops.
metadata:
  description-role: documentation
---

# Resolve Pre-Implementation Blockers

Close the uncertainty that must be closed before implementation, then make the
resulting implementation graph executable without hidden context.

Resolution is complete only when findings and decisions have changed the
downstream work they govern. Closing research/design issues without applying
their consequences is incomplete.

## Responsibility boundary

Own:

- executing the pre-implementation `research` and `design` lane;
- recording evidence, decisions, alternatives, and rationale durably;
- obtaining decisions from the authority assigned during Planning;
- creating newly discovered blocking research/design work when necessary;
- updating, splitting, canceling, and grooming affected implementation issues;
- changing the Project from `READY_AFTER_RESOLUTION` to `READY`.

Do not:

- redefine the Outcome Contract or the scope cut silently;
- execute production implementation issues;
- turn non-blocking implementation details into up-front design;
- impose milestone review cadence;
- choose a human-owned or external decision by default;
- declare READY while any implementation-critical input remains unresolved.

If the research invalidates the Outcome Contract itself, stop and return to
`planning-toolkit-plan`. Treat this as an exceptional planning invalidation, not
a normal reconcile phase.

## Required integrations and records

- Load `planning-toolkit-base` first and apply its
  `references/delivery-model.md`. It owns the contract, the scope policy shape,
  classifications, authority, readiness state machine, persistence boundary,
  issue contract, and handoff payload used below.
- Apply `linear-base` for Project resolution, Issue lifecycle, Type/Repo labels,
  self-completeness, dependencies, completion notes, and grouping.
- Apply the installed llm-wiki skills for retrieval and durable writes. Use
  `llm-wiki-base` for setup, scope, links, and note-model rules.
- Use `discuss-toolkit-dig` only when a human-owned decision lacks enough shared
  meaning to choose. Do not reopen already explicit criteria.

If Linear is unavailable, the resolution lane cannot be driven or certified
READY. If llm-wiki or `zk` is unavailable, stop before resolving an item whose
acceptance requires a durable finding or decision record.

Read [references/resolution-records.md](references/resolution-records.md) before
executing an issue, asking for a human decision, or reporting readiness.

## Workflow

### 1. Load and verify the resolution contract

Resolve the finite Project and retrieve its planning record from llm-wiki. Load
every field in the base Planning → Resolution handoff, including the scope policy
in force, plus completion notes on already-finished blockers.

Require `READY_AFTER_RESOLUTION` or equivalent explicit pre-implementation
blockers. If the Project is already READY, report that Resolution is unnecessary.
If the Outcome Contract or resolution issues are too incomplete to identify what
must be learned or decided, return to `planning-toolkit-plan` rather than
improvising a new plan.

Build a live resolution graph from Linear. Do not create a separate local state
file. Linear statuses, relations, descriptions, and completion notes make the
workflow resumable.

### 2. Audit the lane before execution

For every planned blocker, verify:

- it can change feasibility, a material contract, or downstream sequencing;
- `research` asks one answerable question and names required evidence;
- `design` asks for one binding decision and names its inputs and authority;
- affected implementation issues are linked through `blocked by`;
- the issue can complete in one focused session;
- its acceptance says where the durable output will live.

Remove or demote work that is merely a reversible implementation choice. Do not
front-load it because Planning happened to create an issue.

When a genuine missing blocker is discovered, add the smallest `research` or
`design` issue needed and connect it to the affected downstream work. When the
missing input belongs to a human or external owner and cannot be investigated
autonomously, mark the Project BLOCKED and name the owner.

### 3. Work the dependency frontier

Repeatedly select an unresolved `research` or `design` issue whose `blocked by`
relations are all complete. Prefer:

1. research that can invalidate several downstream decisions;
2. decisions with the largest blocked implementation surface;
3. otherwise the Project's priority order.

Work one issue at a time by default. Parallel execution is optional only for
independent research whose evidence and writes cannot interfere; it is not
required by this portable skill.

Before work, move the issue to In Progress. On completion:

1. verify its Acceptance;
2. write the durable finding or decision to llm-wiki;
3. leave the required Linear completion note with the actual result and any
   deviation from the planned approach;
4. move it through In Review when a real review exists, otherwise to Done;
5. enqueue every affected implementation issue for impact application.

Do not start a downstream design or implementation issue before its input is
durably recorded.

### 4. Execute research as evidence production

Answer the issue's question with the minimum investigation that can settle the
blocker. Prefer primary sources, direct repository inspection, and reproducible
experiments.

Research may run disposable probes or prototypes when the issue requires them,
but its deliverable is evidence and constraints, not hidden production code.
Do not leave experimental code in the implementation path unless the issue
explicitly defines it as a durable artifact.

Record:

- question and conclusion;
- evidence and how it was obtained;
- constraints and confidence;
- options ruled out;
- implications for named decisions and implementation issues;
- remaining uncertainty, if any.

If the evidence is insufficient, keep the issue open and state what is missing.
Do not convert uncertainty into a confident conclusion to unblock the graph.

### 5. Settle design according to authority

Consume only completed Inputs. Evaluate the options against the Outcome Contract,
research evidence, and issue constraints.

Follow the base Decision Authority:

- **AI decides** — choose the best-supported option, record rejected
  alternatives and rationale, then complete the issue.
- **Human decides** — prepare one decision packet with evidence, viable options,
  consequences, and a recommendation. Continue other independent autonomous
  resolution work first; ask when no more useful work can proceed or when the
  ready human decisions form a coherent batch. Do not mark the issue Done until
  the user decides.
- **External owner decides/provides input** — record the exact missing input and
  owner, leave dependent work blocked, and set Project readiness to BLOCKED when
  nothing else can advance.

Batching is an attention optimization, not permission to combine distinct
decisions. Preserve one binding outcome per design issue.

### 6. Detect planning invalidation

After each material finding or decision, compare it with the confirmed Outcome
Contract using the base planning-invalidation rule.

Apply locally when the result only changes:

- a technical approach within the agreed outcome;
- files, APIs, or constraints of affected issues;
- issue size, dependency order, or milestone composition;
- an implementation capability that remains inside the agreed scope.

When invalidated, return to `planning-toolkit-plan`, set readiness to BLOCKED,
record the invalidating evidence in llm-wiki and the Project, and do not keep
resolving work derived from the old contract.

### 7. Apply every outcome downstream

For every completed research/design issue, inspect all affected implementation
issues. Update them so a context-free executor can act from the issue plus its
explicit completed Inputs under the base Issue execution contract:

- replace provisional alternatives with the binding decision;
- add the completed finding/decision under Inputs and state what it supplies;
- update What & Why, Where, Acceptance, verification, and Constraints;
- remove work made unnecessary by the outcome;
- split work that is no longer one atomic deliverable;
- cancel work whose intended outcome is no longer needed;
- add newly necessary work only when it remains inside the confirmed scope;
- repair milestones and `blocked by` relations.

Follow `linear-base` grouping rules when splitting or rebuilding. Keep completed
blocker relations when useful for provenance; their completed state no longer
blocks execution.

An implementation issue remains Backlog until this update makes it
self-complete. Move it to Todo only when a fresh executor needs no conversation
history and no unresolved input.

### 8. Audit implementation readiness

After the resolution graph is empty, verify:

- every genuine pre-implementation research/design blocker is Done or explicitly
  canceled with rationale;
- every finding and decision has a durable llm-wiki record and Linear completion
  note;
- no implementation issue consumes an unresolved or implicit input;
- affected issues reflect the chosen decisions rather than provisional options;
- each first-wave implementation issue is atomic, verifiable, and Todo-ready;
- dependencies and milestone membership match the resolved plan;
- Deferred scope has not leaked into executable issues;
- the Outcome Contract still holds.

Set the Project to READY only after this audit and the base Resolution →
Execution handoff both pass. Update its readiness summary and identify the first
unblocked implementation issue or issues.

If any check fails, keep `READY_AFTER_RESOLUTION` while autonomous resolution can
continue. Use BLOCKED only for missing human/external input or planning
invalidation, and state the exact blocker.

### 9. Hand off

Report:

- final readiness;
- research conclusions;
- decisions, authorities, and rationale;
- implementation issues updated, split, added, or canceled;
- any scope or milestone effect;
- first unblocked Todo implementation work;
- llm-wiki and Linear records updated.

For READY, report that execution may start and name the first unblocked work. Do
not pick an execution skill for the user, and do not implement in this session.

## Resume behavior

On re-entry, rebuild the graph from Linear and llm-wiki:

- skip Done issues after verifying their completion records;
- resume In Progress issues from their description and handoff note;
- re-evaluate the unblocked frontier;
- preserve pending human/external decisions;
- continue impact application that completion notes show as unfinished.

Never repeat research merely because the chat context was cleared.

## Gotchas

- **A closed issue is not a resolved dependency.** Its result must be durable and
  applied to affected implementation work.
- **Do not use AI authority for convenience.** Respect the authority recorded by
  Planning.
- **Do not broaden research.** Stop when the blocking question is answered.
- **Do not smuggle implementation into Resolution.** A probe may create evidence;
  production behavior belongs to the implementation lane.
- **Do not preserve obsolete tickets for completeness.** Cancel or reshape them
  when evidence changes the route.
- **Do not patch a broken contract locally.** Return to Planning.

## Success criteria

- [ ] Every blocking research question has sufficient durable evidence.
- [ ] Every blocking design issue has one binding decision from the assigned
      authority.
- [ ] Findings and decisions are recorded in both llm-wiki and Linear at the
      appropriate level of detail.
- [ ] Every affected implementation issue consumes explicit completed Inputs.
- [ ] Obsolete or incorrectly sized work is canceled, updated, or split.
- [ ] No Deferred capability entered the implementation lane.
- [ ] At least the first unblocked implementation work is self-complete and Todo.
- [ ] The Project is READY, or BLOCKED with an exact human/external/planning
      blocker.
- [ ] A context-free executor can start without this conversation.
