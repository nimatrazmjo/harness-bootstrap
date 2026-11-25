# .claude/ — optional Claude Code layer for the harness

This folder makes Claude Code enforce rules `.harness/AGENTS.md` already states. It adds no new
rules. Delete it and the harness still works: the markdown is the source of truth.

## The deny list is the floor, not the rulebook
`settings.json` → `permissions.deny` holds only what no rule should ever bend: reading `.env`,
secrets and keys, and force pushes. Most rules stay in markdown, where the model weighs them.
Deny rules match command text, so they are partial for Bash (`git -C . push --force`, a script
that opens `.env`). The hooks back them up; for OS-level enforcement, use sandboxing.
`ask` covers destructive git. `allow` covers routine git/gh so auto mode stops prompting —
**add your Commands table (`.harness/SESSION-CHECKLIST.md`) here**, e.g. `"Bash(npm test *)"`.

## Hooks → rules
| Hook | Does | Rule |
|---|---|---|
| `session-start.sh` | prints PROJECT_STATE + CURRENT_TASK into context at startup/resume/clear/compact | 1 |
| `pre-tool.sh` | blocks `git commit` while the "Test (full suite)" command is red | 3, conventions Git |
| `pre-tool.sh` | blocks adding `COMPLETE` to ROADMAP/phases while "Check boundaries" is red | 3, 4 |
| `pre-tool.sh` | blocks machinery edits on `feat/*`, `lane/*`, `worktree-lane-*` branches | never edit rules to pass |
| `pre-tool.sh` | blocks any force push | conventions Git |
| `stop.sh` | blocks stopping when code changed but PROJECT_STATE / CURRENT_TASK / CHANGELOG didn't, or a feature is newly `COMPLETE` with no `Evidence:` in CHANGELOG | 3, 8 |

Gates read their commands from `SESSION-CHECKLIST.md` → Commands. A `<placeholder>` there skips
the gate. A green run is cached per tree state in `.git/harness/`, so re-committing the same
tree doesn't re-run the suite. The Stop hook nudges once per stop (`stop_hook_active`), then
lets Claude stop. Needs `bash` + `jq`. Turn hooks off for a session: `HARNESS_HOOKS=off claude`.

## Also here
- `skills/` — `/harness-start`, `/harness-feature`, `/harness-verify`, `/harness-record` and
  `/harness-lane` (the last two run only when you ask).
- `agents/` — `evaluator`, `simplicity-reviewer`, `integrator`: fresh contexts, per
  `.harness/verification/roles.md`.
- `rules/` — context discipline (always loaded); `.harness/` and test guidance (loaded by path).

Git-ignore `.claude/settings.local.json` and `.claude/worktrees/`.
