#!/usr/bin/env bash
#
# opts-lib.sh — shared helpers for install-opts.sh and uninstall-opts.sh.
#
# Both scripts need the same two things: where an agent keeps its config, and
# which links under there are ours. Keeping one copy means the install and
# uninstall sides cannot drift apart about either.
#
# Sourced, not executed.

# Map an opts/<agent> directory name to that agent's config home.
# Extend this table as more agents are supported.
agent_home() {
  case "$1" in
    claude) echo "$HOME/.claude" ;;
    codex)  echo "$HOME/.codex" ;;
    *)      return 1 ;;
  esac
}

# opts_links <src_base> <dst_base>
#
# Print, NUL-separated, every symlink under the agent's config home that this
# repo installed — identified by its literal target pointing inside
# opts/<agent>. Reading the target with readlink rather than readlink -f is
# deliberate: a link whose target file has since been deleted still names a path
# under opts/, so it is still recognisably ours and can be cleaned up.
#
# The scan covers the subtrees opts/<agent> currently populates (agents/,
# skills/, …). A subtree deleted from opts/ wholesale therefore falls out of
# range — run uninstall-opts.sh before removing one, or `make reset` after.
#
# Copy-mode installs (--copy) are ordinary files, not symlinks, and are
# invisible to this scan by design: nothing distinguishes them from a file the
# user put there.
opts_links() {
  local src_base="$1" dst_base="$2"
  local sub subtree link tgt
  for sub in "$src_base"/*/; do
    [[ -d "$sub" ]] || continue
    subtree="$(basename "$sub")"
    [[ -d "$dst_base/$subtree" ]] || continue
    while IFS= read -r -d '' link; do
      tgt="$(readlink "$link")"
      [[ "$tgt" == "$src_base/"* ]] && printf '%s\0' "$link"
    done < <(find "$dst_base/$subtree" -type l -print0)
  done
}

# prune_empty_dirs <src_base> <dst_base>
# Drop directories that opts created and no longer fills. Calls the sourcing
# script's run(), so --dry-run is honoured by whichever script sources this.
prune_empty_dirs() {
  local src_base="$1" dst_base="$2"
  local sub subtree
  for sub in "$src_base"/*/; do
    [[ -d "$sub" ]] || continue
    subtree="$(basename "$sub")"
    [[ -d "$dst_base/$subtree" ]] || continue
    run find "$dst_base/$subtree" -mindepth 1 -type d -empty -delete
  done
}
