# Clean-state checklist (run before ending a session)

The session should end in a state the next session can resume from cleanly. Check every
item before you stop.

## Verification
- [ ] Tests / lint / type checks were actually run (not assumed).
- [ ] Evidence recorded (path/log) for the active feature.
- [ ] Any feature marked `passing` has recorded evidence.

## State of the tree
- [ ] No half-applied edits; the build still works, or the breakage is documented.
- [ ] Only in-scope files were changed (no unrelated refactors).
- [ ] Working tree committed, or a clean restart path is documented if not.

## Memory & plan updated
- [ ] `feature_list.json` statuses are accurate (exactly one `in_progress`, or none).
- [ ] `harness/memory/progress.md` has a new Session Record entry.
- [ ] `harness/memory/progress.md` "Current Verified State" is still accurate.
- [ ] `harness/memory/session_handoff.md` written: what's verified, what changed, what's
      still broken, next best action, key commands.

## Restart path
- [ ] The next session can run `bash ./init.sh` and reach a known-good state.
- [ ] "Next best action" points to a concrete starting step.

If any box is unchecked, the session is not clean — fix it or document why before ending.
