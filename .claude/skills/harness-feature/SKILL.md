---
name: harness-feature
description: Use when starting, planning, or continuing the harness's active feature (the F0xx id in .harness/CURRENT_TASK.md) — sprint contract first, then implement, then harness-verify. Not for editing harness machinery.
allowed-tools: Read, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git switch *)
effort: high
---

# Harness feature — contract → implement → verify

Work only the feature in `.harness/CURRENT_TASK.md` (rule 2), on `feat/<FID>` or your lane's
branch.

## 1. Contract (Planner), in plan mode
- No signed contract for this FID yet: enter plan mode and fill the template in
  `.harness/verification/sprint-contract.md` from the phase file. Vague acceptance: interview
  the user until you could write the contract yourself — at most six questions, no code.
- §2 from `verification/edge-cases.md`. §6: expected files and lines, owned modules, the 2–3
  neighboring files you read and will match, and every new dependency, abstraction or config
  tied to an acceptance item (default: none).
- The contract is the plan. Once it's approved, write it to disk.

## 2. Implement (Maker)
- Thinnest slice (rule 9). Match the neighbors (`rules/conventions.md` → Readability & fit).
  Write the direct version: no new seam unless `architecture/MODULES.md` lists it or this is
  its third occurrence (rule 6). If a change can be made by deleting code, delete.
- Write the edge/error tests and the e2e test the contract names. Don't grade your own work.
- Going over the §6 budget: write the reason in §6 before you continue.

## 3. Verify
Run `/harness-verify`. REVISE: fix the listed defects and repeat, up to MAX_ROUNDS
(`loops/loop-state.md`). PASS: ask the user to run `/harness-record`.
