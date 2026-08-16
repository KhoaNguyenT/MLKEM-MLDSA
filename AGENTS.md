# Project agent instructions

The agent harness for this repository is kept in
`harness-codex-MLKEM-MLDSA/` so its state, memory, configuration, and run
artifacts remain isolated from the project sources.

Before doing project work:

1. Read and follow `harness-codex-MLKEM-MLDSA/AGENTS.md`.
2. Treat this directory (the directory containing this file) as the project root.
3. Treat `harness-codex-MLKEM-MLDSA/` as the harness package root.
4. Keep feature tracking, agent state, memory, and run evidence inside the harness
   package unless a task explicitly requires a project artifact elsewhere.

If these instructions conflict with the nested harness instructions, these path and

root-location rules take precedence.

## Parallel-agent mode

The current user-facing Codex conversation operating the main worktree is the Captain
session. It coordinates the project and reports status to the user. A session launched
inside a worktree listed under `workers` in `assignments.json` is that named worker,
not another Captain.

Before a worker starts, read
`harness-codex-MLKEM-MLDSA/harness/coordination/assignments.json` and the assigned
work packet. Codex and Antigravity workers must use separate branches/worktrees, edit
only listed writable paths, and return a report plus commit hash.

Only the Captain may update `feature_list.json`, `harness/memory/`,
`harness/state/`, or the assignment registry. Workers never merge, rebase,
force-push, or mark features passing.
