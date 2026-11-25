# Script Contracts

These are **contracts, not code** (this harness ships no code). Each script is specified by
purpose, inputs, behavior, output, and exit code. The first build session implements them as
real scripts under `scripts/` at the repo root and wires them into the commands in
`SESSION-CHECKLIST.md`. The Evaluator verifies each implementation against its contract.

The commands are **tool-neutral** — any agent runs them the same way; they wrap the repo's own
toolchain (`SESSION-CHECKLIST.md` → Commands), not a vendor feature. **In Adopt mode** (an
existing repo), reuse what already exists: the repo's own install/test/build become the
Commands, and its existing passing suite is the `init` baseline — only write the thin
`check-architecture` / `e2e` wrappers that are genuinely missing; don't duplicate a working
test runner.

Convention for all: exit `0` = success, non-zero = failure with a human-readable reason on
stderr. Structured (json) logs on stdout where noted. No script mutates `.harness/` rule
files.

---

## init
- **Purpose**: verify a clean, reproducible baseline before any work. The "start" half of
  `state/clean-state-checklist.md`.
- **Inputs**: none (reads repo state).
- **Behavior**: check the working tree is clean (warn on a dirty tree — see
  `loops/failure-modes.md`); install deps if needed; run typecheck, lint, the FULL test suite,
  `check-architecture`, and the e2e smoke; confirm the LANES invariants hold (each lane has at
  most one `IN PROGRESS` feature, every `IN PROGRESS` feature maps to exactly one live lane, no
  double-claim — or, with `MAX_LANES=1`, exactly one `IN PROGRESS` feature); print this lane's
  active feature + next step from the handoff.
- **Output**: a short readiness summary.
- **Exit**: `0` if the baseline is clean and buildable; non-zero listing exactly what is not.
- **Used by**: every session start; the goal loop; the timer loop.

## check-architecture
- **Purpose**: enforce `rules/layer-boundaries.md`.
- **Inputs**: the source tree.
- **Behavior**: build/inspect the import graph and assert each rule in `layer-boundaries.md`.
- **Output**: a list of violations (file -> forbidden import -> rule number), or "clean."
- **Exit**: `0` if no violations; non-zero with the list. A non-zero result blocks marking
  any feature `passed`.
- **No-op until architecture exists**: while `rules/layer-boundaries.md` has no real rules
  (architecture is defined after the requirement), this is a permissive no-op — exit `0`,
  print "no boundaries defined yet." It becomes an enforcing gate the moment real rules are
  written. This lets the loop run on day one for any project type before its architecture is
  chosen.
- **Used by**: init; the verify node in the workflow graph; the maker-checker Checker.

## e2e
- **Purpose**: prove user-facing flows end-to-end against the real stack (UI -> API ->
  datastore -> back, or CLI -> real side effect). The evidence form in
  `verification/acceptance-evidence.md`.
- **Inputs**: a running app (or the runner boots one), seeded/deterministic test data, and a
  base URL / entrypoint.
- **Behavior**: drive the primary flow and its applicable error/edge flows (unauthorized,
  not-found, empty) the way a user/client does; assert observable outcomes, not internal call
  counts; save traces/recordings under `.harness/evidence/<feature-id>/`.
- **Output**: pass/fail per scenario + the artifact paths.
- **Exit**: `0` if all scenarios pass; non-zero with the failing scenario. A non-zero result
  blocks marking a user-facing feature `passed`.
- **Used by**: the verify node; the maker-checker Checker; the PR review (via CI); the timer
  loop (smoke subset).
- **Note**: e2e must be deterministic. A flaky e2e is a defect (`loops/failure-modes.md`), not
  evidence — no `sleep`-and-hope; await real state.

## smoke
- **Purpose**: a fast subset of `e2e` — the one or two critical paths — for the timer loop and
  quick post-change confidence.
- **Behavior**: run only the flows tagged `@smoke`; same determinism rules.
- **Exit**: `0` all green; non-zero with the failing path.
- **Used by**: the timer loop; a quick check after a risky change.

## logger (contract, not a script)
- **Purpose**: runtime observability. "If you can't see why it failed, add a log before you
  add a fix."
- **Shape**: structured json lines: `{ ts, level, event, correlationId, ...ids }`.
- **Emit at**: process start (config + versions), each layer-boundary crossing (API request
  in/out, job start/end), and every caught error with its cause and the ids involved.
- **Rule**: a correlation id flows from an API request through any job it spawns. No
  `console.log` debugging left in committed code (clean-state red flag).

## benchmark
- **Purpose**: measure whether the harness is actually helping. Compares agent runs with vs.
  without harness discipline on a fixed task set.
