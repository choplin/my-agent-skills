---
name: discuss-toolkit-dig
description: This skill should be used when the user's intent is unclear, when their thinking would benefit from guided exploration, or when they explicitly call "/dig". It maintains a whole-discussion map while asking questions that clarify, broaden, test, or converge the user's thinking. Also used as a base skill by other skills before consequential work. Should NOT trigger for quick decisions with clear context, or when requirements are already well-defined. 「意図が不明確」「曖昧な依頼」「発想を広げたい」「詳細を確認したい」
metadata:
  description-role: trigger
---

# dig - Guided Exploration

Clarify or expand the user's thinking while keeping sight of the whole
discussion. Treat questions as moves in that discussion, not items in an
interview checklist.

## Why This Skill Exists

AI tends to fill unclear intent with general practices or to ask stock questions
without knowing how the answers will affect the discussion. The first behavior
loses the user's context; the second creates interrogation without progress. dig
maintains a provisional map of the discussion and asks only questions that can
meaningfully update it.

## Invocation Patterns

dig can be invoked in three ways:

### 1. AI Autonomous Invocation (Primary)

When AI detects that user's request lacks specifics needed to proceed:
- "Create a login feature" → What authentication method? What fields? What happens on failure?
- "Improve performance" → Which part? What's the current bottleneck? What's acceptable?

**When to invoke**: AI would need to make a material assumption to proceed.

### 2. Base Skill for Other Skills

Specialized skills call dig to ensure intent clarity before their work:
- inception and exec-plan call dig to clarify the goal before shaping or planning

### 3. Direct User Invocation

User explicitly calls `/dig` when they want to clarify or broaden their
thinking.

**Key implication**:
The caller provides the subject, what it needs to learn, and which later decision
or action this understanding will inform. It does not prescribe the questions.
dig chooses questions from the evolving discussion.

## The Discussion Map

Before asking the first question, build a provisional map from the entire
conversation and the caller's context:

- **Subject and desired movement**: what is being explored, and whether the user
  wants to clarify, broaden, choose, or prepare for action
- **Established ground**: what the user has already stated or confirmed
- **Open areas**: material uncertainties, tensions, and promising branches
- **Downstream consequence**: which decision, artifact, or next step this
  discussion is meant to inform
- **Convergence condition**: what must become clear before further questioning
  stops being useful

Keep this map provisional. Update it after every answer. Do not force the user to
approve every internal update, but surface a short reframe when the map changes
materially, the conversation may be drifting, or several turns have passed
without restating the whole.

## Core Rule: Every Question Must Move the Discussion

Before asking, identify internally:

1. **Target**: the open area or branch in the discussion map
2. **Role**: clarify, diverge, test, choose, or converge
3. **Expected update**: how plausible answers would change the map or the
   downstream decision

If the expected update cannot be named, do not ask the question. In particular,
do not ask merely to cover an axis, fill a summary field, or collect an example.

Prioritize the question with the highest expected effect on the direction of the
discussion. Do not ask about information already established, and do not ask a
question when different answers would lead to the same next step.

When a question could sound generic or disconnected, briefly make its relevance
visible: state which distinction or direction the answer will clarify. Keep this
to a short clause rather than narrating the entire internal map. For example,
instead of only asking "When would you use it?", say that the answer will
distinguish between a pull-based search tool and proactive reminders, then ask
about the intended situation. Avoid empty framing such as "to clarify the
direction"; name the actual alternatives, consequence, or decision area. If
naming alternatives would unduly narrow a divergent discussion, name the
decision area without presenting a closed menu.

## Exploration Lenses

Use these as optional lenses, not mandatory rounds:

- **Intent and motivation**: why this matters and what change the user seeks
- **Possibilities and alternatives**: what other framings, options, or outcomes
  may be worth considering
- **Use and boundaries**: where the idea must work, fail, or distinguish itself
- **Constraints and priorities**: what limits exist and which trade-offs govern
  a choice
