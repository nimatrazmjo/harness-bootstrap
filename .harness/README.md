# Project Harness

This is the **harness** for building this project. A harness gives the model a closed-loop
working system so it builds the right thing, verifies its own work, and — through the
persistent tracking system below — survives across sessions without relying on
conversation history.

**The `.harness/` folder is a persistent tracking system + rules + specs — not application
code.** In a greenfield repo it is all there is at first; in an **adopted** repo it sits
alongside the existing codebase and describes it (see `ADOPTION.md`). Either way, a coding
agent reads it, then writes/extends the app one verified feature at a time.

## Any coding agent (LLM-agnostic)
This harness is not tied to one tool. The canonical operating contract is **`AGENTS.md`** in
this folder. At the repo root, one thin pointer file per tool — `AGENTS.md`, `CLAUDE.md`,
`GEMINI.md`, `.github/copilot-instructions.md`, `.cursor/rules/harness.mdc`,
`.windsurf/rules/harness.md` — redirects here, so Claude, Gemini/Antigravity, Copilot, Cursor,
Windsurf, Codex/ChatGPT, Grok, or any other agent runs the same loop from the same rules. There
is exactly one contract; the rest are pointers.

## Read order (every session starts here)
1. `PROJECT_STATE.md` — **MASTER FILE.** Where the project is. Read this before anything.
2. `CURRENT_TASK.md` — the one feature to work on next.
3. `ROADMAP.md` — all features across the phases, with status.
4. The active `phases/PHASE-XX-*.md` — acceptance criteria.
5. `DECISIONS.md` + `BLOCKERS.md`, then inspect the real code.

(The full rules are in `AGENTS.md`; the per-session checklist is `SESSION-CHECKLIST.md`.)

## Layout
```
.harness/
├── PROJECT_STATE.md   # MASTER: where we are (read first)
├── ROADMAP.md         # all phases/features + status (source of truth for scope)
├── CURRENT_TASK.md    # the one feature in progress + next step
├── CHANGELOG.md       # completed-implementation history (evidence)
├── DECISIONS.md       # decision log (indexes the ADRs)
├── BLOCKERS.md        # known blockers
├── AGENTS.md          # CANONICAL operating contract (the rules) — vendor-neutral
├── SESSION-CHECKLIST.md  # per-session bootstrap checklist
├── ADOPTION.md        # existing-repo discovery (stack, archetype, baseline, adopted vs verified)
├── RUNTIME-CONTINUITY.md # runtime failover on session limits
├── RUNTIME-SWITCHES.md   # runtime switch ledger
├── phases/            # PHASE-01..N — feature defs + acceptance criteria
├── product/           # PRODUCT.md, PERSONAS.md (the vision)
├── architecture/      # ARCHITECTURE, DATA_MODEL, API_SURFACE, MODULES + decisions/ (ADRs)
├── rules/             # layer-boundaries, scope-guard, conventions
├── verification/      # roles, evaluator-rubric, sprint-contract, acceptance-evidence
├── loops/             # goal, timer, maker-checker, pr-review + loop-state
├── graph/             # workflow-graph (+ json) — the loop, drawn
└── scripts/           # SCRIPTS.md — automation contracts (specs, not code)
# repo root: AGENTS.md / CLAUDE.md / GEMINI.md / .github/copilot-instructions.md /
#            .cursor/rules/harness.mdc / .windsurf/rules/harness.md — pointers to AGENTS.md above
# optional:  .claude/ — Claude Code hooks/permissions/skills/agents that enforce these rules
```

## The tracking system (why it exists)
The project must not depend on chat history to know what's done. `PROJECT_STATE.md`
answers "where am I?", `ROADMAP.md` answers "where am I going?", `CURRENT_TASK.md`
answers "what do I do now?". After implementing and verifying, the agent updates the
tracking files and picks the next task. A brand-new session — in any tool — can enter the repo
and continue with no prior context.

## The idea in one line
One vendor-neutral contract (`AGENTS.md`) reachable from every tool's entry file, an
agent-readable workspace (this tree), multi-session continuity (the tracking files), runtime
feedback + scope control (`rules/` + `scripts/`), self-verification + role separation
(`verification/`), automated loops (`loops/`), and the workflow drawn as a graph (`graph/`).
