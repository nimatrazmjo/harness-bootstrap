---
name: harness-record
description: Record a verified harness feature — evidence, tracking files, commit, push, PR and the review loop. Runs only when the user asks.
disable-model-invocation: true
allowed-tools: Read, Edit, Grep, Glob, Bash(git status *), Bash(git diff *), Bash(git add *), Bash(git commit *), Bash(git push -u origin *), Bash(gh pr list *), Bash(gh pr view *), Bash(gh pr create *), Bash(gh pr checks *)
effort: medium
---

# Harness record — evidence, state, PR (rule 8)

Precondition: `/harness-verify` printed `Verdict: PASS` for this FID REQUIRED_PASSES times in
a row. Otherwise stop and say so.

1. Add a `.harness/CHANGELOG.md` entry from its template: commands + results, full suite, e2e,
   edge cases, the evaluator's score line. Binary evidence goes in `.harness/evidence/<FID>/`.
2. Run `AGENTS.md` → Session-completion protocol: phase file, ROADMAP, CURRENT_TASK,
   PROJECT_STATE, your LANES row, BLOCKERS/DECISIONS. The Stop hook blocks while these are stale.
3. Commit (`rules/conventions.md` → Git). The PreToolUse hook re-runs the full suite if the
   tree changed since its last green run.
4. `loops/pr-review-loop.md`: push, open or reuse the PR (body = `.harness/reviews/<FID>-PR.md`),
   run `/code-review`, then the `simplicity-reviewer` subagent. Fix findings as the Maker and
   repeat, up to MAX_PR_ROUNDS.
5. Clean + CI green: enqueue (`loops/integration-loop.md`). With MAX_LANES=1, ask the user
   before merging to the default branch.
6. Tell the user to `/clear` before the next feature: a feature boundary is a context boundary.
