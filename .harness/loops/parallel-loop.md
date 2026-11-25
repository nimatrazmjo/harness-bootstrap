# Parallel Loop — concurrent build lanes (opt-in)

The single-feature loop (`maker-checker-loop.md`, `graph/workflow-graph.md`) is the default.
This file is how you run several of those loops at once **without dropping or double-claiming a
feature, and without lanes breaking each other**. It is off until you set `MAX_LANES > 1` in
`LANES.md`; at `MAX_LANES=1` everything here collapses to the classic loop and you can ignore it.

## What a lane is
A **lane** = one git worktree + a `lane/<FID>` branch + exactly one claimed feature + its own
`CURRENT_TASK.md` / `loop-state.md` / sprint contract on that branch. Lanes run the whole
per-feature loop independently and concurrently (one runtime/agent each is typical). The only
serialized step is integration (`integration-loop.md`).

## The two invariants (this is the whole point)
1. **No missing / double-claimed feature.** A feature goes `IN PROGRESS` only via a **claim**,
   and a claim is a commit to `LANES.md` on `main`. Git is the mutex.
2. **No lane breaks another.** Lanes own disjoint modules and never merge ad hoc; the Integrator
   serializes merges and re-runs the full suite on the integrated `main`.

## Coordinator (what picks work for lanes)
```
loop:
  ready = lane ready            # deps merged to main + phase unlocked + unclaimed + module-disjoint
  if free lane slot (active lanes < MAX_LANES) and ready non-empty:
      pick a ready feature (respect phase order; prefer unblockers of the most dependents)
      claim it (below); on success spawn a lane, on race retry with the next ready feature
  else if no ready feature: wait for a lane to merge (which grows the ready set), then recompute
  stop when every feature is COMPLETE and merged
```
The coordinator can be a human assigning lanes, a script, or the lead agent. It owns no code; it
only claims and spawns.

## Claim protocol (the git-mutex)
```
claim <FID>:
  git fetch; git switch main; git pull --rebase
  re-read LANES.md: is <FID> still in the ready set and unclaimed?  no -> abort, pick another
  append the claim line to LANES.md (FID | lane/FID | owner | owned-modules | claimed-at)
  set ROADMAP <FID> -> IN PROGRESS
  commit ("chore(lanes): claim <FID>") and push
    push rejected (someone claimed first) -> pull --rebase, re-check; <FID> taken -> pick another
    push accepted -> the claim is yours
  git worktree add ../wt-<FID> -b lane/<FID> main
```
Two lanes racing for the same feature cannot both win: one push lands, the other is rejected and
backs off. No lock server, no out-of-band coordination — just `main`.

## Running a lane
Each lane runs `graph/workflow-graph.md` on its worktree: read-state -> plan (sprint contract,
incl. §0 owned modules) -> implement -> verify -> evaluate -> record -> push -> PR review. Stay
inside the lane's owned modules. On a clean, CI-green PR the lane **enqueues** for integration
(`integration-loop.md`) instead of merging, then — once merged — releases its claim and either
claims the next ready feature or ends (worktree removed).

## Choosing what parallelizes
- **Parallel**: features with no dependency between them and disjoint modules (the ready set).
- **Sequential**: a dependency chain — `F003 deps: F001` waits until F001 is *merged*, not just
  passed. Declared in `ROADMAP.md`; enforced by the ready set (`rules/scope-guard.md`).
- **Serialize alone**: anything that must edit the shared/pure core. Give it the whole floor
  (claim it when no other lane overlaps) rather than racing edits into the core. A wide
  mechanical change (a rename, a migration across modules) is one `par: solo` feature, not
  many lanes.

## Parameters (in `LANES.md`)
- `MAX_LANES` — concurrent lanes (default 1 = off). Keep it <= the number of genuinely
  independent ready features; more lanes than independent work just creates integration churn.
- WIP = active lanes; never exceed `MAX_LANES`.

## Bound it
More lanes is not more throughput past the point where features stop being independent — every
extra lane adds integration/rebase cost and conflict risk. Start at 2–3, raise only if the ready
set is reliably that wide. Abnormal states (claim race, orphaned lane, cross-lane collision) are
handled in `loops/failure-modes.md` → "Parallel lanes".

## Native (Claude Code)
Claim first (above — the ledger stays yours), then open the lane with `claude -w lane-<FID>`:
worktree at `.claude/worktrees/lane-<FID>`, branch `worktree-lane-<FID>` — record that branch
in `LANES.md`. `claude agents` is the lane dashboard; `/rename <FID>` names a session, `/bg`
backgrounds it; hand-offs (lane -> Integrator) go as a cross-session message. A `par: solo`
wide mechanical change runs as `/batch <instruction>` inside its one lane.
