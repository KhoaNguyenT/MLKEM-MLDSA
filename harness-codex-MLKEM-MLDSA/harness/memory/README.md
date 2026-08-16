# Memory — session continuity

The record of what happened over time, so a new session can resume instead of starting
from scratch.

## Files
- `progress.md` — the progress log. Every session **reads it first** and **writes to it
  last**. Holds the *Current Verified State* plus one *Session Record* per session.
- `session_handoff.md` — a compact handoff for the next session (what's verified, what
  changed, what's still broken, next best action, key commands). Optional for small
  sessions; important for long or multi-area work.

## Read / write flow (per session)
```
START  read progress.md (Current Verified State + last Session Record)
       read session_handoff.md (fast pickup)
WORK   (do the feature)
WRAP   append a new Session Record to progress.md (newest on top)
       update Current Verified State if it changed
       write session_handoff.md, leaving a clean restart path
```

## Rules
- Append-only history: add new entries; do not rewrite past ones.
- `progress.md` is the source of truth for startup + verification commands and the
  highest-priority unfinished feature.
- Memory answers "what happened"; `../state/` answers "where are we right now".
