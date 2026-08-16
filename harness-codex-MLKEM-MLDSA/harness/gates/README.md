# Gates

Every result must pass the gates before it is accepted. Fail-closed: if one gate fails,
stop — do not pass the result downstream.

| Gate | Name               | Type          | Checks |
|------|--------------------|---------------|--------|
| G1   | technical_validity | computational | runs / parses / valid |
| G2   | structure          | computational | correct format / schema |
| G3   | verification       | computational | tests / checks pass |
| G4   | semantic_review    | inferential   | matches intent (see `evaluator-rubric.md`) |

- computational — deterministic checks (parser, linter, tests, types).
- inferential — judgment via `evaluator-rubric.md`.

Implemented in `gates.py` (`run_gates()` runs them in order, fail-closed). Replace the
`gN_*` functions with your project's real checks. Before ending a session, run
`clean-state-checklist.md`.
