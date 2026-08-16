# Evaluator rubric (inferential check, used by the verifier)

Deterministic gates (G1–G3) answer "does it run / parse / pass tests?". This rubric is
the **inferential** check (G4): does the work actually satisfy the feature's intent? The
verifier applies it with a clean context, judging the result — not the process.

Score each dimension: **pass / partial / fail**. Any `fail` blocks `passing`.

## 1. Behavior match
- Does the result produce the feature's `user_visible_behavior` exactly?
- Were the feature's `verification` steps followed as written?

## 2. Scope
- Changes stay within the active feature; nothing unrelated was modified.
- No new features were silently introduced.

## 3. Correctness beyond the happy path
- Obvious edge cases / error paths considered.
- No regressions in adjacent behavior.

## 4. Evidence
- Verification was actually run and its output is recorded (not asserted).
- Evidence is specific enough to reproduce.

## 5. Clean state
- The tree is resumable; no half-finished edits left undocumented.
- `progress.md` / `feature_list.json` reflect reality.

## Decision
- All dimensions `pass` → set the feature `status` to `passing`, fill `evidence`.
- Any `partial` → keep `in_progress` with a concrete follow-up.
- Any `fail`, or conflicting/low-confidence evidence → keep `in_progress`/`blocked`, and
  escalate to a human (HITL) when the call is high-risk.
