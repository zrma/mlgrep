#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

version=$(scripts/read-version.sh)
expected="    return \"$version\""
count=$(grep -Fxc "$expected" src/version/version.mlg || true)
[ "$count" -eq 1 ] || {
  echo "VERSION and src/version/version.mlg are not synchronized" >&2
  exit 1
}

printf 'version contract is valid: mlgrep %s\n' "$version"
