---
name: harness-verify
description: Use after implementing a harness feature step, or when asked to verify, check, or score work against the harness rubric. Runs the full verify, then the evaluator and simplicity-reviewer subagents in fresh contexts.
allowed-tools: Read, Grep, Glob, Bash(./scripts/*), Bash(git diff *), Bash(git status *)
effort: high
---

# Harness verify — the Checker pass (rule 7)

1. Run every verify command in `.harness/SESSION-CHECKLIST.md` → Commands: typecheck, lint,
   the FULL test suite, check-architecture, e2e. Keep each exact command and its result. If
   one is red, go back to the Maker; don't call the evaluator on red.
2. Spawn the `evaluator` subagent. Give it the feature id, the sprint contract path and the
   commands you ran. Don't explain why the code is right; it re-runs the checks and judges.
3. Spawn the `simplicity-reviewer` subagent on the same diff.
4. Update `loops/loop-state.md`: round, verdict, consecutivePasses, standing defects (the
   evaluator's defects plus any simplicity findings not rebutted).
5. Print the evaluator's scored block verbatim, including its `Verdict:` line (a `/goal`
   condition reads it).

PASS needs avg ≥ 4.0, no criterion at 1, and REQUIRED_PASSES consecutive passes.
