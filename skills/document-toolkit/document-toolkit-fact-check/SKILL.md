---
name: document-toolkit-fact-check
description: >-
  Verifies the factual claims in a technical document against sources, and
  reports which hold, which do not, and which could not be checked.
allowed-tools: Read, Grep, Glob, Task, Bash, WebSearch
metadata:
  description-role: documentation
---

# Fact Check Document

Ensure that technical documents contain ONLY verified facts - no assumptions, guesses, or unverified claims.

## Execution — isolate the verification reads

Fact-checking reads many files, runs commands, and searches the web to confirm each
claim. That bulk does not belong in the caller's context: if the agent can run a
subagent, run the Process below in one and have it return only the findings.
Otherwise apply the Process inline.

The procedure and the four-state output are the same either way — isolation is a
context boundary, not a different check. Whichever way it runs, return the findings
and leave rewriting the document to the caller.

## Process

1. **Read the document thoroughly** - Identify all factual claims, technical statements, and assertions

2. **Verify each claim** by:
   - Searching the codebase for implementation details
   - Reading source files to confirm behavior
   - Checking configuration files
   - Running commands to verify system behavior
   - Using web search for external libraries/APIs documentation
   - Testing code snippets when applicable

3. **Mark findings** as:
   - **VERIFIED**: Confirmed as fact through code/documentation
   - **INCORRECT**: Contradicts actual implementation
   - **UNVERIFIABLE**: Cannot confirm (suggest removal or rewording)
   - **NEEDS UPDATE**: Partially correct but needs clarification

4. **Report results** with:
   - Line-by-line analysis of claims
   - Evidence from investigation (file paths, code snippets)
   - Suggested corrections for any non-factual content

5. **Rewrite the document** if requested, ensuring it contains only verified facts

## Important Rules

- **NO assumptions** - If you cannot verify it, mark it as unverifiable
- **NO opinions** unless explicitly marked as such
- **NO guesses** about how things "might" or "should" work
- **ONLY facts** that can be proven through code, tests, or official documentation
- Every technical claim must have a verifiable source

When in doubt, mark it as unverifiable rather than making assumptions.