- **Inputs**: a task set (start with the first slice's features) and a mode flag
  (`--with-harness` / `--baseline`).
- **Behavior**: run the task set, then score results against each feature's acceptance + the
  evaluator rubric; count features that actually pass and boundary violations introduced.
- **Output**: a table: features attempted, passed-with-evidence, violations, rounds used.
- **Exit**: `0` when the run completes (pass/fail is in the report, not the exit code).
- **Used by**: periodic health/ablation checks, not the build loop.
- **Mechanism (Claude Code)**: `claude plugin eval` with the harness installer plugin. Each
  case is `evals/<case>/prompt.md` + `graders/`; it runs every prompt with and without the
  plugin, and the WITH − W/OUT gap is the harness's value. `/usage` and `/insights` show where
  real sessions spend and fail.

## cleanup-scanner
- **Purpose**: keep quality maintainable between sessions.
- **Inputs**: the source tree.
- **Behavior**: report dead code, unused deps/exports, TODOs that imply out-of-scope work,
  files over the size guideline, and `.harness` docs that are stale relative to the code they
  describe. Plus the speculative-generality set (rubric criterion 6): interfaces/abstract
  types with one implementation, wrappers that only delegate, exported symbols with one
  internal caller, config entries never read with more than one value, and files that diverge
  from the conventions of their directory.
- **Output**: a findings list, grouped by severity. Report-only — never auto-edits.
- **Exit**: `0` always (advisory); findings go to the timer loop's report policy.
- **Used by**: the daily timer loop.

## progress-counter
- **Purpose**: keep `PROJECT_STATE.md` progress honest.
- **Inputs**: `ROADMAP.md`.
- **Behavior**: count features by status (COMPLETE / IN PROGRESS / BLOCKED / NOT STARTED)
  from the ROADMAP checkboxes + phase files; compute Progress % = COMPLETE / total.
- **Output**: the counts + percentage, written into `PROJECT_STATE.md` "Overall Progress" and
  `ROADMAP.md` "Progress".
- **Exit**: `0` always (advisory).
- **Used by**: session-completion protocol; the timer loop.
- **Note**: until implemented, maintain the counts by hand on every status change.

## lane (parallel mode — `MAX_LANES > 1`)
- **Purpose**: manage build lanes (git worktrees) and the claim ledger in `LANES.md`.
  Implements the claim git-mutex so no feature is dropped or double-claimed
  (`loops/parallel-loop.md`).
- **Subcommands**:
  - `lane ready` — print the ready set (deps merged to main + phase unlocked + unclaimed +
    module-disjoint from active lanes), derived from `ROADMAP.md` + `LANES.md`.
  - `lane claim <FID>` — append the claim line to `LANES.md` **on `main`**, commit, and push.
    On a rejected push (race lost), pull --rebase, re-check, and exit non-zero so the caller
    picks another ready feature. On success, create the worktree `lane/<FID>` and print its path.
  - `lane list` — the live lanes: FID, branch, worktree path, status, owned modules, queue pos.
  - `lane release <FID>` — remove the feature's claim line on `main` (after it merged) and
    print the worktree to remove.
  - `lane remove <FID>` — `git worktree remove` for a merged/abandoned lane.
- **Behavior**: never overrides an existing claim; refuses to claim a feature not in the ready
  set; treats `LANES.md` on `main` as the single source of truth and always rebases before a
  claim/release commit.
- **Exit**: `0` on success; non-zero (with reason) on a lost race, a non-ready feature, or an
  overlap conflict.
- **Used by**: the parallel loop; the coordinator; the claim node in the graph.
- **No-op when `MAX_LANES=1`**: `claim`/`release` are trivial (the single lane is the main
  tree); `ready` still reports the next feature.

## integrate (parallel mode — `MAX_LANES > 1`)
- **Purpose**: the merge queue — land queued lanes on `main` one at a time with a full re-run,
  the cross-feature regression gate (`loops/integration-loop.md`).
- **Inputs**: the integration queue in `LANES.md`.
- **Behavior**: take the head lane; rebase its branch on current `main`; on conflict, hand back
  to the lane to resolve (don't resolve blindly). Merge to a staging ref, run the FULL suite +
  e2e **on the integrated result**. Green → fast-forward/merge `main`, mark the feature
  `COMPLETE`, `lane release` it, advance the queue. Red → do not merge; hand the lane back to
  fix on its branch (`integrateRound++`); past `MAX_INTEGRATE_ROUNDS` exit non-zero to escalate.
  One lane in flight at a time; never force-push `main`.
- **Output**: per-lane merged/blocked status + the integrated-main verify result.
- **Exit**: `0` when the queue drains green; non-zero naming the lane that blocked and why.
- **Used by**: the Integrator role; the integrate node in the graph; CI on `main`.
- **No-op when `MAX_LANES=1`**: a single clean lane fast-forwards; there is no queue to serialize.

---

## (optional) scheduler / agent-relay
If you automate across runtimes (`RUNTIME-CONTINUITY.md`), these two are useful:
- **scheduler**: runs the remaining ROADMAP queue one feature at a time, detects a runtime's
  session/rate limit from its output, fails over to the other runtime, and on a dual limit
  sleeps until the sooner reset then resumes. Flags: `--start=<FID> --end=<FID>`, `--dry-run`.
- **agent-relay**: launches one runtime; when it exits (e.g. on a limit) launches the other,
  looping. Pauses for a keypress before each switch so a normal quit doesn't ping-pong.

---

## Implementation order
`init` and `check-architecture` come with the first feature (the loop needs them
immediately) — `check-architecture` ships as a permissive no-op stub and gains real rules only
when `rules/layer-boundaries.md` is filled (architecture comes after the requirement). The
`e2e`/`smoke` runner is stood up with the first user-facing feature and wired into CI then —
not before it has a flow to drive. `logger` lands with the first
API/worker code. `benchmark` and `cleanup-scanner` are useful once there is enough code to
measure — implement them by the end of the first phase, not before an active feature needs
them (scope-guard). `lane` and `integrate` are implemented only when you turn parallel mode on
(`MAX_LANES > 1` in `LANES.md`); until then the single-lane loop needs neither.
