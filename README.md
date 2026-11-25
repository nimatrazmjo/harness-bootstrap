# harness-bootstrap

A portable, **LLM-agnostic**, closed-loop build harness you can drop into **any** repository —
greenfield or one that already has code. One self-contained file —
[`HARNESS-BOOTSTRAP.md`](./HARNESS-BOOTSTRAP.md) — scaffolds a project-neutral `.harness/`: the
maker-checker, PR-review, timer and goal **loops**, the workflow **graph**, the roles + rubric +
evidence discipline (with a first-class **e2e + edge-case battery**), **failure-mode** handling,
the **tracking system** (state / roadmap / task / changelog / decisions / blockers), **runtime
continuity**, and an **opt-in parallel mode** — concurrent build **lanes** (git worktrees) with a
git-native **claim ledger** (no dropped or double-claimed feature) and an **integration queue**
(lanes merge to `main` one at a time with a full re-run, so no lane breaks another).

## Works with any coding agent

The canonical operating contract lives in one vendor-neutral file, `.harness/AGENTS.md`. The
bootstrap also writes thin **entry-point pointer files** at the repo root — `AGENTS.md`,
`CLAUDE.md`, `GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/harness.mdc`,
`.windsurf/rules/harness.md` — that each redirect to that one contract. So the same harness
drives **Claude, Gemini / Antigravity, GitHub Copilot, Cursor, Windsurf, Codex / ChatGPT, Grok**,
or any other agent, with no content duplication and no drift. Add a one-line pointer for any tool
not listed; the contract never changes.

## Two modes

- **Greenfield** (new/empty repo) — ships **no requirement**. Product vision, roadmap, phases and
  architecture are left as placeholders you fill after scaffolding. The same original behavior.
