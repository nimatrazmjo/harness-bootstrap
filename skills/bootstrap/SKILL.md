---
name: bootstrap
description: Scaffold the portable build harness (.harness/ tracking + loops + rubric, root entry-point pointers, and the optional .claude/ enforcement layer) into the current repo, or adopt an existing codebase into it. Use when asked to install, set up, scaffold, or adopt the build harness.
allowed-tools: Read, Write, Bash(git status *), Bash(git init *), Bash(mkdir *), Bash(jq *), Bash(bash -n *)
effort: medium
---

# Scaffold the harness

The whole product is one file: `${CLAUDE_PLUGIN_ROOT}/HARNESS-BOOTSTRAP.md`. Read it in full.

Then do what its "How to use" prompt says, in the current repo:
1. Decide the **Mode**: Adopt if the repo already has application code, otherwise Greenfield.
2. Create every `FILE:` block at its path, verbatim (content between `<<<BEGIN` and `END>>>`),
   including the *Optional — Claude Code layer* section, since this is Claude Code. Never
   clobber an existing file; append to existing root pointers; merge into an existing
   `.claude/settings.json`.
3. Greenfield: leave every `<<FILL: …>>` as written. Adopt: follow its *Adopt procedure*.
4. Run its Self-check and report the counts.

Don't copy `HARNESS-BOOTSTRAP.md` into the repo.
