#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/sample-project"
cp "$SOURCE_ROOT/init.sh" "$TEST_ROOT/sample-project/init.sh"
(
  cd "$TEST_ROOT/sample-project"
  bash ./init.sh > "$TEST_ROOT/init-first.log"
  bash ./init.sh > "$TEST_ROOT/init-second.log"
)
grep -Fq "init.sh complete." "$TEST_ROOT/init-first.log"
cmp "$TEST_ROOT/init-first.log" "$TEST_ROOT/init-second.log"
echo "PASS: init.sh is idempotent"
