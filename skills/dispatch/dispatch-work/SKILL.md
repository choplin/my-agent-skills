---
name: dispatch-work
description: >-
  Single front door for STARTING work when the execution mode has not been chosen.
  Invoked explicitly (for example /dispatch-work) or delegated to by a routing skill
  such as linear-start; do not auto-activate on unrelated in-progress work. First
  distinguishes an unshaped project concept (inception), an unclear request
  (discuss-toolkit-dig), and an identifiable direction the user wants challenged
  (grill-me).
  For executable work, recommends one concrete route from dev-workflow-kickoff,
  ordinary in-session collaboration, the host's native /goal, exec-plan, or direct
  implementation based on the task's judgment, risk, and planning horizon. It
  presents a task-specific recommendation rather than making the user traverse a
  generic mode questionnaire. Not an executor: after routing, it hands off.
allowed-tools: Read, Glob, Grep, AskUserQuestion, Skill
user-invocable: true
---

# Dispatch Work

Choose the control model for one new work unit, then hand off. This skill does not
interview for requirements, write artifacts, or implement the work.

## Responsibility boundary

`dispatch-work` is the **only cross-family mode selector**:

- `inception` shapes a fuzzy What before execution.
- `discuss-toolkit-dig` clarifies what the user means when proceeding would
  require assumptions.
- `grill-me` pressure-tests an identifiable candidate direction.
- `dev-workflow-kickoff` starts work whose phases are gated by human approval of a
  durable spec, plan, and review.
- Ordinary in-session collaboration keeps the work conversational without loading
  another workflow skill or creating its durable artifacts.
- Native `/goal` and `exec-plan` are autonomous modes. They differ in how
  completion and exceptional decisions are handled.
- Direct in-session implementation is the cheap route for a trivial change.

The three thinking routes are different operations, not three degrees of
vagueness. Do not present them beside execution modes. They precede execution
mode selection when needed.

Once `dev-workflow-kickoff` is chosen, that choice is settled: kickoff must not
redirect the work back to an autonomous mode based on issue contents.

## Decision tree

Evaluate these gates in order.

### Gate 1 — What kind of uncertainty is active?

Route by the operation the user needs, not by how sparse or rough their words
look. Evaluate these checks top to bottom and stop at the first match:

- **Concept gap → `inception`.** The user's request is understandable, but they
  do not yet know what should be built or foundational product questions remain
  open. They want to explore possibilities, make decisions, and leave with a
  durable footing and first actions.
- **Interpretation gap → `discuss-toolkit-dig`.** The user has or may have an
  intended outcome, but the request does not communicate it precisely enough to
  proceed without guessing. Dig establishes a confirmed understanding and a
  concrete next step. It does not invent or shape a project concept.
- **Confidence gap → `grill-me`.** A plan, design, decision, idea, or other
  proposition can be identified, and the user wants it challenged, pressure-
  tested, or attacked before acting. The candidate may still be rough; it need
  not be a complete specification.
- **No thinking gap.** The work is shaped and understood well enough to choose
  an execution mode. Continue to Gate 2.

Explicit intent wins: "clarify what I mean" points to dig, "help me figure out
what to build" points to inception, and "poke holes in this direction" points
to grill-me. If a requested grill has no identifiable test object, still hand
off to `grill-me`; its own gate uses dig only until that object is clear.

Concept comes before interpretation because an unformed What naturally produces
underspecified language; that is not a communication defect for dig to repair.
Interpretation comes before confidence because grill-me requires an identifiable
proposition to challenge.

Do not use dig merely because inception or grill-me will ask questions. Inception
already uses dig for faithful elicitation, and grill-me owns its own dig gate.

When Gate 1 selects a thinking route, recommend that route alone. Do not list
`/goal`, `exec-plan`, `dev-workflow-kickoff`, or direct implementation in the
same prompt. After dig or grill-me reaches shared understanding, return to
`dispatch-work` if the user wants to start execution. Inception returns concrete
actions only after the footing is finalized.

### Gate 2 — What control model fits the task?

Infer a default from the task instead of asking the user to choose between abstract
control models:

- **Durable human gates → `dev-workflow-kickoff`.** Recommend this when correctness
  depends on settling subjective requirements before implementation; several
  one-way-door decisions have broad consequences; approval, auditability, or
  handoff requires a durable spec and plan; or distinct phases should not advance
  without human acceptance.
- **Conversational collaboration → ordinary session.** Recommend working directly
  in the current session when decisions are best made through a lightweight
  back-and-forth, but a formal spec/plan/review state machine would be overhead.
  This route is not limited to trivial edits: it fits bounded design and
  implementation work where the user wants to steer meaningful choices as they
  appear. Use no workflow skill and create no workflow artifacts unless the work
  itself requires an artifact.
- **Autonomous execution → continue to Gate 3.** Recommend autonomy when the
  outcome and observable completion conditions are clear, most decisions are
  reversible or already constrained, and useful progress does not depend on
  frequent user judgment.
- **Immediate implementation → ordinary session.** For a small, obvious, low-risk
  change with self-evident completion, recommend simply doing it now.

