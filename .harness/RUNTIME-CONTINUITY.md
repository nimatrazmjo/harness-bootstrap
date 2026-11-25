# Runtime Continuity — failover across agent runtimes

Keep building without interruption when one agent runtime hits its usage/session limit, by
failing over to another. This works because **the harness is the source of truth, not the
conversation** — any runtime resumes from `PROJECT_STATE.md`. It applies multi-session
continuity across *tools*, not just sessions. Because the harness is LLM-agnostic (one contract
behind every tool's entry file), the two runtimes can be **different vendors** — the failover
reads the same `.harness/AGENTS.md` and continues the same feature.

## The runtimes
Pick any two agent CLIs/IDEs you have access to (e.g. Claude Code, Gemini CLI / Antigravity,
GitHub Copilot, Cursor, Codex/ChatGPT, Grok). They need not be the same vendor.
| Runtime | Launch (in the repo) | Role |
|---|---|---|
| `claude` (Claude Code) | in the repo root | Primary — where you start |
| `gemini` (Gemini CLI) / Cursor / Antigravity | in the repo root | Failover (any other tool) |

Gemini CLI: `npm i -g @google/gemini-cli`, then `gemini` in the repo root. Or open the repo in
Cursor / Windsurf / Antigravity, or run Copilot — each reads its own root entry-point file,
which points to `.harness/AGENTS.md`. The failover need not be the same vendor as the primary;
all of them resume from `PROJECT_STATE.md`.

## The principle
Nothing important lives in the chat. Before a runtime stops (or when it hits a limit) it
commits its work and writes the exact next step into `CURRENT_TASK.md`. The other runtime
reads `PROJECT_STATE.md → CURRENT_TASK.md → ROADMAP.md → the active phase file`, inspects the
code (the codebase is the source of truth for what exists), and continues the one active
feature. No context is lost.

## Trigger
The active runtime reaches its usage/session limit (a rate-limit or max-session message).

## Handoff protocol (in order)
1. **Finish the current safe step** — don't stop mid-edit; get the tree compiling.
2. **Run the Session-completion protocol** (`AGENTS.md`): update `PROJECT_STATE.md`,
   `CURRENT_TASK.md` (exact next step — file + function), `ROADMAP.md`, `CHANGELOG.md`;
   open/close `BLOCKERS.md`; commit on the `feat/<FID>` branch. **Never leave the tree dirty.**
3. **Log the switch** in `RUNTIME-SWITCHES.md`.
4. **Start the other runtime** in the repo and give it the resume bootstrap below.
5. **Alternate** on each subsequent limit.

## Resume bootstrap (paste into whichever runtime you start)
> Resume this project. Read `.harness/PROJECT_STATE.md`, then `CURRENT_TASK.md`, then follow
> `.harness/AGENTS.md`. Work only the one active feature. Do NOT restart from Phase 1.

## Guardrails
- One active feature at a time per lane (whatever that lane's `CURRENT_TASK.md` says). A
  failover changes *who* works a lane, never *what* that lane works on.
- Commit before switching; the receiving runtime trusts committed code over stale tracking
  and reconciles per `AGENTS.md`.
- If a limit hits mid-feature, `CURRENT_TASK.md` must record the exact next step so the other
  runtime continues rather than restarts.

## Failover vs. parallel (don't confuse them)
Failover and parallel lanes are orthogonal. **Failover** swaps the runtime driving a lane when
it hits a limit — same feature, different tool. **Parallel** (`loops/parallel-loop.md`) runs
*different* features in *different* lanes at once. You can combine them: assign a runtime per
lane, and fail a single lane over to a backup runtime while the others keep going. A limit
pauses one lane, never the whole project. When a runtime dies mid-lane and no backup picks it
up, the lane is **orphaned** — recover it per `loops/failure-modes.md` (adopt the branch or
release the claim); never let an abandoned claim pin a feature.

## Platform note
If more than one machine/VM touches the repo, native build artifacts (installed dependencies)
belong to whichever platform installed last. After a cross-platform touch, reinstall/rebuild
for the current platform before running native-dependent tools. Treat any uncommitted change
you find in the tree as something to inspect, not assume.
