---
name: harness-start
description: Use at the start of a session in a repo with a .harness/ folder, after /clear, or when asked to resume, re-check, or repair harness state. Finishes the read order, runs init, and routes abnormal start states to failure-modes.
allowed-tools: Read, Grep, Glob, Bash(git status *), Bash(git log *), Bash(git branch *), Bash(./scripts/init.sh)
effort: low
---

# Harness start

The SessionStart hook already printed PROJECT_STATE + CURRENT_TASK. Do the rest of
`.harness/SESSION-CHECKLIST.md` → "On session start":

1. Read the active phase file (`.harness/phases/`) for the current feature, then
   `DECISIONS.md` + `BLOCKERS.md`. If `MAX_LANES > 1` in `LANES.md`, read it and name your lane.
2. Run `init` (`SESSION-CHECKLIST.md` → Commands → Verify baseline). Not implemented yet? Say
   so and run the "Test (full suite)" command instead.
3. Check `state/clean-state-checklist.md` → "Before starting work". Anything fails → follow
   `loops/failure-modes.md` → "At session start" before any feature work.
4. Inspect the code the current task touches. If it disagrees with the tracking files, the
   code wins: correct the files and note it in `CHANGELOG.md`.
5. Report in at most five lines: feature, exact next step, baseline green/red, what you repaired.
