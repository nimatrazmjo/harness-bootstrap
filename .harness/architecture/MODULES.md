# MODULES — the extension points that exist

These seams exist today, each with several registrants. A variant of one of them is a
registration, not a core edit. A new seam is added only when `AGENTS.md` rule 6 earns it (third
occurrence + a `DECISIONS.md` entry); rubric criterion 4 penalizes both bypassing a listed seam
and inventing an unlisted one. The optional `.claude/` layer is not a seam: it is one tool's
enforcement of the same rules.

## 1. Tool entry points (the LLM-agnostic registry)
To support another agent, add ONE thin pointer file in that tool's convention at the repo root,
redirecting to `.harness/AGENTS.md`. No change to the canonical contract.
- Registered today: `AGENTS.md` (agents.md standard — Codex/ChatGPT, Grok, Cursor fallback, …),
  `CLAUDE.md` (Claude), `GEMINI.md` (Gemini CLI / Antigravity),
  `.github/copilot-instructions.md` (Copilot), `.cursor/rules/harness.mdc` (Cursor),
  `.windsurf/rules/harness.md` (Windsurf).
- To add one (e.g. Cline `.clinerules`, Aider `CONVENTIONS.md`): copy an existing pointer's
  body, change only the tool name + any required front-matter. Never copy the rules themselves.

## 2. Architecture archetypes
A new project shape = a new section in `architecture/ARCHETYPES.md` (A full-stack / B
DevOps-IaC / C Airflow / D docs-tooling). Adopt mode *picks* one; it never edits the loop.

## 3. Script contracts
New automation = a new contract in `scripts/SCRIPTS.md` (purpose / inputs / behavior / output /
exit code), implemented as feature work. The loop calls it through the Commands table, never by
hard-coding it into the core.

## 4. Modes
Greenfield vs. Adopt is selected by the adoption record in `ADOPTION.md`; the machinery is
identical either way. A new mode would be a new discovery procedure + record, not a change to
the loops / graph / rules.
