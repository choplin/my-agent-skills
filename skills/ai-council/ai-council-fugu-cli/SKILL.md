---
name: ai-council-fugu-cli
description: >-
  Use this skill when the user wants Sakana AI's Fugu opinion or review via the
  Codex interface (the `codex-fugu` command). Triggers on phrases like
  "Fuguに聞いて", "Fuguの意見", "Fuguでレビュー", "ask fugu", "what does fugu think",
  "get fugu's opinion", "Sakana Fugu". Should NOT trigger for OpenAI Codex
  consultation (use ai-council-codex-cli), troubleshooting the codex-fugu wrapper,
  or casual mentions of Fugu without consultation intent.
---

# Fugu CLI Usage Guide

**Fugu** is Sakana AI's model. It is invoked through the **Codex CLI as its interface**,
wrapped by the `codex-fugu` command. Functionally `codex-fugu` is `codex -p fugu`
(the `fugu` profile) plus an automatic version-reconciliation/update layer, so it
accepts the **same subcommands and flags as Codex**.

Use Fugu when you want **another AI's perspective from a different vendor** than OpenAI Codex.

## Relationship to Codex CLI

- Command mechanics (`exec`, `review`, `-s read-only`, `-o`, `--json`, `-c key=value`)
  are identical to Codex. For full subcommand/flag details, see the
  `ai-council-codex-cli` skill.
- **Key difference**: `codex-xhigh` runs OpenAI's model with higher reasoning effort;
  `codex-fugu` runs **Sakana AI's Fugu model** behind the same interface. Attribute
  opinions to Fugu, not to Codex/OpenAI.
- When called non-interactively (output piped or redirected), `codex-fugu` skips its
  update check and passes straight through to the Fugu model — safe to call from scripts/agents.

## Basic Commands

### Non-interactive Mode (codex-fugu exec)

```bash
# Read-only sandbox (safe for reviews / opinions)
codex-fugu exec -s read-only "Review this code and share your thoughts"

# Output to file
codex-fugu exec -s read-only -o /tmp/fugu-response.txt "your prompt"

# JSON output format
codex-fugu exec -s read-only --json "your prompt"
```

### Code Review Mode (codex-fugu review)

```bash
# Review uncommitted changes
codex-fugu review --uncommitted

# Review changes against a base branch
codex-fugu review --base main

# Review specific files
codex-fugu review path/to/file.ts
```

## Management Flags

`codex-fugu` adds a few wrapper-only flags (handled before the model runs):

- `--status`    — show installed Codex version, Fugu bundle target, and any version mismatch
- `--recheck`   — clear suppressed update decisions and the update-check throttle
- `--no-update` — skip the update/version check for this run (also `CODEX_FUGU_NO_UPDATE=1`)
- `--set-key`   — (re)configure the Fugu API key via the recorded installer

## Best Practices for Getting Opinions

1. **Use read-only sandbox** for safety: `-s read-only`
2. **Be specific** about the kind of feedback you want
3. **Provide context** about the codebase or design goals
4. **Capture output** with `-o` or `--json` for structured responses
5. **Attribute clearly** — label the response as Fugu's (Sakana AI), distinct from Codex/Claude

## Example Prompts

### Code Review
```bash
# Fugu can read files directly — just provide the path
codex-fugu exec -s read-only "Review src/utils/parser.ts for potential bugs and improvements"
```

### Design Discussion
```bash
codex-fugu exec -s read-only "What are the trade-offs between Redux and React Context for a medium-sized React app?"
```

## Output Interpretation

Fugu responses typically include analysis of the problem, concrete suggestions,
concerns/risks, and code examples where applicable. Present them as Fugu's view.
