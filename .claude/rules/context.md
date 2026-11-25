# Context discipline (Claude Code)

- The harness writes state to disk because context doesn't survive. After compaction or
  `/clear`, the SessionStart hook re-prints PROJECT_STATE + CURRENT_TASK. Everything else is
  re-read from `.harness/` when a step needs it.
- A feature boundary is a context boundary: `/clear` after `/harness-record`, before the next
  feature. Don't carry one feature's reasoning into the next.
- `/context` shows what is loaded. Read loops/graph/verification docs when a step needs them,
  not all up front.
- Anything a later session needs goes into a tracking file before you stop, not into chat.
- Skills: `/harness-start`, `/harness-feature`, `/harness-verify`; the user runs
  `/harness-record` and `/harness-lane`.
