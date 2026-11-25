# Roles — Separation of Duties

The single biggest reliability lever is not a smarter model; it is separating who builds
from who judges. When one agent plans, builds, and grades itself, it declares victory early.
Splitting the work into roles that hand off with evidence removes that failure. (In the
harness-engineering benchmark, one self-reviewing role scored ~1.6/5; planner+generator+
evaluator scored ~4.9/5. The roles are the difference.)

You play these roles in sequence, switching context deliberately. Announce the switch
("Now acting as Evaluator") so it is visible and you do not blur them.

## Planner
- Input: the active feature in `ROADMAP.md`, the product/architecture docs, the handoff.
- Output: a filled `sprint-contract.md` — scope, acceptance mapped to checks, the plan,
  out-of-scope list, risks. Nothing is built until the contract exists.
- Discipline: the Planner decides *what done means* before the Generator can be tempted to
  redefine it mid-build.

## Generator (maker)
- Input: the signed sprint contract.
- Output: the implementation, plus the evidence each acceptance item calls for.
- Discipline: builds only what the contract says. Discovers scope creep? Parks it, does not
  build it. Produces the evidence; does not grade it.

## Evaluator (checker)
- Input: the contract + the Generator's output + evidence. **Does not trust the Generator's
  summary — re-runs the checks: the full suite + e2e (not a subset), plus the edge-cases
  battery.**
- Output: a score against `evaluator-rubric.md`, a defect list, and a verdict: PASS or REVISE.
- Discipline: independent and adversarial-in-good-faith. Looks for the acceptance item that
  was quietly skipped, the test that asserts nothing, the "passed" with no evidence, the
  boundary violation. The Evaluator may not fix code; it reports. A vague "looks good" is a
  failed evaluation.

## Integrator (parallel mode only — `MAX_LANES > 1`)
- Input: the integration queue in `LANES.md` — lanes whose feature passed maker-checker and
  has a clean, CI-green PR.
- Output: each queued lane merged to `main` one at a time, with the FULL suite + e2e re-run
  **on the integrated main** as the proof, and the lane's claim released.
- Discipline: serialize. Take the head of the queue, rebase it on current `main`, resolve
  conflicts, re-run the whole verify on the merged result — and only land it if green. A
  per-lane green PR is not trusted as proof the integrated trunk is green; that is the
  cross-feature regression the Integrator exists to catch. On red, the integrating lane fixes
  on its branch and re-queues; the Integrator never lands a red merge and never force-pushes
  `main`. With `MAX_LANES=1` this role collapses into a trivial fast-forward and needs no
  separate pass. See `loops/integration-loop.md`.

## Handoff rules
- Generator -> Evaluator handoff must include: what was built, the exact commands to
  reproduce evidence, and any deviation from the contract.
- Evaluator -> Generator (on REVISE) must include: specific defects, each tied to an
  acceptance item or rubric line, and the failing evidence.
- A feature is `passed` only after an Evaluator PASS with score >= threshold. The Generator
  cannot set `passed` on its own say-so.
- Lane -> Integrator handoff (parallel mode) must include: the clean-PR link, CI-green
  evidence, and the lane's owned-modules list so the Integrator can anticipate conflicts.
- A feature is `COMPLETE` only after the Integrator lands it green on `main` and releases the
  claim — passing maker-checker + PR is "ready to integrate," not "done."

## When roles run as one agent vs. separate agents
- Same session, sequential: acceptable for most features. Switch context explicitly; re-run
  checks with fresh eyes.
- Separate agent/loop (`loops/maker-checker-loop.md`): preferred for risky or large
  features, and for the automated loop. The checker is a different invocation so it cannot
  see the maker's rationalizations.

## Anti-patterns (an automatic REVISE)
- Grading your own work by assertion.
- "Tests pass" without showing which tests and their output.
- Marking passed to move on, intending to "come back to it."
- Evaluator softening a defect to avoid another round.
