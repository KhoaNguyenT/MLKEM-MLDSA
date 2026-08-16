# Parallel-agent coordination

This directory is the control plane for one Captain session and multiple isolated workers.

## Roles

- Captain: the long-lived user-facing session. Owns planning, assignments, integration, feature status, evidence acceptance, memory, and final project reports.
- Codex worker: performs one bounded work packet in its own Git branch/worktree.
- Antigravity worker: performs one bounded work packet in its own Git branch/worktree.

Workers do not communicate through chat context. They communicate through committed work packets, reports, evidence, and commit hashes.

## Isolation rules

1. Each worker uses a separate branch and worktree.
2. A work packet lists exact writable paths. Everything else is read-only.
3. Workers must not edit feature_list.json, harness/memory, harness/state, or assignments.json.
4. Only the Captain changes shared harness state and merges worker commits.
5. Two active work packets must not have overlapping writable paths.
6. A worker never merges, rebases, force-pushes, or marks a feature passing.
7. On completion, a worker writes a report under its permitted report path and returns the commit hash.
8. The Captain reviews the diff and evidence before cherry-picking or merging.

## Lifecycle

1. Captain updates assignments.json and creates a work packet.
2. User starts the worker in its assigned worktree.
3. Worker reads root AGENTS.md and its work packet.
4. Worker implements only the packet and runs listed verification.
5. Worker commits to its own branch after user approval.
6. Captain reviews and integrates; Captain alone updates feature status and memory.

## Conflict policy

If a worker discovers that it needs an unassigned path, it stops and reports the requested scope expansion. It does not edit the path speculatively.
