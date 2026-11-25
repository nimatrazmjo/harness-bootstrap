# Phase 01 — The Harness

Acceptance-criteria home for Phase 01. F001 / F002 are adopted (criteria recorded as met by the
baseline self-check); F003 is the active feature; F004 is next.

## F001 — one-file portable bootstrap
**Status**: COMPLETE (adopted — commit f538e2e)
**Depends on**: none
### Acceptance criteria
- [x] A single `HARNESS-BOOTSTRAP.md` scaffolds the full `.harness/` tree, delimiters balanced,
      no leaks.
- [x] Ships the loops, graph (+ JSON twin), verification discipline, rules, script contracts,
      tracking system, runtime continuity.
- [x] Self-check passes (file count, no leaks, valid JSON, FILL discipline).
### Evidence
Adopted: baseline self-check GREEN on the scaffolded tree (`ADOPTION.md`, `CHANGELOG.md`).

## F002 — opt-in parallel lanes + integration queue
**Status**: COMPLETE (adopted — commit 9728a23)
**Depends on**: F001
### Acceptance criteria
- [x] `LANES.md` claim ledger; a claim is a commit to `main` (git mutex); no feature dropped or
      double-claimed.
- [x] Integration queue merges lanes one at a time with a full re-run on the integrated main.
- [x] Ships OFF (`MAX_LANES=1`) — identical to the single-feature loop until turned on.
### Evidence
Adopted: present and self-consistent in the bootstrap; baseline self-check GREEN.

## F003 — existing-repo (Adopt) mode + LLM-agnostic entry points
**Status**: IN PROGRESS
**Depends on**: F002
### Acceptance criteria
- [ ] Bootstrap detects Greenfield vs Adopt and documents both; the Adopt procedure reads the
      code and fills requirement / architecture / tracking from reality.
- [ ] Canonical contract `.harness/AGENTS.md` is vendor-neutral; six root pointer files
      (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`,
      `.cursor/rules/harness.mdc`, `.windsurf/rules/harness.md`) each redirect to it, no copy.
- [ ] `.harness/CLAUDE.md` renamed to `.harness/SESSION-CHECKLIST.md`; no Claude-only skill or
      CLI assumed in machinery.
- [ ] Self-check updated to 48 files (64 with the Claude layer) + agnostic-wiring + Adopt +
      Claude-layer checks, and passes on this repo.
- [ ] This repo dogfoods it: `.harness/` scaffolded and populated via Adopt mode.
- [ ] **Simplicity bias fixed** (folded in 2026-11-24): rule 6 = rule of three; rubric
      criterion 4 two-sided + new criterion 6 Simplicity (veto); MODULES lists only existing
      seams; conventions "Readability & fit"; sprint contract §6 Budget & fit + interview
      pattern; cleanup-scanner reports speculative generality; PR loop has a separate
      fresh-context simplicity pass.
- [ ] **Optional Claude Code layer** (folded in): 16 FILE blocks under `.claude/` in a fenced
      optional section (settings floor, 3 hooks, 3 path/always rules, 5 skills, 3 subagents);
      every hook runs and is covered by `scripts/test-hooks.sh`; native-feature footers in the
      goal/parallel/pr-review/timer loops; model/effort column in the graph; benchmark →
      `claude plugin eval`. Skipping the section still yields a complete 48-file harness.
- [ ] Plugin installer (`.claude-plugin/`, `skills/bootstrap/`, `evals/scaffold-smoke/`) passes
      `claude plugin validate .`; curl path unchanged.
### Evidence expected
- `HARNESS-BOOTSTRAP.md` edits + extraction into this repo; self-check GREEN (recorded in
  `CHANGELOG.md` at completion).
- Edge cases (`verification/edge-cases.md`): existing root file present → append, not clobber;
  re-run idempotent; ambiguous/stub repo → greenfield; malformed FILE block → extractor skips.

## F004 — runnable automation + CI
**Status**: NOT STARTED
**Depends on**: F003
### Acceptance criteria
- [ ] `scripts/selfcheck.sh`, `scripts/check-architecture.sh` (rules 1–8 of
      `rules/layer-boundaries.md`), `scripts/e2e.sh` (scaffold into a scratch dir + self-check).
- [ ] A CI workflow runs them on every PR and fails the build on any violation.
- [ ] E2E: `HARNESS-BOOTSTRAP.md` scaffolds cleanly into an empty scratch repo (greenfield) and
      the self-check is green there.

## Phase completion criteria
F001–F004 `COMPLETE` with evidence and the self-check (the phase smoke test) green before any
Phase 02 starts.
