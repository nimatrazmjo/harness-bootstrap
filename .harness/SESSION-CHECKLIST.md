# SESSION-CHECKLIST — Session Bootstrap (tool-neutral)

Quick reference for any coding agent. `AGENTS.md` is the full, canonical contract; this is the
checklist you run every session. (This file was `CLAUDE.md` in older harnesses — renamed so no
single vendor owns the checklist. The repo-root tool pointers lead here via `AGENTS.md`.)

## On session start (in order)
1. Read `PROJECT_STATE.md` — the master file. Where we are.
2. Read `LANES.md` — the lanes, the claim ledger, the integration queue. Know which lane you
   are (or that you are the single default lane, `MAX_LANES=1`).
3. Read your lane's `CURRENT_TASK.md` — the one feature + its exact next step.
4. Read `ROADMAP.md` — the feature list + statuses + deps + the parallel plan.
5. Read the active phase file under `phases/` — acceptance criteria.
6. Read `DECISIONS.md` + `BLOCKERS.md`.
7. Run `init` (see `scripts/SCRIPTS.md`) to confirm a clean baseline.
8. **Inspect the actual code.** Never trust the tracking files blindly — the codebase is
   the truth for what exists. If they disagree, correct the tracking files and note it in
   `CHANGELOG.md`.

## The one rule you break most often
Work the ONE feature your lane has `IN PROGRESS`. Evidence before you move on. Don't "quickly
also add" the next thing, and never touch a feature another lane claimed in `LANES.md`.

## Where things live
| I need to know... | Read |
|---|---|
| Where the project is right now | `PROJECT_STATE.md` (master) |
| Which lanes exist / what's claimed / the queue | `LANES.md` |
| What to do next | my lane's `CURRENT_TASK.md` |
| The whole feature list + status + deps + parallel plan | `ROADMAP.md` |
| How lanes are spawned/claimed and merged | `loops/parallel-loop.md`, `loops/integration-loop.md` |
| Acceptance for the current feature | the active `phases/PHASE-XX-*.md` |
| What's been shipped | `CHANGELOG.md` |
| What's decided (don't relitigate) | `DECISIONS.md` (+ `architecture/decisions/` ADRs) |
| What's stuck | `BLOCKERS.md` |
| Why / for whom | `product/PRODUCT.md`, `product/PERSONAS.md` |
| How it's structured / the data shape | `architecture/ARCHITECTURE.md`, `DATA_MODEL.md` |
| What I may import | `rules/layer-boundaries.md` |
| What's off-limits now | `rules/scope-guard.md` |
| How I prove it works | `verification/evaluator-rubric.md`, `acceptance-evidence.md` |
| The edge cases I must cover | `verification/edge-cases.md` |
| What to do when state is abnormal | `loops/failure-modes.md` |

## Commands
This repo is archetype D (docs/tooling): the "suite" is the bootstrap self-check. Runnable
scripts + CI land in **F004**; until then run the self-check inline (recorded in `ADOPTION.md`
→ Baseline and `CHANGELOG.md`).

| Action | Command |
|---|---|
| Install | `n/a` — no dependencies |
| Dev server | `n/a` |
| Typecheck | `n/a` — Markdown + one JSON file |
| Lint | `python3 -I -c "import json;json.load(open('.harness/graph/graph.json'))"` (+ optional markdown style) |
| Test (full suite) | `[ $(grep -c '^FILE:' HARNESS-BOOTSTRAP.md) = 64 ] && [ $(grep -c '^<<<BEGIN$' HARNESS-BOOTSTRAP.md) = 64 ] && [ $(grep -c '^END>>>$' HARNESS-BOOTSTRAP.md) = 64 ] && bash scripts/test-hooks.sh .claude/hooks` — block counts + hook behavior tests (full self-check wrapper → `scripts/selfcheck.sh`, **F004**) |
| E2E | scaffold `HARNESS-BOOTSTRAP.md` into a scratch dir, run the self-check there (→ `scripts/e2e.sh`, **F004**) |
| Build | `n/a` — the artifact is the source |
| Verify baseline | the self-check above (no `scripts/init.sh` yet — **F004**) |
| Check boundaries | `<check-architecture>` — not runnable yet: assert the 8 rules in `rules/layer-boundaries.md` (→ `scripts/check-architecture.sh`, **F004**); the Claude hook skips the gate while this is a placeholder |
| Progress % | count `ROADMAP.md` checkboxes (manual until **F004**) |
| Lane / Integrate | parallel mode OFF (`MAX_LANES=1`) — N/A |

## Current target
Phase 01 — The Harness. Feature **F003** — existing-repo (Adopt) mode + LLM-agnostic entry
points (IN PROGRESS). Details in `CURRENT_TASK.md`.

## Before you stop
`AGENTS.md` → Session-completion protocol, then `state/clean-state-checklist.md`.
