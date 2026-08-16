# Roles — the agents and how they work together

Each agent has a narrow job. The **Captain** orchestrates; the others are specialists it
dispatches one at a time. Full instructions for each are in `../agents/<name>.md`.

| Role | File | Responsibility | Dispatched by | Writes |
|------|------|----------------|---------------|--------|
| captain | `../agents/captain.md` | Orchestrates the loop; reads state and results; enforces the rules. | — (entry point) | `../state/captain.state.md`, memory, `feature_list.json` |
| initializer | `../agents/initializer.md` | One-time bootstrap: fill `init.sh`, seed `feature_list.json` and `progress.md`. | Captain (fresh repo) | `init.sh`, `feature_list.json`, `progress.md` |
| planner | `../agents/planner.md` | Turn the active feature into a plan + acceptance criteria. Writes no code. | Captain | `../state/planner.state.md` |
| builder | `../agents/builder.md` | Implement the one active feature, in scope only. Does not self-certify. | Captain | source files, `../state/builder.state.md` |
| tester | `../agents/tester.md` | Run tests/lint/types, capture evidence. Does not fix code. | Captain | evidence, `../state/tester.state.md` |
| verifier | `../agents/verifier.md` | Run gates + rubric; the only role that sets a feature `passing`. | Captain | `feature_list.json`, `../state/verifier.state.md` |
| reviewer | `../agents/reviewer.md` | Optional clean-context review of the diff before commit. | Captain | `../state/reviewer.state.md` |

## How they hand off (one feature)
```
Captain
  → planner   (plan + acceptance criteria)
  → builder   (implement, in scope)
  → tester    (run checks, capture evidence)
  → verifier  (gates + rubric → set passing, or send back)
  → reviewer  (optional: check the diff before commit)
Captain → update memory + feature_list + state → next feature or stop
```
At each step the agent writes its `../state/<name>.state.md`; the Captain reads it and
decides the next step. High-risk actions pause for human approval (see
`human-in-the-loop.md`).

## Why split roles
A narrow role is easier to instruct and harder to get wrong than one agent doing
everything. Key separations: the **builder** never certifies its own work; only the
**verifier** can mark a feature `passing`, and only with recorded evidence.

## Add a new role
1. Copy `../agents/AGENT_TEMPLATE.md` to `../agents/<new>.md` and fill it in.
2. Reference it from `../agents/captain.md` so the Captain knows when to dispatch it.
3. It writes its status to `../state/<new>.state.md` like the others.
