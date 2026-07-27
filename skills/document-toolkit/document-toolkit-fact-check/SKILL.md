---
name: document-toolkit-fact-check
description: Use this skill when the user wants to verify claims in a technical document. Triggers on phrases like "fact-check this", "verify this document", "check if this is accurate", "validate these claims", or when reviewing documentation for accuracy.
allowed-tools: Read, Grep, Glob, Task, Bash, WebSearch
---

# Fact Check Document

Ensure that technical documents contain ONLY verified facts - no assumptions, guesses, or unverified claims.

## Execution — isolate the verification reads

Fact-checking reads many files, runs commands, and searches the web to confirm each
claim. That bulk should not land in the caller's context.

- **Under Claude Code**, dispatch the `document-toolkit-fact-check` subagent
  (`subagent_type: document-toolkit-fact-check`) so those reads stay out of this
  context; it runs the Process below in isolation and returns only the findings.
- **Otherwise**, apply the Process below inline.

Either way the verification procedure and the four-state output are exactly the same
— the subagent is only a context boundary, not a different check.

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
