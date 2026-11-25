# Goal Loop

The first step from manual driving to automation: hand the agent a goal with a hard finish
line and let it iterate until done or a stop condition trips. Use this to complete a single
feature (or slice) without babysitting.

## Contract
```
GOAL:        <one feature or slice, e.g. "F001 passes">
DONE WHEN:   every acceptance item in the phase file for this feature is met
             AND evidence recorded AND Evaluator PASS (>=4.0, no 1s)
VERIFY WITH: the FULL verify (SESSION-CHECKLIST.md → Commands: typecheck + lint + full test +
             check-architecture + e2e) + the feature's edge/error tests + its sprint-contract checks
STOP AFTER:  15 turns  OR  90 minutes  OR  3 consecutive Evaluator REVISEs on the same defect
CONSTRAINTS: obey scope-guard.md; one feature only (this lane's claimed feature); no new deps
             without contract justification; never mark passed without evidence; never edit
             .harness rules to make a check pass; stay inside this lane's owned modules (LANES.md);
             on any abnormal state (dirty tree, red init, regression, flaky test) follow failure-modes.md
ON STOP:     update ROADMAP.md + CHANGELOG.md + PROJECT_STATE.md, commit, report why it stopped
```

## How it runs each turn
1. Read state (PROJECT_STATE, CURRENT_TASK, sprint contract).
2. Advance the feature by the smallest demonstrable step.
3. Run VERIFY. Capture output as evidence.
4. Switch to Evaluator, score against the rubric.
5. PASS -> record evidence, mark passed, exit loop. REVISE -> log defect, continue.
6. Check stop conditions. If tripped, do ON STOP and halt for human review.

## Notes
- The goal must be *verifiable*, not aspirational. "Make it nice" is not a goal;
  "F009 acceptance met" is.
- The loop does not get to redefine DONE. That is fixed by the feature's acceptance +
  sprint contract.
- If it stops on turns/time rather than success, that is useful data, not failure — it
  means the feature was mis-sized or blocked. Note which in PROJECT_STATE.md.

## Native (Claude Code)
`/goal <FID> done: every acceptance item has evidence in CHANGELOG.md and the evaluator
subagent printed "Verdict: PASS" — or stop after 15 turns`. The goal judge sees only the
transcript, so the condition names output the transcript will show. The loop above is the
fallback for any other tool.
