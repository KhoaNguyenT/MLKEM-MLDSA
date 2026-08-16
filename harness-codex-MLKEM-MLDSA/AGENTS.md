# AGENTS.md — root instructions

Entry point for every session. Keep it small.

## What's in the harness
- `feature_list.json`  — the feature plan.
- `init.sh`            — environment setup.
- `harness/agents/`    — agent roles.
- `harness/gates/`     — quality checks (fail-closed).
- `harness/memory/`    — progress log + session handoff.
- `harness/state/`     — per-agent working state.
- `harness/tools/`     — tools the agents may use.

## Session lifecycle (in order)

STARTUP
Prerequisite: the user runs `bash ./init.sh` before starting the agent session.
The agent must not run or re-run `init.sh`; if bootstrap outputs are missing, ask the
user to run it and stop.
1. Read `harness/agents/captain.md`.
2. Read `harness/memory/progress.md` first, then `harness/memory/session_handoff.md`.
3. Read `feature_list.json`; pick the single `in_progress` feature (or the
   highest-priority `not_started`).

WORK (one feature at a time)
4. Plan it (planner), then implement it (builder). Stay strictly in scope.

VERIFY (never skip)
5. Run checks (tester), then gates + rubric (verifier). "Done" means tests pass,
   lint/types clean, and behaviour matches `user_visible_behavior`.
6. If it passes, record evidence. If not, keep `in_progress`/`blocked` with a reason.

WRAP UP
7.  Update `harness/state/<agent>.state.md`.
8.  Append a Session Record to `harness/memory/progress.md`.
9.  Update the feature's `status` + `evidence` in `feature_list.json`.
10. Write `harness/memory/session_handoff.md`; run `harness/gates/clean-state-checklist.md`.

## Roles (harness/agents/)
captain (orchestrator) · initializer (bootstrap) · planner · builder · tester ·
verifier (sets `passing`) · reviewer (optional).

## Rules
- Only one feature may be `in_progress` at a time.
- Never mark a feature `passing` without recorded evidence.
- Gates are fail-closed: if a check fails, stop.
- Pause for human review before destructive/irreversible actions or before committing
  (`harness/docs/human-in-the-loop.md`).


Full lifecycle and roles: `harness/docs/overview.md`.

## Parallel workers

When `harness/coordination/assignments.json` exists, the Captain/worker protocol in
`harness/coordination/README.md` is mandatory.

- The long-lived user-facing session is Captain and owns all shared harness state.
- Codex and Antigravity workers use separate branches/worktrees and one work packet each.
- Workers edit only their packet's writable paths.
- Workers return evidence, a report, and a commit hash; they do not merge or update
  feature status, memory, state, or assignments.
- Overlapping writable paths are forbidden.
