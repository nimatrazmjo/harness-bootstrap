#!/usr/bin/env bash
# PreToolUse gate (Bash | Edit | Write | MultiEdit). Exit 2 blocks the tool; stderr says why.
#   git commit while the full suite is red                 -> rule 3, conventions.md "Git"
#   adding COMPLETE to ROADMAP/phases while boundaries red -> rules 3 + 4
#   editing harness machinery on a feature/lane branch     -> "never edit .harness rules to pass"
#   any force push                                         -> conventions.md "Git"
set -u
input=$(cat)
[ "${HARNESS_HOOKS:-on}" = off ] && exit 0
start_dir=$PWD
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
root=$(cd "$root" && pwd -P)
cd "$root" || exit 0
[ -f .harness/AGENTS.md ] || exit 0

block() { echo "harness: $1" >&2; exit 2; }

# The command in a SESSION-CHECKLIST.md Commands row, e.g. "Test (full suite)".
command_for() {
  grep -F "| $1 |" .harness/SESSION-CHECKLIST.md | head -n 1 | sed -E 's/^[^`]*`([^`]*)`.*/\1/'
}

# Run a Commands row; block with its output tail if red. Green is cached per tree state.
run_gate() {
  local row=$1 action=$2 cmd key stamp out
  cmd=$(command_for "$row")
  case "$cmd" in
    '' | '<'*) echo "harness: '$row' not set in SESSION-CHECKLIST.md — gate skipped" >&2; return 0 ;;
  esac
  key=$( { git rev-parse HEAD 2>/dev/null; git diff HEAD 2>/dev/null
           git ls-files --others --exclude-standard -z | xargs -0 shasum 2>/dev/null; } | shasum | cut -c1-40)
  stamp="$(git rev-parse --git-dir)/harness/green-$(printf '%s' "$row" | tr -c 'A-Za-z' '_')"
  [ "$(cat "$stamp" 2>/dev/null)" = "$key" ] && return 0
  if out=$(bash -c "$cmd" 2>&1); then
    mkdir -p "$(dirname "$stamp")" && echo "$key" > "$stamp"
    return 0
  fi
  block "$action blocked — '$row' is red ($cmd):
$(printf '%s\n' "$out" | tail -n 20)"
}

tool=$(printf '%s' "$input" | jq -r '.tool_name // ""')
ws='[[:space:]]'
git_cmd="(^|[;&|(]|$ws)git($ws+-C$ws+[^[:space:]]+)?$ws+"

if [ "$tool" = Bash ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
  if printf '%s' "$cmd" | grep -Eq "${git_cmd}push($ws.*)?$ws(--force[a-z-]*|-f|\+[^[:space:]]+)($ws|=|\$)"; then
    block "force push is never allowed (rules/conventions.md → Git). Merge the default branch in instead of rebasing a pushed branch."
  fi
  if printf '%s' "$cmd" | grep -Eq "${git_cmd}commit($ws|\$)"; then
    run_gate "Test (full suite)" "git commit"
  fi
  exit 0
fi

path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
case "$path" in /*) ;; *) path="$start_dir/$path" ;; esac
# Resolve symlinks (e.g. /var -> /private/var) via the nearest existing directory.
dir=$(dirname "$path"); while [ ! -d "$dir" ]; do dir=$(dirname "$dir"); done
rel=$(cd "$dir" && pwd -P)${path#"$dir"}
rel=${rel#"$root"/}
case "$tool" in
  Edit)      old=$(printf '%s' "$input" | jq -r '.tool_input.old_string // ""')
             new=$(printf '%s' "$input" | jq -r '.tool_input.new_string // ""') ;;
  MultiEdit) old=$(printf '%s' "$input" | jq -r '[.tool_input.edits[]?.old_string] | join("\n")')
             new=$(printf '%s' "$input" | jq -r '[.tool_input.edits[]?.new_string] | join("\n")') ;;
  Write)     old=$(cat "$rel" 2>/dev/null || true)
             new=$(printf '%s' "$input" | jq -r '.tool_input.content // ""') ;;
  *)         exit 0 ;;
esac

case "$(git branch --show-current 2>/dev/null)" in
  feat/* | lane/* | worktree-lane-*)
    case "$rel" in
      .harness/loops/loop-state.md | .harness/verification/sprint-contract.md) ;;  # per-feature files
      .harness/AGENTS.md | .harness/README.md | .harness/SESSION-CHECKLIST.md | \
      .harness/RUNTIME-CONTINUITY.md | .harness/loops/* | .harness/graph/* | \
      .harness/verification/* | .harness/rules/conventions.md | .harness/scripts/* | \
      .harness/state/* | .harness/architecture/ARCHETYPES.md | .harness/architecture/decisions/ADR-template.md | \
      .claude/settings.json | .claude/hooks/* | .claude/agents/* | .claude/skills/* | .claude/rules/*)
        block "$rel is harness machinery; don't change the rules during a feature. Use a chore/harness-<slug> branch." ;;
    esac ;;
esac

case "$rel" in
  .harness/ROADMAP.md | .harness/phases/*.md)
    if [ "$(printf '%s' "$new" | grep -o COMPLETE | wc -l)" -gt "$(printf '%s' "$old" | grep -o COMPLETE | wc -l)" ]; then
      run_gate "Check boundaries" "marking a feature COMPLETE"
    fi ;;
esac
exit 0