Treat explicit user preference as an override. Otherwise, base the recommendation
on the evidence above; do not ask a context-free "human-gated or autonomous?"
question. Linear size, labels, and testability are evidence, not a decision by
themselves.

Calibration examples:

- A bounded change whose design tradeoffs should be discussed as they appear →
  ordinary session.
- A release with stakeholder-approved behavior, several consequential decisions,
  and required acceptance review → `dev-workflow-kickoff`.
- A concrete multi-file change with visible steps and observable acceptance →
  `exec-plan`.
- A repository-wide migration whose intermediate route will evolve across stages
  → native `/goal`.
- An obvious one-file fix with a direct check → implement immediately.

### Gate 3 — Which autonomous mode?

Use **distance and planning horizon** to distinguish the two autonomous routes:

- **Native `/goal`** — the outcome is clear, but it is a distant or multi-stage
  target whose route may need to be discovered, revised, or organized into
  workflows while work continues. The persistent goal keeps the active chat
  pointed at the outcome across those intermediate plans and continuations.
  Prefer this for migrations, broad ports, repository-wide transformations, or
  "keep working until this larger outcome is achieved."
- **`exec-plan`** — the goal and direction are already concrete enough to write
  a self-contained execution plan now. The work is comparatively light or
  near-horizon: most of the route is visible, and the few high-impact decisions
  can be parked without blocking most progress. The agent drives the plan
  inline and batch-reviews those decisions at the end.

If most steps require human judgment, the work is not autonomous: return to the
ordinary-session or durable-human-gates choice according to whether that judgment
needs a persistent contract. If the direction itself is still unsettled, return
to `inception`. If parked decisions would block most of the visible plan, prefer
native `/goal` only when the larger outcome can guide useful route discovery;
otherwise recommend ordinary-session collaboration or `dev-workflow-kickoff`
according to the same contract test.

## Present a concrete recommendation

Complete the relevant gates internally, then recommend one terminal route. Do not
make the user answer Gate 2 and then Gate 3 as separate questionnaires.

- At Gate 1, present only the recommended thinking operation (plus the user's
  ability to decline through free-form input). State the diagnosed gap in one
  line: interpretation, concept, or confidence. If two routes genuinely remain
  plausible, contrast only those adjacent outcomes and let the user choose.
- For executable work, name the concrete destination — `dev-workflow-kickoff`,
  ordinary-session collaboration, `exec-plan`, native `/goal`, or immediate
  implementation — and explain the task evidence in one or two lines.
- When recommending autonomy, include the Gate 3 result in that same recommendation;
  never first ask "autonomous?" and then ask "`exec-plan` or `/goal`?"
- State the recommendation immediately before handoff and mention that the user
  can redirect it; do not turn that notice into a confirmation question. Proceed
  with the recommended handoff in the same turn when the user already asked to
  start and no consequential ambiguity remains. If two terminal routes are
  genuinely tied, ask one focused question that names the consequence separating
  them.

Do not flatten thinking routes and execution routes into one menu. Do not present
every available execution route merely to prove that it exists; mention that the
user can choose a different mode without forcing a generic choice.

## Handoff

After stating the recommendation:

- `discuss-toolkit-dig`, `inception`, `grill-me`, `exec-plan`, or
  `dev-workflow-kickoff` → invoke that skill.
- ordinary-session collaboration or direct implementation → return control to the
  ordinary session and proceed without invoking a workflow skill.
- native `/goal` → use the host's built-in goal mechanism. If the host exposes it
  only as a user command, provide a compact goal statement and ask the user to run
  `/goal`; do not substitute a repository skill or invent a portable loop.

The destination receives the task context from session history. Do not perform
its intake inside this router.

## Success criteria

- [ ] Recommend exactly one thinking route or one terminal execution route.
- [ ] Cite the task-specific evidence that drove the recommendation.
- [ ] If recommending autonomy, name `exec-plan` or native `/goal` in the same
  recommendation.
- [ ] Consider ordinary-session collaboration for work that needs dialogue but
  not durable workflow gates.
- [ ] Ask a routing question only when a consequential tie remains, and name the
  consequence that separates the tied routes.

## Anti-patterns

- Do not treat every unclear goal as inception. Distinguish unclear communication,
  an unformed concept, and an untested candidate direction.
- Do not use dig to shape a concept or grill-me to discover what proposition the
  user might mean.
- Do not present any thinking route alongside execution modes.
- Do not force every executable task through a human-gated-versus-autonomous
  questionnaire; conversational in-session work is a first-class route.
- Do not ask a second autonomous-mode question after recommending autonomy;
  recommend `exec-plan` or native `/goal` from the planning horizon.
- Do not choose a route solely from issue-content/skill similarity; apply the
  judgment, contract, reversibility, and horizon criteria.
- Do not send a user who selected human gates through another autonomous-fit
  assessment in kickoff.
- Do not equate "has tests" with "must be autonomous"; control preference comes
  first.
- Do not run a requirements interview or implementation inside this skill.
- Do not hide a consequential routing assumption; state the recommendation and
  its reason before handing off.
