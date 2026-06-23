---
name: discuss-toolkit-dig
description: This skill should be used when the user's intent is unclear and needs to be clarified before proceeding. Triggers when user request lacks specifics (e.g., "create X" without details), when AI would need to make assumptions to proceed, or when user explicitly calls "/dig". Also used as a base skill by other skills. Should NOT trigger for quick decisions with clear context (use quick-chat), or when requirements are already well-defined. 「意図が不明確」「曖昧な依頼」「詳細を確認したい」
user-invocable: true
---

# dig - Intent Clarification

Dig deep to understand user intent before proceeding. Never fill gaps with assumptions.

## Why This Skill Exists

AI tends to fill unclear intent with general best practices. This produces outputs that don't reflect the user's actual context and fail to solve real problems. This skill ensures AI understands user intent through structured interview before acting.

## Invocation Patterns

dig can be invoked in three ways:

### 1. AI Autonomous Invocation (Primary)

When AI detects that user's request lacks specifics needed to proceed:
- "Create a login feature" → What authentication method? What fields? What happens on failure?
- "Improve performance" → Which part? What's the current bottleneck? What's acceptable?

**When to invoke**: AI would need to make assumptions to fill gaps in user's request.

### 2. Base Skill for Other Skills

Specialized skills call dig to ensure intent clarity before their work:
- name-project calls dig to understand project goals → proceeds to generate names
- skill-authoring calls dig to extract experiential rationale → proceeds to write skill content

### 3. Direct User Invocation

User explicitly calls `/dig` when they want structured clarification.

**Key implication**:
The "never fill gaps with assumptions" principle applies to the entire workflow—
both the clarification process AND any content created based on the result.
If certain information remains unclarified, it must not be filled with general practices.

## Interview Structure: Axes and Subject

dig provides three **axes** (perspectives) to clarify intent:
1. **Intent & Motivation** - WHY is this needed?
2. **Use Cases & Edge Cases** - HOW will it be used concretely?
3. **Constraints & Priorities** - WHAT limits exist, what matters most?

The **subject** (what to clarify) comes from the caller's context.

**How axes and subject work together**:
- Caller specifies the subject and context (what needs to be clarified and why)
- dig dynamically constructs questions based on user responses and the provided context
- Each axis is applied as needed to explore different aspects of the subject

**Important**: Callers provide the **purpose and context** (e.g., "need to understand experiential rationale, success criteria, and trigger conditions"), NOT specific questions to ask. dig determines the actual questions dynamically based on how the conversation unfolds.

**Example**:
```
Caller context: "Creating a skill for code review"
Subject: "code review skill requirements"
Context: Need to understand experiential rationale (lessons from past failures),
         binary success criteria, and intent-based triggers

dig dynamically explores through axes:
- Intent & Motivation → Why do you need a code review skill? What problem does it solve?
- (Based on response) → When did code reviews fail in the past? What happened?
- Use Cases & Edge Cases → Walk through a concrete code review scenario.
- (Based on response) → What's a borderline case where you're unsure if this skill should trigger?
- Constraints & Priorities → What trade-offs would you accept?

Questions adapt based on user responses - not predetermined from caller's context.
```

## Core Rule: Never Assume, Always Ask

When information is missing:
1. Do NOT fill with assumptions or general practices
2. Do NOT proceed with guesses
3. DO ask using AskUserQuestion tool

When making hypotheses based on general knowledge:
1. Present as hypothesis: "Generally X applies, but for your case..."
2. Explicitly ask for confirmation
3. Never use unconfirmed hypotheses in final understanding

## Interview Process

### Phase 1: Initial Assessment

Identify what's unclear in user's request:
- What is the goal?
- Why do they want this?
- What constraints exist?

### Phase 2: Deep Interview

**Critical**: Continue until quality indicators in Phase 3 are satisfied. No upper limit on questions.

Use AskUserQuestion tool repeatedly. **AI decides when to move to Phase 3** by self-evaluating quality indicators after each answer. User can say "done" or "complete" to end early (because prolonged questioning may frustrate users who already know their intent), but the default is AI-driven progression.

**Interview Rounds**:

1. **Intent & Motivation**
   - "Why do you need this?"
   - "What happens if you don't have it?"
   - Follow up until you can state the underlying need with specific criteria
     (not "user wants good performance" but "user needs <5s response time")

2. **Use Cases & Edge Cases**
   - "Walk me through a specific example"
   - "What's a borderline case?"
   - "What would failure look like?"
   - Follow up until you have a specific example with concrete inputs and outputs

3. **Constraints & Priorities**
   - "What trade-offs would you accept?"
   - "What must be avoided?"
   - "What's the minimum viable outcome?"
   - Follow up until decision criteria are clear

**Follow-up Question Patterns**:
- "Why?" - uncover motivation
- "For example?" - convert abstract to concrete
- "What else did you consider?" - reveal trade-offs
- "When did this fail before?" - extract lessons learned
- Present hypothesis for confirmation - validate assumptions

### Phase 3: Confirmation

**AI initiates this phase** once quality indicators are likely satisfied. Do NOT ask the user "Do you have anything else to clarify?" or wait for user to signal completion. The user's role is to confirm accuracy, not to decide when AI is done asking.

Before presenting the summary, verify quality indicators:

- [ ] **Motivation documented**: Summary includes user's answer to "why is this important?"
- [ ] **Examples collected**: Summary contains at least one example with specific inputs/outputs
- [ ] **Action determined**: Summary ends with "Next step: [specific action]"
- [ ] **Verification complete**: Every claim in summary was either stated by user or explicitly confirmed by user

Present understanding summary to user and get explicit confirmation ("correct", "yes", "approved" - not "maybe" or "I think so").

**Anti-patterns to avoid**:
- "Is there anything else you'd like to clarify?" - Incorrectly delegates completion decision to user
- "Do you have more questions?" - Same issue
- Waiting for user to say "that's all" before moving to summary - AI should proactively move forward

### Phase 4: Completion

Return results in format requested by caller:
- If called by specialized skill: format they need
- If called directly: verbal confirmation in session

## Success Criteria

The intent clarification deliverable is complete when:
- [ ] User explicitly confirms understanding with "correct", "yes", or "approved" (not "maybe" or "I think so")
- [ ] Every statement in summary can be traced to a specific user answer in the conversation
- [ ] Summary contains zero adjectives (appropriate, proper, good, clean, etc.) without accompanying measurable criteria
- [ ] Summary includes at least one concrete example provided by the user
- [ ] Summary states the user's underlying motivation in user's own words or confirmed paraphrase

## When NOT to Use

- Quick decisions with obvious context → use quick-chat
- Requirements already documented and clear
- User explicitly wants fast action without discussion

