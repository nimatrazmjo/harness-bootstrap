---
paths:
  - ".harness/**"
---

# Editing .harness/

- **Machinery** — the rules. Never edit them to make a check pass; change them only on a
  `chore/harness-<slug>` branch (the PreToolUse hook enforces this on feature/lane branches):
  `AGENTS.md`, `README.md`, `SESSION-CHECKLIST.md`, `RUNTIME-CONTINUITY.md`, `loops/*` (not
  `loop-state.md`), `graph/*`, `verification/*` (not the sprint contract), `rules/conventions.md`,
  `scripts/*`, `state/*`, `architecture/ARCHETYPES.md`, `architecture/decisions/ADR-template.md`.
- **Tracking** — update every session (`AGENTS.md` → Session-completion protocol):
  `PROJECT_STATE`, `CURRENT_TASK`, `ROADMAP` + `phases/`, `CHANGELOG`, `DECISIONS`, `BLOCKERS`,
  `LANES`, `loops/loop-state.md`.
- Statuses: only `NOT STARTED` · `IN PROGRESS` · `BLOCKED` · `IN REVIEW` · `COMPLETE` ·
  `DEPRECATED`.
- `COMPLETE` needs a CHANGELOG entry with an `Evidence:` line (Stop hook) and check-architecture
  green (PreToolUse hook).
