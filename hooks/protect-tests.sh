#!/usr/bin/env bash
# PreToolUse hook: while a fix round is running (marker file present), deny
# edits to test files so a fixer cannot make a failing test pass by editing
# it. Inert when the marker is absent, and a marker older than one hour is
# treated as stranded by a crashed run: removed, edit allowed. Override the
# test-file pattern with one extended regex in <repo>/.minipowers/test-pattern.
#
# The hook fires on every Edit, Write, and NotebookEdit, so the no-marker
# path is bash builtins only: no sed, no git, no find. Measured at about
# 3.5 ms per call (bash startup is 1.9 ms); the git rev-parse version it
# replaced took about 20 ms.
set -u

input=$(cat)
[[ $input =~ \"(file_path|notebook_path)\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] || exit 0
path=${BASH_REMATCH[2]}
case "$path" in
  /*) ;;
  *) [[ $input =~ \"cwd\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]] || exit 0
     path="${BASH_REMATCH[1]}/$path" ;;
esac

# Walk up from the file's directory; the controller puts the marker at the
# repo root, which is always an ancestor.
root=
dir=$path
while dir=${dir%/*}; [ -n "$dir" ]; do
  if [ -e "$dir/.minipowers/sdd/fix-round" ]; then root=$dir; break; fi
done
[ -n "$root" ] || exit 0

marker="$root/.minipowers/sdd/fix-round"
if [ -n "$(find "$marker" -mmin +60 2>/dev/null)" ]; then
  rm -f "$marker"
  exit 0
fi

pattern='(^|/)(tests?|__tests__|spec)/|(^|/)test_[^/]+\.[A-Za-z0-9]+$|(_|\.)(test|spec)\.[A-Za-z0-9]+$|Tests?\.(java|kt|cs|swift|scala)$'
[ -s "$root/.minipowers/test-pattern" ] && pattern=$(head -1 "$root/.minipowers/test-pattern")

rel=${path#"$root"/}
if [[ $rel =~ $pattern ]]; then
  echo "fix round in progress: test files are read-only ($rel). Report the test as a blocker instead." >&2
  exit 2
fi
exit 0
