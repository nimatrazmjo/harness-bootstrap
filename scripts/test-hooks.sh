#!/usr/bin/env bash
# Behavior tests for the optional Claude Code hooks shipped by HARNESS-BOOTSTRAP.md.
# Usage: scripts/test-hooks.sh <dir containing session-start.sh stop.sh pre-tool.sh>
# Builds a throwaway git repo with a minimal .harness/, feeds each hook fixture JSON, and
# asserts the exit code. Exit 0 = all pass.
set -u
hooks=$(cd "${1:?usage: $0 <hooks-dir>}" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fails=0

expect() {  # expect <exit code> <name> <hook> <json>
  local want=$1 name=$2 hook=$3 json=$4 got
  printf '%s' "$json" | bash "$hooks/$hook" >"$tmp/out" 2>"$tmp/err"; got=$?
  if [ "$got" = "$want" ]; then echo "ok   $name"
  else echo "FAIL $name (want $want, got $got)"; sed 's/^/     /' "$tmp/err"; fails=$((fails + 1)); fi
}

# --- no .harness: every hook is a no-op ---------------------------------------------------
mkdir "$tmp/plain" && cd "$tmp/plain" && git init -q && git commit -q --allow-empty -m init
echo x > dirty.txt
expect 0 "no .harness: stop no-op"      stop.sh     '{"stop_hook_active":false}'
expect 0 "no .harness: pre-tool no-op"  pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git push -f"}}'

# --- harness repo fixture -----------------------------------------------------------------
r="$tmp/repo"; mkdir -p "$r/.harness/phases" && cd "$r" && git init -q -b main
cat > .harness/AGENTS.md <<'EOF'
# AGENTS
EOF
cat > .harness/PROJECT_STATE.md <<'EOF'
## Where we are
- **Active feature(s)**: F001
## Lanes
## Next step
do the thing
## Open blockers
EOF
printf '# CURRENT TASK\n**Feature**: F001\n' > .harness/CURRENT_TASK.md
echo '- [ ] **F001** — thing — IN PROGRESS' > .harness/ROADMAP.md
printf '# CHANGELOG\n' > .harness/CHANGELOG.md
cat > .harness/SESSION-CHECKLIST.md <<'EOF'
| Test (full suite) | `test -f ../green` |
| Check boundaries | `test -f ../arch-ok` |
EOF
git add -A && git commit -q -m init

expect 0 "session-start prints state" session-start.sh '{"source":"startup"}'
if grep -q "do the thing" "$tmp/out"; then echo "ok   session-start output has next step"
else echo "FAIL session-start output missing next step"; fails=$((fails + 1)); fi
if [ -s .git/harness/base ]; then echo "ok   session-start wrote base"
else echo "FAIL base not written"; fails=$((fails + 1)); fi

expect 0 "stop: nothing changed" stop.sh '{"stop_hook_active":false}'
echo code > app.txt
expect 2 "stop: code changed, tracking stale" stop.sh '{"stop_hook_active":false}'
expect 0 "stop: stop_hook_active lets it stop" stop.sh '{"stop_hook_active":true}'
for f in PROJECT_STATE CURRENT_TASK CHANGELOG; do echo "updated" >> ".harness/$f.md"; done
expect 0 "stop: dirty but tracking updated" stop.sh '{"stop_hook_active":false}'
sed -i.bak 's/IN PROGRESS/COMPLETE/' .harness/ROADMAP.md && rm .harness/ROADMAP.md.bak
expect 2 "stop: COMPLETE without evidence" stop.sh '{"stop_hook_active":false}'
printf '## 2026-01-01 — F001 thing — COMPLETE\nEvidence:\n  - test -> ok\n' >> .harness/CHANGELOG.md
expect 0 "stop: COMPLETE with evidence" stop.sh '{"stop_hook_active":false}'
HARNESS_HOOKS=off expect 0 "HARNESS_HOOKS=off" stop.sh '{"stop_hook_active":false}'

# pre-tool: force push
expect 2 "pre-tool: git push -f"            pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git push -f origin main"}}'
expect 2 "pre-tool: git -C . push --force"  pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git -C . push origin x --force"}}'
expect 2 "pre-tool: +refspec push"          pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git push origin +main"}}'
expect 0 "pre-tool: normal push"            pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git push -u origin feat/F001"}}'

# pre-tool: commit gate (suite = `test -f green`)
expect 2 "pre-tool: commit while suite red" pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git add -A && git commit -m x"}}'
touch ../green
expect 0 "pre-tool: commit while suite green" pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
if ls .git/harness/green-* >/dev/null 2>&1; then echo "ok   green run cached"
else echo "FAIL green cache missing"; fails=$((fails + 1)); fi
rm ../green
expect 0 "pre-tool: cached green, same tree" pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
echo more >> app.txt
expect 2 "pre-tool: tree changed, suite red again" pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"git commit -m x"}}'
expect 0 "pre-tool: non-commit bash" pre-tool.sh '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'

# pre-tool: COMPLETE gate (boundaries = `test -f ../arch-ok`)
edit_complete="{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$r/.harness/ROADMAP.md\",\"old_string\":\"IN PROGRESS\",\"new_string\":\"COMPLETE\"}}"
expect 2 "pre-tool: COMPLETE while boundaries red" pre-tool.sh "$edit_complete"
touch ../arch-ok
expect 0 "pre-tool: COMPLETE while boundaries green" pre-tool.sh "$edit_complete"
expect 0 "pre-tool: unrelated ROADMAP edit" pre-tool.sh "{\"tool_name\":\"Edit\",\"tool_input\":{\"file_path\":\"$r/.harness/ROADMAP.md\",\"old_string\":\"a\",\"new_string\":\"b\"}}"

# pre-tool: machinery guard
edit_rules="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$r/.harness/rules/conventions.md\",\"content\":\"x\"}}"
git switch -q -c feat/F001
expect 2 "pre-tool: machinery edit on feat/*" pre-tool.sh "$edit_rules"
expect 0 "pre-tool: sprint contract on feat/*" pre-tool.sh "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$r/.harness/verification/sprint-contract.md\",\"content\":\"x\"}}"
git switch -q -c chore/harness-x
expect 0 "pre-tool: machinery edit on chore/harness-*" pre-tool.sh "$edit_rules"

echo; [ "$fails" = 0 ] && echo "all hook tests passed" || echo "$fails hook test(s) failed"
[ "$fails" = 0 ]
