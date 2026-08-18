---
name: document-reader-review
description: >-
  Reviews whether a finished document works on its intended readers, by running
  reader personas over it as independent agents and reporting what each one
  stumbled on, refused to accept, and took away. Judges the substance —
  comprehension, persuasiveness, and where the argument invites challenge — not
  the writing and not whether every claim is true. Returns findings only, never
  edits. Applies when a draft is complete and the question is whether readers
  will follow it, believe it, and be able to act on it.
allowed-tools: Read, Grep, Glob, Task, AskUserQuestion
metadata:
  description-role: trigger
---

# Reader Review

Simulate the document's readers and report what happened to them.

Every other document review in this repository is text-internal or
source-external: it asks whether the document is consistent, readable, or
factually right. This one asks a question that cannot be answered from the text
alone — **does this document work on the person it was written for?** Answering
it requires a reader with a prior state, so the unit of review is a persona, not
a lens.

You are the caller. You select the readers, brief them, and assemble what comes
back. **You do not read the document as a reader yourself** — you have the
author's intent and the whole document at once, which is exactly the state no
persona is allowed to be in.

## The personas

Each is a skill. A persona agent loads its own skill and
`document-reader-base`, and nothing else — that isolation is the design, not an
implementation detail. A reader that has seen another reader's brief starts
noticing what that reader notices, and stops being the reader it was supposed to
simulate.

| Persona skill | The reader | Reads | Checks sources |
|---------------|-----------|-------|----------------|
| `document-reader-newcomer` | Meeting the subject for the first time | sequential | no |
| `document-reader-skeptical-peer` | A colleague who is not convinced | whole | no |
| `document-reader-implementer` | The person who has to build it | sequential | after reading |
| `document-reader-decision-maker` | The person who approves or rejects | whole | no |
| `document-reader-domain-expert` | A practitioner who has done this before | whole | after reading |

Tool grants differ by persona and enforce the reading rules: the personas that
must not look anything up have no tools to look with. Do not hand a persona
agent tools its skill does not grant.

## Responsibility boundary

Own:

- selecting the personas the document has to work on;
- assembling the context briefing, and holding it to what a reader knew before
  the document existed;
- dispatching each persona as an independent agent;
- assembling stumbles, objections, and takeaway models;
- comparing takeaway models against the author's intent, where intent was given.

Do not:

- propose fixes, wording, or additions — that is `document-reader-revise`;
- edit the document;
- verify claims yourself, or verify claims no persona doubted — systematic
  verification is `document-toolkit-fact-check`;
- report writing defects — wording, structure, notation and terminology are
  `document-writing-review` and `-audit`;
- run a persona outside the document's audience;
- resolve disagreement between personas.

## 1. Resolve the inputs

Confirm the document is a concrete file or supplied text, and that it is
complete. This review reads a finished draft; on a partial one every persona
reports the missing half.

**Personas.** Take the caller's selection, or select as below. State which
personas will run, and why, before running them.

Default to `newcomer` + `skeptical-peer`. Between them they cover comprehension
and persuasion, the two families that apply to every document. Then add by what
the document is for:

- a design or implementation document → `implementer`
- a proposal or a recommendation → `decision-maker`
- claims a practitioner could refute → `domain-expert`

Neither default persona checks anything against a source. Where the document
describes a system that exists and being wrong about it would matter, add
`implementer` or `domain-expert` — they are the only route by which a checked
contradiction reaches this review.

Do not run a persona the document is not written for. A persona outside the
audience reports gaps the author was right to leave.

**Author intent** — what the document is meant to make which reader do. Optional.
If given, you hold it: **it is never passed to a persona.** A persona given the
intent stops building a model from the document and starts checking the document
against the intent, which turns the takeaway model into a copy of the intent and
destroys the strongest signal this review produces. Intent is used in step 3 and
nowhere else.

**Context briefing** — project-specific knowledge the intended readers already
have: past decisions, existing system shape, team vocabulary, prior discussion.
Optional; supplied by the caller as text or named files. Never collected
automatically from the repository — whether a reader actually holds a piece of
repository knowledge cannot be determined, and guessing quietly violates the rule
below.

