# Work packet: Codex - M0 operation matrix

Status: active.

## Objective

Populate the normative algorithm decomposition in docs/operation_matrix.md from official FIPS 203 and FIPS 204 sources.

## Writable paths

- docs/operation_matrix.md
- harness-codex-MLKEM-MLDSA/harness/coordination/reports/codex-m0-operation-matrix.md

## Read-only context

- MLKEM_MLDSA_CODEX_HANDOFF.md
- NTT-iNTT/
- harness-codex-MLKEM-MLDSA/feature_list.json

## Forbidden paths

- harness-codex-MLKEM-MLDSA/feature_list.json
- harness-codex-MLKEM-MLDSA/harness/memory/
- harness-codex-MLKEM-MLDSA/harness/state/
- harness-codex-MLKEM-MLDSA/harness/coordination/assignments.json

## Deliverables

- Hardware-relevant decomposition of all six top-level operations.
- Exact citations for normative operations and constants.
- Facts and architecture hypotheses clearly separated.
- Worker report containing verification commands, limitations, changed files, and commit hash.

## Verification

Run the strict active-artifact verifier and manually check citation coverage. Do not mark the feature passing.
