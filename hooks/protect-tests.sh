#!/usr/bin/env bash
# PreToolUse hook: while a fix round is running (marker file present), deny
# edits to test files so a fixer cannot make a failing test pass by editing
# it. Inert when the marker is absent, and a marker older than two hours is
# treated as stranded by a crashed run: removed, edit allowed. Override the
# test-file pattern with one extended regex in <repo>/.minipowers/test-pattern.
set -u

input=$(cat)
path=$(printf '%s' "$input" | sed -nE 's/.*"(file_path|notebook_path)"[[:space:]]*:[[:space:]]*"([^"]*)".*/\2/p' | head -1)
[ -n "$path" ] || exit 0

cwd=$(printf '%s' "$input" | sed -nE 's/.*"cwd"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -1)
root=$(git -C "${cwd:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0
marker="$root/.minipowers/sdd/fix-round"
[ -e "$marker" ] || exit 0
if [ -n "$(find "$marker" -mmin +120 2>/dev/null)" ]; then
  rm -f "$marker"
  exit 0
fi

pattern='(^|/)(tests?|__tests__|spec)/|(_|\.)(test|spec)\.[A-Za-z0-9]+$'
[ -s "$root/.minipowers/test-pattern" ] && pattern=$(head -1 "$root/.minipowers/test-pattern")

case "$path" in "$root"/*) rel=${path#"$root"/} ;; *) rel=$path ;; esac
if printf '%s' "$rel" | grep -qE "$pattern"; then
  echo "fix round in progress: test files are read-only ($rel). Report the test as a blocker instead." >&2
  exit 2
fi
exit 0
