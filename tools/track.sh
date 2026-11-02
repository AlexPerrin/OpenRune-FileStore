#!/usr/bin/env bash
# tools/track.sh <verb> <slug> [arg]: the FileStore track (docs/ARCHITECTURE.md of osrs-harness). Env from hd: SLUG HEAD T
# TCOMMIT BASE CLONE EVIDENCE BUILD HD_ROOT. build and tree are tools/build/build.sh's (the code a build runs, keyed alone);
# gate, tests, evidence and commits tools/gate/gate.sh's (the code a gate runs). Verbs:
#   down                nothing: the track brings nothing up (its proof is its build and its tests)
#   log <slug> PATTERN  the change's last build or test log
set -euo pipefail
verb=$1; slug=${2:-${SLUG:-}}; arg=${3:-}   # a contract row passes no slug: hd exports SLUG
self=$(cd "$(dirname "$0")" && pwd)
root=${HD_ROOT:-$HOME/osrs-harness}
[ -f "$root/harness/changes/$slug.md" ] || { echo "no change \"$slug\": tools/track.sh <verb> <slug> [arg]" >&2; exit 2; }
# a run reads its own copy of the track's files, one per content in state/tools/<hash>/tools (exported: TOOLS_ROOT, its parent,
# where hd runs a gate's rows; TOOLS_SRC, the checkout): a ship of the tools branch moves the checkout under a running script, and
# hd's repairs remove a copy once no process or container uses it; upstream's own tools/ module (build.gradle.kts, src/) is not the track's
case $self in "$root"/state/tools/*) ;; *)
  files() { (cd "$self" && find . -type f ! -path './src/*' ! -path '*/__pycache__/*' ! -name build.gradle.kts -print0 | sort -z); }
  k=$(files | (cd "$self" && xargs -0 sha1sum) | sha1sum | cut -c1-12); c=$root/state/tools/$k
  [ -d "$c" ] || { d=$root/state/tools/.$k.$$; rm -rf "$d"; mkdir -p "$d/tools"; files | (cd "$self" && xargs -0 cp -a --parents -t "$d/tools"); mv -T "$d" "$c" 2>/dev/null || rm -rf "$d"; }
  TOOLS_SRC=$self TOOLS_ROOT=$c exec bash "$c/tools/track.sh" "$@" ;;
esac
case ${1:-} in build|tree) exec "$self/build/build.sh" "$@" ;; gate|tests|evidence|commits) exec "$self/gate/gate.sh" "$@" ;; esac
state=$root/state/$slug; mkdir -p "$state"
log() { grep -hE "${arg:-.}" "$state"/build-*.log "$state/test.log" 2>/dev/null | tail -200 || true; }

case $verb in down) ;; log) log ;; *) echo "verbs: build gate tests evidence commits tree log down" >&2; exit 2 ;; esac
