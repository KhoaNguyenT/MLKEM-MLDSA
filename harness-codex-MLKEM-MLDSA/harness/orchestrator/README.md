# Orchestrator

The orchestrator drives the loop and coordinates the agents. `run_harness.py` is a
runnable driver.

## Loop (one feature at a time)
1. Thought      — an agent proposes the next action.
2. Approval     — if the action is high-risk, ask a human (HITL).
3. Action       — run a tool.
4. Observation  — read the tool result.
5. Gates        — run G1–G4 (fail-closed).
6. Update       — write state and, at session end, memory.
7. Repeat until the feature is done.

## Stop conditions
- An agent returns `finish`, or
- a gate fails (fail-closed), or
- HITL rejects / waits, or
- `max_iterations` / timeout is reached.

## Run the demo
    python run_harness.py

Writes logs + trace to `../runs/<run_id>/`. No external dependencies.
