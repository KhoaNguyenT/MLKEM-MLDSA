# Project progress

## Current Verified State

- Project stage: pre-M0 / M0 architecture research
- Project root: parent of harness-codex-MLKEM-MLDSA
- Harness root: harness-codex-MLKEM-MLDSA
- Bootstrap command: bash harness-codex-MLKEM-MLDSA/init.sh
- Verification command: python3 harness-codex-MLKEM-MLDSA/harness/tools/verify_project.py --project-root . --harness-root harness-codex-MLKEM-MLDSA
- Active feature: m0-operation-matrix
- Source status: Mydev_before contains a legacy, pre-optimization ML-KEM RTL baseline;
  it has no build manifest, testbench, XDC, Vivado project, or reproducible PPA result
- Local research input: KiD unified NTT paper under docs/references/papers
- Normative baseline: NIST FIPS 203 and FIPS 204; constants must be sourced, not inferred from the handoff

## Session Records

### 2026-08-16 - Harness initialization

- Read the ChatGPT-to-Codex handoff and inventoried the repository.
- Confirmed NTT-iNTT currently contains only the KiD PDF.
- Replaced the example backlog with four concrete M0 features.
- Selected m0-operation-matrix as the sole in-progress feature.
- Added an idempotent bootstrap check and deterministic harness-integrity verifier.
- Created an operation-matrix skeleton without claiming algorithmic completion.
- PDF extraction was initially deferred pending local tooling.

### 2026-08-16 - Parallel-agent control plane

- Designated the current user-facing Codex conversation as the Captain session.
- Added isolated Codex and Antigravity work packets with non-overlapping writable paths.
- Reserved shared harness state, integration, evidence acceptance, and user reporting for the Captain.
- Worker worktrees were created and are stored inside the Captain root as
  `MLKEM-MLDSA-codex/` and
  `MLKEM-MLDSA-antigravity/`; both are ignored by the Captain branch.

### 2026-08-16 - Handoff-driven workflow audit

- Re-read the project handoff as context and compared it with the active worker packets.
- Corrected the initial assignment that sent Antigravity to KiD research too early.
- Split the active operation-matrix feature by normative standard: Codex stages the
  FIPS 203 / ML-KEM half; Antigravity stages the FIPS 204 / ML-DSA half.
- Reserved `docs/operation_matrix.md` for Captain review and integration, preventing
  concurrent writes while keeping both workers on the highest-priority M0 objective.
- Deferred KiD architecture extraction until reference-architecture or NTT research.

### 2026-08-17 - Reference library and vendor sources

- Moved the existing KiD PDF into `docs/references/papers/`.
- Added `docs/references/PAPERS_NEEDED.md` using only document titles explicitly
  present in the project handoff.
- Shallow-cloned the two golden candidates and four RTL/architecture references into
  `Vendor/`; the large PQC-OpenTitan repository uses a partial sparse checkout.
- Recorded upstream URLs and exact commits in `Vendor/MANIFEST.md`.

### 2026-08-17 - Legacy ML-KEM baseline and EDA policy

- Discovered the supplied `Mydev_before/00_src` tree with 96 Verilog and 30
  SystemVerilog files across arithmetic, NTT/INTT, Keccak, sampler, codec, memory, and
  controller blocks.
- Confirmed Verilator 5.032 and Windows Vivado 2024.2 are locally available.
- Recorded that Mydev_before has no build scripts, source manifest, XDC, Vivado project,
  target FPGA part, or documented clock target.
- Added a not-started baseline-reproduction feature and a dual Verilator/Vivado PPA
  methodology; no historical PPA claim is accepted until reproduced.
- Removed the unused, untracked `Mydev_before/00_src/NTT_fail` directory (12 files) at
  the project owner's explicit request; retained `NTT_INTT` is unchanged.

### 2026-08-17 - Paper library update

- Inventoried eight local PDFs: FIPS 203, FIPS 204, three handoff-requested architecture
  papers, and three supplementary ML-KEM/ML-DSA architecture papers.
- Marked four previously requested documents as present and retained the two
  owner-reported missing titles as unavailable.
- Added local FIPS PDFs to the respective worker read-only contexts.
- Verified PDF metadata, page count, and first-page title text with Poppler 26.01.0 in WSL;
  paper-result and implementation-claim review remains pending.
