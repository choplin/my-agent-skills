---
name: skill-quality-standard
description: >-
  Defines a role-aware qualitative standard for agent skills: classify what a
  skill contributes, preserve model judgment where the work is interpretive,
  specify only necessary workflow boundaries, and use scripts or mechanical
  validation only for genuinely deterministic operations. Applies when
  authoring, reviewing, or improving skill content.
metadata:
  description-role: trigger
---

# Skill quality standard

Use this as the canonical qualitative definition of a good skill. A skill is
guidance interpreted by a capable model, not a program that guarantees one
behavior. Its job is to contribute information or control the model needs while
leaving the rest to the model's reasoning.

Start by identifying what the skill contributes. Do not apply one content shape
to every skill.

## 1. Classify before prescribing

First identify which sources of value apply:

| Value source | Question |
|--------------|----------|
| **Capability uplift** | What does this help the model do that it otherwise cannot do, or cannot do consistently? |
| **Encoded intent** | What chosen practice, constraint, sequence, or organizational context does this supply for work the model can already perform? |

These sources are non-exclusive. A capability uplift may become redundant as
models improve; encoded intent remains useful only while it faithfully expresses
what its users want or require.

- Review a capability uplift by asking what useful ability or consistency it
  adds beyond the base model. Simplify or remove it when that uplift disappears.
- Review encoded intent by asking whether it faithfully communicates the
  intended practice or constraint. Do not judge it by whether that intent is
  universally superior.

Identify the skill's primary role:

| Role | Contribution | Typical content |
|------|--------------|-----------------|
| **Guidance** | Gives a direction, norm, lens, or body of domain judgment | principles, rationale, boundaries, representative examples |
| **Workflow** | Coordinates work whose order or handoffs matter | stages, decisions, handoff contracts, stop conditions |
| **Task** | Performs a task or produces an artifact | task-specific knowledge, tools, inputs, outputs |

This is a lens, not a required metadata field or an exclusive taxonomy. A skill
may combine roles. Classify each substantial part by the kind of control it
needs:

| Nature of the work | Give the model | Appropriate control |
|--------------------|----------------|---------------------|
| **Interpretive** | direction, relevant considerations, trade-offs, boundaries | high freedom; the model judges in context |
| **Coordinated** | necessary order, decisions, handoffs, invariants | constrain the spine; leave individual steps flexible |
| **Deterministic** | exact operation, inputs, outputs, failure behavior | scripts, schemas, commands, and mechanical checks may be appropriate |

Separately classify each relevant property of the result as **qualitatively
reviewable**, **mechanically checkable**, or both. One deliverable may combine
them: schema compliance can be mechanical while usefulness remains qualitative.
A clear purpose does not imply a binary success criterion. Call a property
mechanically checkable only when it can be evaluated reproducibly without model
judgment.

Use the least control that preserves the task's real requirements. Do not turn
this classification into another schema, score, or decision tree that claims to
settle contextual judgment mechanically.

Read `references/skill-types.md` when the value source or role is unclear, or
when reviewing the coverage and boundaries of a larger skill library. Its domain
categories are examples for discovery, not required labels.

## 2. Apply the common standard

These requirements apply to every role.

### Be loadable

Run the mechanical preflight before reviewing content:

```sh
skill-quality-standard/scripts/lint-frontmatter.sh <skill-path>
```

Exit 0 means this lightweight lint found none of the common frontmatter traps it
checks; it is not a complete YAML parse. Exit 1 identifies a likely
load-blocking format problem to fix before applying the qualitative standard.
Use the repository's real YAML parser when available, especially before claiming
that frontmatter is loadable.

### Spend context wisely

- Add what the model lacks: domain facts, current constraints, non-obvious
  judgment, tool contracts, and real gotchas. Omit general knowledge.
- Keep one coherent contribution. A skill can combine roles when they serve the
  same task, but unrelated capabilities belong elsewhere.
- Prefer deletion, merging, and generalization over another case-specific rule.
  More encoded detail is not inherently more reliable.
- Keep only material that changes action or judgment. Remove design history,
  speculative exceptions, duplicated guidance, and unused contract data.

Ask of each passage: *What useful decision or action becomes possible because
the model read this?* If there is no concrete answer, cut it.

### State the current direction directly

Describe the desired action, direction, boundary, or contract. Do not make the
model reconstruct it from rejected alternatives or former behavior. Preserve
negative wording when it expresses a present safety boundary or invariant, not
merely design history.

### Make the result reviewable at the right level

State what the skill is meant to help the model accomplish. Match the account of
success to the work:

- For interpretive work, give enough direction and considerations for a model or
  human to explain why the result fits the context. Do not imply a unique correct
  answer.
- For coordinated work, make the required handoffs and preserved invariants
  visible.
