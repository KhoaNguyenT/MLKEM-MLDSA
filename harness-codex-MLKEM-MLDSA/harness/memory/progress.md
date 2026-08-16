# Project progress

## Current Verified State

- Project stage: pre-M0 / M0 architecture research
- Project root: parent of harness-codex-MLKEM-MLDSA
- Harness root: harness-codex-MLKEM-MLDSA
- Bootstrap command: bash harness-codex-MLKEM-MLDSA/init.sh
- Verification command: python3 harness-codex-MLKEM-MLDSA/harness/tools/verify_project.py --project-root . --harness-root harness-codex-MLKEM-MLDSA
- Active feature: m0-operation-matrix
- Source status: no RTL, model, build manifest, or testbench exists yet
- Local research input: KiD unified NTT paper under NTT-iNTT
- Normative baseline: NIST FIPS 203 and FIPS 204; constants must be sourced, not inferred from the handoff

## Session Records

### 2026-08-16 - Harness initialization

- Read the ChatGPT-to-Codex handoff and inventoried the repository.
- Confirmed NTT-iNTT currently contains only the KiD PDF.
- Replaced the example backlog with four concrete M0 features.
- Selected m0-operation-matrix as the sole in-progress feature.
- Added an idempotent bootstrap check and deterministic harness-integrity verifier.
- Created an operation-matrix skeleton without claiming algorithmic completion.
- PDF extraction remains pending because Poppler/pip are not installed and sudo requires user interaction.

### 2026-08-16 - Parallel-agent control plane

- Designated the current user-facing Codex conversation as the Captain session.
- Added isolated Codex and Antigravity work packets with non-overlapping writable paths.
- Reserved shared harness state, integration, evidence acceptance, and user reporting for the Captain.
- Worktrees are planned but cannot be created from the new protocol until these uncommitted setup changes are reviewed and committed.
