# harness-bootstrap

A portable, closed-loop build harness you can drop into **any** repository. One
self-contained file — [`HARNESS-BOOTSTRAP.md`](./HARNESS-BOOTSTRAP.md) — scaffolds a
project-neutral `.harness/`: the maker-checker, PR-review, timer and goal **loops**, the
workflow **graph**, the roles + rubric + evidence discipline (with a first-class **e2e +
edge-case battery**), **failure-mode** handling for abnormal states, the **tracking system**
(state / roadmap / task / changelog / decisions / blockers), **runtime continuity**, and an
**opt-in parallel mode** — concurrent build **lanes** (git worktrees) with a git-native
**claim ledger** (no dropped or double-claimed features) and an **integration queue** (lanes
merge to `main` one at a time with a full re-run, so no lane breaks another).

It ships **no requirement**. Product vision, roadmap, phases and architecture are left as
placeholders you fill per project — so the same harness fits a full-stack app, a DevOps/IaC
repo, or an Airflow pipeline.

## Use it in any repo

Pull the file into the target repo:

```bash
curl -fsSL https://raw.githubusercontent.com/nimatrazmjo/harness-bootstrap/main/HARNESS-BOOTSTRAP.md -o HARNESS-BOOTSTRAP.md
```

Then tell your coding agent (Claude Code, etc.), in that repo:

> Read `HARNESS-BOOTSTRAP.md` at the repo root and scaffold the harness: create every file it
> defines verbatim at the path in its `FILE:` header (content between `<<<BEGIN` and `END>>>`),
> making directories as needed. Don't clobber anything that already exists. Leave every
> `<<FILL: …>>` placeholder as written — I'll add product, roadmap, and architecture later. Do
> NOT fill the architecture files or write `layer-boundaries.md` yet. Run the self-check and
> report the counts, then delete `HARNESS-BOOTSTRAP.md`.

## Then fill "the requirement"

1. **Product + scope**: `product/PRODUCT.md`, `product/PERSONAS.md`, `ROADMAP.md` (+ a
   `phases/PHASE-XX-*.md` per phase), `rules/scope-guard.md`.
2. **Architecture — later, shaped to the project type**: start from the closest shape in
   `architecture/ARCHETYPES.md` (full-stack / DevOps-IaC / Airflow), fill `ARCHITECTURE.md` +
   `MODULES.md` (+ `DATA_MODEL.md` / `API_SURFACE.md` only where they apply), then encode the
   real import rules in `rules/layer-boundaries.md`. `check-architecture` stays a **no-op**
   until you do — so the loop runs from feature one.
3. **Toolchain + first run**: set `CLAUDE.md` → Commands and `AGENTS.md` → Tech stack, then
   write the first `PROJECT_STATE.md` + `CURRENT_TASK.md` + `loops/loop-state.md`.

## Parallel features (opt-in)

The harness ships single-feature-at-a-time (`MAX_LANES=1`) — its default and its original
discipline. Turn on parallel work by setting `MAX_LANES > 1` in `.harness/LANES.md`: mark each
feature's `deps:` in `ROADMAP.md` (what must be done sequentially) and the **parallel plan**
(what can run at once), and the **ready set** + lane/integration loops do the rest. Two git-level
guarantees keep it safe: **claiming** a feature is a commit to `main`, so a race is a mutex (no
feature dropped or double-claimed); and the **integration queue** merges lanes one at a time with
a full re-run on the integrated `main` (cross-feature regressions caught before they land).

## What it produces

41 files under `.harness/`. The full tree is at the top of `HARNESS-BOOTSTRAP.md`, and the
bootstrap ends with a self-check (all files present, no delimiter leaks, valid `graph.json`).