- For deterministic work, state the observable input/output contract and valid
  failure behavior.

Reviewability is not a guarantee. Do not invent measurable criteria merely to
make qualitative work look objective.

## 3. Apply only the relevant role guidance

### Guidance: orient judgment

A guidance or normative skill should shape reasoning without replacing it.

- State the direction, scope, and important considerations.
- Explain the reason behind a non-obvious principle so the model can handle cases
  the text does not enumerate.
- Use examples to reveal judgment, not to define an exhaustive case table.
- Prefer a small set of generative principles over detailed rules that encode one
  author's interpretation of every edge case.
- Let the model resolve tensions in context. Name a hard boundary only when the
  work truly has one.

Qualities such as clarity, usefulness, taste, coherence, or sound judgment stay
qualitative. Review them with model or human judgment and make uncertainty
visible.

### Workflow: constrain the spine

A workflow skill should prescribe only the coordination that makes it a
workflow.

- Define each substantial stage around its own task and the minimum handoff its
  consumers need. The orchestrator owns ordering, transitions, and invariants
  across stages. A stage should normally depend only on its task inputs and any
  shared base guidance, without needing to know its caller or neighboring
  stages. Keep workflow-specific coupling only when a real dependency requires
  it; do not turn qualitative handoffs into schemas or mechanical validation
  merely to enforce this separation.
- Keep shared domain knowledge and machinery separate from orchestration so each
  stage remains independently effective. Direct the dependencies accordingly:
  the orchestrator composes the stages, while stages may depend directly on
  shared guidance such as a base skill for a common state model, terminology,
  storage layout, CLI, or other foundation, without depending on the
  orchestrator itself.
- Include an order only where later work depends on earlier work.
- Define handoffs, approval points, invariants, and stop conditions that must be
  shared across stages.
- Leave the method inside a stage to the model when several approaches can work.
- Keep a compact workflow inline. For substantial stages, keep only order and
  handoff contracts in `SKILL.md`; route to one stage reference when that stage
  begins.
- Use a checklist only when persistent progress tracking prevents a real
  coordination failure. A numbered procedure is enough for most short flows.

### Task: separate judgment from machinery

A task skill often mixes interpretive choices with deterministic
operations. Treat them separately.

- Give the model task-specific knowledge and a clear default where choosing among
  tools is incidental to the task.
- Keep context-dependent planning and adaptation as guidance.
- Use a script when the operation itself is repeatable, has a stable input/output
  contract, or is fragile enough that textual reimplementation creates needless
  variance.
- Use schemas and mechanical validators at actual machine or external-contract
  boundaries. Do not introduce structured intermediates solely to constrain the
  model's reasoning.
- Keep safety-critical and destructive operations explicit even when the rest of
  the task allows freedom.

## 4. Place content where it earns its load cost

Use progressive disclosure according to relevance, not file size alone:

| Layer | Content |
|-------|---------|
| `description` | What the skill contributes and the context needed for its recorded trigger or documentation role |
| `SKILL.md` | The direction, shared workflow spine, essential constraints, gotchas, and routing decisions needed whenever the skill runs |
| `references/` | Domain, variant, or stage detail loaded only when a named decision or step requires it |
| `scripts/` | Deterministic operations executed without reproducing their logic in context |
| `assets/` | Materials copied or transformed into the deliverable |

Name each reference from `SKILL.md` at the point where it becomes relevant. Do
not duplicate its contents in the body, eagerly load all references, or create a
reference whose routing text costs more than the detail it contains.

Keep a gotcha in `SKILL.md` when the model must know it before it could recognize
the condition that makes it relevant.

## 5. Write the description to its actual role

A description may trigger the skill from the user's intent or document a skill
selected by a caller. Determine which role is recorded before judging it.

- A trigger description states the positive intent the skill serves, using the
  language in which that need appears.
- A documentation description identifies the contribution, inputs, or place in a
  larger flow without pretending to perform discovery.
- Neither redirects to sibling skills or catalogs excluded work.
- Both stay concise because descriptions share the global context budget.

Read `references/writing-descriptions.md` when writing or reviewing a
description.

## 6. Select structures after classification

Read `references/instruction-patterns.md` only when the classification above
shows that a concrete structure may help. Read `references/anti-patterns.md` when
reviewing for excess or misplaced control. Read
`references/agentskills-best-practices.md` only when these condensed rules leave
an authoring question unresolved.

The available structures are not a checklist. The absence of a template,
checklist, schema, script, or validation loop is not a defect unless the task's
actual coordination or deterministic boundary needs it.

## Review rule

First classify the skill and its substantial parts. Apply the common standard,
then only the relevant role guidance. When two designs communicate the same
direction and preserve the same real constraints, prefer the simpler one and
leave the remaining judgment to the model.
