#!/usr/bin/env bash
# init.sh — project environment setup.
# The user runs this before each agent session (see AGENTS.md). Keep it idempotent.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

PROJECT_ROOT="$(cd "$ROOT/.." && pwd)"

command -v python3 >/dev/null 2>&1 || {
  echo "ERROR: python3 is required (run this script from WSL)." >&2
  exit 1
}
command -v git >/dev/null 2>&1 || {
  echo "ERROR: git is required." >&2
  exit 1
}

python3 "$ROOT/harness/tools/verify_project.py" \
  --project-root "$PROJECT_ROOT" \
  --harness-root "$ROOT"

printf 'bootstrap_verified_at=%s\nproject_root=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$PROJECT_ROOT" > "$ROOT/.harness-bootstrap.ok"

echo "init.sh complete. You can now start an agent session from this repository root."
