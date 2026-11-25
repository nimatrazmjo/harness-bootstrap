# CLAUDE.md — this repository runs on a build harness

This repo is governed by a portable, closed-loop build **harness**. Its rules are tool-neutral
and shared with every other agent via one canonical file.

> **Canonical operating contract: [`.harness/AGENTS.md`](.harness/AGENTS.md). Read it in full
> before doing anything, and follow it even where it overrides your defaults.**

Every session, read in order:
1. `.harness/PROJECT_STATE.md` — master: where the project is.
2. `.harness/CURRENT_TASK.md` — the one feature to work next.
3. `.harness/ROADMAP.md` — all features + status + deps.
4. the active `.harness/phases/PHASE-XX-*.md` — acceptance criteria.
5. `.harness/DECISIONS.md` + `.harness/BLOCKERS.md`, then inspect the real code.

Then obey `.harness/AGENTS.md`: one feature at a time, no victory without evidence, update the
tracking files before you stop. `.harness/SESSION-CHECKLIST.md` is the per-session checklist;
`.harness/ADOPTION.md` says whether this repo was adopted (pre-existing code) or greenfield.

This file is only a pointer — do not duplicate the contract here; edit `.harness/AGENTS.md`.
The import below loads the contract every session; Claude-only usage lives in `.claude/`.

@.harness/AGENTS.md
