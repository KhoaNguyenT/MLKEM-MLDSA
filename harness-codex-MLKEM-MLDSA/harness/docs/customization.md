# Customization — where to change things

Find what you want to change on the left; edit the file on the right.

## Behaviour & policy (no code)
| To change... | Edit | Where |
|--------------|------|-------|
| Which model an agent uses, or its temperature | `harness/config/harness.yaml` | `models:` |
| Max loop iterations, retries, step timeout | `harness/config/harness.yaml` | `limits:` |
| Which actions require human approval | `harness/config/harness.yaml` | `hitl.require_approval_for` |
| When to escalate (confidence, conflicts, retries) | `harness/config/harness.yaml` | `hitl.escalate_when` |
| Who approves / how long to wait | `harness/config/harness.yaml` | `hitl.reviewers`, `approval_timeout_seconds` |
| Turn approval off for a demo | `harness/config/harness.yaml` | `hitl.demo_auto_approve` |

## The plan & the environment
| To change... | Edit |
|--------------|------|
| The features to build, their status/priority/evidence | `feature_list.json` (rules: `feature_list.schema.json`) |
| The environment setup commands | `init.sh` |
| What the agent records each session | `harness/memory/progress.md` (the entry format) |
| What the handoff captures | `harness/memory/session_handoff.md` |

## Agents (roles)
| To change... | Edit |
|--------------|------|
| An agent's job, scope, or allowed tools | `harness/agents/<name>.md` |
| Add a new agent role | Copy `harness/agents/AGENT_TEMPLATE.md` to `harness/agents/<new>.md`, then reference it from `harness/agents/captain.md` |
| How the Captain coordinates the others | `harness/agents/captain.md` |

## Verification ("what counts as done")
| To change... | Edit |
|--------------|------|
| Add or change an automated check | `harness/gates/gates.py` (the `gN_*` functions) |
| The order of the gates, or fail-closed behaviour | `harness/config/harness.yaml` `gates:` and `gates.py` `GATE_ORDER` |
| The judgement criteria for "done" | `harness/gates/evaluator-rubric.md` |
| The end-of-session checklist | `harness/gates/clean-state-checklist.md` |

## Tools
| To change... | Edit |
|--------------|------|
| Add a tool the agents can call | Add it under `harness/tools/` (follow `example_tool.py`) and list it in `harness/tools/README.md` |

## The flow & the loop
| To change... | Edit |
|--------------|------|
| The session startup flow or the rules | `AGENTS.md` (`CLAUDE.md` mirrors it) |
| The loop implementation itself | `harness/orchestrator/run_harness.py` |

## Rule of thumb
- Changing **policy** (models, limits, approvals, gate order) → `harness/config/harness.yaml`.
- Changing **an agent's behaviour** → its `harness/agents/*.md`.
- Changing **what "done" means** → `harness/gates/`.
- Changing **the plan or environment** → `feature_list.json` / `init.sh`.
- Only touch `harness/orchestrator/run_harness.py` when you change the loop mechanics.
