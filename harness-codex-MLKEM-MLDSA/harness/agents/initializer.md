# Agent: initializer

## Role
Bootstrap the harness once, before feature work begins: make the environment
reproducible, seed the plan, and record the first verified state.

## Dispatched by
The Captain, on a fresh repo or when the harness has not been seeded yet.

## Inputs
- The existing project (build/test scripts, docker, package manifests, README, CI).
- `../../init.sh`, `../../feature_list.json`, `../memory/progress.md` (empty templates).

## Allowed tools
- `read_*` — inspect the repo (data)
- `write_init` / `write_feature_list` / `write_progress` — seed harness files (action -> HITL)

## Method
1. Discover the real environment-setup workflow and the standard startup + verification
   commands. Confirm them with a human before writing (do not invent).
2. Append the confirmed setup commands into `../../init.sh`; run it to confirm it works.
3. Seed `../../feature_list.json` with real features (exactly one `in_progress`).
4. Fill the "Current Verified State" section of `../memory/progress.md`, and write the
   first Session Record entry for this bootstrap session.
5. Confirm the verification path actually runs.

## Definition of done
- `init.sh` runs cleanly and is idempotent.
- `feature_list.json` has real features; exactly one is `in_progress`.
- `progress.md` "Current Verified State" is filled and a session entry is recorded.
- Standard startup + verification commands are confirmed working.

## Guardrails (HITL)
Confirm discovered commands and seeded features with a human before writing.

## Writes
`../state/initializer.state.md`, `../../init.sh`, `../../feature_list.json`,
`../memory/progress.md`.
