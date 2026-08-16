# Session handoff

## Verified

- The repository is at pre-M0/M0; there is no RTL or executable golden model yet.
- The isolated harness points to the parent directory as the project root.
- feature_list.json contains exactly one active feature: m0-operation-matrix.
- verify_project.py uses only the Python standard library.
- NTT-iNTT contains the KiD paper and no source code.

## Changed

- Seeded the real M0 backlog.
- Replaced the no-op bootstrap with prerequisite and integrity checks.
- Added the ignored .harness-bootstrap.ok marker written by init.sh.
- Added initializer state and the initial docs/operation_matrix.md skeleton.

## Not yet verified

- The user has not yet run bash harness-codex-MLKEM-MLDSA/init.sh.
- The KiD PDF has not been text-extracted or visually inspected because PDF tooling is unavailable.
- No FIPS documents or golden implementations have been pinned locally.
- The operation matrix is a skeleton and must remain in_progress.

## Next best action

1. User runs: bash harness-codex-MLKEM-MLDSA/init.sh
2. Install Poppler in WSL if desired: sudo apt-get update && sudo apt-get install -y poppler-utils
3. Fetch official FIPS 203 and FIPS 204 sources and populate docs/operation_matrix.md with exact citations.
4. Run verify_project.py with --strict-active and record evidence only after substantive decomposition.
5. Run each worker bootstrap in its nested worktree before opening its agent session.
6. Start Codex and Antigravity from their assigned nested worktrees; both packets are active.

## Parallel-agent mode

- This conversation is the Captain and remains the user's project-status interface.
- Codex worker target: normative FIPS operation-matrix decomposition.
- Antigravity worker target: KiD paper evidence extraction.
- Workers must not update feature_list, memory, state, assignments, or each other's output paths.

## Key commands

```bash
bash harness-codex-MLKEM-MLDSA/init.sh
python3 harness-codex-MLKEM-MLDSA/harness/tools/verify_project.py \
  --project-root . \
  --harness-root harness-codex-MLKEM-MLDSA
```
