# Harness

Drop the contents of this folder into your project root. Replace every
`TODO`/`<placeholder>`.

## Layout
```
<project-root>/
├── AGENTS.md                  # root instructions (entry point)
├── init.sh                    # environment setup
├── feature_list.json          # feature tracker
├── feature_list.schema.json   # schema for feature_list.json
└── harness/
    ├── config/harness.yaml    # models, limits, gates, HITL policy
    ├── agents/                # captain + initializer/planner/builder/tester/verifier/reviewer
    ├── orchestrator/          # run_harness.py — the loop driver
    ├── tools/                 # project tools the agents may use
    ├── gates/                 # gates.py + evaluator-rubric.md + clean-state-checklist.md
    ├── memory/                # progress.md + session_handoff.md
    ├── state/                 # per-agent working state
    ├── runs/                  # per-run logs and traces
    └── docs/                  # getting-started, overview, customization, roles, human-in-the-loop
```

## Start here (new users)
- `docs/getting-started.md` — what this is, how to set it up, run the demo, what each file is.
- `docs/overview.md` — the session lifecycle and roles.
- `docs/customization.md` — where to change things.
- `docs/roles.md` — the agents and how they hand off.
- `AGENTS.md` — the instructions agents follow every session.

## Run the demo
    cd harness/orchestrator && python run_harness.py

Reads `feature_list.json`, runs one loop (with an approval step and the gates), and
writes `harness/runs/<run_id>/`. No external dependencies; it does not modify the
`memory/` or `state/` templates.
