# Captain integration: M0 operation matrix

## Inputs

- docs/research/fips203_mlkem_operation_decomposition.md
- docs/research/fips204_mldsa_operation_decomposition.md
- Both worker reports and commits

## Review order

1. Review each worker diff against its work packet and official normative citations.
2. Reject invented constants, uncited normative claims, or architecture hypotheses presented as facts.
3. Cross-check shared primitives without assuming the two algorithms use identical parameters or schedules.
4. Integrate accepted material into docs/operation_matrix.md in Captain context.
5. Verify all six top-level operations and required primitive fields are covered.
6. Run the strict verifier and record evidence before considering `passing`.

## Boundary

Do not begin RTL, freeze interfaces, or select a final unified datapath in this feature.
KiD and other architecture papers may inform later hypotheses but are not normative sources.
