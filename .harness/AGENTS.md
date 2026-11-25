# AGENTS.md — Operating Contract (canonical, vendor-neutral)

You are a coding agent building this project — **any** agent: Claude, Gemini/Antigravity,
GitHub Copilot, Cursor, Windsurf, Codex/ChatGPT, Grok, or another. This file overrides your
defaults. Read it fully. If a request conflicts with this contract, follow the contract and
say so.

**This is the one contract.** The repo-root files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`,
`.github/copilot-instructions.md`, `.cursor/rules/harness.mdc`, `.windsurf/rules/harness.md`)
are thin pointers to this file — whichever one your tool loaded, the rules are here. Nothing in
this contract is tool-specific: where it says "run the verify" or "do a review pass", use
whatever command or capability your tool provides (`SESSION-CHECKLIST.md` → Commands has the
project's exact commands). Never fork tool-specific rules into a pointer file. Tool-specific
*enforcement and usage* (hooks, permissions, skills) may live in an optional tool layer such
as `.claude/`; it enforces these rules, it never adds new ones.

## Mode — greenfield vs. adopted repo
If `ADOPTION.md` exists and records an adoption, this harness was wrapped around a **pre-existing
codebase**: features marked `COMPLETE` with evidence "adopted (pre-harness)" were NOT built
under this loop — they are trusted only as far as the baseline test suite proves. The moment you
**change** an adopted area, it re-enters the full loop (sprint contract → maker → verify →
checker) and must earn real evidence. A greenfield repo (no adoption in `ADOPTION.md`) has no
such inherited work — everything is built under the loop from F001.

## What this project is
See `product/PRODUCT.md` for the vision and `architecture/ARCHITECTURE.md` for the shape.
Build the product the requirement describes — never a shortcut that fakes the acceptance.

## Read this order, every session (before touching code)
1. `PROJECT_STATE.md` — MASTER FILE. Where the project is right now.
2. `LANES.md` — which lanes exist, what each has claimed, the integration queue. Identify
   **which lane you are** (your worktree/branch) before anything, or that you are the single
   default lane. Skip only if parallel mode is off (`MAX_LANES=1`) and you are in the main tree.
3. `CURRENT_TASK.md` — your lane's one feature and its exact next step.
4. `ROADMAP.md` — all features across the phases, with status + deps.
5. The active phase file under `phases/` — acceptance criteria for the current feature.
6. `DECISIONS.md` + `BLOCKERS.md` — what's decided, what's stuck.
7. **Then inspect the actual code.** The codebase is the source of truth for what EXISTS;
   the tracking files are the source of truth for intended state + history. If they
   disagree: inspect, correct the tracking files, and note the discrepancy in `CHANGELOG.md`.

## The ten rules
1. **Tracking before memory.** Never rely on conversation history. The `.harness/`
   tracking files are the state of the project. Read them first; update them before you stop.
2. **One feature at a time — per lane.** Each lane works exactly one feature that is
   `IN PROGRESS` (its row in `LANES.md`, detailed in that lane's `CURRENT_TASK.md`). Do not
   start the next in your lane until the current one is verified. With `MAX_LANES=1` this is
   the single global active feature. Across lanes: never touch a feature another lane has
   claimed, and claim before you build (`loops/parallel-loop.md` — the claim is a commit to
   `main`, which is the mutex). No feature is ever `IN PROGRESS` with zero or two owners.
3. **No victory without evidence.** A feature is `COMPLETE` only when every acceptance
   criterion in its phase file is met AND verification is recorded in `CHANGELOG.md`:
   happy path + the applicable `verification/edge-cases.md` battery + error paths + the FULL
   suite green (no regressions) + an e2e test for any user-facing flow
   (`verification/acceptance-evidence.md`). "It should work" is not evidence.
4. **Respect layer boundaries.** Obey `rules/layer-boundaries.md`. Cross-layer imports are
   a defect. `check-architecture` enforces this and a violation blocks "done".
5. **Stay in scope + phase.** `rules/scope-guard.md` lists what is off-limits for the
   current phase. Phases are gated (ROADMAP order). Don't build a later phase's features now.
6. **Rule of three.** If an extension point already exists (`architecture/MODULES.md`), use
   it — don't edit the core around it. Otherwise write the direct version, even if it
   duplicates a sibling. Abstract on the third real occurrence, not the first or second, and
   record it in `DECISIONS.md` when you do. A seam with one user is a defect (rubric 4 + 6).
7. **Separate maker from checker.** After implementing (maker), switch to the Evaluator
   role (`verification/roles.md`) and score honestly against `verification/evaluator-rubric.md`.
   You may not approve your own work by assertion.
8. **Persist state every session.** Before stopping, update `PROJECT_STATE.md`,
   `CURRENT_TASK.md`, `ROADMAP.md` (+ the phase file), and `CHANGELOG.md`; open/close
   anything in `BLOCKERS.md`; record decisions in `DECISIONS.md`. See `rules/conventions.md`
   and the Session-completion protocol below.
9. **Small, reversible steps.** Thinnest vertical slice that is demonstrable. Commit per
   feature on `feat/<FID>` (or `docs/<slug>`/`chore/<slug>` for harness-only work,
   `rules/conventions.md`) with the message format in `rules/conventions.md`. No drive-by
   refactors. After a feature passes: push, open/reuse a PR, review it, and fix findings
   until clean (`loops/pr-review-loop.md`); then hand the lane to the **integration queue**
   (`loops/integration-loop.md`) — a clean PR is not merged ad hoc. Start your lane's next
   feature only once the current one is queued (or merged). A feature is not done until it is
   merged to `main` with the full suite + e2e green **on the integrated main**.
10. **Observability is not optional.** Structured logs at startup, boundaries, and errors
    (`scripts/SCRIPTS.md` → logger). If you can't see why it failed, add a log before you
    add a fix.

## Statuses (use ONLY these)
`NOT STARTED` · `IN PROGRESS` · `BLOCKED` · `IN REVIEW` · `COMPLETE` · `DEPRECATED`.
No "almost done", "mostly working", "probably fine".

## The loop you run
```
read PROJECT_STATE + CURRENT_TASK + ROADMAP + phase file  ->  confirm the ONE IN PROGRESS feature
  ->  write/confirm sprint-contract  ->  implement (Maker)
  ->  verify (SESSION-CHECKLIST.md Commands: typecheck, lint, FULL tests, check-architecture, e2e)
  ->  score as Checker (evaluator-rubric; edge-cases battery; no regressions)
  ->  pass? record evidence in CHANGELOG, mark COMPLETE in ROADMAP + phase file
      fail? log defects, revise, repeat (bounded rounds)
  ->  push branch, open/reuse PR, review it (a code-review pass, loops/pr-review-loop.md)
      clean? enqueue the lane for integration (loops/integration-loop.md), then claim next ready feature
      issues? fix (Maker), commit, push, review again (bounded rounds)
  ->  update PROJECT_STATE + LANES + CURRENT_TASK + BLOCKERS  ->  stop cleanly
