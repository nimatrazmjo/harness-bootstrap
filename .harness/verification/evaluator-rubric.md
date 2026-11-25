# Evaluator Rubric

Score every feature before it can be marked `passed`. Independent (Evaluator role,
`roles.md`), evidence-based, re-run rather than trusted. Threshold: **PASS requires
>= 4.0/5.0 AND zero criteria scored 1.** Anything below is REVISE with a defect list.

Score each criterion 1–5, then average.

## Criteria

**1. Acceptance completeness** — Are ALL acceptance items in the phase file met, each with
evidence?
- 5: every item met, evidence reproduced by the Evaluator.
- 3: all met but some evidence is thin or unverified.
- 1: an item is unmet or evidence is missing/assumed.

**2. Correctness** — Does it actually work: happy path, the applicable `edge-cases.md`
battery, error paths, no regressions, and (if user-facing) e2e?
- 5: happy path + applicable edge/error cases + full suite green (no regressions) + an e2e
  test of the primary flow for user-facing work, all reproduced by the Evaluator.
- 3: happy path works; edge/error cases untested, OR no e2e for a user-facing flow, OR only a
  test subset was run (regression risk).
- 1: fails on a plausible input; a regression in a COMPLETE feature; "works on my machine";
  or the e2e/edge tests are flaky, skipped, or assert nothing.

**3. Boundary & scope compliance** — Layer boundaries (`rules/layer-boundaries.md`) and
scope guard (`rules/scope-guard.md`) respected?
- 5: check-architecture passes; nothing out of scope built.
- 3: minor smell, no hard violation.
- 1: a boundary violation, or out-of-scope work shipped.

**4. Modularity (two-sided)** — Does the change fit the extension points that exist
(`architecture/MODULES.md`) — no more, no less?
- 5: used the listed registry where one applies; added no new extension point.
- 3: missed a listed registry, OR added a seam whose second user is planned but not built.
- 1: hard-coded into core what a listed registry already handles — OR invented an extension
  point (registry, interface, plugin hook, base class) the current feature doesn't need.
  Extension points are earned, not anticipated (`AGENTS.md` rule 6).

**5. Evidence & handoff quality** — Can a cold agent reproduce the result and continue?
- 5: exact commands/artifacts recorded; state + handoff updated.
- 3: evidence present but handoff vague.
- 1: no reproducible evidence, or state not updated.

**6. Simplicity** — Is this the smallest change that satisfies the acceptance items? Check:
an abstraction with one caller? a wrapper that only forwards? a config knob with one value?
a pattern (factory, strategy, registry, adapter, base class, generic) before a second real
case existed? new code that doesn't match its neighbors (`rules/conventions.md` → Readability
& fit)?
- 5: boring and obvious — a reader of the neighboring files would have written it this way.
- 3: one unneeded layer/knob, trivially inlined.
- 1: speculative generality shipped.

## Output format (the Evaluator writes this)
```
Feature: <id>
Scores: acceptance=_, correctness=_, boundaries=_, modularity=_, evidence=_, simplicity=_  => avg _._
Verdict: PASS | REVISE
Defects (if REVISE):
  - [criterion] <specific defect> — <failing evidence> — <acceptance item it breaks>
```

## Notes
- Grade what you can reproduce, not what the Generator claims. Re-run the commands — including
  the **full** suite (not a subset) and, for user-facing work, the **e2e** test.
- A single criterion at 1 blocks PASS even if the average clears 4.0 — a missing acceptance
  item, a boundary violation, a regression, or a missing/flaky e2e on a user-facing flow is
  disqualifying.
- Probe the `edge-cases.md` categories the Generator skipped; a plausible failing input there
  is a correctness defect, not a nitpick.
- Diff over the sprint contract's §6 budget with no written reason caps criterion 1 at 3.
- Record the scored block in `CHANGELOG.md` as part of the evidence.
