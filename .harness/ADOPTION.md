# ADOPTION — existing-repo discovery

How this harness was attached to a pre-existing codebase. A cold agent reads this to know
whether `COMPLETE` work was built under the loop or inherited. See `AGENTS.md` → "Mode".

## Mode
ADOPTED — the harness was wrapped around this existing repository on 2026-11-02 (dogfood: the
repo's product *is* this harness).

## Discovery
- **Adopted on**: 2026-11-02.
- **Repo**: `harness-bootstrap` — the portable, LLM-agnostic closed-loop build harness.
- **Stack / toolchain**: Markdown (the distributable `HARNESS-BOOTSTRAP.md`) + one JSON twin
  (`graph/graph.json`); POSIX shell + `git` for the loop; `python3` stdlib for extraction and
  the JSON parse. No dependencies, no build, no datastore. (Mirrored in `SESSION-CHECKLIST.md`
  → Commands and `AGENTS.md` → Tech stack.)
- **Archetype**: **D — docs / tooling / single-artifact distribution** (`ARCHETYPES.md`). The
  product is a spec shipped as one file + the `.harness/` tree it generates; `DATA_MODEL.md` +
  `API_SURFACE.md` are N/A.
- **Baseline at adoption**: the bootstrap's own self-check, run on the freshly scaffolded tree —
  48 files (42 under `.harness/` + 6 root pointers), 48/48/48 delimiters, no leaks,
  `graph.json` valid, `<<FILL>>` only in requirement/tracking (pre-adoption). **GREEN.** This is
  the evidence for the adopted `COMPLETE` features.
- **Module map** (`MODULES.md`): tool entry-points (6 pointers → 1 contract), architecture
  archetypes (A–D), script contracts, modes (greenfield/adopt).
- **Boundaries codified** (`rules/layer-boundaries.md`): 8 grep/JSON-checkable rules — delimiter
  integrity, file inventory, FILL discipline, neutral contract, pointers-don't-fork, valid JSON
  twin, idempotent/non-clobbering, no new dependency. `check-architecture` becomes an enforcing
  gate once F004 implements the script; until then the inline self-check covers it. No existing
  violations found.
- **Reconstructed roadmap** (`ROADMAP.md`): F001 (one-file bootstrap, commit f538e2e) and F002
  (parallel lanes + integration queue, commit 9728a23) → `COMPLETE`, adopted. F003 (this change:
  Adopt mode + LLM-agnostic) → IN PROGRESS. F004 (runnable scripts + CI) → NOT STARTED.
- **Adopted vs. loop-verified**: F001 + F002 carry evidence "adopted (pre-harness)" — they were
  NOT built under the maker-checker loop, only validated by the baseline self-check. Any change
  to them re-enters the full loop and must earn real evidence (`AGENTS.md` → Mode).

## Gaps / risks found during adoption
- No runnable test/CI scripts yet — the self-check is executed by hand. Tracked as **F004**
  (`ROADMAP.md`) and `B-DEBT-1` (`BLOCKERS.md`).
- The generated `.harness/` machinery mirrors `HARNESS-BOOTSTRAP.md`; if the bootstrap changes,
  re-extract the machinery so they don't drift. The requirement/tracking files here are authored
  for this repo and are **not** in the bootstrap (the extractor skips existing files, so
  re-running it won't clobber them).
