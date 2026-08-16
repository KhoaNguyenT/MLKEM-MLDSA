# Session handoff

## Verified

- The repository is at M0; `Mydev_before` is a legacy ML-KEM RTL baseline, not yet
  reproducible through a source manifest or testbench.
- The isolated harness points to the parent directory as the project root.
- feature_list.json contains exactly one active feature: m0-operation-matrix.
- verify_project.py uses only the Python standard library.
- The KiD paper has moved from NTT-iNTT to docs/references/papers.

## Changed

- Seeded the real M0 backlog.
- Replaced the no-op bootstrap with prerequisite and integrity checks.
- Added the ignored .harness-bootstrap.ok marker written by init.sh.
- Added initializer state and the initial docs/operation_matrix.md skeleton.

## Not yet verified

- The Captain worktree bootstrap marker exists. Each worker worktree needs its own
  user-run bootstrap before starting that worker session.
- Poppler 26.01.0 in WSL verified metadata, page count, and first-page title text for
  all eight PDFs; detailed technical review remains pending.
- FIPS 203 and FIPS 204 PDFs are locally available, and candidate repositories are
  pinned in `Vendor/MANIFEST.md`.
- The operation matrix is a skeleton and must remain in_progress.

## Next best action

1. Commit the reviewed harness, documentation, Vendor manifest, and legacy-baseline setup.
2. Fast-forward the two worker worktrees and rename their branches to match the revised packets.
3. User runs each worker bootstrap in its nested worktree before opening that worker session.
4. Start Codex and Antigravity from their assigned nested worktrees; both packets are active.
5. Run verify_project.py with --strict-active and record evidence only after substantive decomposition.

## Parallel-agent mode

- This conversation is the Captain and remains the user's project-status interface.
- Codex worker target: stage the ML-KEM half from FIPS 203 in a dedicated research file.
- Antigravity worker target: stage the ML-DSA half from FIPS 204 in a dedicated research file.
- Captain target: review both worker commits and integrate accepted content into
  `docs/operation_matrix.md`.
- KiD paper extraction is deferred until reference-architecture or NTT research.
- `Mydev_before` is a legacy ML-KEM baseline. Use Verilator for per-target simulation
  and Vivado 2024.2 for implementation/PPA after top, part, clock, XDC, and source lists
  are confirmed. Do not optimize the legacy tree in place.
- Workers must not update feature_list, memory, state, assignments, or each other's output paths.

## Key commands

```bash
bash harness-codex-MLKEM-MLDSA/init.sh
python3 harness-codex-MLKEM-MLDSA/harness/tools/verify_project.py \
  --project-root . \
  --harness-root harness-codex-MLKEM-MLDSA
```
