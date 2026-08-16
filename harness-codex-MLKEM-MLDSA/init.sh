#!/usr/bin/env bash
# init.sh — project environment setup.
# The user runs this before each agent session (see AGENTS.md). Keep it idempotent.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

# >>> project setup (append your real environment commands) >>>
# e.g. ./docker-dev.sh start
#      python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt
# <<< project setup <<<

echo "init.sh complete. You can now start an agent session from this repository root."
