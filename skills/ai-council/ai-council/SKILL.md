---
name: ai-council
description: >-
  Gathers opinions from several AI systems on one question in a single blind
  pass and reports them side by side. The one-shot member of the ai-council
  group: each panelist answers independently, without seeing the others.
metadata:
  description-role: documentation
---

# AI Council Skill

Gather opinions from several AI systems to get diverse perspectives on technical decisions.

## Why This Skill Exists

Single AI opinions can have blind spots and biases. By consulting multiple AI systems:
- **Reduce bias**: Different training data and approaches lead to different perspectives
- **Find blind spots**: One AI might catch issues others miss
- **Build confidence**: Agreement across AIs strengthens recommendations
- **Discover alternatives**: Different AIs may suggest different valid approaches

## When to Use

**Appropriate scenarios:**
- Important architectural or design decisions
- Critical code change reviews
- Uncertainty about the best approach among alternatives
- Need for comprehensive feedback before committing to a direction

**Not appropriate for:**
- Simple questions with clear answers
- Learning CLI syntax (use individual CLI skills instead)
- Troubleshooting AI tool errors
- Time-critical situations where one opinion suffices

## Execution Process

### Step 1: Clarify the Question

Before consulting the AIs, formulate a question that includes these three elements:

1. **Specific Target**: The exact code/design element to review
   - File path(s) and function/class names
   - Specific design document or architecture diagram
   - Example: "the authentication flow in `src/auth/login.ts:45-120`"

2. **Decision Context**: What choice needs to be made
   - "Choosing between approach A and B"
   - "Evaluating whether this design is appropriate for our scale"
   - Example: "deciding whether to use JWT or session-based auth"

3. **Feedback Focus**: What specific aspects need evaluation
   - Security implications, performance trade-offs, maintainability
   - Example: "focusing on security vulnerabilities and scalability concerns"

**Why this matters**: Vague questions like "Is this good?" produce generic answers. Specific questions enable AIs to provide targeted, actionable feedback.

### Step 2: Agree the Panel, Then Gather Opinions Blind

**Ask the user which systems to seat, before consulting any of them.** Name the
ones you can reach in this environment and let them confirm, drop, or add. A
roster fixed in this file goes stale the moment a CLI is renamed, a model family
is added, or one of them is missing from the machine — and the failure is quiet:
the report still looks like a council while speaking for fewer members than it
claims.

Seat one panelist per **model family**. Two is the working minimum; a third only
helps if it adds a family, not another voice from one already seated. Usual
candidates:

- **The host model** — reasons directly over the files. Needs a context that has
  **not** seen this conversation; an opinion formed alongside your own is not
  independent evidence.
- **A CLI-backed model** — this group ships the operating constraints for two:
  `ai-council-codex-cli` (`codex`) and `ai-council-fugu-cli` (`codex-fugu`).
  Apply the matching skill when you seat one.
- **Whatever else the user names** — another CLI, another host-side agent.

If a panelist cannot answer — the command is not installed, authentication
fails, the call times out — say which seat is empty and ask whether to proceed
with the rest. Never quietly shrink the panel: the size of the agreement is the
result here.

**Every panelist gets the same brief and none sees another's answer.** That is
what makes agreement mean something here. Give each one the question from Step 1
verbatim, the file paths to read, and the aspects to weigh — nothing about what
any other panelist said or is expected to say.

**Dispatch.** If the host can run isolated subagents, give each panelist its own,
and run the CLI-backed ones concurrently — they spend most of their time waiting
on a network call. If it cannot, run them sequentially in this same session,
keeping each panelist's brief and answer separated: state which panelist you are
speaking as, produce only that answer, then move on. Sequential costs wall-clock
but not independence; a panelist that reads a previous answer costs independence,
which is the whole point.

**Bind every panelist to these rules.**

- **Opinion only.** Read and analyze; never modify a file. A consultation that
  edits the tree has exceeded its mandate.
- **Attribution.** Each answer is labeled with the model family that produced it.
  Never merge two panelists' words, and never present the host model's answer as
  another vendor's.
- **Evidence.** Cite the file and line an observation rests on. An assertion with
  nothing behind it is noise in a synthesis.
- **Uncertainty is reportable.** A panelist that cannot judge says so rather than
  producing a confident guess.

Each panelist returns: an overall position (recommend / caution / reject) with
its reasoning, the specific observations behind it, actionable recommendations,
and at least one trade-off or alternative it would not choose.

### Step 3: Synthesize and Report

After collecting every seated panelist's opinion, create a unified report using
this process:

1. **Extract consensus**: Identify points where the panelists agree

2. **Document divergence**: When panelists disagree, present each view fairly
   - State each panelist's position clearly
   - Note the reasoning behind each position
   - Do NOT force a false consensus

3. **Form recommendation**: Based on the collective input
   - Cite which AI opinions support the recommendation
   - Explain why certain opinions were weighted more heavily
   - Note any unresolved disagreements that may need further investigation

## Output Format

```markdown
## AI Council Report: {Topic}

### Question
{The specific question asked to all AIs}

### Opinions

#### {Model family} ({Vendor})
{Summary of this panelist's key points and recommendations}

<!-- one section per seated panelist, in the order they were agreed -->

### Analysis

**Consensus Points**
- {Points where all/most panelists agree}

**Divergent Views**
- {Points where panelists disagree, with each perspective noted}

**Key Insights**
- {Unique or particularly valuable observations}

### Recommendation
{Synthesized recommendation based on the collective feedback}
```

## Success Criteria

A complete AI Council consultation includes:
- [ ] Question includes all three elements: (1) specific target, (2) decision context, (3) feedback focus
- [ ] The panel was agreed with the user before any panelist was consulted
- [ ] Every seated panelist's opinion collected — or a stated reason for each empty seat
- [ ] Each opinion section names the model family and vendor that produced it
- [ ] Consensus analysis explicitly states whether the panelists agree or diverge
- [ ] Divergent views section presents each panelist's position with its reasoning when disagreements exist
- [ ] Recommendation section: (1) cites specific panelists' opinions, (2) explains reasoning, (3) notes unresolved disagreements

## Example Brief for a Panelist

Give each panelist a brief of this shape:

```
Please analyze the {topic} and provide your opinion on:
1. {Specific aspect 1}
2. {Specific aspect 2}

Relevant files to review:
- {file path 1}
- {file path 2}

Context: {Brief context about the decision}
```

## Notes

- If one AI times out or fails, report the available opinions and note the missing one
- Attribution is critical - never mix up which AI said what
- If AIs strongly disagree, present both sides without forcing a false consensus
