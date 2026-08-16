# Getting started

A **harness** is the scaffolding around a coding agent (Codex, Claude Code, ...) that
makes it work reliably across sessions: clear instructions, a tracked plan, verification
before "done", and memory so the next session resumes instead of restarting.

## 1. Put it in your project
These files live at your project root:
`AGENTS.md`, `init.sh`, `feature_list.json`, `feature_list.schema.json`.
Everything else lives in the `harness/` folder next to them.

## 2. First-time setup (3 things to fill in)
1. `init.sh` — add your project's real environment-setup commands (install deps, build,
   start services). It must run cleanly and be safe to re-run.
2. `feature_list.json` — replace the example with your real features. Exactly one may be
   `in_progress` at a time.
3. `harness/memory/progress.md` — fill in "Current Verified State" (repo root, startup
   command, verification command, top feature).

(These three steps are the `initializer` agent's job — see `roles.md`.)

## 3. How a session runs
The user runs `init.sh` first. The agent then follows `AGENTS.md` without running setup
again: read `progress.md` → pick the one active feature → plan → build →
verify (tests + gates) → update memory/state/feature_list → write the handoff.
Full lifecycle: `overview.md`.

## 4. Try the demo
```bash
cd harness/orchestrator && python run_harness.py
```
It runs one simulated loop (including a human-approval step and the gates) and writes
logs to `harness/runs/<run_id>/`. No dependencies; it does not touch your `memory/` or
`state/` files.

## What each file is
| Path | What it is |
|------|------------|
| `AGENTS.md` | Root instructions the agent follows every session (entry point). |
| `init.sh` | Environment setup, run by the user before each agent session. |
| `feature_list.json` | The plan: features, status, how to verify, evidence. |
| `feature_list.schema.json` | The shape/rules for `feature_list.json`. |
| `harness/config/harness.yaml` | Settings: models, limits, gates, approval policy. |
| `harness/agents/*.md` | One file per agent role (what it does, its scope). |
| `harness/orchestrator/run_harness.py` | The loop driver (runnable demo). |
| `harness/tools/` | The tools/scripts agents may use. |
| `harness/gates/gates.py` | Quality checks; must pass before a result is accepted. |
| `harness/gates/evaluator-rubric.md` | The judgement check for "done". |
| `harness/gates/clean-state-checklist.md` | Run before ending a session. |
| `harness/memory/progress.md` | Progress log (read first, written last). |
| `harness/memory/session_handoff.md` | Handoff note for the next session. |
| `harness/state/*.state.md` | Where each agent is right now. |
| `harness/runs/` | Logs and traces per run. |
| `harness/docs/` | These guides. |

## Next
- `customization.md` — where to change things.
- `roles.md` — the agents and how they hand off.
