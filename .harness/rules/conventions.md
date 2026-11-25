# Conventions

Naming, structure, git, and session hygiene. Small rules that keep the harness legible
across many sessions and agents.

## Ids
Stable, opaque, type-prefixed and immutable once assigned (define the prefixes for your
domain in `architecture/DATA_MODEL.md`). Used identically in DB, API, URLs, logs, and AI
references. Feature ids in the tracking system are `F001`, `F002`, … and never reused.

## Types / language
Strict mode on. No escape hatch (`any`, untyped) without a `// why:` comment. Shared domain
types live in one place and are imported everywhere else; never redefine a model type in a
consumer. Prefer explicit return types on exported functions.

## Files & folders
Follow `architecture/ARCHITECTURE.md` §repository shape. One module per domain area.
Colocate unit/integration tests with code. No file over ~400 lines without a reason.

## Testing
- Unit/integration tests colocated (`*.test.*`); **e2e** tests in a top-level `e2e/`
  directory, named for the flow they drive. Tag the critical ones `@smoke`.
- Every feature covers the applicable `verification/edge-cases.md` battery; user-facing
  features add at least one e2e flow (`verification/acceptance-evidence.md`).
- Tests assert real behavior — no `assert true`, no test edited to pass.
- **Flaky is broken.** A test that isn't deterministic is fixed at the root, not retried or
  quarantined (`loops/failure-modes.md`).

## Git
- One feature per branch: `feat/<feature-id>` matching the `id` in `ROADMAP.md`. For
  harness-only tooling/docs not tied to a ROADMAP feature id, use a descriptive
  `docs/<slug>` or `chore/<slug>` branch instead of forcing a fake `feat/<FID>` — the same
  PR-review-loop discipline still applies.
- Conventional commits: `feat(scope): add X`, `fix(scope): stop Y`. Reference the feature id
  in the body.
- Commit only when the FULL suite is green (not a subset) and the step has evidence. No "wip"
  on main.
- Never commit secrets, `.env`, or generated artifacts.
- After a feature passes maker-checker: push the branch, open a PR (reuse if one is already
  open for it — never open a second), review it, fix findings until clean, then enqueue for
  integration before the lane's next feature. See `loops/pr-review-loop.md` +
  `loops/integration-loop.md`.

## Lanes & worktrees (parallel mode — `MAX_LANES > 1`)
- One lane per feature: a git worktree on a `lane/<FID>` branch (the `feat/<FID>` work happens
  on that branch; `lane/<FID>` and `feat/<FID>` may be the same branch — keep one name per
  feature). `git worktree add ../wt-<FID> -b lane/<FID> main`; remove with
  `git worktree remove` once the feature is merged and the claim released.
- **Claim protocol (the git-mutex that prevents a dropped or double-claimed feature):** to
  start a feature, add its claim line to `LANES.md` **on `main`** and push. If the push is
  rejected (someone else claimed first), `git pull --rebase`, re-read `LANES.md`, and claim a
  different ready feature — never override another lane's claim. The accepted push is the
  claim; only then create the worktree and build.
- **Shared-state files are owned by `main`:** `LANES.md` (claims + queue) and `ROADMAP.md`
  statuses are coordination state every lane must read consistently, so they are read/written
  on `main` via short claim/release/enqueue commits, not edited independently on lane branches.
  Per-lane working files (`CURRENT_TASK.md`, `loops/loop-state.md`, the feature's
  `sprint-contract.md`, `evidence/`) live on the lane branch.
- **Release** the claim (remove the lane's line / mark the feature merged) on `main` only after
  the Integrator lands the feature green. A lane that stops without merging leaves its claim so
  no one else grabs the half-done feature — unless it is declared orphaned (`failure-modes.md`).
- Never force-push `main` or a shared lane branch.

## Evidence discipline
A feature is `passed` only with recorded evidence in `CHANGELOG.md`: the exact command, its
output (or a screenshot path under `.harness/evidence/`), or a test id. "Looks right" is not
evidence. See `verification/acceptance-evidence.md`.

## Logging
Structured logs (json) with `level`, `event`, `correlationId`, and relevant ids. Log at:
process start, each layer boundary crossing (API in/out, job start/end), and every caught
error with cause. See `scripts/SCRIPTS.md` → logger contract.

## Session hygiene
Before you stop, every time: `AGENTS.md` → Session-completion protocol, then
`state/clean-state-checklist.md`.

## Comments & docs
Comment *why*, not *what*. Update the affected `.harness` doc in the same change that makes
it stale (e.g. new endpoint -> update API_SURFACE.md). Stale docs are worse than none.

## Readability & fit
- New code matches the files around it: naming, layout, error handling, test style. Don't
  bring in a pattern the repo doesn't already use for one feature.
- Read 2–3 neighboring files before writing a new one; name them in sprint contract §6.
- A longer function with a clear name beats three indirected ones.
- No new dependency, abstraction layer, or config surface without a §6 line tying it to an
  acceptance item.
- Delete-first: if the change can be made by removing code, do that.
- Extension points: use the ones in `architecture/MODULES.md`; add one only on the third
  occurrence (`AGENTS.md` rule 6).
