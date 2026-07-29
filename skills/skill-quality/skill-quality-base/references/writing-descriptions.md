# Writing Descriptions

How to write the `description` of a skill, and how to judge one. Loaded from
rubric item B4.

## A description does one of two jobs

It is preloaded at startup so the model can decide whether the skill applies,
and it is documentation for someone picking a skill by name. The first job costs
context for every skill in every session, and it is only worth paying for when
the model actually has to make that choice from context.

Which job a given description has is a fact about how the skill is reached, not
a matter of taste. Some repositories record it as `metadata.description-role`,
with the values `trigger` and `documentation`; when that key is present, take it
as given and score the description against the job it names.

When it is absent, work the role out first:

**Does the model have to recognize, from the description alone, that this skill
applies?**

- **Yes — the description is a trigger.** Nothing else supplies the decision, so
  it carries the full weight of being found.
- **No — the description is documentation.** Something else supplies it: another
  skill's body names this skill as a step in its own procedure, a standing
  instruction in a `CLAUDE.md` / `AGENTS.md` does, or the user types its name.

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

## What makes any description good

Upstream
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

**Iterate from observed behavior, not from imagination.** Watch a skill fail on
a real task and fix what actually failed. Writing for confusions you have merely
imagined is how descriptions grow without getting better.

## A skill stands on its own — a description never redirects

A description states what *this* skill is. It does not route the reader
anywhere: no "use `other-skill` instead", no "for X, use Y", no "unlike
`other-skill`".

Two reasons, and either one is sufficient.

**The reference does not survive distribution.** Skills are installed one at a
time, so naming another skill assumes it is installed alongside this one. That
assumption breaks quietly: the neighbour gets renamed, moves to another
repository, or turns out to exist only inside one particular agent, and the
description keeps pointing at it.

A genuine cross-skill dependency is a different thing, and belongs in the body
where it can be stated as a prerequisite and checked at run time.

**A redirect is not information about this skill.** The reader arrived to find
out what this skill covers. Handing them a different name defers that answer and
spends the one field with a hard limit on someone else's job.

State the boundary in terms of the work instead of the neighbour: say what this
skill does and does not cover, not who covers the rest.

## Workflow membership is stated, not routed

A skill that is part of a larger flow — an orchestrator, a phase, a shared base
— states **that it is a part**, in general terms: a phase of a session, a step
in a review flow, the shared resources a family builds on. Which skill calls it,
which one it hands to, and what runs before or after are relationships between
skills, and they belong in the body, where they are read only when the skill
actually runs.

> **Good:** "The convergence phase of an inception run — synthesizes a resolved
> graph into a coherent footing."
> **Avoid:** "Invoked by `inception` after `inception-deepen`; hands off to
> `inception-finalize`."

## Say what the skill is for, not what it is not

Avoid `This is NOT for …`, `Should NOT be used for …`, and their variants. They
read as design, but they are guesswork about confusions that may never happen,
and each one spends characters the positive description needs. A reader — human
or model — matches on what is present, not on what has been ruled out.

When a boundary genuinely has to be drawn, draw it inside the positive
statement: name the work this skill covers precisely enough that the
neighbouring work is visibly outside it.

## Writing a trigger

The description has to make the model recognize the situation on its own, so
this is where the full weight of the section above applies.

**Write in the positive.** State what the skill is for and the situations it
applies to. The model matches on what is there, not on what is ruled out.

**Include the way the request actually gets phrased.** These are the strings
being matched against, and they are worth more than a carefully abstracted
summary.

**Add an exclusion only after observing a real mistrigger.** A `Should NOT
trigger for …` clause is a correction, not a design step. Written up front it
guesses at confusions that may never occur, while spending characters the
positive description needs. Even then, describe the situation that must not
match — not the skill that should have won it.

## Writing documentation

Nobody finds this skill by matching its description. Write what the skill
produces, what it needs, and where it fits. Drop the trigger phrasings and the
exclusions alike — with no matching to correct, an exclusion has nothing left to
do.

**Shorter, not free.** Unless the harness is told to keep the skill out of the
model's reach entirely, the description sits in context in every session exactly
like a trigger does, without doing a trigger's work, so whatever it does not
need to say is pure cost. Anything a reader wants beyond identifying the skill
belongs in the body, which is read only when the skill runs.

## The budget is shared

A description is capped at 1,024 characters by the specification, and the
listing that holds every skill's description has a budget of its own. When it
overflows, descriptions get dropped — so an overlong description does not only
cost itself. It can cost a *different* skill its trigger.
