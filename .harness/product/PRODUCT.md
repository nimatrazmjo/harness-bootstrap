# PRODUCT — the vision

## What this is
**HARNESS-BOOTSTRAP** is a portable, LLM-agnostic, closed-loop build harness distributed as a
single Markdown file (`HARNESS-BOOTSTRAP.md`). Dropped into any repository and handed to any
coding agent, it scaffolds a project-neutral `.harness/` — the maker-checker / PR-review /
timer / goal loops and their failure modes, the workflow graph, the roles + rubric + evidence
discipline (with a first-class e2e + edge-case battery), the rules + script contracts, the
multi-session tracking system, runtime continuity, and an opt-in parallel-lanes + integration-
queue mode — plus six repo-root entry-point files that route every tool to one canonical
contract.

## The problem
Coding agents lose the thread across sessions, declare victory without evidence, and drift out
of scope. And every tool wants its own instructions file — so teams re-explain context each
session and maintain N copies of "how we work" for N tools.

## The core idea
One file installs a **closed loop**: rules-first entry points, an agent-readable workspace,
multi-session continuity via tracking files, self-verification through role separation
(planner / maker / checker), and the workflow drawn as a graph. The project's state lives on
disk, not in chat — so any agent, in any tool, can enter cold and continue.

## What makes it different
- **One file, no dependencies.** Copy-paste portable; runs with only git + a shell + python3.
- **LLM-agnostic.** One canonical contract (`.harness/AGENTS.md`); thin per-tool pointers at
  the root (Claude, Gemini/Antigravity, Copilot, Cursor, Windsurf, Codex/ChatGPT, Grok, …).
- **Two modes.** *Greenfield* (ship placeholders, fill later) and *Adopt* (read an existing
  repo and wrap it — reconstruct the roadmap, codify the real boundaries, keep building).
- **Evidence or it didn't happen.** No feature is `COMPLETE` without reproducible proof and a
  full-suite + e2e green gate.
- **Safe parallelism, opt-in.** Git-native claim ledger (no dropped/double-claimed feature) +
  an integration queue (no lane breaks another).

## The shape of the MVP (already shipped — see ROADMAP / CHANGELOG)
The one-file bootstrap (F001) + opt-in parallel lanes & integration queue (F002). This change
adds existing-repo adoption + LLM-agnostic entry points (F003).

Everything the harness builds should trace back to something here.
