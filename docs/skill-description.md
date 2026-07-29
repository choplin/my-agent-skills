---
title: "Writing Skill Descriptions"
date: 2026-07-29
---

# Writing Skill Descriptions

A `description` does two jobs that pull against each other. It is preloaded at
startup so the model can decide whether the skill applies, and it is
documentation for someone picking a skill by name. The first job costs context
for every skill in every session, and it is only worth paying for when the model
actually has to make that choice from context.

Which job a given description has is a recorded fact, not a judgement made while
writing. Section 1 is how it is recorded and decided; sections 2–4 are how to
write to it.

## 1. The two invocation settings

| Setting | Question | Values |
|---|---|---|
| `user-invocable` | Does the user start it by typing `/name`? | omit for yes, `false` for no |
| `metadata.description-role` | Does the description have to make the model choose the skill? | `trigger` / `documentation` |

**They are independent.** Every combination occurs, and neither value may be
inferred from the other. A skill nobody types can still need to be found from
context; a skill the user types constantly can also be reached by a caller that
supplies the decision. Answer the two questions separately.

`user-invocable` is a Claude Code frontmatter field, so it is written there
directly. `description-role` has no field of its own, which is why it goes in
`metadata` — the free key/value map the Agent Skills specification provides. It
is also the one of the two that means the same thing on any agent that preloads
descriptions.

### Deciding `user-invocable`

Not *could* the user type `/name` — whether a real situation exists where they
do. Whether the skill would technically function standalone is a different
question and does not settle this one.

**No → `user-invocable: false`.**

This is a fact about how the repository is actually used, so it is the owner's
call rather than something to infer from the skill's own text.

### Deciding `description-role`

Does the model have to recognize, from the description alone, that this skill
applies?

**Yes → `description-role: trigger`.** Nothing else supplies the decision. The
description carries the full weight of being found.

**No → `description-role: documentation`.** Something else supplies it: another
skill's body names this skill as a step in its own procedure, or a standing
instruction in `CLAUDE.md` / `AGENTS.md` does, or the user types `/name`. A
skill reached that way gains nothing from trigger keywords and should not spend
its description on them.

A skill can have a caller *and* a genuine need for context discovery. If the
caller is not the only path in, the trigger still has to work.

To tell a real caller from a mention, ask **whose move it is** at that point:

- the caller finishes its own procedure and hands the user a suggestion → the
  user's move, not a caller
- running the skill is a step inside the caller's procedure, even one gated on
  approval → the model's move, a caller

The verb does not decide it. "Propose X" inside a flow that then continues into
X is a call; the same word in a closing message that ends the caller's work is
not.

Upstream has no equivalent of this setting: it assumes every skill must be
discovered from context, and optimizes against **under**triggering. That
assumption does not hold here, because most skills are reached another way.

### Model invocation stays open

