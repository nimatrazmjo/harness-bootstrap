# Sprint Contract — <FID>: <feature name>

Feature: <FID> — <name>
Phase: <phase number + name>
Lane: <lane/FID branch, or "single" when MAX_LANES=1>
Depends on: <FIDs that must be COMPLETE **and merged to main** first, or "none">
Date: <YYYY-MM-DD>

> The Planner fills this before the Maker builds. Copy this template per feature. Nothing is
> built until the contract exists and its acceptance maps to concrete checks. For a vague
> feature: "interview me until you could write this contract yourself — at most six
> questions, no code." Write it read-only (plan mode, where the tool has one).

## 0. Lane ownership & parallel-safety (parallel mode)
- Owned modules/paths (this lane may edit ONLY these): <list — must not overlap any other
  active lane's owned set in `LANES.md`>
- Shared/core touched: <none — or name it. Touching the shared core means this feature is NOT
  parallel-safe: serialize it (run it alone / take the core lock), don't run it beside others.>
- Deps merged to main? <yes — or list the unmerged deps that block claiming this now>
- (With `MAX_LANES=1` this section is "single lane — N/A".)

## 1. Scope & Acceptance Criteria
- [ ] <acceptance item 1> — <the exact check/evidence that proves it>
- [ ] <acceptance item 2> — <check/evidence>
- [ ] <acceptance item 3> — <check/evidence>
- [ ] Boundary invariants: obeys `rules/layer-boundaries.md` (check-architecture passes).
- [ ] Edge/error cases from §2 covered by tests.
- [ ] E2E: the primary user flow passes end-to-end (or "N/A — not user-facing" with why).
- [ ] No regressions: the FULL verify (typecheck + lint + full tests + check-architecture +
      e2e) passes with zero errors.

## 2. Edge cases & failure paths (from `verification/edge-cases.md`)
List each applicable category and the concrete test that covers it; mark the rest N/A with a
word on why. An unconsidered applicable category is an incomplete contract.
- <category> -> <test that covers it>
- <category> -> <test>
- N/A: <categories that don't apply and why>

## 3. E2E scenario(s)
<the user flow(s) an e2e test will drive through the real stack, incl. the error/edge flow
(e.g. unauthorized, not-found, empty). Or "N/A — not user-facing" + reason.>

## 4. Plan (thinnest vertical slice)
<the smallest demonstrable steps, in order>

## 5. Out of scope (parked, not built)
<anything tempting that belongs to a later feature/phase — record it, don't build it>

## 6. Budget & fit
- Expected diff: <N files, ~L lines> · owned modules: <paths> (always, not only parallel mode)
- Neighbors matched: <2–3 existing files whose conventions this follows>
- New dependency / abstraction / config surface: <none — or each one + the acceptance item
  that needs it>
- Over budget? <no — or the reason. The Evaluator reads it under rubric criterion 1.>

## 7. Risks
<what could break; the edge/error paths the Checker should probe>
