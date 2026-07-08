---
title: "Skill Runtime & Dependency Policy"
date: 2026-07-08
type: decision
status: active
tags:
  - architecture
  - agent-skills
  - runtime
  - dependencies
---

# Skill Runtime & Dependency Policy

How a portable skill in this repo may depend on a runtime or external
dependency, and how it must behave when that dependency is absent. Companion to
[skill-first-architecture.md](./skill-first-architecture.md) — that doc covers
*what* travels with a skill; this one covers *what a skill is allowed to require
and how it resolves it at run time*.

The guiding constraint is unchanged: the repo is **agent-agnostic**, so a skill
must run on any host. Every hard prerequisite narrows portability, so the
default is **zero non-baseline dependencies**, and anything beyond that is an
**opt-in convenience layered on top of a portable core** — never a silent hard
requirement.

## 1. Principles — when a dependency is justified

- **Default: no dependencies beyond the baseline.** The baseline is a POSIX
  shell + `jq`. Write skills in `bash` + `jq` whenever the work fits. `jq` is
  itself a prerequisite (assumed on the user's PATH) but is the accepted
  baseline — still guard it (`command -v jq`) with a clear message.
- **Runtime choice is by fit, not by rule.** Escalate to another runtime only
  when the task genuinely warrants it:
  - **Python (+ `uv`)** is the usual next step for data-heavy work (e.g. parsing
    structured JSON). Both studios already ship Python.
  - **JS/Node** is *permitted* when genuinely warranted, though the use case is
    rare. (The earlier "never JS" stance is retracted.)
  - A **per-OS compiled binary** committed to the repo is a poor fit for this
    markdown+scripts repo — avoid it.
- **Whatever the runtime, the rules below apply identically.** The mechanism
  (declare → preflight → resolve or fail) does not depend on which runtime you
  picked.

## 2. Declare every non-baseline dependency in `flake.nix`

Any runtime or system tool beyond shell+jq (python3, node, `uv`, poppler,
MinerU, …) must be:

- **Declared in a `flake.nix`** bundled in the skill's own leaf directory
  (`skills/<group>/<group>-<skill>/`), because the skills CLI distributes at the
  leaf level and **discards everything above it** — a group- or repo-level flake
  never reaches an installed skill. See skill-first-architecture.md § Naming and
  § Authoring conventions.
- The flake owns **all** system dependencies for that skill (uv, python,
  poppler, …) so that the nix path is *all-in-one*.

Bundle the full, reproducible set and **commit the lockfiles**:

```
skills/<group>/<group>-<skill>/
  SKILL.md
  flake.nix          # devShell providing the system deps
  flake.lock         # committed — also the signal that enables the nix path (§4)
  devshell.toml      # optional, if the flake uses numtide/devshell
  pyproject.toml     # Python lib-layer deps (if any)
  uv.lock            # committed — makes `uv run` sync deterministic
  scripts/...
```

Without a committed `flake.lock`, the nix path (§4) does not activate and the
build is not reproducible; without `uv.lock`, `uv run`'s sync is
non-deterministic.

## 3. Baseline is not zero-cost either

Even a shell+jq skill guards its baseline: probe `command -v jq` up front and
fail with an install hint if missing. "Baseline" means *assumed common*, not
*skippable*.

## 4. Preflight resolves the execution mode once

A skill that needs a non-baseline runtime resolves **how to run** at the very
top, before any side effect — not merely *whether* the dependency exists. The
resolution order (PATH first, respecting the user's existing environment; nix as
the opt-in convenience; fail last):

1. **Is the runtime already usable on PATH?** (e.g. `command -v uv`.) → run
   directly. Fast, and honors an environment the user already assembled.
2. **Else, is a `flake.lock` bundled and is `nix` available (with flakes
   enabled)?** → run via `nix develop`. This is the opt-in convenience path.
3. **Else** → **fail** with a single aggregated message listing every option
   (§6). Emit to stderr, exit non-zero, so the calling agent relays it.

Key properties:

- **nix stays opt-in.** The script *never* invokes `nix` or `uv sync`
  implicitly as a hard requirement; nix is only *one blessed way* to provision
  the PATH, chosen only when the direct PATH is unavailable.
- **Decide once, then run mode-agnostically.** When the nix path is chosen, the
  work must end up running with uv/python/poppler on PATH, paying the flake-eval
  cost once (not per invocation). Two shapes do this — pick by how many scripts
  need the env:
  - **Preferred — a separate `preflight.sh` wrapper** that resolves the env and
    then `exec`s the given command inside it. One resolver serves every script in
    the leaf (and any command the SKILL.md tells the agent to run through it), and
    because the wrapper `exec`s the *target* (not itself), it needs **no re-exec
    guard variable**. This is the paper-studio-summarize shape.
  - **Alternative — inline self-re-exec** inside a single worker script, guarded
    by an env var to avoid an infinite loop. Fine when the skill has exactly one
    entry script and you would rather not add a second file.

### Preflight template (preferred: separate wrapper)

Copy this into each skill that needs it as `scripts/preflight.sh` (the snippet
cannot be shared across leaf directories — see §7). The SKILL.md then launches
any env-dependent script through it, e.g.
`bash <SKILL_DIR>/scripts/preflight.sh bash <SKILL_DIR>/scripts/foo.sh <args>`:

```sh
#!/usr/bin/env bash
# preflight.sh — resolve the runtime env once, then exec the given command in it.
# Usage: preflight.sh <command> [args...]
set -euo pipefail

[ $# -gt 0 ] || { echo "usage: $0 <command> [args...]" >&2; exit 2; }

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if command -v uv >/dev/null 2>&1; then
  exec "$@"                                     # PATH mode — runtime already available.
elif [ -f "$SKILL_DIR/flake.lock" ] && command -v nix >/dev/null 2>&1; then
  exec nix develop "$SKILL_DIR" --command "$@"  # nix mode — run the target in the dev shell.
else
  cat >&2 <<EOF
This skill needs a runtime that was not found. Set it up either way, then re-run:
  A) nix (all-in-one): run the command inside the bundled dev shell —
       nix develop "$SKILL_DIR" --command <command> [args...]
     (requires nix with the nix-command & flakes features enabled)
  B) manual: install the tools yourself, e.g.
       uv        -> https://docs.astral.sh/uv/
       poppler   -> macOS: brew install poppler | Debian: apt-get install poppler-utils
EOF
  exit 1
fi
```

The worker it launches is then mode-agnostic and delegates its lib layer to uv
(auto-sync from `uv.lock` is intended, §5):

```sh
# scripts/foo.sh — assumes the env is resolved (launch via preflight.sh).
# Safety net for a direct call, and a pointer back to the wrapper:
command -v uv >/dev/null || { echo "error: uv not found — launch via scripts/preflight.sh" >&2; exit 1; }
uv run --project "$SKILL_DIR" python "$SKILL_DIR/scripts/foo.py" "$@"
```

**A tool the flake cannot provide** (too heavy, or downloads its own weights at
run time — e.g. a multi-GB ML CLI) stays a manual `... install` the user runs,
checked **in the worker, not the wrapper** — in nix mode it only appears on PATH
after the dev shell loads (e.g. `~/.local/bin` for a `uv tool install`ed CLI),
which the wrapper has not entered yet. Never auto-install it (§6).

**Inline variant** (single-script skills): keep the resolution inside the worker
and re-exec it once, guarded by an env var —
`if [ -z "${SKILL_ENV_RESOLVED:-}" ]; then … exec env SKILL_ENV_RESOLVED=1 nix develop "$SKILL_DIR" --command bash "$0" "$@"; fi`.

(If `nix` is present but the `nix-command`/`flakes` features are disabled, the
`nix develop` exec fails — catch that and degrade to the aggregated fail rather
than surfacing a cryptic nix error.)

## 5. Library-layer deps are delegated to `uv run`

For Python, do **not** hand-probe each imported package. Run scripts through
`uv run --project "$SKILL_DIR"`, which resolves the `pyproject.toml` deps into a
project-local `.venv` from `uv.lock`. This makes "PATH-first" robust: uv on PATH
but deps un-synced still works, because `uv run` syncs.

- **Auto-sync from the lockfile is intended and allowed.** It is a
  *project-local* `.venv`, not a system-level install, so it does not violate
  "never mutate the user's system"; and it is deterministic because `uv.lock` is
  committed. The two tiers therefore split cleanly: the **flake** provides the
  *tools* (uv/python/system libs), and **`uv run`** provides the *libraries*.

## 6. Failure is early, aggregated, and promoting — never performing

- **Early.** The preflight runs before any side effect. A skill that cannot run
  stops at the top, not halfway through.
- **Aggregated.** When no mode is viable, print **all** options in one message
  (nix setup *and* the manual install commands). Do not fail one missing piece
  at a time — that forces the user into a re-run loop.
- **Promoting, not performing.** Print the exact command and stop. **Never
  auto-install** a system dependency. (The single allowed exception is `uv
  run`'s project-local lib sync, per §5 — that is project-local, not a system
  mutation.)

## 7. Distribution realities

- **The preflight snippet and flake set live in each leaf** that needs them.
  Because the CLI distributes per leaf and discards higher levels, siblings
  **cannot share** these files — expect duplication (including a `flake.lock`
  per leaf).
- **Mitigate duplication with a single source of truth + sync.** Keep one
  canonical copy of the env/preflight in the repo and **sync it into each leaf
  via the `Makefile`**, rather than hand-editing N copies of the lockfiles.
- **Sandbox / network caveat.** `uv run`'s first sync and `nix develop`'s
  substituter fetches need network and cache writes, which an agent's command
  sandbox may block. The SKILL.md should tell the reader to **re-run without the
  sandbox** on such a failure (paper-studio already documents this pattern).

## Reference implementation

- Guard pattern for a hard prerequisite: `paper-studio-summarize`
  (`scripts/mineru_ocr.sh` — `command -v` + install message + stop).
- The `goal-loop` group is the reference for the broader "portable core, opt-in
  add-on" discipline.