There is a third field, `disable-model-invocation: true`, which blocks the model
from starting a skill. Per the
[Claude Code docs](https://code.claude.com/docs/en/skills): *"The
`user-invocable` field only controls menu visibility, not Skill tool access. Use
`disable-model-invocation: true` to block programmatic invocation."*

**This repository does not set it.** The model may start any skill.

The two failure modes are not symmetric. Blocking fails **silently**: a caller's
body, or a standing instruction in `CLAUDE.md` or `AGENTS.md`, names the skill
and simply cannot reach it, and nothing reports that. Allowing costs only that
the model may pick a skill up on its own, which is rarely harmful. A skill that
genuinely must not run without the user is stopped by a `Skill(name)` deny rule
in permissions, where the block is explicit and lives with the other
permissions.

`description-role` is no part of that. It is a `metadata` record: no harness
reads it, and it blocks nothing. A description written as documentation is
simply less likely to match a situation, because it was not written to.

Side effects are not a reason to reach for it. `git-helpers-commit` has side
effects, but `AGENTS.md` requires the model to invoke it; blocking it would
break that rule.

One consequence matters for writing: **every description stays in context**, for
every skill, in every session. `description-role: documentation` therefore means
*shorter*, not *free*.

## 2. What makes a description good

This layer is not local policy. It is the upstream
[skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices),
restated because everything below assumes it.

**Say what the skill does and when to use it.** Both halves. "Extract text and
tables from PDF files, fill forms, merge documents" is the first half; "Use when
working with PDF files or when the user mentions PDFs, forms, or document
extraction" is the second. A description with only the first half cannot be
selected reliably.

**Write in the third person.** The description is injected into the system
prompt, and a shifting point of view causes discovery problems.

> **Good:** "Processes Excel files and generates reports"
> **Avoid:** "I can help you process Excel files" / "You can use this to process Excel files"

**Be specific and include key terms.** The description is how a skill is picked
out of a hundred others. `Helps with documents`, `Processes data`, and `Does
stuff with files` identify nothing.

**Be concise.** Every skill's description sits in the same context window as the
system prompt, the conversation, and every other skill's metadata. The limit is
1,024 characters, but the limit is not a target.

**Iterate from observed behavior, not from imagination.** Upstream's whole
method is to watch a skill fail on a real task and fix what actually failed.
Writing for confusions you have merely imagined is how descriptions grow without
getting better.

## 3. What this repository adds

Local circumstances change how the above is applied.

### A skill stands on its own — a description never redirects

A description states what *this* skill is. It does not route the reader
anywhere: no "use `other-skill` instead", no "for X, use Y", no "unlike
`other-skill`".

Two reasons, and either one is sufficient.

**The reference does not survive distribution.** Skills here are installed
individually through the `skills` CLI, so naming a sibling assumes it is
installed alongside this one. That assumption does not hold, and it has already
broken: `git-helpers-explain-pr` points at `understanding-explain-diff`, and
`skill-quality-review` points at `skill-creator` — neither exists in this
repository.

**A redirect is not information about this skill.** The reader arrived to find
out what this skill covers. Handing them a different name defers that answer and
spends the one field with a hard limit on someone else's job.

State the boundary in terms of the work instead of the neighbour: say what this
skill does and does not cover, not who covers the rest.

### Workflow membership is stated, not routed

Upstream treats a skill as a self-contained capability, and provides no
mechanism for chaining one into another. This repository composes skills into
workflows anyway — orchestrators, phase skills, base skills — precisely because
nothing else supplies that mechanism. That is a deliberate local departure.

It does not license descriptions to route. A skill inside a workflow states
**that it is a part**, in general terms — a phase of a session, a step in a
review flow, the shared resources a family builds on — and stops there. Which
skill calls it, which one it hands to, and what runs before or after are
relationships between skills, and they belong in the body, where they are read
only when the skill actually runs.

> **Good:** "The convergence phase of an inception run — synthesizes a resolved
> graph into a coherent footing."
> **Avoid:** "Invoked by `inception` after `inception-deepen`; hands off to
> `inception-finalize`."

### Say what the skill is for, not what it is not

Avoid `This is NOT for …`, `Should NOT be used for …`, and their variants. They
read as design, but they are guesswork about confusions that may never happen,
and each one spends characters the positive description needs. A reader — human
or model — matches on what is present, not on what has been ruled out.

When a boundary genuinely has to be drawn, draw it inside the positive
statement: name the work this skill covers precisely enough that the neighbouring
work is visibly outside it. The one sanctioned exception is a skill with
`description-role: trigger` and an *observed* mistrigger — see
[§4](#4-writing-to-description-role).

### Descriptions are written in English

One language, regardless of what the user types in conversation and regardless
of the skill's subject matter. This is the same rule the rest of the
repository's documentation follows.

### A description is evidence about a skill, not authority over it

Twice a description here has asserted an entry point its author never intended,
and reading it as fact produced the wrong answer:

- `linear-base` describes itself as "the agent's home for ad-hoc issue work",
  though it is the conventions the other `linear` skills build on.
- `inception-finalize` says it is "also usable directly", though it is the
  terminal step of an inception run.

Both are `user-invocable: false`. They part on the other setting, which is what
makes the point: `linear-base` is `trigger`, because its conventions have to
apply whenever Linear work starts, whether or not anyone names it;
`inception-finalize` is `documentation`, because an inception run is the only
thing that reaches it. Neither setting follows from the other, and neither
follows from what the description happens to claim.

Settle both from how the skill is actually meant to be reached, then fix the
description to match — never the other way round.

## 4. Writing to `description-role`

### `description-role: trigger`

The description has to make the model recognize the situation on its own.
Nothing else will, so this is where the full weight of section 2 applies.

**Write in the positive.** State what the skill is for and the situations it
applies to. The model matches on what is there, not on what is ruled out.

**Include the way the request actually gets phrased**, in English (see above).
These are the strings being matched against, and they are worth more than a
carefully abstracted summary.

**Add an exclusion only after observing a real mistrigger.** A `Should NOT
trigger for …` clause is a correction, not a design step. Written up front it
guesses at confusions that may never occur, while spending characters the
positive description needs. This is also the only use upstream sanctions for it.
Even then, describe the situation that must not match — not the skill that
should have won it.

### `description-role: documentation`

Nobody finds this skill by matching its description. Write it as documentation:
what the skill produces, what it needs, where it fits. Drop the trigger
phrasings and the exclusions alike — with no matching to correct, an exclusion
has nothing left to do.

**Shorter, not free.** The description sits in context in every session exactly
like a trigger does, without doing a trigger's work, so whatever it does not
need to say is pure cost. Anything a reader wants beyond identifying the skill
belongs in the body, which is read only when the skill runs.

### The budget is shared

A description is capped at 1,024 characters by the specification, and the
listing that holds every skill's description has a budget of its own. When it
overflows, descriptions get dropped — so an overlong description does not only
cost itself. It can cost a *different* skill its trigger.