- **Adopt** (existing repo) — the agent **reads the codebase first**, then fills the harness from
  reality: detects the toolchain + commands, picks an architecture archetype, reverse-engineers
  the module map and import boundaries, reconstructs the roadmap from what already ships (marking
  it `COMPLETE` against the repo's own green test baseline), and sets the next real increment as
  the current task. It wraps the existing project instead of restarting it; `.harness/ADOPTION.md`
  records what was adopted vs. loop-verified.

## Simple by default

The harness pushes toward the smallest change that works and code that reads like its
neighbors. Rule 6 is a **rule of three** (use an existing extension point; otherwise write the
direct version and abstract on the third occurrence). The Evaluator rubric has a **simplicity**
criterion with veto power, and a two-sided modularity criterion that penalizes speculative seams
as hard as missing ones. Each sprint contract declares a **diff budget** and the neighboring files
it matched, and the PR loop adds a separate pass that asks only *what could be deleted or inlined
and still pass?*

## Use it in any repo

**Claude Code** — install as a plugin, then ask it to set up the harness:

```
/plugin install harness --marketplace nimatrazmjo/harness-bootstrap
```

**Any agent** — pull the file into the target repo:

```bash
curl -fsSL https://raw.githubusercontent.com/nimatrazmjo/harness-bootstrap/main/HARNESS-BOOTSTRAP.md -o HARNESS-BOOTSTRAP.md
```

Then tell your coding agent (any of them), in that repo:

> Read `HARNESS-BOOTSTRAP.md` at the repo root and scaffold the harness. Decide the **Mode**
> first (Adopt if the repo already has code, else Greenfield). Create every file it defines
> verbatim at the path in its `FILE:` header (content between `<<<BEGIN` and `END>>>`), including
> the repo-root entry-point pointer files, making directories as needed. Don't clobber existing
> files (append to an existing root entry-point file rather than overwrite). In Greenfield, leave
> every `<<FILL …>>` placeholder as written — I'll fill product/roadmap/architecture later. In
> Adopt, follow the *Adopt procedure*: read the code and fill the requirement + architecture +
> tracking files from what exists. Run the Self-check and report the counts, then delete
> `HARNESS-BOOTSTRAP.md` (unless this repo ships it as a deliverable).

## Then fill "the requirement" (Greenfield)

1. **Product + scope**: `product/PRODUCT.md`, `product/PERSONAS.md`, `ROADMAP.md` (+ a
   `phases/PHASE-XX-*.md` per phase), `rules/scope-guard.md`.
2. **Architecture — shaped to the project type**: start from the closest shape in
   `architecture/ARCHETYPES.md` (full-stack / DevOps-IaC / Airflow / **docs-tooling**), fill
   `ARCHITECTURE.md` + `MODULES.md` (+ `DATA_MODEL.md` / `API_SURFACE.md` only where they apply),
   then encode the real import rules in `rules/layer-boundaries.md`. `check-architecture` stays a
   **no-op** until you do — so the loop runs from feature one.
3. **Toolchain + first run**: set `SESSION-CHECKLIST.md` → Commands and `AGENTS.md` → Tech stack,
   then write the first `PROJECT_STATE.md` + `CURRENT_TASK.md` + `loops/loop-state.md`.

In **Adopt** mode the same files are filled during scaffolding, from the real code, not later.

## Parallel features (opt-in)

The harness ships single-feature-at-a-time (`MAX_LANES=1`). Turn on parallel work by setting
`MAX_LANES > 1` in `.harness/LANES.md`: mark each feature's `deps:` in `ROADMAP.md` and the
parallel plan, and the ready set + lane/integration loops do the rest. Two git-level guarantees
keep it safe: **claiming** a feature is a commit to `main` (a mutex — no feature dropped or
double-claimed); and the **integration queue** merges lanes one at a time with a full re-run on
the integrated `main` (cross-feature regressions caught before they land).

## What it produces

**48 files**: 42 under `.harness/` + 6 tool entry-point pointers at the repo root, plus an
**optional Claude Code layer** of 16 files under `.claude/` (64 total). The full tree
is at the top of `HARNESS-BOOTSTRAP.md`, and the bootstrap ends with a self-check (all files
present, no delimiter leaks, valid `graph.json`, correct FILL discipline, LLM-agnostic wiring).

## Optional: Claude Code enforcement (`.claude/`)

Markdown stays the source of truth and works in any agent. In Claude Code, the optional layer
adds teeth to rules the markdown already states:
- **Permissions**: deny reading `.env`/secrets and force pushes; ask before destructive git;
  allow routine git/gh. This is the floor, not the rulebook.
- **Hooks**: SessionStart injects project state (also after compaction). PreToolUse blocks a
  commit while the full suite is red, blocks marking `COMPLETE` while boundaries fail, blocks
  machinery edits on feature branches and blocks force pushes. Stop blocks ending a session
  with code changed but tracking files stale, or a `COMPLETE` with no evidence.
- **Skills**: `/harness-start`, `/harness-feature`, `/harness-verify`, `/harness-record`,
  `/harness-lane`.
- **Subagents**: `evaluator`, `simplicity-reviewer`, `integrator`. The Checker runs in its own
  context window instead of the one that wrote the code.

Other agents ignore `.claude/` and still get the full harness. Measure the value with
`claude plugin eval .` (with vs. without the plugin; cases in `evals/`). The hooks are tested by
`scripts/test-hooks.sh .claude/hooks`.

## This repo dogfoods itself

`harness-bootstrap` is itself an **adopted** repo: it carries its own `.harness/` (generated from
`HARNESS-BOOTSTRAP.md` and populated via Adopt mode — archetype **D, docs/tooling**). The product
is the single file `HARNESS-BOOTSTRAP.md`; the generated `.harness/` machinery mirrors it, while
the requirement/tracking files there are hand-maintained for this repo. See
[`.harness/PROJECT_STATE.md`](./.harness/PROJECT_STATE.md) and
[`.harness/ADOPTION.md`](./.harness/ADOPTION.md).
