#!/usr/bin/env bash
#
# Validate every skill in the repository's grouped skills/<group>/<skill> layout.
#
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v skill-validator >/dev/null 2>&1; then
  echo "skill-validator is required: https://github.com/agent-ecosystem/skill-validator" >&2
  exit 127
fi

validation_exit=0
skill_count=0

while IFS= read -r skill_file; do
  skill_dir="${skill_file%/SKILL.md}"
  skill_count=$((skill_count + 1))

  skill-validator check "$skill_dir" \
    --strict \
    --allow-extra-frontmatter \
    --allow-dirs=agents,schema \
    "$@" || validation_exit=1
done < <(find skills -mindepth 2 -name SKILL.md -type f | sort)

if [[ "$skill_count" -eq 0 ]]; then
  echo "no skills found under skills/<group>/<skill>/SKILL.md" >&2
  exit 1
fi

exit "$validation_exit"
