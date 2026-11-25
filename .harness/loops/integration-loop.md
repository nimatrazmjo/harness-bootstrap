# Integration Loop — the merge queue (opt-in)

Parallel lanes each prove their own feature on their own branch. That is necessary but **not
sufficient**: two independently-green branches can still break each other once combined. This
loop is the cross-feature regression gate — it merges lanes to `main` **one at a time**, each
with a full re-run on the integrated result, so `main` is never red. Off at `MAX_LANES=1` (a
single clean lane just fast-forwards).

## Why serialize merges
If N lanes merged concurrently, each would test a `main` that none of the others had landed on
yet — exactly the blind spot that lets feature A break feature B. Serializing means every merge
is validated against the real, current `main` including all earlier-merged lanes. One rebase is
ever in flight, so conflicts are pairwise and tractable.

## The queue
Lives in `LANES.md` → `## Integration queue`: an ordered list of lanes whose feature passed
maker-checker and has a clean, CI-green PR. FIFO by default; a lane may be prioritized if it
unblocks the most dependents. A lane enters on its clean PR (`pr-review-loop.md`) and leaves
when merged green or bounced back to fix.

## Cycle (the Integrator role, `verification/roles.md`)
```
while queue non-empty:
  lane = head(queue)
  git switch main; git pull --rebase
  rebase lane/<FID> onto current main
    conflict -> hand back to the lane to resolve on its branch (it owns its code), re-queue; continue
  merge lane into a staging ref (or merge --no-ff into a temp integration branch)
  run the FULL verify on the integrated result: typecheck + lint + FULL suite + check-architecture + e2e
    GREEN -> merge to main (no force-push); mark <FID> COMPLETE in ROADMAP + phase file;
             record evidence in CHANGELOG (incl. "integrated-main suite: green");
             lane release <FID>; lane remove; pop the queue
    RED   -> do NOT merge. integrateRound++. Hand the lane the failing output; it fixes on its
             branch (Maker), re-passes its own PR, and re-queues. The break is a real
             cross-feature defect, not a formality.
  if integrateRound > MAX_INTEGRATE_ROUNDS for this lane -> escalate (AGENTS.md hard stop)
```

## Parameters
- `MAX_INTEGRATE_ROUNDS = 3` — attempts to land one lane before escalating (separate from
  `MAX_ROUNDS` and `MAX_PR_ROUNDS`).

## Who does the fix
The **integrating lane owns the fix**, on its own branch, rebased on current `main` — not the
Integrator patching trunk, and never a merge that lands red "to be fixed later." The Integrator
coordinates and verifies; it does not write feature code (same separation as Checker vs Maker).

## Interaction with CI
CI on `main` is the authoritative re-run (`loops/failure-modes.md` "local green, CI red"). The
Integrator's local full-suite run gates the merge; CI on `main` confirms it. A post-merge red CI
reverts the offending merge (never force-push) and re-queues the lane.

## Definition of done, completed
A feature is `COMPLETE` only after it lands green here and its claim is released. Passing
maker-checker and a clean PR mean "ready to integrate," not "done" (`AGENTS.md` → Definition of
done). With `MAX_LANES=1` the queue holds one lane and this is immediate, but the rule is the
same: nothing is done until it is green on `main`.
