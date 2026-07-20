#!/usr/bin/env bash
#
# uninstall-opts.sh — remove this repo's agent add-ons (opts/) from each agent's
# config location. The inverse of install-opts.sh.
#
# install-opts.sh symlinks opts/<agent>/** into <agent-home>/** pointing back
# into this repo. We identify "our" links by that target: any symlink under the
# agent home whose target is inside this repo's opts/ is removed. Reading the
# link's literal target (readlink, not readlink -f) means a stale link left by a
# renamed/deleted add-on still resolves under opts/ and is cleaned up too, even
# though its target file is gone. Copy-mode installs are not symlinks and are
# left untouched.
#
# Usage:
#   scripts/uninstall-opts.sh [--dry-run] [agent ...]
#
#   --dry-run   Print what would be removed without changing anything.
#   [agent ...] Restrict to specific agents (default: all under opts/).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
opts_dir="$repo_root/opts"

# Map an opts/<agent> directory name to that agent's config home.
# Keep in sync with install-opts.sh.
agent_home() {
  case "$1" in
    claude) echo "$HOME/.claude" ;;
    codex)  echo "$HOME/.codex" ;;
    *)      return 1 ;;
  esac
}

dry_run=0
agents=()

for arg in "$@"; do
  case "$arg" in
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

# Remove every symlink under the agent's config home that points back into this
# repo's opts/<agent> tree, then prune the now-empty directories opts created.
# The scan is scoped to the top-level subtrees opts populates (agents/, skills/…).
uninstall_agent() {
  local src_base="$1" dst_base="$2"
  local sub subtree link tgt
  for sub in "$src_base"/*/; do
    [[ -d "$sub" ]] || continue
    subtree="$(basename "$sub")"
    [[ -d "$dst_base/$subtree" ]] || continue
    while IFS= read -r -d '' link; do
      tgt="$(readlink "$link")"
      if [[ "$tgt" == "$src_base/"* ]]; then
        run rm -f "$link"
        echo "    rm $subtree/${link#"$dst_base/$subtree/"}"
      fi
    done < <(find "$dst_base/$subtree" -type l -print0)
    run find "$dst_base/$subtree" -mindepth 1 -type d -empty -delete
  done
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

  echo "==> $agent  (uninstall <- $dst_base)"
  uninstall_agent "$src_base" "$dst_base"
done
