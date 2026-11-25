# ROADMAP

All features across all phases, with permanent ids and status. Source of truth for **scope**.
Statuses: `NOT STARTED` · `IN PROGRESS` · `BLOCKED` · `IN REVIEW` · `COMPLETE` · `DEPRECATED`.

**Progress**: 2 / 4 COMPLETE (50%)

> Reconstructed in **Adopt** mode from the existing repo (git history + current contents). F001
> and F002 were built before the harness wrapped this repo — they are `COMPLETE` with evidence
> "adopted (pre-harness); baseline self-check green" (`CHANGELOG.md`, `ADOPTION.md`). Changing
> either re-enters the full loop (`AGENTS.md` → Mode).

## Scheduling notation
- **`deps:`** — features that must be `COMPLETE` and merged first.
- **`par:`** — parallel-group tag; `par: solo` = must run alone (touches the single core
  artifact). Parallel mode is OFF here (`MAX_LANES=1`), so this is just the build order.

## Phase 01 — The Harness
- [x] **F001** — one-file portable bootstrap: scaffolds `.harness/` (maker-checker / PR-review /
      timer / goal loops + failure modes, workflow graph + JSON twin, roles + rubric + evidence
      + e2e/edge battery, rules + script contracts, tracking system, runtime continuity) —
      `deps: none` · `par: solo` — `COMPLETE`   <!-- adopted: commit f538e2e -->
- [x] **F002** — opt-in parallel lanes + integration queue: git-native claim ledger (no dropped
      / double-claimed feature) + merge queue (no lane breaks another), `LANES.md` —
      `deps: F001` · `par: solo` — `COMPLETE`   <!-- adopted: commit 9728a23 -->
- [ ] **F003** — existing-repo (Adopt) mode + LLM-agnostic entry points: two-mode bootstrap,
      six root pointer files → one neutral canonical contract, archetype D, dogfooded
      `.harness/` in this repo; plus the simplicity-bias fix (rule of three, rubric criterion 6)
      and the optional Claude Code enforcement layer + plugin installer (DEC-011) —
      `deps: F002` · `par: solo` — `IN PROGRESS`
- [ ] **F004** — runnable automation + CI: `scripts/selfcheck.sh` + `check-architecture.sh` +
      `e2e.sh` (scaffold into a scratch dir, self-check there) + a CI workflow gating PRs —
      `deps: F003` · `par: -` — `NOT STARTED`

## Parallel plan (the explicit schedule)
Build order, one at a time (`MAX_LANES=1`): **F001 → F002 → F003 → F004**. Every feature edits
the single distributable (`HARNESS-BOOTSTRAP.md`), so each is inherently `par: solo` —
serialize them. Turn on parallel mode only if the artifact is ever split into independent
modules with disjoint files.

<!-- add Phase 02 (e.g. richer archetypes, a published install command) when the product grows -->
