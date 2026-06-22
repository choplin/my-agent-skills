#!/usr/bin/env bash
#
# install-opts.sh — distribute agent-specific add-ons (opts/) to each agent's
# config location.
#
# Skills are distributed separately via the vercel-labs/skills CLI
# (`npx skills add <this-repo>`). This script handles only the agent-specific
# extras that the skills CLI does not carry: subagents, commands, hooks, etc.
#
# Layout: opts/<agent>/<subtree> mirrors that agent's config home. For example
#   opts/claude/agents/foo.md   ->  ~/.claude/agents/foo.md
#   opts/claude/hooks/bar.py    ->  ~/.claude/hooks/bar.py
#
# Usage:
#   scripts/install-opts.sh [--copy] [--dry-run] [agent ...]
#
#   --copy      Copy files instead of symlinking (default: symlink).
#   --dry-run   Print what would happen without changing anything.
#   [agent ...] Restrict to specific agents (default: all under opts/).
#
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
opts_dir="$repo_root/opts"

# Map an opts/<agent> directory name to that agent's config home.
# Extend this table as more agents are supported.
agent_home() {
  case "$1" in
    claude) echo "$HOME/.claude" ;;
    codex)  echo "$HOME/.codex" ;;
    *)      return 1 ;;
  esac
}

mode="symlink"
dry_run=0
agents=()

for arg in "$@"; do
  case "$arg" in
    --copy)    mode="copy" ;;
    --dry-run) dry_run=1 ;;
    -*)        echo "unknown option: $arg" >&2; exit 2 ;;
    *)         agents+=("$arg") ;;
  esac
done

if [[ ! -d "$opts_dir" ]]; then
  echo "no opts/ directory at $opts_dir" >&2
  exit 1
fi

# Default to every agent dir present under opts/.
if [[ ${#agents[@]} -eq 0 ]]; then
  for d in "$opts_dir"/*/; do
    [[ -d "$d" ]] && agents+=("$(basename "$d")")
  done
fi

run() {
  if [[ $dry_run -eq 1 ]]; then
    echo "DRY  $*"
  else
    "$@"
  fi
}

for agent in "${agents[@]}"; do
  src_base="$opts_dir/$agent"
  if [[ ! -d "$src_base" ]]; then
    echo "skip: opts/$agent not found" >&2
    continue
  fi
  if ! dst_base="$(agent_home "$agent")"; then
    echo "skip: no config-home mapping for '$agent' (add it to agent_home())" >&2
    continue
  fi

  echo "==> $agent  ($mode -> $dst_base)"
  # Walk every file under opts/<agent> and place it at the mirrored path.
  while IFS= read -r -d '' src; do
    rel="${src#"$src_base"/}"
    dst="$dst_base/$rel"
    run mkdir -p "$(dirname "$dst")"
    if [[ "$mode" == "copy" ]]; then
      run cp -f "$src" "$dst"
    else
      run ln -sfn "$src" "$dst"
    fi
    echo "    $rel"
  done < <(find "$src_base" -type f -print0)
done
