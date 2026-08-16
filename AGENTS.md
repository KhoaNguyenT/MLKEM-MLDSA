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
