#!/usr/bin/env bash
# Stop gate: AGENTS.md session-completion protocol (rule 8) + "no victory without evidence"
# (rule 3). Exit 2 blocks the stop; stderr tells Claude exactly what is missing.
# One nudge per stop: if Claude is already continuing because of this hook, let it stop.
set -u
input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" = true ] && exit 0
[ "${HARNESS_HOOKS:-on}" = off ] && exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
[ -f .harness/PROJECT_STATE.md ] || exit 0

base=$(cat "$(git rev-parse --git-dir)/harness/base" 2>/dev/null || true)
[ -n "$base" ] || base=$(git rev-parse HEAD 2>/dev/null) || exit 0   # no commits yet: nothing to diff

# Everything that differs from the session's start: commits since base, uncommitted, untracked.
changed=$( { git diff --name-only "$base" 2>/dev/null; git ls-files --others --exclude-standard; } | sort -u)
problems=""

# 1. Code changed this session for an in-progress feature, but the tracking files didn't.
code_changed=$(printf '%s\n' "$changed" | grep -v -e '^\.harness/' -e '^\.claude/' -e '^$' || true)
if [ -n "$code_changed" ] && grep -Eq '^[[:space:]]*- \[[ x]\].*IN PROGRESS' .harness/ROADMAP.md 2>/dev/null; then
  stale=""
  for f in PROJECT_STATE.md CURRENT_TASK.md CHANGELOG.md; do
    printf '%s\n' "$changed" | grep -qx ".harness/$f" || stale="$stale .harness/$f"
  done
  if [ -n "$stale" ]; then
    dirty=""
    [ -n "$(git status --porcelain)" ] && dirty=" Working tree is dirty: commit, or stash to wip/<date> per loops/failure-modes.md."
    problems="${problems}- Code changed this session but not updated:${stale}. Run AGENTS.md → Session-completion protocol.${dirty}
"
  fi
fi

# 2. A feature newly marked COMPLETE needs a CHANGELOG entry with an Evidence: line.
for fid in $(git diff "$base" -- .harness/ROADMAP.md 2>/dev/null | grep -E '^\+.*COMPLETE' | grep -oE 'F[0-9]{3,}' | sort -u); do
  if ! awk -v id="$fid" '/^## /{e=(index($0, id) && index($0, "COMPLETE"))} e && /^Evidence:/{ok=1} END{exit !ok}' .harness/CHANGELOG.md; then
    problems="${problems}- $fid is marked COMPLETE in ROADMAP.md but .harness/CHANGELOG.md has no '## … $fid … COMPLETE' entry with an Evidence: line (verification/acceptance-evidence.md).
"
  fi
done

[ -z "$problems" ] && exit 0
printf 'harness: not ready to stop.\n%s' "$problems" >&2
exit 2
