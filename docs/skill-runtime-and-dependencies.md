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
  scripts/...
```

Without a committed `flake.lock`, the nix path (§4) does not activate and the
build is not reproducible. PyPI packages are **not** declared here — they are
resolved on demand by `uvx` (§5), so no `pyproject.toml` / `uv.lock` is bundled.

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

- **nix stays opt-in.** The script *never* invokes `nix` implicitly as a hard
  requirement; nix is only *one blessed way* to provision the PATH, chosen only
  when the direct PATH is unavailable.
- **Decide once, then run mode-agnostically.** When the nix path is chosen, the
  work must end up running with uv/python/poppler on PATH, paying the flake-eval
  cost once (not per invocation). Two shapes do this — pick by how many scripts
  need the env:
  - **Preferred — a separate `preflight.sh` wrapper** that resolves the env and
    then `exec`s the given command inside it. One resolver serves every script in
    the leaf (and any command the SKILL.md tells the agent to run through it), and
    because the wrapper `exec`s the *target* (not itself), it needs **no re-exec
    guard variable**.
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

The worker it launches is then mode-agnostic — it assumes the base env is on PATH
and runs its resolved interpreter/tool directly (a stdlib script needs only
`python3`; a pip-installable CLI tool is resolved PATH-first via `uvx`, §5):

```sh
# scripts/foo.sh — assumes the env is resolved (launch via preflight.sh).
# Safety net for a direct call, and a pointer back to the wrapper:
command -v python3 >/dev/null || { echo "error: python3 not found — launch via scripts/preflight.sh" >&2; exit 1; }
python3 "$SKILL_DIR/scripts/foo.py" "$@"
```

**A tool the flake cannot provide** (too heavy, or downloads its own weights at
run time — e.g. a multi-GB ML CLI): if it is pip-installable, do **not** make it
a manual install — resolve it PATH-first via `uvx`, per §5. Either way the
choice of *how to run the tool* lives **in the worker, not the wrapper**: the
wrapper only guarantees the base env is on PATH, and the worker then decides
between an installed binary and `uvx`. Never hand-install it (§6).

**Inline variant** (single-script skills): keep the resolution inside the worker
and re-exec it once, guarded by an env var —
`if [ -z "${SKILL_ENV_RESOLVED:-}" ]; then … exec env SKILL_ENV_RESOLVED=1 nix develop "$SKILL_DIR" --command bash "$0" "$@"; fi`.

(If `nix` is present but the `nix-command`/`flakes` features are disabled, the
`nix develop` exec fails — catch that and degrade to the aggregated fail rather
than surfacing a cryptic nix error.)

## 5. Pip-installable deps: resolve PATH-first, `uvx` by default

Anything from PyPI is resolved **without a per-skill `pyproject.toml` /
`uv.lock`**. The two tiers split cleanly: the **flake** provides the *tools*
(uv/python/system libs), and **uv resolves PyPI packages on demand** into its own
cache — never a project-local `.venv` committed via a lockfile.

A **CLI tool** the skill shells out to (e.g. an OCR/ML CLI) is resolved
**PATH-first** in the worker: use an already-installed binary if present,
otherwise run it ephemerally with `uvx --from '<tool>[extra]' <tool>`, which
resolves it from PyPI into uv's **shared tool cache**. There is no reason to
ignore a copy the user already has, and the uvx cache is keyed by the requirement
spec — so skills requesting the same spec **share one environment** instead of
each building its own `.venv`, and the skill stays free of a lockfile.

```sh
# Prefer an installed binary; else resolve it ephemerally via uvx (shared cache).
if command -v mytool >/dev/null; then
  TOOL=(mytool)
elif command -v uv >/dev/null; then
  TOOL=(uvx --from 'mytool[extra]' mytool)
else
  echo "error: need 'mytool' or 'uv' on PATH — launch via scripts/preflight.sh" >&2; exit 1
fi
"${TOOL[@]}" <args>   # run through the resolved launcher
```

By default this is **unpinned** — uvx resolves the latest on first use and caches
it. That is the intended trade for the convenient path: lightest weight, shared
across skills, and a user who truly needs a fixed version can pin the spec
themselves (`uvx --from 'mytool[extra]==1.2.3' mytool`; the cache still shares
across skills that use the identical pinned spec). If instead your own code needs
to **import** a third-party library (not shell out to a CLI), resolve it the same
lockfile-free way with `uv run --with '<pkg>' python …` (an ephemeral env) rather
than reintroducing a per-skill `pyproject.toml` / `uv.lock`.

Three things follow:

- **The preflight predicate must admit both paths.** PATH mode is viable when the
  base env (system libs) is present **and** there is a way to get the tool —
  either `uv` (which can provision it *and* supply a Python) **or** the tool
  itself plus any interpreter it needs already on PATH. So the wrapper's test
  becomes e.g. `has poppler && { has uv || { has mytool && has python3; }; }`
  rather than hard-requiring `uv`. (nix mode still provides `uv` + libs, so
  `uvx` provisions the tool there with no extra setup.)
- **A stdlib-only helper script needs no project interpreter.** If the worker
  also runs a stdlib-only Python converter alongside the tool, run it with a PATH
  `python3`, falling back to `uv run python` (an ephemeral interpreter) when only
  `uv` is present — no project or lockfile required.
- **The tool's runtime data is not in the tool env.** Model weights and similar
  large runtime downloads land in the tool's own cache (e.g. `~/.cache` /
  Hugging Face), not the uvx tool env, and are shared across every resolution
  path. So PATH-vs-`uvx` only changes where the *packages* live; the multi-GB
  runtime data is downloaded once and reused either way. Pinning therefore buys
  package reproducibility, not control over that runtime data — which is why the
  unpinned shared path is a cheap default.

## 6. Failure is early, aggregated, and promoting — never performing

- **Early.** The preflight runs before any side effect. A skill that cannot run
  stops at the top, not halfway through.
- **Aggregated.** When no mode is viable, print **all** options in one message
  (nix setup *and* the manual install commands). Do not fail one missing piece
  at a time — that forces the user into a re-run loop.
- **Promoting, not performing.** Print the exact command and stop. **Never
  auto-install** a system dependency. (The single allowed exception is uv
  resolving PyPI packages into its own cache — `uvx`, or `uv run --with`, per §5
  — a user-cache write, not a system mutation.)

## 7. Distribution realities

- **The preflight snippet and flake set live in each leaf** that needs them.
  Because the CLI distributes per leaf and discards higher levels, siblings
  **cannot share** these files — expect duplication (including a `flake.lock`
  per leaf).
- **Mitigate duplication with a single source of truth + sync.** Keep one
  canonical copy of the env/preflight in the repo and **sync it into each leaf
  via the `Makefile`**, rather than hand-editing N copies of the lockfiles.
- **Sandbox / network caveat.** `uvx`'s first resolve and `nix develop`'s
  substituter fetches need network and cache writes, which an agent's command
  sandbox may block. The SKILL.md should tell the reader to **re-run without the
  sandbox** on such a failure.

## Reference implementation

- The `goal-loop` group is the reference for the broader "portable core, opt-in
  add-on" discipline.
