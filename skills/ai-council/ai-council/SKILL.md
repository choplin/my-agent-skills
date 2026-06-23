---
name: ai-council
description: This skill should be used when the user wants to gather opinions from multiple AI systems (Claude, Gemini, Codex) for better decision-making. Triggers on "AI council", "ask the council", "multiple AI opinions", "different AI perspectives", "council discussion", "consult all AIs", "what do all AIs think". Should NOT trigger for single-AI consultation (use individual advisor agents instead), CLI syntax questions, or troubleshooting AI CLI errors.
---

# AI Council Skill

Gather opinions from multiple AI systems (Claude, Gemini, Codex) to get diverse perspectives on technical decisions.

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

### Step 2: Gather Opinions in Parallel

Launch three Task tool calls simultaneously with the following agents:
- `ai-council-claude-advisor` - Claude's perspective (direct analysis)
- `ai-council-gemini-advisor` - Gemini's perspective (via Gemini CLI)
- `ai-council-codex-advisor` - Codex's perspective (via Codex CLI)

**Important**: Use `run_in_background: true` for ai-council-gemini-advisor and ai-council-codex-advisor to allow parallel execution. Claude-advisor can run in foreground.

Provide each agent with:
- The same clear question
- Relevant file paths to analyze
- Specific aspects to focus on

### Step 3: Synthesize and Report

After collecting all three opinions, create a unified report using this process:

1. **Extract consensus**: Identify points where 2 or more AIs agree
   - Strong consensus: All 3 AIs agree
   - Majority consensus: 2 AIs agree

2. **Document divergence**: When AIs disagree, present each view fairly
   - State each AI's position clearly
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

#### Claude (Anthropic)
{Summary of Claude's key points and recommendations}

#### Gemini (Google)
{Summary of Gemini's key points and recommendations}

#### Codex (OpenAI)
{Summary of Codex's key points and recommendations}

### Analysis

**Consensus Points**
- {Points where all/most AIs agree}

**Divergent Views**
- {Points where AIs disagree, with each perspective noted}

**Key Insights**
- {Unique or particularly valuable observations}

### Recommendation
{Synthesized recommendation based on the collective feedback}
```

## Success Criteria

A complete AI Council consultation includes:
- [ ] Question includes all three elements: (1) specific target, (2) decision context, (3) feedback focus
- [ ] All three AI opinions collected (Claude, Gemini, Codex) - or documented reason if one failed
- [ ] Each opinion section explicitly states the AI source (e.g., "#### Claude (Anthropic)")
- [ ] Consensus analysis explicitly states agreement level: "All 3 AIs agree on..." or "2/3 AIs agree on..."
- [ ] Divergent views section presents each AI's position with its reasoning when disagreements exist
- [ ] Recommendation section: (1) cites specific AI opinions, (2) explains reasoning, (3) notes unresolved disagreements

## Example Prompt for Agents

When calling each advisor agent, use a prompt like:

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
