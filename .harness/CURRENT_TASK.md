# CURRENT TASK

> Single lane (`MAX_LANES=1`), main tree.

**Lane**: single
**Feature**: F003 — Adopt mode + LLM-agnostic entry points + simplicity fix + Claude layer
**Phase**: Phase 01 — The Harness
**Depends on**: F002 (COMPLETE)
**Status**: IN PROGRESS

## Exact next step
1. New session → `/harness-verify`: evaluator + simplicity-reviewer score the
   `chore/harness-f003-upgrade` diff against the rubric (6 criteria).
2. With the user's go-ahead: commit, push, open PR, `/code-review`, fix findings, merge.
3. Record evidence in `CHANGELOG.md`, flip F003 → `COMPLETE`; F004 becomes active.

## Budget & fit (contract §6)
- Expected diff: ~4 files touched in the product (`HARNESS-BOOTSTRAP.md`, `README.md`, plugin
  files, `scripts/test-hooks.sh`), bootstrap 2902 → ~3500 planned. Actual: 3553 lines (+22%).
- Neighbors matched: existing FILE-block prose style; hooks follow POSIX-shell + one script per
  hook; test script mirrors the self-check's grep/assert style.
- New dependency: `jq` (Claude layer hooks only) — needed to parse hook JSON input.

## Acceptance (summary)
See `phases/PHASE-01-FOUNDATION.md` → F003 and the signed `verification/sprint-contract.md`.

## Definition of done
Every acceptance item met + evidence in `CHANGELOG.md` + self-check green + an independent
review pass + (dogfood) `.harness/` present and Adopt-populated + merged to `main`
(`AGENTS.md` → Definition of done).
