---
name: harness-lane
description: Parallel-mode lane operations — claim a ready feature, open its worktree session, list lanes, release a merged lane. Only when MAX_LANES > 1, and only when the user asks.
disable-model-invocation: true
argument-hint: claim <FID> | list | release <FID>
allowed-tools: Read, Edit, Grep, Bash(git fetch *), Bash(git switch *), Bash(git pull --rebase *), Bash(git add *), Bash(git commit *), Bash(git push *), Bash(git worktree list *)
effort: medium
---

# Harness lane — $ARGUMENTS

If `MAX_LANES` in `.harness/LANES.md` is 1, say parallel mode is off and stop.

- **claim <FID>**: follow `loops/parallel-loop.md` → Claim protocol exactly. The accepted push
  is the mutex. If the push is rejected, rebase, re-check, and pick another ready feature;
  never override a claim. Skip its `git worktree add` step. Instead, tell the user to run
  `claude -w lane-<FID>`, then `/rename <FID>` and `/harness-feature` in that session. Record
  branch `worktree-lane-<FID>` in the claim row.
- **list**: the Claims table, the integration queue and `git worktree list`. Flag orphans
  (`loops/failure-modes.md` → Parallel lanes).
- **release <FID>**: only after the Integrator merged it green. Remove the claim row on `main`,
  commit `chore(lanes): release <FID>`, push. Tell the user the worktree can be removed.

Hand-offs to the Integrator go as a cross-session message with the PR link, CI-green evidence
and the owned modules (`verification/roles.md` → Handoff rules).
