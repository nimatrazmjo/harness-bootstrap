# Failure Modes — how the loop handles abnormal states

The happy loop lives in `maker-checker-loop.md` and `graph/workflow-graph.md`. This file is
what to do when the state is *not* nominal. Each entry is a defined response, not a judgment
call, so the loop behaves the same every run. When one of these fires, note it (CHANGELOG or
BLOCKERS) so a cold agent sees it happened.

## At session start (read-state)
- **Dirty working tree** (uncommitted changes from a prior/other runtime): do NOT build on it
  blind. `git status` + read the diff; reconcile against `PROJECT_STATE.md`. If it's a
  coherent in-progress step for the active feature, continue it; if it's unknown, stash it to
  a `wip/<date>` branch and note it in `BLOCKERS.md`. Never discard without recording.
- **`init` is red**: fixing it IS the first task — before any feature work. A red baseline
  invalidates every downstream check.
- **More `IN PROGRESS` features than lanes** (invariant violation): each lane owns at most one.
  With `MAX_LANES=1` there must be exactly one — keep the one matching `PROJECT_STATE.md`, set
  the others to their true status. With parallel on, reconcile `ROADMAP.md` against `LANES.md`:
  every `IN PROGRESS` feature must map to exactly one live lane. Note the fix in `CHANGELOG.md`.
- **Tracking vs code disagree**: the codebase is truth for what EXISTS; correct the tracking
  files and note the discrepancy (`AGENTS.md`).
- **Phase / dependency gate not met**: the active feature depends on an incomplete earlier
  one, or its phase isn't unlocked. Don't build ahead — mark it BLOCKED with the dependency,
  or correct the active feature to the real next one (`scope-guard.md`).

## During build (implement / verify)
- **Regression in a previously COMPLETE feature**: the FULL suite (not just this feature's
  tests) must stay green. A regression is a hard defect — fix it as part of this feature or
  revert the change; never mark passed with a red full suite. This is the **regression gate**.
- **Boundary violation**: `rollback` to the last clean commit, then re-implement within
  bounds (graph rollback edge). If the Maker reintroduces the same violation, escalate — do
  not spend rounds.
- **No clean commit to roll back to** (first feature, nothing green yet): reset the offending
  change by hand to the last compiling state; if none exists, the feature was started wrong —
  re-plan the thinnest slice.
- **Flaky test**: a re-run that goes green is not a pass. Confirm the non-determinism, find
  the root cause (timing, ordering, shared state, real clock/network/random), fix it
  deterministically, and record the fix. Quarantining without a fix is a REVISE.
- **Secret / `.env` / generated artifact staged**: stop, unstage, add to `.gitignore`; if it
  was ever committed, rotate the secret and scrub history. A committed secret is a
  clean-state red flag and a hard stop.

## At the gate (evaluate / record / PR)
- **Checker PASS you don't trust**: re-run cold in a clean checkout. Trust the reproduced
  command, not the memory that it worked.
- **Local green, CI red**: environment drift (native deps, DB, env vars, runtime version). CI
  is authoritative for full verification — reconcile to CI, don't override it. Reinstall /
  rebuild native deps for the platform (`RUNTIME-CONTINUITY.md`).
- **Branch conflicts with the default branch**: rebase (or merge) it into the feature branch,
  re-run the full suite + e2e, then push. Never force-push a shared branch.
- **PR findings persist past `MAX_PR_ROUNDS`**: escalate with the standing findings; do not
  keep looping or silently merge.

## Parallel lanes (only when `MAX_LANES > 1`)
- **Claim race (two lanes grabbed the same feature)**: the claim is a commit to `LANES.md` on
  `main`, so one lane's push wins and the other is rejected non-fast-forward. The loser does
  `git pull --rebase`, sees the feature now claimed, drops it, and claims another from the
  ready set. If both somehow recorded a claim, the earlier commit wins; the later lane aborts,
  resets its worktree, and re-claims. Never two owners.
- **Orphaned lane (a runtime died mid-feature)**: a lane in `LANES.md` with no commit on its
  branch for a long gap and no live runtime. Inspect its branch: if there is salvageable work,
  a new lane adopts the branch and continues; otherwise release the claim (feature back to the
  ready set) and remove the worktree. Record it. An abandoned claim must never pin a feature.
- **Cross-lane module collision**: a lane edited a file another active lane owns (ownership in
  `LANES.md` / the sprint contract). Stop — this is how lanes break each other. Revert the
  stray edit; if the feature genuinely needs that shared/core module, it is **not** parallel-
  safe: serialize it (claim the core lock / run it alone) rather than editing across lanes.
- **Integration regression (a lane greens its own PR but reds the integrated `main`)**: the
  merge exposed a cross-feature conflict the per-lane suite couldn't see. The **integrating
  lane owns the fix** on its branch (rebased on main), re-runs the full suite on the integrated
  result, and only then does the merge land. It does not go in red. See `integration-loop.md`.
- **Merge conflict at integrate**: the integrating lane rebases on current `main` and resolves,
  re-running the full suite + e2e after. Lanes merge one at a time, so only one rebase is ever
  in flight. Persisting past `MAX_INTEGRATE_ROUNDS` escalates (a hard stop in `AGENTS.md`).
- **Dependency not yet merged**: a ready-set feature's dep is `COMPLETE` on a branch but not on
  `main`. It is **not** ready — "done" means merged. Wait for the dep to clear the queue, or
  pick another ready feature. Building on an unmerged dep is building on sand.

## Anytime
- **BLOCKED**: record it in `BLOCKERS.md` (what would unblock it), set the feature status
  BLOCKED, then either pick up an unblocked/ready feature in the same phase or stop cleanly —
  never fake progress around a blocker.
- **Usage / session limit**: run the Session-completion protocol and fail over
  (`RUNTIME-CONTINUITY.md`). Never stop mid-edit with a dirty tree. In parallel mode a limit
  pauses that one lane; other lanes keep running.
- **Scope temptation**: park it in `BLOCKERS.md` / `ROADMAP.md`; stay on the active feature.
