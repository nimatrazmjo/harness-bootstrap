# DECISIONS — decision log

Indexes the architecture ADRs (`architecture/decisions/`) and records lighter decisions. Don't
relitigate a decision here without a new one that supersedes it.

## Format
```
DEC-00N (<YYYY-MM-DD>): <decision, stated plainly>. — <why> [ADR-XXXX if applicable]
```

DEC-001 (2026-11-02): Adopt this repo into its own harness (dogfood) rather than keep it
harness-less. — Proves the new Adopt mode end-to-end and gives the project the same tracking +
evidence discipline it ships.

DEC-002 (2026-11-02): Canonical contract is one vendor-neutral file (`.harness/AGENTS.md`);
every tool gets a thin root pointer, never a copy. — "Works with everything" without N drifting
instruction files; adding a tool is a one-file registration (`architecture/MODULES.md`).

DEC-003 (2026-11-02): Rename `.harness/CLAUDE.md` → `.harness/SESSION-CHECKLIST.md`. — The
per-session checklist must not carry a single vendor's name inside an LLM-agnostic harness; the
vendor name lives only on the repo-root pointer `CLAUDE.md`.

DEC-004 (2026-11-02): Classify this repo as archetype D (docs / tooling / single-artifact). — Its
product is a spec distributed as one file, not an app/service; `DATA_MODEL` + `API_SURFACE` N/A.

DEC-005 (2026-11-02): Keep `HARNESS-BOOTSTRAP.md` after scaffolding (do not delete it). — Here
the bootstrap is the repo's tracked deliverable, unlike a normal target repo where it is removed.

DEC-006 (2026-11-24): Rule 6 becomes a rule of three; rubric gains a vetoing Simplicity
criterion and a two-sided Modularity criterion. — The old one-sided modularity rule rewarded
speculative registries/interfaces with no counterweight; extension points are earned, not
anticipated.

DEC-007 (2026-11-24): Claude Code enforcement ships as an optional fenced `.claude/` section of
the bootstrap, not as a plugin. — Plugins can't ship permission rules or `.claude/rules/`, their
hooks fire in every repo, and in-repo `.claude/` reaches teammates through git. The plugin is
only a 3-file installer (+ eval case), so FILE blocks are never duplicated.

DEC-008 (2026-11-24): Machinery-edit guard is a branch-aware PreToolUse hook (blocks on
`feat/*`, `lane/*`, `worktree-lane-*`); harness work uses `chore/harness-*`. — Deny rules are
static and can't express "during a feature"; no special case for this repo.

DEC-009 (2026-11-24): No `REVIEW.md`. — It only configures the managed GitHub Code Review
service; local `/code-review` doesn't read it. Review criteria stay in the rubric.

DEC-010 (2026-11-24): Stop hook blocks only when code changed this session and tracking files
are stale (not on any dirty tree), once per stop via `stop_hook_active`. — A dirty-tree block
would fire on every turn, including clarifying questions.

DEC-011 (2026-11-24): Fold the simplicity fix + Claude layer into F003 (no F005/F006). — User
call; F003 was still uncommitted.
