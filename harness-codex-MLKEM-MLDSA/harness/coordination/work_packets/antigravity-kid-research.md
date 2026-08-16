# Work packet: Antigravity - KiD evidence extraction

Status: active.

## Objective

Inspect the local KiD paper and extract source-backed evidence relevant to unified ML-KEM/ML-DSA NTT architecture. This is supporting research, not authority for final FIPS behavior.

## Writable paths

- docs/research/kid_unified_ntt_notes.md
- harness-codex-MLKEM-MLDSA/harness/coordination/reports/antigravity-kid-research.md

## Read-only context

- NTT-iNTT/AHardwareDesignFrameworkTargetingUnifiedNTTMultiplicationforCRYSTALSKyberandCRYSTALSDilithiumonFPGA.pdf
- MLKEM_MLDSA_CODEX_HANDOFF.md
- docs/operation_matrix.md

## Forbidden paths

- docs/operation_matrix.md
- harness-codex-MLKEM-MLDSA/feature_list.json
- harness-codex-MLKEM-MLDSA/harness/memory/
- harness-codex-MLKEM-MLDSA/harness/state/
- harness-codex-MLKEM-MLDSA/harness/coordination/assignments.json

## Deliverables

- Paper metadata and architecture summary.
- NTT schedule, BFU, memory mapping, twiddle, pipeline, FPGA target, and PPA evidence with page/table/figure references.
- Explicit separation of paper facts, worker interpretation, and applicability caveats for final FIPS 203/204.
- Worker report containing verification performed, limitations, changed files, and commit hash.

## Verification

Confirm every quantitative claim has a page/table/figure reference. Do not modify normative algorithm documentation or mark a feature passing.
