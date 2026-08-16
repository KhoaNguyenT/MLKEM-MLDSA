# Human-in-the-loop (HITL)

HITL pauses the agent at decision points so a human can approve, reject, or edit before
it acts. The run state is checkpointed, so the agent can wait and then resume from the
same point.

## Where it fits
HITL is a branch in the loop, next to the gates:
- Gates handle what can be checked automatically.
- HITL handles what needs human judgement.

The orchestrator handles pause/resume; state holds the checkpoint; memory logs the
decision (who approved, when, and the exact action).

## When to pause
- High-risk or irreversible actions (write, delete, promote, deploy, commit).
- A gate fails or cannot decide.
- Low confidence or conflicting evidence.
- Retry / scope limits reached.

## Configuration
See `hitl:` in `../config/harness.yaml`:
- `require_approval_for` — tool-name patterns that always need approval.
- `escalate_when` — confidence threshold and conflict/retry flags.
- `reviewers`, `approval_timeout_seconds` — who approves and how long to wait.

Reference implementation: `needs_approval()` in `../orchestrator/run_harness.py`.
