#!/usr/bin/env bash
#
# uninstall-opts.sh — remove this repo's agent add-ons (opts/) from each agent's
# config location. The inverse of install-opts.sh.
#
# install-opts.sh symlinks opts/<agent>/** into <agent-home>/** pointing back
# into this repo. Every such link is removed here; install-opts.sh removes only
# the subset whose target is gone. See opts-lib.sh for how a link is recognised
# as ours and what that scan cannot see.
#
# Usage:
#   scripts/uninstall-opts.sh [--dry-run] [agent ...]
#
#   --dry-run   Print what would be removed without changing anything.
#   [agent ...] Restrict to specific agents (default: all under opts/).
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
opts_dir="$repo_root/opts"

# shellcheck source=./opts-lib.sh
source "$repo_root/scripts/opts-lib.sh"

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
uninstall_agent() {
  local src_base="$1" dst_base="$2"
  local link
  while IFS= read -r -d '' link; do
    run rm -f "$link"
    echo "    rm ${link#"$dst_base"/}"
  done < <(opts_links "$src_base" "$dst_base")
  prune_empty_dirs "$src_base" "$dst_base"
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
