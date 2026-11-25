# Clean-State Checklist

Run before you stop and before you start (init verifies the "start" half). A dirty state is
how the next session loses hours. Tick every box.

## Before starting work
- [ ] `git status` is clean, or the only changes are ones you understand from the handoff.
- [ ] `init` runs green (build + boundary check). If not, fixing it IS your first task.
- [ ] LANES invariants hold: your lane owns exactly one `IN PROGRESS` feature, it matches your
      `CURRENT_TASK.md`, and no other lane claims it (`LANES.md`). With `MAX_LANES=1`: exactly
      one `IN PROGRESS` feature, matching `PROJECT_STATE.md`.
- [ ] Your lane's claimed feature is in the ready set (deps merged to main, phase unlocked).
- [ ] You have read the sprint contract for the active feature (incl. its owned-modules list).

## Before stopping work
- [ ] Code compiles: typecheck passes.
- [ ] lint passes with no new warnings.
- [ ] The FULL test suite passes (not just this feature's tests) — no regressions.
- [ ] New feature has tests, including the applicable `verification/edge-cases.md` battery.
- [ ] E2E passes for any user-facing flow (or the contract records "N/A — not user-facing").
- [ ] check-architecture passes — no layer-boundary violations (`rules/layer-boundaries.md`).
- [ ] No secret / `.env` / generated artifact staged or committed.
- [ ] Evidence for any status change is recorded in `CHANGELOG.md`.
- [ ] `ROADMAP.md` status + evidence updated.
- [ ] `PROJECT_STATE.md` rewritten for a cold reader (active feature + next steps + blockers).
- [ ] No stray files, no secrets, no `.env`, no debug logging left on.
- [ ] Committed on a `feat/<feature-id>` / `lane/<FID>` branch (or `docs/<slug>`/`chore/<slug>`
      for harness-only work) with a conventional message.
- [ ] Your lane still owns exactly one `IN PROGRESS` feature (or it merged and the claim was
      released). No edits landed in another lane's owned modules.
- [ ] If the feature's PR just went clean: lane enqueued for integration (`LANES.md`), not
      merged ad hoc. If it merged: claim released, worktree clean for removal.
- [ ] If the feature just went `COMPLETE`: landed green on `main` via the integration queue
      (`loops/integration-loop.md`) with the full suite + e2e green on the integrated main.

## Red flags that mean "not clean"
- Tests skipped or commented out to make the suite pass.
- Only a subset of tests run "to save time" — a regression can hide in the rest.
- An e2e test mocked across the boundary it claims to prove, or quarantined because it's flaky.
- A feature marked `passed` with `evidence: null`.
- A lane owning more than one `IN PROGRESS` feature, a feature with two owners, or an
  `IN PROGRESS` feature no live lane owns (orphan).
- A clean PR merged straight to `main` bypassing the integration queue.
- An edit to a module another active lane owns.
- Uncommitted changes with no handoff note.
- A TODO that silently expands scope (move it to the parking lot instead).
