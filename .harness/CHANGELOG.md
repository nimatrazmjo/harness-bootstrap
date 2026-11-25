# CHANGELOG — completed implementation, with evidence

Newest first. One entry per feature that reached `COMPLETE`. An entry is not valid without
reproducible evidence (`verification/acceptance-evidence.md`).

## 2026-11-02 — Harness adopted into this repo (existing-repo mode)
This repo was wrapped by its own harness (dogfood). Baseline self-check on the freshly
scaffolded tree:
  - `grep -c '^FILE:' HARNESS-BOOTSTRAP.md` = `grep -c '^<<<BEGIN'` = `grep -c '^END>>>'` → 48 / 48 / 48
  - files: 42 under `.harness/` + 6 root entry-point pointers = 48
  - no generated file contains `<<<BEGIN` / `END>>>` (no leak)
  - `python3 -c "import json;json.load(open('.harness/graph/graph.json'))"` → valid JSON
  - `<<FILL>>` only in requirement + 3 first-run tracking + Commands/Tech-stack (pre-adoption)
Result: **GREEN.** This is the "adopted (pre-harness)" evidence for F001 and F002.

## <pending> — F003 existing-repo mode + LLM-agnostic entry points — IN PROGRESS
Branch/commit: `feat/F003` @ <pending>   PR: <pending>   CI: <pending — F004>
Evidence so far:
  - `HARNESS-BOOTSTRAP.md`: two modes (Greenfield / Adopt) + Adopt procedure; canonical neutral
    contract + 6 root pointers; `.harness/CLAUDE.md` → `SESSION-CHECKLIST.md`; `ADOPTION.md`;
    archetype D; self-check now 48 files + agnostic-wiring + Adopt checks.
  - scaffolded `.harness/` (42) + 6 root pointers into this repo; self-check GREEN (above).
Evaluator: pending — an independent review pass is required before F003 → `COMPLETE`.
Notes: F001 / F002 recorded as adopted above. F004 (runnable scripts + CI) is the next feature.

<!-- entries go above, newest first -->
