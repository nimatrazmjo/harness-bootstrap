# PROJECT STATE — MASTER FILE

> Read this first, every session. Rewrite it for a cold reader before you stop.

## Where we are
- **Phase**: Phase 01 — The Harness
- **Active feature(s)**: F003 — Adopt mode + LLM-agnostic entry points + simplicity-bias fix +
  optional Claude Code layer (IN PROGRESS, DEC-011)
- **Overall progress**: 2 / 4 features COMPLETE (50%)
- **Mode**: ADOPTED (existing repo) — see `ADOPTION.md`. F001 / F002 adopted pre-harness.
- **Parallel mode**: `MAX_LANES=1` (off) — see `LANES.md`.

## Lanes (dashboard — authoritative detail in `LANES.md`)
| Lane | Feature | Status | Owned modules | Runtime | Queue |
|---|---|---|---|---|---|
| single | F003 | IN PROGRESS | HARNESS-BOOTSTRAP.md, .harness/, .claude/, root pointers, plugin files | Claude (Opus 5.5) | — |

## Last verified
- **Date**: 2026-11-24
- **init**: n/a yet (F004) — baseline = the self-check + `scripts/test-hooks.sh`
- **Full suite + check-architecture**: GREEN — 64 FILE blocks (42 + 6 + 16 optional `.claude/`),
  64/64/64 delimiters, no leaks, `graph.json` + `settings.json` parse, `<<FILL:` in exactly the
  16 requirement/tracking files, hooks `bash -n` + shellcheck clean, 28/28 hook tests pass.
  check-architecture still a placeholder (F004).
- **E2E**: GREEN — extracted all 64 blocks into a scratch repo; self-check there; live
  `claude -p` saw the SessionStart injection and the 3 subagents. `claude plugin validate .`
  passed (warnings: no icon; root CLAUDE.md not plugin context — expected).
  `claude plugin eval .` (scaffold-smoke, 1 run/arm): WITH 0.67 · W/OUT 0.00 · Δ +0.67. With
  the plugin, `.harness/` was scaffolded, but `.claude/hooks/stop.sh` was missing (suspected:
  the eval sandbox's don't-ask mode protects `.claude/` writes — unverified). The baseline run
  hit a rate limit and timed out.
- **Git**: branch `chore/harness-f003-upgrade`, **working tree DIRTY** (F003 uncommitted)

## Next step
1. Fresh-context Checker pass: in a new session, `/harness-verify` (evaluator +
   simplicity-reviewer subagents) on this branch's diff.
2. With the user's go-ahead: commit (conventional), push, PR, `/code-review`, fix, merge; record
   F003 evidence in `CHANGELOG.md` and flip it `COMPLETE`. Then F004.

## Open blockers
See `BLOCKERS.md`. None blocking; F004 (runnable scripts + CI) is parked as the next feature.

## Notes for the next agent
This repo **is** the harness and now dogfoods itself. The product lives in
`HARNESS-BOOTSTRAP.md`; the generated `.harness/` machinery is extracted from it — don't
hand-edit machinery (it would drift from the distributable); edit the bootstrap and re-extract.
The requirement + tracking files (this one, `ROADMAP`, `CURRENT_TASK`, `product/`,
`architecture/`, `rules/scope-guard` + `layer-boundaries`, `ADOPTION`, `CHANGELOG`, `DECISIONS`,
`BLOCKERS`, `loops/loop-state`) are this repo's own and hand-maintained — they are NOT in the
bootstrap, and the extractor skips existing files so re-running won't clobber them.