- **Consequences**: what a decision enables, prevents, or leaves open

Choose only lenses that can update the current discussion map. It is valid to
stay with one lens or skip several.

## Handling Unknowns and Hypotheses

Do not silently turn missing information into fact.

- Ask about a gap when different answers would materially change the direction,
  output, or risk.
- For a low-impact or reversible gap, state a provisional working assumption or
  leave it unresolved instead of interrupting the discussion.
- Present a useful hypothesis as a possibility and explain which part of the map
  it would change. Ask for confirmation only when proceeding on it would be
  consequential.

### Concrete examples are conditional

Ask for a real example only when it can resolve a named uncertainty—for example,
an abstract term has competing meanings, behavior depends on the situation, or
a boundary must be tested. A hypothetical scenario proposed by the agent can
serve the same purpose.

Do not require the user to recall a past incident when their stated criterion,
a hypothetical case, or direct comparison already supplies the needed
information. When asking for situational detail, make the design or discussion
branch it distinguishes visible. Examples are a means of inquiry, never a
completion condition.

## User-Input Mechanism (host-adaptive)

"Ask" means a real round-trip with the user, never an internal guess. Use the
strongest mechanism the host agent provides:

1. Prefer the host's structured user-input tool when one is available:
   - Claude Code: `AskUserQuestion`
   - Codex: `request_user_input` when the current mode allows it; otherwise ask in the normal assistant reply
   - Other agents: the agent's equivalent confirmation or question tool, if one exists
2. If no structured tool is available, ask one concise question in the assistant reply and wait for the answer.
3. Default to one question. Ask at most three only when they are independent and
   answering them together will not obscure how each updates the discussion.
4. Do not treat tool unavailability as permission to hide a material assumption.
   If a required answer cannot be obtained, state what is blocked.

## Exploration Loop

1. **Map**: form or update the whole discussion map before composing a question.
2. **Choose the move**: decide whether the discussion most needs clarification,
   divergence, testing, choice, or convergence.
3. **Ask**: ask the smallest question that can make that move.
4. **Integrate**: incorporate the answer into the map; do not treat it as an
   isolated field value.
5. **Reorient**: decide again from the updated whole, rather than continuing a
   predetermined sequence of questions.

Continue only while another question has a meaningful expected effect. When the
remaining uncertainty is low-impact, intentionally open, or irrelevant to the
downstream consequence, move to confirmation. The user may also say "done" or
"complete" to end exploration early.

## Confirmation and Completion

AI initiates confirmation when the convergence condition is met. Present a short
understanding summary containing:

- the subject and desired movement
- the conclusions, choices, or possibilities that now shape the direction
- material constraints and intentionally unresolved areas
- the next step, if this discussion feeds one

Ask for explicit confirmation when another skill or consequential action will
rely on the summary. For open-ended exploration with no downstream action,
reflect the current map and let the user continue or stop without manufacturing
a required decision.

Return results in the format requested by the caller:

- If called by specialized skill: format they need
- If called directly: verbal confirmation in session

## Success Criteria

The intent clarification deliverable is complete when:
- [ ] The summary states what the discussion was trying to clarify, broaden, or decide
- [ ] Every conclusion is traceable to the user's input or labeled as provisional
- [ ] Material constraints, tensions, and intentionally open questions are visible
- [ ] Further questions would not materially change the present direction or next step
- [ ] If a caller or consequential action depends on the result, the user explicitly confirmed the summary

## Gotchas

- Do not mistake a list of unanswered topics for a discussion map. The map must
  show why an area matters to the direction of the discussion.
- Do not continue along a promising line merely because the previous answer
  supports a follow-up. Re-evaluate it against the whole map first.
- Do not force convergence when the user's desired movement is divergence.
- Do not make the user supply evidence for a hypothetical possibility before it
  is useful enough to test.

## When NOT to Use

- Quick decisions with obvious context
- Requirements already documented and clear
- User explicitly wants fast action without discussion
