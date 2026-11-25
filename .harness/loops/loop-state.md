# Loop State

Live state for the maker-checker loop (single lane; `MAX_LANES=1`, main tree). Overwrite the
"Current" block each round; append finished features to History. Keep consistent with
`../CURRENT_TASK.md`.

## Parameters (current feature)
- Lane: single
- Feature: F003 — existing-repo (Adopt) mode + LLM-agnostic entry points
- REQUIRED_PASSES: 2
- MAX_ROUNDS: 6

## Current
- Round: 1
- consecutivePasses: 0
- Last Maker change: edited `HARNESS-BOOTSTRAP.md` (two modes + Adopt procedure + LLM-agnostic
  entry points + rename `CLAUDE.md` → `SESSION-CHECKLIST.md` + `ADOPTION.md` + archetype D +
  48-file self-check); scaffolded and Adopt-populated `.harness/` + 6 root pointers in this repo.
- Last Checker verdict: pending (self-check GREEN; independent review pass not yet run)
- Standing defects: none recorded
- Next action: update `README.md`; then review + commit F003 (see `CURRENT_TASK.md`)

## History
```
(feature id | rounds used | final verdict | date)
F001 | adopted | COMPLETE (pre-harness) | 2026-11-02
F002 | adopted | COMPLETE (pre-harness) | 2026-11-02
```

## Escalations
```
(date | feature | reason | resolution)
--- none yet ---
```
