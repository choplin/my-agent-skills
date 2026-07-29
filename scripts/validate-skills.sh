#!/usr/bin/env bash
#
# Validate skills in the repository's grouped skills/<group>/<skill> layout.
#
# Usage: validate-skills.sh [validator-flag...] [path...]
#
# Arguments starting with '-' are forwarded to skill-validator; every other
# argument is a path. Each path is mapped to the skill directory containing it,
# so a hook can pass staged files straight through. With no paths, every skill
# in the repository is validated.
#
# Output defaults to the validator's compact format — one line per passing
# skill, plus the errors for each failing one. Pass -o/--output to override it;
# flags that take a separate value are forwarded as a pair so the value is not
# mistaken for a path.
#
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v skill-validator >/dev/null 2>&1; then
  echo "skill-validator is required: https://github.com/agent-ecosystem/skill-validator" >&2
  exit 127
fi

validator_args=()
paths=()
expect_value=0
output_given=0
for arg in "$@"; do
  if [[ "$expect_value" -eq 1 ]]; then
    validator_args+=("$arg")
    expect_value=0
    continue
  fi
  case "$arg" in
  -o | --output) validator_args+=("$arg") && expect_value=1 && output_given=1 ;;
  -o=* | --output=*) validator_args+=("$arg") && output_given=1 ;;
  -*) validator_args+=("$arg") ;;
  *) paths+=("$arg") ;;
  esac
done

if [[ "$output_given" -eq 0 ]]; then
  validator_args+=(--output=compact)
fi

# Emit one skill directory per line: every skill when no paths were given,
# otherwise just the skills the given paths belong to.
list_skill_dirs() {
  if [[ "${#paths[@]}" -eq 0 ]]; then
    find skills -mindepth 2 -name SKILL.md -type f | sed 's|/SKILL\.md$||' | sort
    return
  fi

  printf '%s\n' "${paths[@]}" \
    | sed "s|^${repo_root}/||" \
    | awk -F/ '$1 == "skills" && NF >= 3 { print $1 "/" $2 "/" $3 }' \
    | sort -u
}

validation_exit=0
skill_count=0

while IFS= read -r skill_dir; do
  # A path can point into a skill that is being deleted, or into skills/ itself.
  [[ -f "$skill_dir/SKILL.md" ]] || continue
  skill_count=$((skill_count + 1))

  skill-validator check "$skill_dir" \
    --strict \
    --allow-extra-frontmatter \
    --allow-dirs=agents,schema \
    ${validator_args[@]+"${validator_args[@]}"} || validation_exit=1
done < <(list_skill_dirs)

if [[ "$skill_count" -eq 0 ]]; then
  # With paths given, matching no skill is a normal outcome — nothing to check.
  if [[ "${#paths[@]}" -eq 0 ]]; then
    echo "no skills found under skills/<group>/<skill>/SKILL.md" >&2
    exit 1
  fi
  echo "no skills matched the given paths; nothing to validate"
fi

exit "$validation_exit"