```
The explicit version, with routing rules, is `graph/workflow-graph.md`.

## Parallel lanes (opt-in — `MAX_LANES` in `LANES.md`; default 1)
Off by default. When on: claim before you build (a commit to `LANES.md` on `main` is the
mutex), and lanes reach `main` only through the integration queue. `loops/parallel-loop.md`.

## Definition of done (per feature)
- Every acceptance criterion in the phase file met.
- Applicable edge/error cases (`verification/edge-cases.md`) covered by tests.
- FULL suite green — no regression in any previously COMPLETE feature (regression gate).
- E2E test passes for every user-facing flow (or contract says "N/A — not user-facing").
- Verification recorded in `CHANGELOG.md` (reproducible command/output or artifact path).
- No layer-boundary violation (`check-architecture` passes).
- Evaluator score >= threshold (`verification/evaluator-rubric.md`).
- `ROADMAP.md` + phase file marked `COMPLETE`; `PROJECT_STATE.md` + `CURRENT_TASK.md`
  updated; committed on `feat/<FID>` (or `docs/<slug>`/`chore/<slug>` for harness-only work).
- Branch pushed, PR opened/reused, reviewed clean, CI (incl. e2e) green, no unresolved
  findings (`loops/pr-review-loop.md`).
- Merged to `main` through the integration queue with the FULL suite + e2e green **on the
  integrated main** (`loops/integration-loop.md`), and the lane's claim released in `LANES.md`.
  (With `MAX_LANES=1` the queue is trivial — the lane merges, then releases.)

When the state is not nominal (dirty tree, red baseline, regression, flaky test, CI drift,
merge conflict, committed secret, blocked feature, a double-claimed or orphaned lane, an
integration regression), follow `loops/failure-modes.md` — each has a defined response.

## Session-completion protocol (do all of this before you stop)
1. Determine exactly what was implemented and run the appropriate tests.
2. Update the feature status (phase file) and phase status.
3. Update `ROADMAP.md` (checkbox + counts) and your lane's `CURRENT_TASK.md`.
4. Update `PROJECT_STATE.md` (current phase/feature, progress, last verified, git commit) and
   your lane's row in `LANES.md` (round, status, queue position).
5. Add a `CHANGELOG.md` entry (feature ID + evidence).
6. If the feature just went `COMPLETE`: push the branch, open (or reuse) its PR, review it,
   and fix findings until clean (`loops/pr-review-loop.md`); then **enqueue the lane for
   integration** (`loops/integration-loop.md`). Only after it merges green on main do you
   release the claim and let the lane take its next feature.
7. Update `BLOCKERS.md` and `DECISIONS.md` if anything changed.
8. Record git branch/commit (or `Working tree: DIRTY`) in `PROJECT_STATE.md`.
9. Clearly set the next task in `CURRENT_TASK.md`. If you are ending the lane (no next ready
   feature), release its claim in `LANES.md` and leave the worktree clean for removal.

## Usage / session limits
When you hit a usage or session limit, do not just stop: run the Session-completion
protocol above (commit + update the tracker), then fail over to the other runtime per
`RUNTIME-CONTINUITY.md`. The next runtime resumes from `PROJECT_STATE.md`.

## Hard stops (ask a human)
- A change would delete user data or break a public API contract.
- Scope/acceptance is ambiguous and the files don't resolve it.
- Maker-checker has failed the same feature for the max rounds (`loops/loop-state.md`).
- An integration-queue merge keeps re-breaking `main` past `MAX_INTEGRATE_ROUNDS`, or two
  lanes have a conflict neither can own without redesign (`loops/integration-loop.md`).

## Tech stack
- **Language/format**: Markdown — the distributable spec `HARNESS-BOOTSTRAP.md` — plus one JSON
  twin (`graph/graph.json`). No compiled code, no runtime, no datastore.
- **Toolchain**: a POSIX shell + `git` for the loop; `python3` (stdlib only) for extraction and
  the JSON parse in the self-check. No package manager, no third-party dependencies.
- **Distribution**: one self-contained file, consumed by any coding agent; it scaffolds
  `.harness/` (42 files) + 6 repo-root entry-point pointers + an optional `.claude/` layer (16 files; its hooks need `bash` + `jq`). Shape: `architecture/ARCHITECTURE.md`.
- **Locked choice**: the artifact stays copy-paste portable — runnable by any agent with only
  git + a shell + python3. Adding a dependency is a boundary violation unless justified in the
  sprint contract (`rules/layer-boundaries.md` rule 8).
