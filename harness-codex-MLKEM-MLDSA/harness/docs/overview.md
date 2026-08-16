# Harness overview

A harness is the system around the model that makes an agent reliable across sessions:
instructions, a feature plan, verification, memory, tool safety, orchestration, and
human-in-the-loop.

## Layout and responsibilities
- `AGENTS.md`                — root instructions: how to start, stay in scope, finish.
- `feature_list.json`        — the feature plan (what to build, how to verify, evidence).
- `init.sh`                  — reproducible environment setup.
- `harness/agents/`          — agent roles (captain + specialists).
- `harness/orchestrator/`    — the loop driver.
- `harness/tools/`           — the project's tools/scripts the agents may use.
- `harness/gates/`           — quality checks (fail-closed) + rubric + clean-state checklist.
- `harness/memory/`          — progress log + session handoff (continuity across sessions).
- `harness/state/`           — per-agent working state (where each agent is right now).
- `harness/runs/`            — per-run logs and traces.

## Session lifecycle
```
USER PREREQUISITE
  0. bash ./init.sh
STARTUP
  The agent never runs init.sh. Missing bootstrap outputs require user action.
  1. read AGENTS.md + agents/captain.md
  2. read memory/progress.md first, then memory/session_handoff.md
  3. read feature_list.json -> pick the ONE in_progress feature
WORK  (one feature at a time)
  4. planner -> plan + acceptance criteria
  5. builder -> implement (in scope only)
VERIFY  (fail-closed, never skip)
  6. tester   -> run checks, capture evidence
  7. verifier -> gates + rubric; matches user_visible_behavior?
  8. reviewer -> optional clean-context review before commit
WRAP UP
  9. update state/<agent>.state.md
 10. append a Session Record to memory/progress.md
 11. update feature status + evidence in feature_list.json
 12. write session_handoff.md; run gates/clean-state-checklist.md
```

## Roles
- captain     — orchestrator / manager.
- initializer — one-time bootstrap (env + seed plan + first verified state).
- planner     — what to do + how success is measured.
- builder     — implement one feature.
- tester      — run checks, capture evidence.
- verifier    — gates + rubric; only it sets `passing`.
- reviewer    — optional independent diff review.

## Control layers
- Gates — automated, fail-closed. Deterministic (linter, tests, types) and inferential
  (rubric).
- Human-in-the-loop — pause for approval on high-risk / irreversible actions, low
  confidence, or conflicting evidence. See `human-in-the-loop.md`.
