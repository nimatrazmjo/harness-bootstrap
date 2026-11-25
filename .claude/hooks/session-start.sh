#!/usr/bin/env bash
# SessionStart (startup | resume | clear | compact): print harness state into Claude's context,
# so a fresh or compacted session starts from disk, not memory (AGENTS.md rule 1).
# Also records the commit this session started from; stop.sh diffs against it.
set -u
input=$(cat)
[ "${HARNESS_HOOKS:-on}" = off ] && exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
[ -f .harness/PROJECT_STATE.md ] || exit 0

source=$(printf '%s' "$input" | jq -r '.source // "startup"' 2>/dev/null || echo startup)
state_dir="$(git rev-parse --git-dir)/harness"
mkdir -p "$state_dir"
# resume/compact continue the same session: keep its original base.
if [ "$source" = startup ] || [ "$source" = clear ] || [ ! -s "$state_dir/base" ]; then
  git rev-parse HEAD 2>/dev/null > "$state_dir/base" || : > "$state_dir/base"
fi

{
  echo "## Harness state (injected from .harness/ at $source)"
  awk '/^## Where we are/{f=1} /^## Lanes/{f=0} f' .harness/PROJECT_STATE.md
  awk '/^## Next step/{f=1} /^## Open blockers/{f=0} f' .harness/PROJECT_STATE.md
  echo "### CURRENT_TASK.md (head)"
  sed -n '1,25p' .harness/CURRENT_TASK.md
  echo "### git"
  echo "branch $(git branch --show-current 2>/dev/null), $(git status --porcelain | wc -l | tr -d ' ') uncommitted path(s)"
  echo "Contract: .harness/AGENTS.md. Full init + repair: /harness-start."
} | head -n 60
exit 0
