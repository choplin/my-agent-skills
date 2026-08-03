---
name: ai-council-fugu-cli
description: >-
  What differs when a consultation panelist is Sakana AI's Fugu model, reached
  through the Codex CLI interface as `codex-fugu`: attribution, and the wrapper
  flags its own help does not list. The shared constraints come from the Codex
  CLI skill.
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

- Command mechanics are identical to Codex — `codex-fugu --help` forwards to the
  Codex help, so read the syntax there.
- **Key difference**: `codex` runs OpenAI's model; `codex-fugu` runs **Sakana AI's
  Fugu model** behind the same interface. Attribute opinions to Fugu, not to
  Codex/OpenAI.
- When called non-interactively (output piped or redirected), `codex-fugu` skips its
  update check and passes straight through to the Fugu model — safe to call from scripts/agents.

## Commands

Command usage is **identical to Codex**, with the `codex-fugu` prefix — the
prescribed calls transfer verbatim:

```bash
codex-fugu exec -s read-only "<the brief>"
codex-fugu review --uncommitted
```

Every constraint in the `ai-council-codex-cli` skill applies here unchanged —
the mandatory read-only sandbox, the host sandbox that must be disabled on
macOS, and confirming with the user before sending files that may hold secrets.
Read that skill when seating Fugu; for anything it does not prescribe, ask
`codex-fugu --help`.

Only two things are Fugu-specific:

1. **Attribute clearly** — always present the response as Fugu's (Sakana AI),
   distinct from OpenAI's Codex and from any other panelist on the same panel.
2. **Wrapper-only management flags.** These are handled by the wrapper before
   the model runs, and `codex-fugu --help` does **not** list them — it forwards
   to the Codex help, so this is the only place they are written down:
   - `--status`    — show installed Codex version, Fugu bundle target, and any version mismatch
   - `--recheck`   — clear suppressed update decisions and the update-check throttle
   - `--no-update` — skip the update/version check for this run (also `CODEX_FUGU_NO_UPDATE=1`)
   - `--set-key`   — (re)configure the Fugu API key via the recorded installer
