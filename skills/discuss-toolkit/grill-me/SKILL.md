---
name: grill-me
description: >-
  Interviews the user relentlessly to stress-test a plan, design, decision, or
  idea until both sides share the same understanding. Challenges assumptions
  and looks for holes rather than clarifying intent, and needs an identifiable
  thing to challenge before it starts.
metadata:
  description-role: documentation
---

# Grill Me

## Gate

Identify the plan, design, decision, idea, or other proposition the user wants
challenged. A rough statement is enough; its motivation, constraints, and
details may remain open for the grilling session.

If the test object cannot be identified without guessing what the user means,
invoke `discuss-toolkit-dig` only until one is confirmed. Then return here. Do
not require a complete specification before grilling.

## Grilling

Interview me relentlessly about every aspect of this until we reach a shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering. If a *fact* can be found by exploring the environment (filesystem, tools, etc.), look it up rather than asking me. The *decisions*, though, are mine — put each one to me and wait for my answer. Do not act on it until I confirm we have reached a shared understanding.

## Local stopping rule

Prioritize branches that could materially change or invalidate the direction.
Stop when only low-impact details remain or when the user ends the session.

## Position in discuss-toolkit

- `discuss-toolkit-dig` improves **fidelity**: clarify what the user means.
- `grill-me` improves **robustness**: challenge whether a candidate direction
  holds.
- `discuss-toolkit-one-point` improves **pacing**: keep multiple discussion
  points navigable.

Route by the desired outcome, not by how detailed the initial statement looks.
The same rough idea may fit `dig` when the user wants to discover their intent,
or `grill-me` when they want a candidate direction challenged.

## Provenance

The **Grilling** section is reproduced verbatim from Matt Pocock's `grilling`
skill in [`mattpocock/skills`](https://github.com/mattpocock/skills). It is
licensed under the MIT License; retain
[`references/mattpocock-mit-license.md`](references/mattpocock-mit-license.md)
with copies or substantial portions. This version adds only the
`discuss-toolkit-dig` gate, toolkit positioning, and the local stopping rule.
