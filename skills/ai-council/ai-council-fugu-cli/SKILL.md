---
name: ai-council-fugu-cli
description: >-
  Use this skill when the user wants Sakana AI's Fugu opinion or review via the
  Codex interface (the `codex-fugu` command). Triggers on phrases like
  "Fuguに聞いて", "Fuguの意見", "Fuguでレビュー", "ask fugu", "what does fugu think",
  "get fugu's opinion", "Sakana Fugu". Should NOT trigger for OpenAI Codex
  consultation (use ai-council-codex-cli), troubleshooting the codex-fugu wrapper,
  or casual mentions of Fugu without consultation intent.
user-invocable: false
metadata:
  description-role: documentation
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
- **Key difference**: `codex` runs OpenAI's model; `codex-fugu` runs **Sakana AI's
  Fugu model** behind the same interface. Attribute opinions to Fugu, not to
  Codex/OpenAI.
- When called non-interactively (output piped or redirected), `codex-fugu` skips its
  update check and passes straight through to the Fugu model — safe to call from scripts/agents.

## Commands

Command usage is **identical to Codex** — same subcommands and flags (`exec`,
`review`, `-s read-only`, `-o`, `--json`, `-c key=value`) with the `codex-fugu`
prefix. See the `ai-council-codex-cli` skill for syntax, examples, best practices,
and output interpretation. Only two things are Fugu-specific:

1. **Attribute clearly** — always present the response as Fugu's (Sakana AI),
   distinct from Codex/OpenAI and Claude.
2. **Wrapper-only management flags** (handled before the model runs):
   - `--status`    — show installed Codex version, Fugu bundle target, and any version mismatch
   - `--recheck`   — clear suppressed update decisions and the update-check throttle
   - `--no-update` — skip the update/version check for this run (also `CODEX_FUGU_NO_UPDATE=1`)
   - `--set-key`   — (re)configure the Fugu API key via the recorded installer
