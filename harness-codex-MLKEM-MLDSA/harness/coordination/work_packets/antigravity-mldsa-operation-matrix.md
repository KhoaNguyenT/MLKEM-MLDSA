# Work packet: Antigravity - ML-DSA operation decomposition

Status: active.

## Objective

Produce the ML-DSA half of the operation matrix from official FIPS 204 sources. Work
in a staging document so the Captain can integrate it with the independently reviewed
ML-KEM half.

## Writable paths

- docs/research/fips204_mldsa_operation_decomposition.md
- harness-codex-MLKEM-MLDSA/harness/coordination/reports/antigravity-mldsa-operation-matrix.md

## Read-only context

- docs/references/papers/NIST.FIPS.204.pdf
- MLKEM_MLDSA_CODEX_HANDOFF.md
- docs/operation_matrix.md
- harness-codex-MLKEM-MLDSA/feature_list.json

## Forbidden paths

- docs/operation_matrix.md
- docs/research/fips203_mlkem_operation_decomposition.md
- harness-codex-MLKEM-MLDSA/feature_list.json
- harness-codex-MLKEM-MLDSA/harness/memory/
- harness-codex-MLKEM-MLDSA/harness/state/
- harness-codex-MLKEM-MLDSA/harness/coordination/assignments.json

## Deliverables

- Hardware-relevant decomposition of ML-DSA KeyGen, Sign, and Verify.
- Recursive algorithm -> function -> polynomial/hash/sampler/codec -> arithmetic primitive mapping.
- Exact FIPS 204 section/algorithm citations for normative operations and constants.
- Invocation counts, widths, modulus, dimensions, dependencies, memory lifetime,
  parallelism, sharing potential, and security concerns where derivable.
- Facts and architecture hypotheses clearly separated.
- Worker report containing verification commands, limitations, changed files, and commit hash.

## Verification

Check citation coverage and internal consistency. Do not edit the integrated operation
matrix or mark the feature passing.
