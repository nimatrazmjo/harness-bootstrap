# PR Review Loop

Runs after maker-checker passes and `record` writes evidence. Local checks + a self-scored
rubric are not the same as a diff a reviewer actually looked at. This loop closes that gap:
it gates moving to the next feature on a clean PR, not just a clean local run.

## Cycle
```
after record (feature passed maker-checker):
  push branch to origin
  open a PR if none exists for this branch (reuse if one does — never open a second)
  review the PR (an independent code-review pass over the diff, not self-grading)
  simplicity pass (a second, fresh-context pass — see Review)
    CLEAN (both) -> enqueue this lane in LANES.md integration queue (loops/integration-loop.md)
    ISSUES -> fix (Maker) -> commit -> push (same branch/PR) -> review again
  if issues persist for MAX_PR_ROUNDS -> escalate to human with standing findings
```
A clean PR does **not** merge here — it hands off to the integration queue, which merges lanes
to `main` one at a time and re-runs the full suite on the integrated main (the cross-feature
regression gate). With `MAX_LANES=1` the queue has one entry and this is immediate.

## Components

`<branch>` is `feat/<FID>` for a ROADMAP feature, or `docs/<slug>`/`chore/<slug>` for
harness-only tooling work (`rules/conventions.md`'s branch-naming exception). `<name>` is
the FID, or the branch's slug for harness-only work.

### Push
`git push -u origin <branch>` (plain `git push` once upstream is set). Never force-push a
shared branch.

### Open / reuse PR
`gh pr create --base main --head <branch> --title "<type>(<scope>): <desc>"` — title
follows the commit convention (`rules/conventions.md`). Body is the write-up at
`.harness/reviews/<name>-PR.md` — write that file first, pass it as `--body-file`. Check
`gh pr list --head <branch>` before creating; if one is open, push updates to it instead.

### Review
Run a Checker-style code-review pass against the branch/PR diff — whatever review capability
your tool offers (a dedicated review command, a cold second agent, or a disciplined manual
diff read). Same principle as the Checker in `maker-checker-loop.md`: it must not just trust
the Maker's summary of its own diff. Record findings in `.harness/reviews/<name>-review.md`.

### Simplicity pass
A separate pass in a fresh context (not a bullet inside the review above) with one question:
**what could be deleted or inlined and still pass acceptance?** It checks the diff against
rubric criterion 6 and the sprint contract §6 budget. Findings go to
`.harness/reviews/<name>-simplicity.md`; each is fixed or rebutted in one line.

### Fix
Findings get addressed as the Maker, committed, and pushed to the same branch — never a new
PR, never a force-push. Then review again.

## Parameters
- `MAX_PR_ROUNDS = 4` (a round here is push+review+fix, not a full maker-checker cycle —
  keep it separate from `MAX_ROUNDS` in `maker-checker-loop.md`).

## Gate
A lane's next feature does not start until this feature's PR is clean **and CI is green** (the
full suite + e2e in CI, which is authoritative — see `loops/failure-modes.md` "local green, CI
red") **and the lane has been enqueued for integration**. This is `AGENTS.md` rule 2 ("one
feature at a time, per lane") extended past the local check to the PR — a feature that passed
maker-checker but has an open PR with unresolved findings, red CI, or an unmerged integration
is not done. Other lanes keep running their own features in parallel meanwhile.

## Conflicts with the default branch
If the branch falls behind and conflicts, rebase (or merge) the default branch in, re-run the
full suite + e2e locally, then push — never force-push a shared branch (`failure-modes.md`).

## Why after record, not before
Maker-checker already proves correctness + evidence locally. Doing the PR after `record`
means every PR opened describes a feature already proven, not a WIP diff — the PR review is
one more independent pass (real CI checks, a fresh look at the diff), not a substitute for
the local one.

## Native (Claude Code)
Review = `/code-review` (standard) or `/code-review ultra` (deep, cloud). Simplicity pass =
the `simplicity-reviewer` subagent (`.claude/agents/`). Both read the rubric from
`.harness/verification/evaluator-rubric.md`; pass its path in the prompt.
