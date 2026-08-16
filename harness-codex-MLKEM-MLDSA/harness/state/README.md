# State — working-state subsystem

**Working / session state**: a snapshot of what each orchestrated agent is doing *right
now* and what it returned. The Captain reads these files to coordinate the next step.

State answers **"where are we right now?"**; `../memory/` answers **"what happened over
time?"**. State is overwritten with the current snapshot; memory is append-only.

## Files
- One file per agent: `captain.state.md`, `planner.state.md`, `builder.state.md`,
  `tester.state.md`, `verifier.state.md`, `reviewer.state.md`, ...
- Start a new agent's file from `_TEMPLATE.state.md`.

## Flow (per step)
```
Captain dispatches agent
   └─ agent writes ../state/<agent>.state.md  (status, current task, result)
Captain reads ../state/<agent>.state.md
   └─ decides next step, updates ../../feature_list.json + ../memory/progress.md
```

## Status values
`idle | running | waiting_human | blocked | done`

## What each field means
- Status / Current task — what the agent is doing now.
- Active feature id — the one `in_progress` feature from `feature_list.json`.
- Inputs consumed / Outputs produced — traceability.
- Result summary — what it returned to the Captain.
- Blocker — why it stopped, if it did.
