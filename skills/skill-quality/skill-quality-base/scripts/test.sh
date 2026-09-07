#!/usr/bin/env bash
# Regression tests for the skill-quality state and gate scripts.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/skill-quality-base-test.XXXXXX")

cleanup() {
  case "$TMP_ROOT" in
    */skill-quality-base-test.*) rm -rf -- "$TMP_ROOT" ;;
  esac
}
trap cleanup EXIT

expect_failure() {
  if "$@" >/dev/null 2>&1; then
    echo "expected failure: $*" >&2
    exit 1
  fi
}

init_run() {
  "$SCRIPT_DIR/init.sh" --run-dir "$1" --skill demo \
    --train t1,t2 --holdout h1,h2 --signal-kind oracle --signal-cmd true \
    >/dev/null
}

# A complete baseline and candidate remain accepted by the normal flow.
valid="$TMP_ROOT/valid"
init_run "$valid"
"$SCRIPT_DIR/record.sh" "$valid" --version v0 --split train \
  --results 't1::pass,t2::fail' >/dev/null
"$SCRIPT_DIR/record.sh" "$valid" --version v0 --split holdout \
  --results 'h1::fail,h2::fail' >/dev/null
"$SCRIPT_DIR/gate.sh" "$valid" --set-baseline >/dev/null
"$SCRIPT_DIR/record.sh" "$valid" --version v1 --split train \
  --results 't1::pass,t2::pass' >/dev/null
"$SCRIPT_DIR/record.sh" "$valid" --version v1 --split holdout \
  --results 'h1::pass,h2::pass' >/dev/null
"$SCRIPT_DIR/gate.sh" "$valid" --candidate v1 >/dev/null
[ "$(jq -r '.current' "$valid/state.json")" = "v1" ]

# Train and holdout must not share task ids.
expect_failure "$SCRIPT_DIR/init.sh" --run-dir "$TMP_ROOT/overlap" --skill demo \
  --train shared --holdout shared --signal-kind oracle --signal-cmd true
expect_failure "$SCRIPT_DIR/init.sh" --run-dir "$TMP_ROOT/duplicate" --skill demo \
  --train t1,t1 --holdout h1 --signal-kind oracle --signal-cmd true

# A partial result set must not produce a score.
partial="$TMP_ROOT/partial"
init_run "$partial"
expect_failure "$SCRIPT_DIR/record.sh" "$partial" --version v0 --split holdout \
  --results 'h1::pass'

# The gate requires complete train and holdout results for every candidate.
missing_train="$TMP_ROOT/missing-train"
init_run "$missing_train"
"$SCRIPT_DIR/record.sh" "$missing_train" --version v0 --split train \
  --results 't1::pass,t2::fail' >/dev/null
"$SCRIPT_DIR/record.sh" "$missing_train" --version v0 --split holdout \
  --results 'h1::fail,h2::fail' >/dev/null
"$SCRIPT_DIR/gate.sh" "$missing_train" --set-baseline >/dev/null
"$SCRIPT_DIR/record.sh" "$missing_train" --version v1 --split holdout \
  --results 'h1::pass,h2::pass' >/dev/null
expect_failure "$SCRIPT_DIR/gate.sh" "$missing_train" --candidate v1

echo "skill-quality-base script tests passed"
