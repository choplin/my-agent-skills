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
# Installing is add-and-prune: every current opts file is placed, and links this
# repo left behind whose source has since been renamed or deleted are removed.
# Without the prune an add-on outlives its definition — a deleted subagent keeps
# showing up in the agent's list, backed by a link into a file that is gone.
#
# Wholesale removal is handled by the sibling uninstall-opts.sh.
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

# shellcheck source=./opts-lib.sh
source "$repo_root/scripts/opts-lib.sh"

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

# Refuse to install opts/<agent>/skills/<name> when it would collide with a
# skills-CLI-managed skill of the same name: both mechanisms own
# <agent-home>/skills/<name>, so whichever runs last silently wipes the other
# (the skills CLI recreates the whole skill dir on every `skills add`).
# Two checks:
#   1. static  — <name> must not equal any portable skill in skills/*/<name>/
#   2. runtime — the install target must not be a symlink managed by another
#      mechanism (i.e. one that does not point into this repo's opts/)
check_skill_collisions() {
  local agent="$1" dst_base="$2"
  local src_base="$opts_dir/$agent"
  local dir name target resolved
  [[ -d "$src_base/skills" ]] || return 0
  for dir in "$src_base"/skills/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"
    if compgen -G "$repo_root/skills/*/$name/SKILL.md" > /dev/null; then
      echo "error: opts/$agent/skills/$name collides with the portable skill '$name'" >&2
      echo "  Both would install to <agent-home>/skills/$name and overwrite each other." >&2
      echo "  Rename the add-on dir so it is not a portable skill name (e.g. '$name-addon')." >&2
      return 1
    fi
    target="$dst_base/skills/$name"
    if [[ -L "$target" ]]; then
      resolved="$(cd "$(dirname "$target")" 2>/dev/null && readlink -f "$target" || true)"
      if [[ "$resolved" != "$opts_dir"/* ]]; then
        echo "error: $target is a symlink managed by another mechanism (-> ${resolved:-unresolvable})" >&2
        echo "  Refusing to write through it; installing would pollute that mechanism's files." >&2
        echo "  Rename opts/$agent/skills/$name or remove the conflicting install first." >&2
        return 1
      fi
    fi
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

  echo "==> $agent  ($mode -> $dst_base)"
  check_skill_collisions "$agent" "$dst_base"
  # Walk every file under opts/<agent> and place it at the mirrored path.
  # Include symlinks (-type l): some opts resources are symlinks to a base
  # skill's bundled script (e.g. scripts/verify.sh), and those must be
  # distributed too.
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
  done < <(find "$src_base" \( -type f -o -type l \) -print0)

  # Prune: our links whose target no longer exists. Everything current was just
  # (re)placed above, so a dangling one is a leftover by definition. -e follows
  # the link, which is exactly the test wanted here.
  #
  # Copy mode places files, not links, so it has nothing to prune and the scan
  # finds nothing — a stale copy is indistinguishable from a user's own file.
  while IFS= read -r -d '' link; do
    [[ -e "$link" ]] && continue
    run rm -f "$link"
    echo "    pruned ${link#"$dst_base"/}"
  done < <(opts_links "$src_base" "$dst_base")
  prune_empty_dirs "$src_base" "$dst_base"
done