**The briefing must not contain the document's own answers.** Admit a fact only
if it existed before the document was written *and* the intended reader already
had it. Anything failing that test would let a persona fill a gap the document
left, which is the exact defect this review exists to find. State what was
excluded on that ground.

## 2. Dispatch

Run the personas in parallel, each as an independent agent.

Give an agent:

- an instruction to apply its persona skill by name;
- the document — the whole text for a `whole` persona; for a `sequential`
  persona, the reading units in order, withheld until the previous unit's record
  is returned;
- the context briefing, cut to the volume its persona skill specifies. Cut it
  yourself; do not hand over the full briefing and expect the persona to ignore
  the surplus. `newcomer` receives none.

Never give an agent:

- the author's intent;
- your framing of what is wrong with the document, or a passage you suspect;
- another persona's output, or the list of which other personas are running;
- unrelated conversation history.

A persona that returns generic writing advice, or a proposed fix, has not done
the review. Retry once, then report it as unrun rather than counting it as
covered.

## 3. Assemble

Merge what came back. Do not rewrite a persona's reaction into your own words —
the reader's account is the evidence.

**Two personas reacting oppositely to the same passage is a result, not a
conflict.** It means the passage works on one audience and not the other, and
collapsing it hides that. Record both, attributed.

Deduplicate only exact repeats: same anchor, same observation, same cause. Keep
which personas raised each — three readers stumbling in one place is stronger
than one.

Drop observations that restate a definition instead of reporting a reaction, and
observations whose anchor is not in the document.

Where intent was supplied, compare each persona's takeaway model against it.
**Report divergence at the top.** A reader who finished the document and took
away something other than what it meant to say outranks every individual
finding: the findings are the mechanism, this is the outcome.

Route out rather than judging:

- doubts no persona could settle, and every doubt raised by a persona that does
  not check → `document-toolkit-fact-check`;
- stumbles the personas attributed to phrasing → `document-writing-review`.

**A reader review never certifies accuracy.** Even with the checking personas
run, only what somebody doubted was checked. Say so in the report rather than
letting a clean result read as a clean document.

## 4. Report

```yaml
document:
personas_run: []
personas_unrun: []          # with the reason
context_briefing: supplied | none
briefing_exclusions: []     # facts withheld as the document's own answers

takeaway_divergence:        # first, when intent was supplied
  - persona:
    took_away:
    intent:
    divergence: none | partial | opposed

takeaways:                  # every persona, including those that matched
  - persona:
    took_away:
    would_act:
    confidence:

stumbles:
  - persona:
    observation:
    anchor:
    unit:                   # sequential personas
    reaction:
    closed_as: answered-late (<unit>) | never-answered | n/a

objections:
  - persona:
    observation:
    anchor:
    reaction:
    verified: not-checked | holds | contradicted | unsettled
    evidence:               # required when verified is holds or contradicted

disagreements:              # same anchor, opposite reactions
  - anchor:
    reactions: []

verification:
  personas_that_checked: []
  claims_checked: <count>   # only what a reader doubted — never the claims as a whole
  unsettled: <count>

routed_out:
  - anchor:
    to: document-toolkit-fact-check | document-writing-review
    why:
```

State plainly when a persona went unrun, or when the review ran with no context
briefing. Silence about coverage reads as coverage.

## Success criteria

- [ ] No persona received the author's intent, another persona's output, or a
      briefing beyond what its skill specifies.
- [ ] `newcomer`, if run, received no context briefing.
- [ ] Every sequential persona was fed units in order, and every carried question
      came back closed as `answered-late` or `never-answered`.
- [ ] Every briefing item predates the document and was already held by the
      intended reader; excluded items are listed.
- [ ] Every observation carries an anchor found in the document.
- [ ] Every `holds` or `contradicted` verdict carries its evidence.
- [ ] Disagreements between personas are reported as disagreements, not resolved.
- [ ] The report states that only doubted statements were checked.
- [ ] The report contains no fix, no wording proposal, and no edit.
