# LANES — parallel build lanes, the claim ledger, the integration queue

Shared coordination state, **owned by `main`** (every lane reads/writes it on `main` via short
claim/release/enqueue commits — never edited independently on a lane branch). This is the
mutex + dashboard that lets features run in parallel without being dropped, double-claimed, or
broken by each other. Read `loops/parallel-loop.md` + `loops/integration-loop.md` for the how.

With `MAX_LANES=1` (the default) parallel mode is **off**: one lane in the main tree, the
classic single-feature loop. Nothing here needs filling then — the Claims table has one row (or
none between features) and the queue is trivial. Set `MAX_LANES > 1` to turn it on.

## Config
- `MAX_LANES`: 1   <!-- concurrent lanes; 1 = parallel mode off -->
- `MAX_INTEGRATE_ROUNDS`: 3

## Claims (the git-mutex ledger — one row per active lane)
A row here means the feature is claimed; adding/removing a row is a commit to `main`. No feature
appears twice; no `IN PROGRESS` feature in `ROADMAP.md` is absent here.
```
(FID | lane branch | worktree path | owner/runtime | owned modules | status | claimed-at)
--- none yet (single lane: work in the main tree) ---
```

## Integration queue (FIFO — lanes with a clean, CI-green PR awaiting merge to main)
The Integrator (`loops/integration-loop.md`) takes the head, rebases on `main`, re-runs the full
suite on the integrated result, merges only if green, then releases the claim.
```
(position | FID | lane branch | PR url | enqueued-at | integrateRound)
--- empty ---
```

## Ready set (snapshot — recompute from ROADMAP deps + these claims before each claim)
Features claimable now: deps `COMPLETE` and merged to `main`, phase unlocked, unclaimed,
modules disjoint from every active lane. Authoritative derivation: `rules/scope-guard.md`.
```
--- compute with `lane ready` (scripts/SCRIPTS.md) ---
```

## History (released/merged lanes)
```
(FID | lane | merged-at main sha | integrate rounds | notes)
--- none yet ---
```
