#!/usr/bin/env bash
# lint-frontmatter.sh — will this skill's YAML frontmatter actually load?
#
# A skill whose frontmatter does not parse is never loaded at all: the agent behaves
# as if it did not exist, and the symptom ("my skill never triggers") looks nothing
# like the cause. This is the mechanical precondition to any content review.
#
# It checks exactly four things, and nothing else:
#   1. delimiters     — opens with --- on line 1, closed by a later ---
#   2. line shape     — every non-indented line inside is `key: value`
#   3. scalar traps   — an unquoted value must not contain ": " nor end with ":"
#   4. required keys  — name and description are present
#
# Checks 1, 2 and 4 are the walk in lint_file(); check 3 — the one that actually
# breaks skills, and the only one with real subtlety — is scalar_trap_in().
#
# Usage: lint-frontmatter.sh [PATH...]   # SKILL.md files and/or dirs (default: .)
# Exit:  0 = all clean, 1 = at least one file is broken, 2 = bad usage
set -euo pipefail

die() { echo "error: $*" >&2; exit 2; }

# A finding goes to stdout; `main` collects a file's findings by capturing lint_file.
report() { echo "  line $1: $2"; }

# --- check 3: the trap that actually breaks skills ---------------------------
# `description: the FIRST step: writing the script` — YAML reads the second colon as
# a nested key, the file fails to parse, and the skill silently never loads. Prose
# invites this constantly. Quoted values ("…", '…') and block scalars (>-, |) escape
# the trap by construction, so only a bare value can trip it.
#
# Names the trap in the value, or nothing if it is safe. The caller reports it.
scalar_trap_in() {
  local value=$1

  case $value in
    '' | '"'* | "'"* | '|'* | '>'*) return ;;   # empty, quoted, or block scalar: safe
  esac

  case $value in
    *': '*) echo colon-space ;;
    *:)     echo trailing-colon ;;
  esac
}

# --- checks 1, 2 and 4, and the walk -----------------------------------------
# Prints one line per finding; prints nothing for a healthy file.
lint_file() {
  local file=$1
  local lineno=0 closed=0 has_name=0 has_description=0 line key value

  while IFS= read -r line; do
    lineno=$((lineno + 1))

    if [ "$lineno" -eq 1 ]; then                      # check 1: opening delimiter
      [ "$line" = "---" ] || { report 1 "frontmatter must open with --- on line 1."; return; }
      continue
    fi
    if [ "$line" = "---" ]; then closed=1; break; fi  # check 1: closing delimiter

    # An indented line is inside a block scalar, or continues the previous value.
    # YAML treats it as raw text there, so no trap applies and we can skip it.
    case $line in
      '' | [[:space:]]* | '#'*) continue ;;           # blank, indented, or comment
    esac

    if [[ ! $line =~ ^([A-Za-z0-9_.-]+):[[:space:]]*(.*)$ ]]; then   # check 2: shape
      report "$lineno" "not a \`key: value\` line, and not indented.\
 A value spilling onto the next line must be indented to continue the previous one."
      continue
    fi
    key=${BASH_REMATCH[1]}
    value=${BASH_REMATCH[2]}

    case $(scalar_trap_in "$value") in                # check 3
      colon-space)
        report "$lineno" "\`$key\` is an unquoted value containing \": \" (colon + space).\
 YAML reads it as a nested key, so the file fails to parse and the skill never loads.\
 Reword it (\"the FIRST step: writing X\" -> \"the FIRST step, writing X\") or quote the value."
        ;;
      trailing-colon)
        report "$lineno" "\`$key\` is an unquoted value ending in \":\" — same trap, the file fails to parse."
        ;;
    esac

    case $key in                                      # check 4: gather
      name)        has_name=1 ;;
      description) has_description=1 ;;
    esac
  done < "$file"

  [ "$closed" -eq 1 ]          || report "$lineno" "frontmatter is never closed with ---."
  [ "$has_name" -eq 1 ]        || report "-" "missing required key: name"
  [ "$has_description" -eq 1 ] || report "-" "missing required key: description"
}

# --- entry point --------------------------------------------------------------
collect_files() {
  local target
  for target in "$@"; do
    if [ -d "$target" ]; then
      find "$target" -name SKILL.md -type f | sort
    elif [ -f "$target" ]; then
      echo "$target"
    else
      die "no such file or directory: $target"
    fi
  done
}

main() {
  local targets=("$@")
  [ $# -gt 0 ] || targets=(".")

  local files=() file
  while IFS= read -r file; do files+=("$file"); done < <(collect_files "${targets[@]}")
  [ ${#files[@]} -gt 0 ] || die "no SKILL.md found under: ${targets[*]}"

  local broken=0 findings
  for file in "${files[@]}"; do
    findings=$(lint_file "$file")
    if [ -n "$findings" ]; then
      echo "FAIL $file"
      echo "$findings"
      broken=$((broken + 1))
    fi
  done

  if [ "$broken" -gt 0 ]; then
    echo "lint-frontmatter: ${#files[@]} checked, $broken BROKEN — these skills will not load." >&2
    return 1
  fi
  echo "lint-frontmatter: ${#files[@]} checked, all clean." >&2
}

main "$@"
