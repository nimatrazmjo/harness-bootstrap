# Scope Guard

What is **off-limits right now**. The active phase is whatever `PROJECT_STATE.md` says. Building
ahead of it is a defect, not initiative.

## Current phase: Phase 01 — The Harness

### In scope (current phase only)
- **F003** — existing-repo (Adopt) mode + LLM-agnostic entry points. The active feature: the
  two-mode bootstrap, the six root pointer files, the neutral canonical contract, archetype D,
  and the dogfooded `.harness/` in this repo.

### Off-limits until their phase (do NOT build now)
- **F004** — runnable automation: `scripts/selfcheck.sh` + `scripts/check-architecture.sh` +
  `scripts/e2e.sh` (scaffold-into-scratch) + a CI workflow gating PRs on them. Park it until
  F003 is merged.
- Any new archetype, any tool pointer beyond the six, or parallel-mode enablement
  (`MAX_LANES>1`) — future features; add to `ROADMAP.md`, don't build now.

## Rules of the guard
1. Tempted outside the current phase? Note it in `BLOCKERS.md` or as a future `ROADMAP.md`
   feature; stay on the active feature.
2. No dependency unless the active feature needs it — and the artifact must stay dependency-free
   (`rules/layer-boundaries.md` rule 8).
3. Keep the file inventory stable. Don't build seams for later — they earn their own
   (`AGENTS.md` rule 6). Build only now.
4. Wrong scope? Propose an edit to this file + `ROADMAP.md`; record it in `DECISIONS.md`.

## The ready set
With `MAX_LANES=1`, this is simply the build order: F003 now, F004 once F003 is merged. Phase
gating holds — a Phase 02 (if added) starts only after Phase 01 completion criteria pass.
